import sys
import pandas as pd
import requests
import time
from datetime import datetime
import boto3
import io

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

def fetch_data(offset=0, limit=BATCH_SIZE):
    """Fetch data from Socrata API with pagination"""
    params = {
        "$limit": limit,
        "$offset": offset,
        "$$app_token": app_token,
        "$order": "incident_date DESC"
    }
    
    try:
        response = requests.get(SOCRATA_ENDPOINT, params=params)
        response.raise_for_status()
        data = response.json()
    
        print(f"Fetched {len(data)} records from offset {offset}")

        if not data:
            print(f"Warning: No data returned for offset {offset}")
            
        return data
    except Exception as e:
        print(f"API request failed: {str(e)}")
        print(f"URL: {response.url}")
        raise

def get_total_records():
    """Get total record count for pagination"""
    params = {
        "$select": "count(*)",
        "$$app_token": app_token
    }
    response = requests.get(SOCRATA_ENDPOINT, params=params)
    return int(response.json()[0]["count"])

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

    # Upload to S3
    s3 = boto3.client('s3')
    bucket = output_path.replace("s3://", "").split("/")[0]
    key = f"raw/fire_incidents/dt={partition_date}/data.parquet"
    
    s3.put_object(
        Bucket=bucket,
        Key=key,
        Body=parquet_buffer.getvalue()
    )

    print(f"Saved {len(final_df)} records to {key}")

def main():
    print("Starting SF Fire Incidents data extraction")
    
    total_records = get_total_records()
    print(f"Total records to fetch: {total_records}")
    
    processed_records = 0
    partition_date = datetime.now().strftime("%Y-%m-%d")
    all_dfs = []
    
    while processed_records < total_records:
        print(f"\nFetching batch starting at offset: {processed_records}")
        batch = fetch_data(offset=processed_records)
        
        if not batch:
            print("No more records to fetch")
            break
            
        df = process_data(batch)
        all_dfs.append(df)

        processed_records += len(df)
        print(f"Processed {processed_records}/{total_records} records ({(processed_records/total_records)*100:.2f}%)")
        time.sleep(1)
    
    if processed_records < total_records:
        print(f"Warning: Only processed {processed_records} out of {total_records} records")
    
    if all_dfs:
        final_df = pd.concat(all_dfs, ignore_index=True)
        save_data(final_df, partition_date)

    print(f"Job completed. Total records processed: {processed_records}")

if __name__ == "__main__":
    main()