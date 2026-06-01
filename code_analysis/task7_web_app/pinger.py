import os
import time
import logging
import psycopg2
import requests
from vault_client import get_db_credentials  

# Configuración de Logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
def connect_to_db(user, password):
    
    try:
        conn = psycopg2.connect(
            host="db",     
            port="5432",
            database="seminario_db",
            user=user,
            password=password
            )
        logging.info("✅ Success PostgreSQL connection.")
        return conn
    except Exception as e:
        logging.error(f"❌ DB Connection failed  PostgreSQL: {e}")
        return None
    

def main():
    logging.info("--- Starting Pinger Service (Vault + PostgreSQL Integration) ---")
    
    tables = ["Authors", "Publishers", "Genres", "Books", "Book_Genres"]
    
    while True:
        user, password = get_db_credentials()
        
        if user and password:
            logging.info(f"✅ Credentials retrieved. User DB: {user}")
            
            conn = connect_to_db(user, password)
            if conn:
                logging.info("✅ Connected to PostgreSQL with Vault credentials.")
                cur =conn.cursor()
                
                print("\n---LIBRARY TABLES STATUS---")
                for table in tables:
                    try:
                        cur.execute(f'SELECT COUNT(*) FROM "{table}";')
                        count = cur.fetchone()[0]
                        logging.info(f"📊 Table '{table}': {count} records found.")
                    except Exception as e:
                        logging.error(f"❌ Error querying table '{table}': {e}")
                        conn.rollback()
                print("---------------------------\n")
                
                cur.close() 
                conn.close()
         
        else:
            logging.error("❌ Vault credentials could not be obtained.")
       
        time.sleep(10)

if __name__ == "__main__":
    main()