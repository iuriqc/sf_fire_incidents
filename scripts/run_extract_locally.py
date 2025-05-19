import os
from dotenv import load_dotenv
import sys

def mock_glue_args():
    """Mock AWS Glue arguments for local testing"""
    # Load environment variables
    load_dotenv()
    
    # Validate required environment variables
    required_vars = ['OUTPUT_S3_PATH', 'SOCRATA_APP_TOKEN']
    missing_vars = [var for var in required_vars if not os.getenv(var)]
    
    if missing_vars:
        raise EnvironmentError(f"Missing required environment variables: {', '.join(missing_vars)}")
    
    # Set up command line arguments
    sys.argv = [
        sys.argv[0],
        '--OUTPUT_S3_PATH', os.getenv('OUTPUT_S3_PATH'),
        '--SOCRATA_APP_TOKEN', os.getenv('SOCRATA_APP_TOKEN')
    ]

if __name__ == "__main__":
    try:
        mock_glue_args()
        from sf_fire_extract import main
        main()
    except Exception as e:
        print(f"Error executing script: {str(e)}")
        sys.exit(1)