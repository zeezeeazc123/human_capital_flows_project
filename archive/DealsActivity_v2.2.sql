with emp_hist as (
	select	co_id 
			-- ,co_name 
			,co_year_founded 
			--,unnest(co_verticals) vertical
			,split_part(unnest(co_employee_hist), ': ', 1)::numeric emp_cnt_yr
			,split_part(unnest(co_employee_hist), ': ', 2)::numeric emp_cnt
	from pitchbook.employee_hist eh
),

deal_info as (
	select	deal_id
			,co_id 
			-- ,co_name 
			,unnest(co_verticals) vertical
			,deal_number 
			,deal_vintage
			,deal_vc_round 
			,deal_premoney 
			,deal_postmoney 
			,deal_size 
			,deal_investor_count 
	from 	pitchbook.deals d 
),

all_data as (
	select	d.deal_id
			,d.co_id
			,d.vertical
			,e.co_year_founded
			,e.emp_cnt_yr
			,e.emp_cnt
			,d.deal_number 
			,d.deal_vintage
			,d.deal_vc_round 
			,d.deal_premoney 
			,d.deal_postmoney 
			,d.deal_size 
			,d.deal_investor_count 
	from	deal_info d
	left join emp_hist e on d.co_id = e.co_id
	where deal_size notnull
	order by co_id, deal_vintage, emp_cnt_yr
)

select	*
		,lead (emp_cnt, 1) over (partition by(co_id) order by emp_cnt_yr asc) next_yr_cmp_cnt
from 	all_data;