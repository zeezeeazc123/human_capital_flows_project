import getpass
from sqlalchemy import create_engine


def conn_psql(db_user:str, host:str='localhost')->str:
    """Connects to posgreSQL server using SQLAlchemy
    
    Args:
    - db_user (str):    The username for the database connection.       
    - host (str):       (Optional) Host location
    
    Returns:
    - SQLAlchemy Connectable
    """
    
    pwd = getpass.getpass('database user password: ')
    
    return create_engine(f'postgresql+psycopg2://{db_user}:{pwd}@{host}/pitchbook_data').connect()


def load_query_from_file(file_path:str)->str:
    """Loads a query from SQL file as a String for processing with Pandas
    
    Args:
    - file_path (str):  The path to the SQL file
    
    Returns:
    - Query (str)
    
    """
    with open(file_path, 'r') as f:
        return f.read().replace('\t', '    ') # turn tabs into spaces for better compatibility

