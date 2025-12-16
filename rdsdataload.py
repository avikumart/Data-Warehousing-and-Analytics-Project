import pandas as pd
from sqlalchemy import create_engine, text
import urllib.parse

# ---------------------------------------------------------
# CONFIGURATION
# ---------------------------------------------------------
DB_USER = 'admin'  # Or whatever your username is
DB_PASSWORD = 'buNIb***************************' # add your password here
DB_HOST = 'database-1.cnqscyas2poo.us-east-2.rds.amazonaws.com'
DB_PORT = '3306'
NEW_DB_NAME = 'health_lifestyle_db'  # We will create this specific DB
FILE_PATH = 'data/health_lifestyle_dataset.csv'

def create_database_if_not_exists():
    """
    Connects to the MySQL server (sys database) to create the new database.
    """
    encoded_password = urllib.parse.quote_plus(DB_PASSWORD)
    
    # Connect to the 'mysql' system database just to run the CREATE command
    # We use 'mysql' or empty database to establish the initial connection
    server_connection_str = f"mysql+pymysql://{DB_USER}:{encoded_password}@{DB_HOST}:{DB_PORT}/mysql"
    
    engine = create_engine(server_connection_str)
    
    with engine.connect() as conn:
        # We must use commit() because CREATE DATABASE cannot run inside a transaction block in some drivers
        conn.execute(text("COMMIT")) 
        conn.execute(text(f"CREATE DATABASE IF NOT EXISTS {NEW_DB_NAME}"))
        print(f"✅ Database '{NEW_DB_NAME}' exists or was created successfully.")

def load_data_to_rds():
    try:
        # 1. Ensure the database exists
        create_database_if_not_exists()

        # 2. Connect to the NEW database
        encoded_password = urllib.parse.quote_plus(DB_PASSWORD)
        db_connection_str = f"mysql+pymysql://{DB_USER}:{encoded_password}@{DB_HOST}:{DB_PORT}/{NEW_DB_NAME}"
        engine = create_engine(db_connection_str)

        # 3. Load and Upload Data
        print(f"Reading data from {FILE_PATH}...")
        df = pd.read_csv(FILE_PATH)
        
        print(f"Uploading {len(df)} rows to table 'life_style_data' in DB '{NEW_DB_NAME}'...")
        df.to_sql('life_style_data', con=engine, if_exists='replace', index=False)
        
        print("✅ Data loaded successfully!")

    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    load_data_to_rds()