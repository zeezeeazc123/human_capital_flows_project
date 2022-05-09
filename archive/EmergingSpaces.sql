/*
 Recreates a simplistic version of the Emerging Spaces Feature of PitchBook. The main query does not include when
 verticals and industries arrays are null.

 More EDA will need to be explored for null values.
 */

-- Get the required columns and break out arrays
WITH basic_stats AS (
    SELECT unnest(d.co_verticals)     vertical
         , unnest(c.co_industries)    industry
         , d.co_id
         , d.deal_id
         , d.deal_postmoney
         , unnest(e.co_employee_hist) empl_hist
    FROM pitchbook.deals d
             INNER JOIN pitchbook.employee_hist e using (co_id)
             INNER JOIN pitchbook.companies c using (co_id)
    WHERE d.deal_postmoney notnull
),

-- Determine the "spaces" and retrieve the most recent count of employees
space_stats AS (
    SELECT CASE
               WHEN vertical notnull then vertical
               WHEN vertical isnull AND industry notnull then industry
               ELSE null
        END           space
         , co_id
         , deal_id
         , deal_postmoney
         , split_part(first_value(empl_hist) over (
        partition by co_id
        order by empl_hist desc
        ), ' ', 2) as n_most_recent_employees
    FROM basic_stats
),

-- Get aggregate information
emerging_spaces_basic_stats as (
    SELECT  space
            ,count(distinct co_id) n_companies
            ,count(distinct deal_id) n_deals
            ,sum(deal_postmoney) capital_invested
            ,sum(n_most_recent_employees::numeric) n_employees
    FROM    space_stats
    WHERE   space notnull
    GROUP BY space
)

SELECT  *
FROM    emerging_spaces_basic_stats;


