import os
import re
from numpy import DataSource
import pandas as pd
from pandasql import sqldf

class Error(Exception):
    """Base class for other exceptions"""
    pass
class queryLimitError(Error):
    """Raised when the args value exceeds number of rows, 10,000"""
    pass
class invalidWorkingDirectory(Error):
    """Raised when the working directory is not the top of the project"""
    pass

def DATA_SRC(file_name):
    """Returns the relative path to the data files"""
    
    try:
        if re.search("human_capital_flows_project$",os.getcwd()) == None:
            raise invalidWorkingDirectory
        else:
            return f'data/{file_name}'
    
    except(invalidWorkingDirectory):
        print("Invalid Working Directory Path.")
        exit()

def DEALS(limit=None):
    """Returns Deals CSV as a DataFrame
    
    Args:
    limit(int):   Query limit

    Return:
    pd.DataFrame  
    """

    if limit != None:
        return pd.read_csv(
            DATA_SRC('PitchBook_sampleData_deals.csv'),
            nrows=limit
        )
    
    else:
        return pd.read_csv(
            DATA_SRC('PitchBook_sampleData_deals.csv'),
        )

def EMPLOYEE_HISTORY(limit=None):
    """Returns employee history table from CSV as a DataFrame
    
    Args:
    limit(int):   Query limit

    Return:
    pd.DataFrame
    """
    if limit != None:
        return pd.read_csv(
            DATA_SRC('PitchBook_sampleData_employee_hist.csv'),
            nrows=limit
        )
    else:
        return pd.read_csv(
            DATA_SRC('PitchBook_sampleData_employee_hist.csv'),
        )

def COMPANIES(limit=None):
    """Returns deals table from CSV as a DataFrame
    
    Args:
    limit(int):   Query limit

    Return:
    pd.DataFrame
    """
    if limit != None:
        return pd.read_csv(
            DATA_SRC('PitchBook_sampleData_companies.csv'),
            nrows=limit
        )
    else:
        return pd.read_csv(
            DATA_SRC('PitchBook_sampleData_companies.csv')
        )

    """Returns deals as a query
    
    Args:
    limit (int): Query limit. Default is the max allowed, 10,000.

    Returns:
    query (str)
    """

    try:
        if limit < 0 \
            or limit > 10000:
            raise queryLimitError
    
    except(queryLimitError):
        print("Invalid query limit.")
        exit()

    return f"""
    SELECT  *
    FROM    {DATA_SRC('PitchBook_sampleData_deals.csv')}
    LIMIT   {limit};
    """ 

    """Returns a dataframe of the deals table as specified by get_dealsTable_query()"""
    return sqldf(f"""
    SELECT  *
    FROM    {pd.read_csv(DATA_SRC('PitchBook_sampleData_deals.csv'))}
    LIMIT   {limit};
    """)

def get_dealActivityOverTime(limit=None):
    """Returns Deal Activity (n_deals, n_companies, avg_deal_size, avg_postmoney, n_investors) over time per Vertical
    
    Args:
    limit (int):            Query limit
    
    Returns:
    query (str)
    """
    d = DEALS()
    eh = EMPLOYEE_HISTORY()

    return sqldf(f"""
        WITH base as (
            SELECT d.co_id
                , d.deal_id
                , unnest(d.co_verticals) vertical
                , d.deal_vintage
                , d.deal_size
                , d.deal_postmoney
                , d.deal_investor_count
            FROM d
            WHERE deal_vintage notnull
            and (deal_size notnull or deal_postmoney notnull or deal_investor_count notnull)
        ),
            empl_hist as (
                SELECT co_id
                        ,vertical
                        ,split_part(first_value(empl_hist) over (
                            partition by co_id
                            order by empl_hist desc
                            ), ': ', 1) as year
                        ,split_part(first_value(empl_hist) over (
                            partition by co_id
                            order by empl_hist desc
                            ), ' ', 2) as n_employees
                FROM (
                        SELECT co_id
                            , unnest(co_verticals) as vertical
                            , unnest(co_employee_hist) as empl_hist
                        FROM eh
                    ) x
            )

        SELECT  b.vertical
                ,b.deal_vintage as year
                ,count(b.deal_id) total_n_deals
                ,count(distinct b.co_id) total_n_companies
                ,avg(b.deal_size) avg_deal_size
                ,avg(b.deal_postmoney) avg_postmoney
                ,sum(b.deal_investor_count) total_n_investors
                ,sum(e.n_employees::numeric) total_n_employees
                ,avg(e.n_employees::numeric) avg_n_employees
        FROM    base b
        LEFT JOIN empl_hist e on b.co_id = e.co_id
                    and b.deal_vintage = e.year::numeric
        GROUP BY b.vertical, b.deal_vintage
        {'LIMIT '+str(limit) if limit != None else ''}
    """) 