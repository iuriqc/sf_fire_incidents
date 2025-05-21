import sys
import pandas as pd
import requests
import time
from datetime import datetime
import boto3
import io
import logging
from tenacity import retry, stop_after_attempt, wait_exponential, retry_if_exception_type

# Set up logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.StreamHandler(),
        logging.FileHandler('sf_fire_extract.log')
    ]
)
logger = logging.getLogger(__name__)

# Get job arguments
def get_job_args():
    """Get job arguments from either Glue or local environment"""
    try:
        from awsglue.utils import getResolvedOptions
        args = getResolvedOptions(sys.argv, ['OUTPUT_S3_PATH', 'SOCRATA_APP_TOKEN'])
    except ImportError:
        args = {}
        for i in range(1, len(sys.argv), 2):
            if sys.argv[i].startswith('--'):
                key = sys.argv[i][2:]
                args[key] = sys.argv[i + 1]
    
    if 'OUTPUT_S3_PATH' not in args or 'SOCRATA_APP_TOKEN' not in args:
        raise ValueError("Required arguments OUTPUT_S3_PATH and SOCRATA_APP_TOKEN must be provided")
    
    return args

args = get_job_args()
output_path = args['OUTPUT_S3_PATH']
app_token = args['SOCRATA_APP_TOKEN']

# API Configuration
SOCRATA_ENDPOINT = "https://data.sfgov.org/resource/wr8u-xric.json"
BATCH_SIZE = 50000

@retry(
    stop=stop_after_attempt(3),
    wait=wait_exponential(multiplier=1, min=4, max=10),
    retry=retry_if_exception_type((requests.exceptions.RequestException, requests.exceptions.Timeout)),
    before_sleep=lambda retry_state: logger.error(f"Attempt {retry_state.attempt_number} failed. Retrying in {retry_state.seconds_since_start} seconds...")
)
def fetch_data(offset=0, limit=BATCH_SIZE):
    """Fetch data from Socrata API with pagination"""
    params = {
        "$limit": limit,
        "$offset": offset,
        "$$app_token": app_token,
        "$order": "incident_date DESC"
    }
    
    try:
        response = requests.get(
            SOCRATA_ENDPOINT, 
            params=params,
            timeout=30
        )
        response.raise_for_status()
        data = response.json()
    
        logger.info(f"Fetched {len(data)} records from offset {offset}")

        if not data:
            logger.warning(f"No data returned for offset {offset}")
            
        return data
    except requests.exceptions.Timeout:
        logger.error(f"Request timed out for offset {offset}")
        raise
    except requests.exceptions.RequestException as e:
        logger.error(f"API request failed: {str(e)}")
        logger.error(f"URL: {response.url}")
        raise
    except Exception as e:
        logger.error(f"Unexpected error: {str(e)}")
        raise

@retry(
    stop=stop_after_attempt(3),
    wait=wait_exponential(multiplier=1, min=4, max=10),
    retry=retry_if_exception_type((requests.exceptions.RequestException, requests.exceptions.Timeout))
)
def get_total_records():
    """Get total record count for pagination"""
    params = {
        "$select": "count(*)",
        "$$app_token": app_token
    }
    try:
        response = requests.get(
            SOCRATA_ENDPOINT, 
            params=params,
            timeout=30
        )
        response.raise_for_status()
        return int(response.json()[0]["count"])
    except Exception as e:
        logger.error(f"Failed to get total records: {str(e)}")
        raise

def process_data(data):
    """Process batch of data with Pandas"""
    df = pd.DataFrame(data)
    df['_processing_date'] = datetime.now().date()
    return df

def save_data(final_df, partition_date):
    """Process data with Pandas and save to S3"""    
    # Convert to Parquet in memory
    parquet_buffer = io.BytesIO()
    final_df.to_parquet(parquet_buffer, index=False)

    s3 = boto3.client('s3')
    bucket = output_path.replace("s3://", "").split("/")[0]
    key = f"raw/fire_incidents/dt={partition_date}/data.parquet"

    # Check if file already exists and save its version id
    try:
        old_version = s3.head_object(Bucket=bucket, Key=key).get('VersionId')
    except s3.exceptions.ClientError:
        old_version = None
    
    # Upload to S3
    try:
        response = s3.put_object(
            Bucket=bucket,
            Key=key,
            Body=parquet_buffer.getvalue()
        )
        new_version = response.get('VersionId')

        # Verify data integrity
        head_response = s3.head_object(Bucket=bucket, Key=key)
        if head_response['ContentLength'] != len(parquet_buffer.getvalue()):
            raise Exception("Data integrity check failed - size mismatch")
            
        logger.info(f"Successfully saved {len(final_df)} records to {key}")

    except Exception as e:
        logger.error(f"Failed to upload to S3: {str(e)}")

        # Rollback to previous version if it existed
        if old_version:
            try:
                s3.delete_object(
                    Bucket=bucket,
                    Key=key,
                    VersionId=new_version
                )
                logger.info(f"Rolled back to previous version {old_version}")
            except Exception as rollback_error:
                logger.error(f"Rollback failed: {str(rollback_error)}")

        raise

    logger.info(f"Saved {len(final_df)} records to {key}")

def main():
    logger.info("Starting SF Fire Incidents data extraction")
    
    total_records = get_total_records()
    logger.info(f"Total records to fetch: {total_records}")
    
    processed_records = 0
    partition_date = datetime.now().strftime("%Y-%m-%d")
    all_dfs = []
    
    while processed_records < total_records:
        logger.info(f"Fetching batch starting at offset: {processed_records}")
        batch = fetch_data(offset=processed_records)
        
        if not batch:
            logger.info("No more records to fetch")
            break
            
        df = process_data(batch)
        all_dfs.append(df)

        processed_records += len(df)
        logger.info(f"Processed {processed_records}/{total_records} records ({(processed_records/total_records)*100:.2f}%)")
        time.sleep(1)
    
    if processed_records < total_records:
        logger.warning(f"Only processed {processed_records} out of {total_records} records")
    
    if all_dfs:
        final_df = pd.concat(all_dfs, ignore_index=True)
        save_data(final_df, partition_date)

    logger.info(f"Job completed. Total records processed: {processed_records}")

if __name__ == "__main__":
    main()