with CTE_combined_data as (
		select 
		fabd.ad_date 
		, fc.campaign_name
		, fa.adset_name
		, COALESCE (fabd.spend, 0) spend
		, COALESCE (fabd.impressions, 0) impressions
		, COALESCE (fabd.reach, 0) reach
		, COALESCE (fabd.clicks,0) clicks
		, COALESCE (fabd.leads,0) leads
		, COALESCE (fabd.value,0) value
		, fabd.url_parameters
		, 'facebook' media_source
	from facebook_ads_basic_daily fabd 
left join facebook_campaign fc on fc.campaign_id = fabd.campaign_id 
left join facebook_adset fa on fa.adset_id = fabd.adset_id 
union all 
	select
	      gabd.ad_date
		, gabd.campaign_name
		, gabd.adset_name
		, COALESCE (gabd.spend, 0) spend
		, COALESCE (gabd.impressions, 0) impressions
		, COALESCE (gabd.reach, 0) reach
		, COALESCE (gabd.clicks, 0) clicks
		, COALESCE (gabd.leads, 0) leads
		, COALESCE (gabd.value, 0) value
		, gabd.url_parameters
		, 'google' media_source
	from google_ads_basic_daily gabd
	),
	CTE_with_metrics as (
		select 
		date_trunc('month', ad_date) ad_month
		, substring(url_parameters from 'utm_campaign=([^&#$]+)') as utm_campaign
		, sum(spend) total_spend
		, sum (impressions) total_impressions
		, sum (clicks) total_clicks
		, sum (value) total_value
		, case 
			when sum (impressions) > 0
			then round ((sum (clicks) * 1.00 / sum(impressions)) * 100, 2)
			else null
			end CTR
		, case 
			when sum (clicks) > 0
			then round (1.00 * sum (spend) / sum (clicks), 2)
			else null
			end CPC
		, case 
			when sum(impressions) > 0
			then round ((1.00 * sum (spend) / sum (impressions)) * 1000, 2)
			else null
			end CPM
		, case 
			when sum (spend) > 0
			then round (((1.00 * SUM(value) - SUM(spend)) / SUM(spend))*100, 2)
			else null
			end ROMI
		from CTE_combined_data
		group by date_trunc ('month', ad_date), substring(url_parameters from 'utm_campaign=([^&#$]+)')
		)
	select
	utm_campaign
	, ad_month
	, total_spend
	, total_impressions
	, total_clicks
	, total_value
	, CTR
	, CPC
	, CPM
	, ROMI
	, lag (CTR, 1) over (partition by utm_campaign order by ad_month) AS prev_ctr 
	, lag (CPC, 1) over (partition by utm_campaign order by ad_month) as prev_cpc
	, lag (CPM, 1) over (partition by utm_campaign order by ad_month) as prev_cmp
	, lag (ROMI, 1) over (partition by utm_campaign order by ad_month) as prev_romi
	, case 
		when lag (CTR, 1) over (partition by utm_campaign order by ad_month) > 0
		then round (100 * (CTR / lag (CTR, 1) over (partition by utm_campaign order by ad_month) - 1), 2)
		else null 
		end difference_CTR
	, case 
		when lag (CPC, 1) over (partition by utm_campaign order by ad_month) > 0
		then round (100 * (CPC / lag (CPC, 1) over (partition by utm_campaign order by ad_month) - 1), 2)
		else null 
		end difference_CPC
	, case 
		when lag (CPM, 1) over (partition by utm_campaign order by ad_month) > 0
		then round (100 * (CPM / lag (CPM, 1) over (partition by utm_campaign order by ad_month) - 1), 2)
		else null 
		end difference_CPM
	, case 
		when lag (ROMI, 1) over (partition by utm_campaign order by ad_month) > 0
		then round (100 * (ROMI / lag (ROMI, 1) over (partition by utm_campaign order by ad_month) - 1), 2)
		else null 
		end difference_ROMI
	from CTE_with_metrics
	
	
