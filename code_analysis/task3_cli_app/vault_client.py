import hvac
import os
from dotenv import load_dotenv

load_dotenv()

def get_db_credentials():
   
    """
    Connects to Vault using AppRole and retrieves DB credentials.
    Using 'hvac' 
    """
    vault_url = os.getenv('VAULT_ADDR', 'http://vault_server:8200')
    role_id = os.getenv('VAULT_ROLE_ID')
    secret_id = os.getenv('VAULT_SECRET_ID')

   
    if not role_id or not secret_id:
        print("ERROR: VAULT_ROLE_ID o VAULT_SECRET_ID no están configurados.")
        return None, None

    try:
        # 2. Inicializar el cliente de Vault
        client = hvac.Client(url=vault_url, token='root')

        # 3. Autenticarse con AppRole (Método recomendado para aplicaciones)
        client.auth.approle.login(role_id=role_id, secret_id=secret_id)

        # 4. Read secret (Motor KV v2)
        read_response = client.secrets.kv.v2.read_secret_version(
            mount_point='secret',
            path='library_db'
        )

        # Extraer los datos del diccionario de respuesta
        credentials = read_response['data']['data']
        
        # Devolvemos usuario y contraseña
        return credentials['username'], credentials['password']

    except Exception as e:
        print(f"❌ Error connecting to Vault: {e}")
        return None, None