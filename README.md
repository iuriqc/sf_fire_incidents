# San Francisco Fire Incidents Data Pipeline

This project implements an end-to-end a scalable data pipeline for San Francisco Fire Incidents data, transforming raw data into analytics-ready tables through AWS services.

## 📌 Overview

- **Objective**: Build a reliable data warehouse for analyzing fire incidents across time, districts, and battalions
- **Data Source**: [SF OpenData API](https://data.sfgov.org/Public-Safety/Fire-Incidents/wr8u-xric)
- **Infrastructure**: AWS (S3, Redshift, Glue)
- **Orchestration**: Terraform + dbt
- **CI/CD**: GitHub Actions
- **Key Deliverables**:
  - Raw → Processed → Mart data layers
  - Time-based and geospatial analysis capabilities
  - Automated data quality checks

## 🛠️ Project Structure
```
sf_fire_incidents/
├── terraform/           # Infrastructure as code
├── scripts/            # Python scripts for data extraction
└── dbt_sf_fire/       # dbt models and transformations
```

## 🚀 Setup Instructions

### 1. Prerequisites
- Python 3.8+
- AWS Account
- Terraform
- dbt
- Required Python packages:
```bash
pip install -r requirements.txt
```

### 2. Infrastructure Setup
```bash
cd terraform
terraform init
terraform plan
terraform apply
```

### 3. Environment Configuration
Create a `.env` file:
```env
AWS_ACCESS_KEY_ID=your_key
AWS_SECRET_ACCESS_KEY=your_secret
REDSHIFT_HOST=your_host
REDSHIFT_USER=admin
REDSHIFT_PASSWORD=your_password
```

### 4. Data Pipeline Execution

#### a. Extract Data

##### To run locally:
```bash
python scripts/run_extract_locally.py
```

##### To execute in Glue/MWAA:
```bash
scripts/sf_fire_extract.py
```

#### b. Run dbt Transformations (only locally)
```bash
cd dbt_sf_fire
dbt deps
dbt run
dbt test
```

## 🔍 Data Models

### Staging
- `stg_fire_incidents`: Clean version of raw data

### Dimensions
- `dim_battalion`: Fire battalion information
- `dim_district`: Supervisor districts
- `dim_time`: Date dimension table

### Facts
- `fact_fire_incidents`: Main fact table with metrics

### Mart Tables
- `incidents_by_time`: daily/monthly trends
- `incidents_by_district`: response district performance
- `incidents_by_battalion`: response unit performance

## Testing
- Data quality tests in dbt
- Unit tests for Python scripts
- Infrastructure tests with Terraform

## 🛑 Troubleshooting
- **AWS Credentials**: Ensure AWS credentials are set up correctly. Create a role with the necessary permissions specific for this project.
- **Terraform**: Ensure your Terraform configuration is correct and up-to-date. Attempt to create the infrastructure using `terraform init` and `terraform apply`.
- **dbt**: Check your dbt configuration and ensure the necessary dependencies are installed.

### Docker Setup Alternative
If you prefer to use Docker, follow these steps to set up the project:

1. Build and run locally:
```bash
docker-compose build

docker-compose up -d postgres

docker-compose run airflow-webserver airflow db init
docker-compose run airflow-webserver airflow users create \
    --username admin \
    --firstname Admin \
    --lastname User \
    --role Admin \
    --email your-email@example.com \
    --password admin

docker-compose up -d

docker-compose down
```

2. Run ETL script in container:
```bash
docker build -t sf-fire-etl -f Dockerfile.etl .
docker run -it --env-file .env sf-fire-etl
```

3. To run in AWS:
```bash
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $AWS_ACCOUNT.dkr.ecr.us-east-1.amazonaws.com
docker tag sf-fire-airflow:latest $AWS_ACCOUNT.dkr.ecr.us-east-1.amazonaws.com/sf-fire-airflow:latest
docker push $AWS_ACCOUNT.dkr.ecr.us-east-1.amazonaws.com/sf-fire-airflow:latest
```