-- Main Objective (1): Analyzing Channel Portfolios

-- Task: An Email was sent on November 29-2012 from the Marketing Director: Tom Parmesan and it includes the following:

-- With gsearch doing well and the site performing better, we launched a second paid search channel, bsearch , around August 22.
-- Can you pull weekly trended session volume since then and compare to gsearch nonbrand so I can get a sense for how important this will be for the business?

-- -----------------------------------------------------------------------------------------------------------------------------

-- Solution Starts:

SELECT
-- utm_source
min(date(created_at)) AS Start_of_Week, -- For Weekly Volume patterns
COUNT(DISTINCT website_session_id) AS Total_Number_of_Sessions,
COUNT(DISTINCT CASE WHEN utm_source='gsearch' THEN website_session_id ELSE NULL END) AS gsearch_sessions, -- Always Use CASE WHEN to count weekly trends, dont group by utm_source as it will yield the overall number of sessions
COUNT(DISTINCT CASE WHEN utm_source='bsearch' THEN website_session_id ELSE NULL END) AS bsearch_sessions -- Always Use CASE WHEN to count weekly trends, dont group by utm_source as it will yield the overall number of sessions
FROM website_sessions
WHERE created_at > '2012-08-22' AND created_at < '2012-11-29'
AND utm_campaign='nonbrand'
GROUP BY YEARWEEK(created_at); -- For Weekly Volume patterns

-- Conlcusion to question(1):
-- bsearch sessions are third of gsearch sessions
-- -----------------------------------------------------------------------------------------------------------------------------

-- Main Objective (2): Comparing Channel Characteristics

-- Task: An Email was sent on November 30-2012 from the Marketing Director: Tom Parmesan and it includes the following:

-- I’d like to learn more about the bsearch nonbrand campaign.
-- Could you please pull the percentage of traffic coming on Mobile , and compare that to gsearch
-- Feel free to dig around and share anything else you find interesting. Aggregate data since August 22nd is great, no need to show trending at this point.

-- -----------------------------------------------------------------------------------------------------------------------------

-- Solution Starts:

SELECT
utm_source, -- used utm_source here since we want the overall value, we dont need trending again
COUNT(DISTINCT website_session_id) AS Total_Number_of_Sessions,
COUNT(DISTINCT CASE WHEN  device_type='mobile'THEN website_session_id ELSE NULL END) AS mobile_sessions,
COUNT(DISTINCT CASE WHEN  device_type='mobile'THEN website_session_id ELSE NULL END)/COUNT(DISTINCT website_session_id) AS Percentage_of_traffic_coming_from_mobile
-- COUNT(DISTINCT CASE WHEN utm_source='bsearch' AND device_type='mobile'THEN website_session_id ELSE NULL END) AS mobile_bsearch_sessions
FROM website_sessions
WHERE utm_campaign='nonbrand'
AND created_at BETWEEN '2012-08-22' AND '2012-11-30'
GROUP BY utm_source;

-- Conlcusion to question(2):
-- The desktop to mobile split between gsearch and bsearch is quite huge
-- -----------------------------------------------------------------------------------------------------------------------------

-- Main Objective (3): Cross Channel Bid Optimization

-- Task: An Email was sent on December 01-2012 from the Marketing Director: Tom Parmesan and it includes the following:

-- I’m wondering if bsearch nonbrand should have the same bids as gsearch.
-- Could you pull nonbrand conversion rates from session to order for gsearch and bsearch, and slice the data by device type
-- Please analyze data from August 22 to September 18 ; we ran a special pre holiday campaign for gsearch starting on September 19th , so the data after that isn’t fair

-- -----------------------------------------------------------------------------------------------------------------------------

-- Solution Starts:

SELECT
utm_source,
device_type,
COUNT(DISTINCT website_sessions.website_session_id) AS Total_Number_of_Sessions,
COUNT(DISTINCT orders.order_id) AS Number_of_orders,
COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id) AS Conversion_Rate
FROM website_sessions
LEFT JOIN orders
ON website_sessions.website_session_id=orders.website_session_id
WHERE website_sessions.created_at BETWEEN '2012-08-22-' AND '2012-09-19'
AND utm_campaign= 'nonbrand'
GROUP BY 1,2
ORDER BY 3 DESC;

-- Conlcusion to question(3):
-- For both desktop and mobile, gsearch outperforms bsearch
-- -----------------------------------------------------------------------------------------------------------------------------

-- Main Objective (4): Channel Portfolio Trends

-- Task: An Email was sent on December 22-2012 from the Marketing Director: Tom Parmesan and it includes the following:

-- Based on your last analysis, we bid down bsearch nonbrand on December 2nd.
-- Can you pull weekly session volume for gsearch and bsearch nonbrand, broken down by device, since November 4th
-- If you can include a comparison metric to show bsearch as a percent of gsearch for each device, that would be great too.

-- -----------------------------------------------------------------------------------------------------------------------------

-- Solution Starts:

SELECT
min(DATE(created_at)) AS start_of_week,
COUNT(DISTINCT CASE WHEN utm_source='gsearch' AND device_type='mobile' THEN website_session_id ELSE NULL END) AS gsearch_mobile_sessions,
COUNT(DISTINCT CASE WHEN utm_source='bsearch' AND device_type='mobile'THEN website_session_id ELSE NULL END) AS bsearch_mobile_sessions,
COUNT(DISTINCT CASE WHEN utm_source='bsearch' AND device_type='mobile'THEN website_session_id ELSE NULL END)/
COUNT(DISTINCT CASE WHEN utm_source='gsearch' AND device_type='mobile' THEN website_session_id ELSE NULL END) AS bsearch_to_gsearch_percentage_mobile,
COUNT(DISTINCT CASE WHEN utm_source='gsearch' AND device_type='desktop' THEN website_session_id ELSE NULL END) AS gsearch_desktop_sessions,
COUNT(DISTINCT CASE WHEN utm_source='bsearch' AND device_type='desktop' THEN website_session_id ELSE NULL END) AS bsearch_desktop_sessions,
COUNT(DISTINCT CASE WHEN utm_source='bsearch' AND device_type='desktop' THEN website_session_id ELSE NULL END)/
COUNT(DISTINCT CASE WHEN utm_source='gsearch' AND device_type='desktop' THEN website_session_id ELSE NULL END) AS bsearch_to_gsearch_percentage_desktop
FROM website_sessions
WHERE 
website_sessions.created_at BETWEEN '2012-11-4' AND '2012-12-22'
AND utm_campaign= 'nonbrand' 
GROUP BY YEARWEEK(created_at);

-- Conlcusion to question(4):
-- The impact of the bsearch non brand biddown that took place on 2nd of december can be seen clearly as the sessions volume have dropped (For the desktop)
-- As for the mobile, the biddown has much less impact on the volume of sessions (the volume of sessions for the bsearch nonbrand is less sensitive to bid changes in case of mobile)
-- as for gsearch, the sessions volume have also dropped probably due to black friday and cyber monday.
-- -----------------------------------------------------------------------------------------------------------------------------

-- Main Objective (5): Analyzing Free Channels

-- Task: An Email was sent on December 23-2012 from the CEO: Cindy Sharp and it includes the following:

-- A potential investor is asking if we’re building any momentum with our brand or if we’ll need to keep relying on paid traffic.
-- Could you pull organic search, direct type in, and paid brand search sessions by month , and show those sessions as a % of paid search nonbrand
-- -----------------------------------------------------------------------------------------------------------------------------

-- Solution Starts:
SELECT
YEAR (created_at) as yr,
MONTH(created_at) as mo,
COUNT(DISTINCT CASE WHEN channel_grouping= 'Paid_brand' then website_session_id ELSE NULL END) AS brand,

COUNT(DISTINCT CASE WHEN channel_grouping= 'Paid_nonbrand' then website_session_id ELSE NULL END) AS nonbrand,

COUNT(DISTINCT CASE WHEN channel_grouping= 'Paid_brand' then website_session_id ELSE NULL END)/
COUNT(DISTINCT CASE WHEN channel_grouping= 'Paid_nonbrand' then website_session_id ELSE NULL END) AS brand_percentage_of_nonbrand,

COUNT(DISTINCT CASE WHEN channel_grouping= 'Direct_Type_In' then website_session_id ELSE NULL END) AS Direct,

COUNT(DISTINCT CASE WHEN channel_grouping= 'Direct_Type_In' then website_session_id ELSE NULL END)/
COUNT(DISTINCT CASE WHEN channel_grouping= 'Paid_nonbrand' then website_session_id ELSE NULL END) AS direct_type_in_percentage_of_nonbrand,

COUNT(DISTINCT CASE WHEN channel_grouping= 'organic_search' then website_session_id ELSE NULL END) AS organic,

COUNT(DISTINCT CASE WHEN channel_grouping= 'organic_search' then website_session_id ELSE NULL END)/
COUNT(DISTINCT CASE WHEN channel_grouping= 'Paid_nonbrand' then website_session_id ELSE NULL END) AS organic_percentage_of_nonbrand
FROM
(
SELECT -- To Create a subquery to group and bucket channels
website_session_id,
created_at,
	CASE
		WHEN utm_source IS NULL AND http_referer IS NULL THEN 'Direct_Type_In'
		WHEN utm_source is NULL AND http_referer IN ('https://www.gsearch.com','https://www.bsearch.com') THEN 'organic_search'
		WHEN utm_campaign = 'brand' THEN 'Paid_brand'
        WHEN utm_campaign = 'nonbrand' THEN 'Paid_nonbrand'
	END AS channel_grouping
FROM website_sessions
WHERE created_at < '2012-12-23') AS sessions_with_channel_grouping
GROUP BY YEAR (created_at),
MONTH(created_at);

-- Conlcusion to question(5):
-- organic and direct type % is increasing over the months from just 2 % in April to 7 % in December.
-- That's great because it's unpaid so it's a high margin traffic.
-- This means your brand is growing
-- -----------------------------------------------------------------------------------------------------------------------------
