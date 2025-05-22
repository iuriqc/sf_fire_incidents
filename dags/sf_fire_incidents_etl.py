from datetime import timedelta
from airflow import DAG
from airflow.utils.dates import days_ago
from airflow.operators.python import PythonOperator
from airflow.operators.dummy import DummyOperator
from airflow.providers.amazon.aws.hooks.s3 import S3Hook
from airflow.providers.amazon.aws.operators.dbt import DbtRunOperator, DbtTestOperator
import sys
import os
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

def download_scripts(**context):
    """Download scripts from S3 to Airflow worker"""
    s3 = S3Hook(aws_conn_id='aws_default')
    scripts_path = '/opt/airflow/scripts'
    os.makedirs(scripts_path, exist_ok=True)
    
    s3.download_file(
        key='scripts/sf_fire_extract.py',
        bucket_name='your-s3-bucket',
        local_path=f"{scripts_path}/sf_fire_extract.py"
    )
    
    return scripts_path

def run_extract_script(**context):
    """Execute the extraction script"""
    scripts_path = context['task_instance'].xcom_pull(task_ids='download_scripts')
    sys.path.append(scripts_path)
    
    from sf_fire_extract import main
    try:
        main()
    except Exception as e:
        logger.error(f"Extract script failed: {str(e)}")
        raise

def prepare_dbt_project(**context):
    """Download and prepare dbt project"""
    s3 = S3Hook(aws_conn_id='aws_default')
    dbt_path = '/opt/airflow/dbt'
    os.makedirs(dbt_path, exist_ok=True)
    
    s3.download_directory(
        key='dbt/',
        bucket_name='your-s3-bucket',
        local_path=dbt_path
    )
    
    return dbt_path

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
    
    download_scripts_task = PythonOperator(
        task_id='download_scripts',
        python_callable=download_scripts,
        provide_context=True
    )

    extract_task = PythonOperator(
        task_id='extract_and_load',
        python_callable=run_extract_script,
        provide_context=True
    )

    prepare_dbt = PythonOperator(
        task_id='prepare_dbt',
        python_callable=prepare_dbt_project,
        provide_context=True
    )

    dbt_run = DbtRunOperator(
        task_id='dbt_run',
        dbt_root_path='{{ task_instance.xcom_pull(task_ids="prepare_dbt") }}',
        select=['models'],
        env={
            'DBT_PROFILES_DIR': '{{ task_instance.xcom_pull(task_ids="prepare_dbt") }}'
        }
    )

    dbt_test = DbtTestOperator(
        task_id='dbt_test',
        dbt_root_path='{{ task_instance.xcom_pull(task_ids="prepare_dbt") }}',
        select=['models'],
        env={
            'DBT_PROFILES_DIR': '{{ task_instance.xcom_pull(task_ids="prepare_dbt") }}'
        }
    )

    start >> download_scripts_task >> extract_task >> prepare_dbt >> dbt_run >> dbt_test >> end