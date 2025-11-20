import pandas as pd
from sqlalchemy import create_engine
import os

# ---------------------------------------------------------
# CONFIGURATION
# ---------------------------------------------------------
# Ideally, load these from environment variables for security
DB_TYPE = 'mysql'  # Options: 'postgresql', 'mysql', 'mssql'
DB_USER = 'avikumart'
DB_PASSWORD = 'Avit1699@#'
DB_HOST = 'database-1.cluster-cnqscyas2poo.us-east-2.rds.amazonaws.com'
DB_PORT = '3306' # 5432 for Postgres, 3306 for MySQL
DB_NAME = 'your_database_name'

FILE_PATH = 'data.csv'   # Path to your local data file
TABLE_NAME = 'target_table_name'

def get_connection_string():
    """Constructs the connection string based on DB_TYPE."""
    if DB_TYPE == 'postgresql':
        # Uses psycopg2 driver
        return f"postgresql+psycopg2://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"
    elif DB_TYPE == 'mysql':
        # Uses pymysql driver
        return f"mysql+pymysql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"
    else:
        raise ValueError("Unsupported DB_TYPE specified.")

def load_data_to_rds():
    try:
        print("--- Starting Data Load Process ---")
        
        # 1. Create the SQLAlchemy Engine
        connection_str = get_connection_string()
        engine = create_engine(connection_str)
        
        # 2. Load Data from CSV into Pandas DataFrame
        # Note: If your file is Excel, use pd.read_excel(FILE_PATH)
        print(f"Reading data from {FILE_PATH}...")
        df = pd.read_csv(FILE_PATH)
        
        # Optional: Clean data here if necessary
        # df.dropna(inplace=True)
        
        # 3. Upload Data to RDS
        print(f"Uploading {len(df)} rows to table '{TABLE_NAME}'...")
        
        # if_exists options: 'fail', 'replace', 'append'
        # index=False prevents pandas from creating an extra column for the index
        df.to_sql(TABLE_NAME, con=engine, if_exists='append', index=False)
        
        print("✅ Data loaded successfully!")

    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    load_data_to_rds()