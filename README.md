## Customer Segmentation _at_ Materialize _using_ Materialize
#### ...and also Segment, Upstash Kafka, Dbt, and Hightouch

---
**Segment** is a customer data platform (CDP) that collects data from your website and other tools and sends it to the destination of your choosing. 
We’ll be using the Segment JS library to generate input data from our external website and our cloud product and Segment's webhook destination to `export` the data to http endpoints. 

**Upstash.com** provides serverless kafka with a built in REST API - useful in our case for consuming events from segment. 

**Materialize** is a streaming database that accepts data from a variety of sources - files (s3), relational databases (postgres) or streams (kafka) 
and allows users to write SQL to define incrementally updated real time views across those data sources. 

We will set up Materialize to read from our Upstash kafka broker, aggregate the actions a user has taken, and score them based on what we think each engagement event means.
Our goal is to create a real time representation of if a user is interested in our product. Those lucky folks will be classified as MQL's or Marketing Qualified Leads. 

We'll use **dbt** for data modeling and **Hightouch** to send our MQLs from Materialize to Salesforce. Our sales team will take it from there.

That was a mouth-full. Let's demonstrate how simple this actually is. 

1. Set up your website to ['track'](https://segment.com/docs/connections/spec/track/) actions that a user might take if they were curious about your product. 
In our case, we think that if a user signs up for a demo, downloads a whitepaper, joins our community, subscribes to our newsletter, or attends a meetup, they might want to learn more about what we are up to.
2. Set up a kafka cluster on [upstash.com](https://docs.upstash.com/kafka). Create a topic for your website events to be sent to. 
3. Set up a segment [webhook destination](https://segment.com/docs/connections/destinations/catalog/webhooks/) to submit our website data to our kafka topic.
4. Use the dbt project in this repo to: 
   - set up a materialize kafka source to ingest our website data and deserialize our event payloads
   - set up a materialize table to house our event definitions
   - create a materialized view of the events each user has taken
   - create a materialied view represting our MQLs
5. Set up a [PostgreSQL](https://hightouch.io/docs/sources/postgresql/) connection within hightouch, 
optionally sync our [dbt models](https://hightouch.io/docs/models/dbt-models/), and start sending our MQL's to [Salesforce](https://hightouch.io/docs/destinations/salesforce/).

---
###Local Development:

Optionally create a local environment:
```sql
python3 -m venv venv
. venv/bin/activate
```

Install the latest version of the dbt-materialize adapter:
```sql
pip install dbt-materialize
```


#### Run dbt!

- Create a view of the actions we expect users to take based on the csv we've defined in (seeds/mql_score.csv).
```sql
dbt seed
```
```sql
materialize=> show views;
   name
-----------
mql_score
(1 row)

materialize=> select * from public.mql_score;
event_name       | mql_score
-----------------------+-----------
 demo_requested        |        30
 meetup_attended       |         5
 community_joined      |         5
 newsletter_subscribed |        10
 whitepaper_downloaded |        20
(5 rows)
```
_Note_: Any update of the csv and re-run of this command will cascade to views that depend on it in real time.

- Create Materialize kafka sources from the segment destinations we created:
```
dbt run --m models/sources
```
_Note_: We instruct dbt to create sources in the `materialize.public` database and schema. Both development and production environments have access.

- Create staging views to deserialize our data, and materialized views to aggregate, filter, and time window. 
```
dbt run --exclude models/sources
```
Exercise: Play with these! 

- Run tests to make sure the transformation code we wrote makes sense
```
dbt test
```
_Note_: We've configured dbt to store the results of test failures in materialized views. We'll check in as we are developing to ensure things act as we expect them to. When we merge to production, we'll set up alerts to future-proof against changes in upstream data sources.

---
###Peep our views:
```sql
materialize=> select * from public_dbt_anna.user_mql_score order by last_event_received_at desc;
             email             | mql_score |        mql_events                                  |   last_event_received_at
-------------------------------+-----------+-------------------------------------------------------------------------------
 awesomeuser1@fun.com          |         5 | ["community_joined"]                               | 2022-06-22 18:08:19.621+00
 holymoly@wild.com             |         5 | ["community_joined"]                               | 2022-06-22 14:15:21.602+00
 hi@hihihihihih.io             |        25 | ["whitepaper_downloaded", "community_joined"]      | 2022-06-22 08:00:53.69+00
```

And who our lucky MQL's are! 
```sql
materialize=> select * from public_dbt_anna.user_alerts;
 alert_condition  |           alert_labels           | alert_value
------------------+----------------------------------+-------------
 mql_threshold_20 | {"email":"hi@hihihihihih.io"} |          20
```
