with emp_hist_abs as (
	select	co_id 
			-- ,co_name 
			,co_year_founded
			,co_primary_industry_sector
			--,unnest(co_verticals) vertical
			,split_part(unnest(co_employee_hist), ': ', 1)::numeric emp_cnt_yr
			,split_part(unnest(co_employee_hist), ': ', 2)::numeric emp_cnt_abs
	from pitchbook.employee_hist eh
),

emp_hist as (
	select	*
			,log(emp_cnt_abs + 0.0001) as emp_cnt
	from 	emp_hist_abs
),

emp_hist_plus_prev_next_yr as (
	select	*
			,lead (emp_cnt_yr, 1) over (partition by(co_id) order by emp_cnt_yr asc) next_emp_cnt_yr
			,lead (emp_cnt, 1) over (partition by(co_id) order by emp_cnt_yr asc) next_emp_cnt_rec
			,lag (emp_cnt_yr, 1) over (partition by(co_id) order by emp_cnt_yr asc) prev_emp_cnt_yr
			,lag (emp_cnt, 1) over (partition by(co_id) order by emp_cnt_yr asc) prev_emp_cnt_rec
	from	emp_hist
	
),
emp_hist_w_calc as (

	select	*
			,next_emp_cnt_rec - emp_cnt  as emp_abs_growth_fromNext
			,(next_emp_cnt_rec - emp_cnt)/emp_cnt as emp_perc_growth_fromNext
			,emp_cnt - prev_emp_cnt_rec  as emp_abs_growth_fromPrev
			,(emp_cnt - prev_emp_cnt_rec)/prev_emp_cnt_rec as emp_perc_growth_fromPrev
	from	emp_hist_plus_prev_next_yr

),
/*
emp_hist_w_calc as (

	select	*
			,next_emp_cnt_rec - emp_cnt  as emp_abs_growth_fromNext
			,case
				when emp_cnt != 0 then (next_emp_cnt_rec - emp_cnt)/emp_cnt
				else null
			end emp_perc_growth_fromNext
			,emp_cnt - prev_emp_cnt_rec  as emp_abs_growth_fromPrev
			,case
				when prev_emp_cnt_rec != 0 then (emp_cnt - prev_emp_cnt_rec)/prev_emp_cnt_rec
				else null
			end emp_perc_growth_fromPrev
	from	emp_hist_plus_prev_next_yr

), */

deal_info as (
	select	deal_id
			,co_id 
			-- ,co_name 
			,unnest(co_verticals) vertical
			,deal_number 
			,deal_vintage
			,deal_vc_round 
			,log(deal_premoney + 0.0001) deal_premoney 
			,log(deal_postmoney + 0.0001) deal_postmoney
			,log(deal_size + 0.0001) deal_size
			,log(deal_investor_count + 0.001) deal_investor_count
	from 	pitchbook.deals d
),

all_data as (
	select	d.deal_id
			,d.co_id
			,e.co_primary_industry_sector
			,d.vertical
			,e.co_year_founded
			,e.emp_cnt_yr
			,e.emp_cnt
			,e.next_emp_cnt_yr
			,e.next_emp_cnt_rec
			,e.emp_abs_growth_fromNext
			,e.emp_perc_growth_fromNext
			,e.prev_emp_cnt_yr
			,e.prev_emp_cnt_rec
			,e.emp_abs_growth_fromPrev
			,e.emp_perc_growth_fromPrev
			,d.deal_number 
			,d.deal_vintage
			,d.deal_vc_round 
			,d.deal_premoney 
			,d.deal_postmoney 
			,d.deal_size
			,d.deal_investor_count 
	from	deal_info d
	left join emp_hist_w_calc e on d.co_id = e.co_id
	where deal_size notnull
	order by co_id, deal_vintage, emp_cnt_yr
)

select	*
from 	all_data;