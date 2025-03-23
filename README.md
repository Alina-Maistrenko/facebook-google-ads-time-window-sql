# Facebook and Google Ad Campaign Analysis with Time Windows (SQL)

This SQL code is used to analyze Facebook and Google ad campaigns over time (monthly). It combines data from both platforms, processes UTM parameters, calculates key metrics, and compares changes between months.

## What it does

The code uses two CTEs (Common Table Expressions) and a main query. The first CTE (`CTE_combined_data`) combines data from the `facebook_ads_basic_daily` and `google_ads_basic_daily` tables. The second CTE (`CTE_with_metrics`) calculates monthly key metrics, grouping by date and UTM campaign. The main query selects the necessary fields, adds fields with previous metric values (`lag`), and calculates the percentage difference between current and previous metric values.

## Tables

* `facebook_ads_basic_daily`: Basic data about Facebook ad campaigns.
* `facebook_campaign`: Information about Facebook campaigns.
* `facebook_adset`: Information about Facebook ad sets.
* `google_ads_basic_daily`: Basic data about Google ad campaigns.

## Metrics

* `ad_date`: The date the ad was shown.
* `campaign_name`: The name of the campaign.
* `utm_campaign`: The campaign name from the ad's URL.
* `total_spend`: How much money was spent.
* `total_impressions`: How many times the ad was shown.
* `total_clicks`: How many times people clicked on the ad.
* `total_value`: The total value of conversions (e.g., sales).
* `CTR (Click-Through Rate)`: How often people clicked on the ad after seeing it.
* `CPC (Cost Per Click)`: How much each click cost.
* `CPM (Cost Per Mille)`: How much it cost to show the ad 1000 times.
* `ROMI (Return on Marketing Investment)`: How much money was made compared to how much was spent.
* `difference_CTR`, `difference_CPC`, `difference_CPM`, `difference_ROMI`: Percentage difference between current and previous metric values.


## How the code works

1. **CTE `CTE_combined_data`:**
    * Takes data from `facebook_ads_basic_daily` and `google_ads_basic_daily` tables and puts them together.
    * Changes `NULL` values to 0 using `COALESCE`.
    * Adds a `media_source` column to show if the data is from Facebook or Google.
2. **CTE `CTE_with_metrics`:**
    * Extracts the month from `ad_date` using `date_trunc('month', ad_date)`.
    * Extracts `utm_campaign` from `url_parameters` using `substring`.
    * Adds up the total spend, impressions, clicks, and value for each month.
    * Calculates CTR, CPC, CPM, and ROMI, using `CASE` to avoid dividing by zero.
    * Groups the results by month and UTM campaign.
3. **Main query:**
    * Selects the necessary fields from `CTE_with_metrics`.
    * Adds fields with previous metric values using `lag()`.
    * Calculates the percentage difference between current and previous metric values.
