-- Deal Activity (n_deals, n_companies, avg_deal_size, avg_postmoney, n_investors) over time
-- per vertical.
WITH base as (
    SELECT d.co_id
         , d.deal_id
         , unnest(d.co_verticals) vertical
         , d.deal_vintage
         , d.deal_size
         , d.deal_postmoney
         , d.deal_investor_count
    FROM pitchbook.deals d
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
                  FROM pitchbook.employee_hist
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
GROUP BY b.vertical, b.deal_vintage;