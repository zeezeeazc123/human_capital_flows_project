-- Goal: Get the rate of employee count change leading up to the date of deal
/*
 Recreates a simplistic version of the Emerging Spaces Feature of PitchBook. The main query does not include when
 verticals and industries arrays are null.

 More EDA will need to be explored for null values.
 */

-- Get the required columns and break out arrays
WITH basic_stats AS (
    SELECT unnest(d.co_verticals)     vertical
         -- , unnest(c.co_industries)    industry
         , d.co_id
         , d.deal_id
         , d.deal_postmoney
         , unnest(e.co_employee_hist) empl_hist
    FROM pitchbook.deals d
             INNER JOIN pitchbook.employee_hist e using (co_id)
             INNER JOIN pitchbook.companies c using (co_id)
    WHERE d.deal_postmoney notnull
    order by d.co_id, empl_hist asc
)

select	distinct co_id 
		, vertical
		, deal_id
		, deal_postmoney 
		, empl_hist 
from basic_stats ;



/*
Notes: There are some companies that are in multiple verticals
*/