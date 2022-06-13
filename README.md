## Customer Segmentation using Segment, Upstash Kafka, Materialize, Dbt and Hightouch

Segment is a customer data platform (CDP) that collects data from your website and other tools and sends it to the destination of your choosing. 
We’ll be using the Segment JS library to generate input data from our external website and our cloud product and Segment's webhook destination to `export` the data to http endpoints. 

Upstash.com provides serverless kafka with a built in REST API - useful in our case for consuming events from segment. 

Materialize is a streaming database that accepts data from a variety of sources - files (s3), relational databases (postgres) or streams (kafka) 
and allows users to write SQL to define incrementally updated real time views across those data sources. 

We will set up Materialize to read from our Upstash kafka broker, enrich the data by joining events coming from our website with data from TODO: xxx source, 
and create a real time view of if a user is interested in our product. These users will be classified as MQL's or Marketing Qualified Leads. 

We'll use dbt for data modeling and Hightouch to send our MQLs from Materialize to Salesforce - our sales team will take it from there.

That was a mouth-full. Let's demonstrate how simple this actually is. 

1. Set up your website to ['track'](https://segment.com/docs/connections/spec/track/) actions that a user might take if they were curious about your product. 
In our case, we think that if a user signs up for a demo, downloads a whitepaper, joins our community, subscribes to our newsletter, or attends a meetup, they might want to learn more about what we are up to.
2. Set up a kafka cluster on [upstash.com](https://docs.upstash.com/kafka). Create a topic for your website events to be sent to. 
3. Set up a segment [webhook destination](https://segment.com/docs/connections/destinations/catalog/webhooks/) to submit our website data to our kafka topic. 
4. TODO Platform: Create a Materialize cluster 
5. Use the dbt project in this repo to: (TODO: Update our dbt profile and upstash source credentials, CONNECTIONs)
   - set up a materialize kafka source to ingest our website data and deserialize our event payloads
   - set up a materialize table to house our event definitions
   - create a materialized view of the events each user has taken
   - create a materialied view represting our MQLs (and tag it with our hightouch tag)
6. Set up a [PostgreSQL](https://hightouch.io/docs/sources/postgresql/) (TODO: MATERIALIZE?) Hightouch source, 
sync our [dbt models](https://hightouch.io/docs/models/dbt-models/), and start sending our MQL's to [Salesforce](https://hightouch.io/docs/destinations/salesforce/).