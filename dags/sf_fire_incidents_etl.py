from datetime import timedelta
from airflow import DAG
from airflow.utils.dates import days_ago
from airflow.operators.python import PythonOperator
from airflow.operators.dummy import DummyOperator
from airflow.providers.amazon.aws.operators.dbt import DbtRunOperator, DbtTestOperator
import boto3
import logging

logger = logging.getLogger(__name__)

# DAG default arguments
default_args = {
    'owner': 'IQC',
    'start_date': days_ago(1),
    'depends_on_past': False,
    'email_on_failure': True,
    'email_on_retry': False,
    'retries': 3,
    'retry_delay': timedelta(minutes=5),
    'execution_timeout': timedelta(hours=1),
}

def run_extract_script(**context):
    """Execute the extraction script"""
    s3 = boto3.client('s3')
    bucket_name = context['var'].get('s3_bucket')
    
    try:
        response = s3.get_object(
            Bucket=bucket_name,
            Key='scripts/sf_fire_extract.py'
        )
        exec(response['Body'].read().decode())

    except Exception as e:
        logger.error(f"Extract script failed: {str(e)}")
        raise

# Create DAG
with DAG(
    'sf_fire_incidents_etl',
    default_args=default_args,
    description='SF Fire Incidents ETL pipeline',
    schedule_interval='0 9 * * *',
    catchup=False,
    max_active_runs=1,
    tags=['sf_fire', 'etl']
) as dag:

    start = DummyOperator(task_id='start')
    end = DummyOperator(task_id='end')

    extract_task = PythonOperator(
        task_id='extract_and_load',
        python_callable=run_extract_script,
        provide_context=True
    )

    dbt_run = DbtRunOperator(
        task_id='dbt_run',
        dbt_root_path=f"s3://{{'{{ var.value.s3_bucket }}'}}/dbt",
        select=['models'],
        full_refresh=True,
        env={
            'DBT_PROFILES_DIR': f"s3://{{'{{ var.value.s3_bucket }}'}}/dbt"
        }
    )

    dbt_test = DbtTestOperator(
        task_id='dbt_test',
        dbt_root_path=f"s3://{{'{{ var.value.s3_bucket }}'}}/dbt",
        select=['tests'],
        retries=1,
        env={
            'DBT_PROFILES_DIR': f"s3://{{'{{ var.value.s3_bucket }}'}}/dbt"
        }
    )

    start >> extract_task >> dbt_run >> dbt_test >> end