import getpass
from sqlalchemy import create_engine


def conn_psql(db_user:str, host:str='localhost'):
    """Connects to posgreSQL server using SQLAlchemy
    
    Args:
    - db_user (str):    The username for the database connection.       
    - host (str):       Host location
    Return:
    - SQLAlchemy Connectable
    """
    
    pwd = getpass.getpass('database user password: ')
    
    return create_engine(f'postgresql+psycopg2://{db_user}:{pwd}@{host}/pitchbook_data').connect()