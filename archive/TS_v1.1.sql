with emp_hist as (
	select	co_id
			,co_year_founded
			,co_primary_industry_sector
			,emp_cnt_yr
			,log(x.emp_cnt_abs + 0.0001) as emp_cnt_log
	from (
		select	co_id 
				-- ,co_name 
				,co_year_founded
				,co_primary_industry_sector
				--,unnest(co_verticals) vertical
				,split_part(unnest(co_employee_hist), ': ', 1)::numeric emp_cnt_yr
				,split_part(unnest(co_employee_hist), ': ', 2)::numeric emp_cnt_abs
		from pitchbook.employee_hist eh
	) x
),

deal_info as (
	select	deal_id
			,co_id 
			-- ,co_name 
			,unnest(co_verticals) vertical
			,deal_number 
			,deal_vintage
			,deal_vc_round 
			,deal_number
			,deal_series
			,log(deal_premoney + 0.0001) deal_premoney 
			,log(deal_postmoney + 0.0001) deal_postmoney
			,log(deal_size + 0.0001) deal_size
			,log(deal_investor_count + 0.001) deal_investor_count
	from 	pitchbook.deals d
)

select	*
from	deal_info d
left join emp_hist h on h.co_id = d.co_id
order by d.co_id, d.deal_id, d.deal_vintage, h.emp_cnt_yr;