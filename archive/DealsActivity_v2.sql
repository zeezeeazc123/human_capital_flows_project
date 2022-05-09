-- Construct main table: co_id, deal_id, year of deal, eval of deal, verticals, n_deals the company has in total
with base as (
	select	d.co_id
			, d.deal_id 
			, d.deal_vintage
			, d.deal_premoney 
			, d.deal_postmoney
			, d.deal_size 
			, n.n_deals
	from 	pitchbook.deals d 
	inner join (
		select	co_id
				, count(deal_id) n_deals
		from	pitchbook.deals d
		group by co_id
	) n on n.co_id = d.co_id 
	where 	deal_postmoney notnull
	order by d.co_id, deal_postmoney desc
),

-- get employee data
emp_data as (
	select	co_id
			,split_part(emp_hist, ': ', 1)::numeric  emp_hist_yr
			,split_part(emp_hist, ': ', 2)::numeric  emp_cnt
	from (
		select	co_id
				,unnest(co_employee_hist) emp_hist
		from 	pitchbook.employee_hist eh
	) b
),

agg_data as (
	select  b.*
			, e.emp_hist_yr 
			, e.emp_cnt as emp_cnt
			-- , eh.co_employee_hist
			, lag(e.emp_cnt, 1) over (
				partition by b.co_id, b.deal_id
				order by b.co_id, b.deal_id, e.emp_hist_yr
			) prev_emp_cnt
	from 	base b
	left join emp_data e on b.co_id = e.co_id
	-- left join pitchbook.employee_hist eh on eh.co_id = b.co_id
	where e.emp_hist_yr <= b.deal_vintage
	order by b.co_id, b.deal_id, e.emp_hist_yr
)

select 	*
		, (emp_cnt - prev_emp_cnt)/prev_emp_cnt as perc_change_emp_cnt
		, first_value(emp_cnt) over (
			partition by co_id, deal_id
			order by co_id, deal_id, emp_hist_yr
		) earliest_yr_emp_cnt
		, last_value(emp_cnt) over (
			partition by co_id, deal_id
			order by co_id, deal_id, emp_hist_yr
			RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
		) latest_yr_emp_cnt 
from agg_data ;