# Week 2 — Distributed Tracing by Jessica Kerr (Jessitron)

## Jotted Notes 
Observability -- 
    Give software instructions to tell us what is going on with our services
    
Distributed tracing 
- Keeping track of requests and their traces (story) as it connects to other services or systems
- Span is a part of trace that represet a single unit of work that was done as part of a requests
- Traces tells you what happen, when they happens and the dependencies involved
- Service maps can be used to really show the interraction between services mostly on an enterprise level
- Instrumentation is the code that sends the data that makes trace
    

#### We are gonna add Distributed Tracing to our backend application


### Instructions from Live Stream
- From your github repo, launch gitpod

- Log into your [ui.honeycomb.io](ui.honeycomb.io) account

![https://github.com/Ibrahim-saliu/aws-bootcamp-cruddur-2023/blob/main/my_resources/Week2/creating_new_env_honeycomb.png](https://github.com/Ibrahim-saliu/aws-bootcamp-cruddur-2023/blob/main/my_resources/Week2/creating_new_env_honeycomb.png)


- Create a new environment 
    - Observe the **API Keys** : they determine what environment the the incoming data ends up in. (Keep them safe - breach could rresult in a flooding of your environment with irrelevant data that could make tracing more inefficient).
    
    - export your API key and set it as a variable in gitpod so that it is loaded everytime you log into gitpod
    
```sh
            export HONEYCOMB_API_KEY="jhddedvc887blahblah"
            gp env HONEYCOMB_API_KEY="jhddedvc887blahblah"
            
            # Note: Your whole project should use the same API key
```
    
    

```sh
            # export and set the service name as well
            # export HONEYCOMB_SERVICE_NAME="Cruddur"
            # gp env HONEYCOMB_SERVICE_NAME="Cruddur"
            
            #Note: a good practice if we have multiple services is to hardcode our `HONEYCOMB_SERVICE_NAME` in dockercompse file as we do not want the service name to be consistent accross multiple services. 
```
    
- so we add `OTEL_SERVICE_NAME: "backend-flask"` to our `compose.yml`
    `OTEL` is short for **open telemetry** [https://opentelemetry.io/](https://opentelemetry.io/)
- we also add `OTEL_EXPORTER_OTLP_ENDPOINT: "https://api.honeycomb.io"` and `OTEL_EXPORTER_OTLP_HEADERS: "x-honeycomb-teams=${HONEYCOMB_API_KEY}"`

- We need to add the following requirements from [ui.honeycomb.io](ui.honeycomb.io) under `Python` to our `requirements.txt`

- we execute the installation of our requirements in our `requirements.txt`
```sh
        pip install -r requirements.txt
```

- Add the following to your `app.py`
```python
    from opentelemetry import trace
    from opentelemetry.instrumentation.flask import FlaskInstrumentor
    from opentelemetry.instrumentation.requests import RequestsInstrumentor
    from opentelemetry.exporter.otlp.proto.http.trace_exporter import OTLPSpanExporter
    from opentelemetry.sdk.trace import TracerProvider
    from opentelemetry.sdk.trace.export import BatchSpanProcessor
```

- we also need to add the following to our `app.py`to initialize honeycomb. 
    
```python
    # HoneyComb initializaion
    provider = TracerProvider()
    processor = BatchSpanProcessor(OTLPSpanExporter())
    provider.add_span_processor(processor)
    trace.set_tracer_provider(provider)
    tracer = trace.get_tracer(__name__)


    app = Flask(__name__)

    # HoneyComb initializaion
    # Initialize automatic instrumentation with Flask
    FlaskInstrumentor().instrument_app(app)
    RequestsInstrumentor().instrument()
```
    
    
- we can now bring our application up using `docker compose up`

- We can see that data being created in our home and datasets section of honeycomb environment 

![https://github.com/Ibrahim-saliu/aws-bootcamp-cruddur-2023/blob/main/my_resources/Week2/backenddatasetsarrivinghoneycomb.png](https://github.com/Ibrahim-saliu/aws-bootcamp-cruddur-2023/blob/main/my_resources/Week2/backenddatasetsarrivinghoneycomb.png)

![https://github.com/Ibrahim-saliu/aws-bootcamp-cruddur-2023/blob/main/my_resources/Week2/backenddatahoneycombhomepage.png](https://github.com/Ibrahim-saliu/aws-bootcamp-cruddur-2023/blob/main/my_resources/Week2/backenddatahoneycombhomepage.png)


Side note : **Check out Glitch**

- Now, we are gonna create a span around our `home_activities.py`. We are going to start by acquiring a tracer by adding the following to our code:

```python
        # we add this to our home_activities.py
        from opentelemetry import trace

        tracer = trace.get_tracer("tracer.name.here")

```
- Then, we will create our span by adding the following to our code:

```python
        # this will be inside of our def run () function
        with tracer.start_as_current_span("home-activities-mock-data"):
```

- we can now refresh our backend page on port 4567 and see data in our honeycomb environment with 2 spans.

![https://github.com/Ibrahim-saliu/aws-bootcamp-cruddur-2023/blob/main/my_resources/Week2/backendspanmockdata.png](https://github.com/Ibrahim-saliu/aws-bootcamp-cruddur-2023/blob/main/my_resources/Week2/backendspanmockdata.png)

- Now, we can add attributes to our span, we will add the following to our `home_activities.py` code - see image 

```python
        span = trace.get_current_span()
        span.set_attribute("app.now", now.isoformat())     

        span.set_attribute("app.result_length", len(results))
```

- After adding the above codes, our code will look like this :

![https://github.com/Ibrahim-saliu/aws-bootcamp-cruddur-2023/blob/main/my_resources/Week2/spancode.png](https://github.com/Ibrahim-saliu/aws-bootcamp-cruddur-2023/blob/main/my_resources/Week2/spancode.png)


- we could now run a query in our honeycomb console by choosing `New-Query` and making `VISUALIZE=COUNT` and `GROUP BY=trace.trace_id`. We also will indicate that we only want data for the last 10 minutes and the hit Run Query.

![https://github.com/Ibrahim-saliu/aws-bootcamp-cruddur-2023/blob/main/my_resources/Week2/newqueryhonetcomb.png](https://github.com/Ibrahim-saliu/aws-bootcamp-cruddur-2023/blob/main/my_resources/Week2/newqueryhonetcomb.png)


- We can also click on any of the data point on our trace to view the trace. Observe that we can see our app.py span attribute in the span we created.



![https://github.com/Ibrahim-saliu/aws-bootcamp-cruddur-2023/blob/main/my_resources/Week2/app.py%20trace%20.png](https://github.com/Ibrahim-saliu/aws-bootcamp-cruddur-2023/blob/main/my_resources/Week2/app.py%20trace%20.png)



## CLOUD SECURITY VIDEO - Observability vs Monitoring
- Logging helps identify events in your workload
- Observability Pillars : Metrics, Traces, Logs
- Instrumentation : helps you create logs, metrics and traces e.g OTEL, AWS X-ray, AWS Cloudwatch agent


## XRAY instrumentation
- This is one of AWS instrumentation for observability. 
- An Xray Daemon is need for Xray API to work 
- We will need to install the `aws-xray-sdk`. More information can be found here [https://github.com/aws/aws-xray-sdk-python](https://github.com/aws/aws-xray-sdk-python)
- We will install the sdk by add it it to our `requirements.txt`

```sh
    pip install -r requirements.txt 
```

- The add the following middleware code to our `app.py`

```python
    from aws_xray_sdk.core import xray_recorder
    from aws_xray_sdk.ext.flask.middleware import XRayMiddleware

    xray_url = os.getenv("AWS_XRAY_URL")
    xray_recorder.configure(service='Cruddur', dynamic_naming=xray_url)
    XRayMiddleware(app, xray_recorder)
```

- We will create a new `xray.json` file

```json
    {
  "SamplingRule": {
      "RuleName": "Cruddur",
      "ResourceARN": "*",
      "Priority": 9000,
      "FixedRate": 0.1,
      "ReservoirSize": 5,
      "ServiceName": "Cruddur",
      "ServiceType": "*",
      "Host": "*",
      "HTTPMethod": "*",
      "URLPath": "*",
      "Version": 1
  }
}
```

- Next, we create a group 

```sh
    aws xray create-group \
   --group-name "Cruddur" \
   --filter-expression "service(\"backend-flask\")"
```

- We can now see our created xray group in the aws console. **Note - the new Xray UI in the console might be tricky and takes you to cloudwatch, so you want to ensure that you are still in the old UI to be able to view the logs**. WE CAN REACH THERE BY POINTING OUR BROWSER TO IN YOUR RESPECTIVE REGIONS - mine is US-EAST-1 [https://us-east-1.console.aws.amazon.com/xray/home?region=us-east-1#/service-map](https://us-east-1.console.aws.amazon.com/xray/home?region=us-east-1#/service-map)

![https://github.com/Ibrahim-saliu/aws-bootcamp-cruddur-2023/blob/main/my_resources/Week2/Xray%20Cruddur%20Group.png](https://github.com/Ibrahim-saliu/aws-bootcamp-cruddur-2023/blob/main/my_resources/Week2/Xray%20Cruddur%20Group.png)

- Next we will create a sampling rule : This determines how much information we want to see. We can create the sampling rule by executing:

```sh
    aws xray create-sampling-rule --cli-input-json file://aws/json/xray.json
```
- We can now see our rule

![https://github.com/Ibrahim-saliu/aws-bootcamp-cruddur-2023/blob/main/my_resources/Week2/xray%20sampling%20rule.png](https://github.com/Ibrahim-saliu/aws-bootcamp-cruddur-2023/blob/main/my_resources/Week2/xray%20sampling%20rule.png)


- next we will add the installation of the xray daemon in our docer compose file
```yml
    xray-daemon:
      image: "amazon/aws-xray-daemon"
      environment:
        AWS_ACCESS_KEY_ID: "${AWS_ACCESS_KEY_ID}"
        AWS_SECRET_ACCESS_KEY: "${AWS_SECRET_ACCESS_KEY}"
        AWS_REGION: "us-east-1"
      command:
        - "xray -o -b xray-daemon:2000"
      ports:
        - 2000:2000/udp

```
- we need to add the following `env_vars` to our backend in our docker compose file

```sh
    AWS_XRAY_URL: "*4567-${GITPOD_WORKSPACE_ID}.${GITPOD_WORKSPACE_CLUSTER_HOST}*"
    AWS_XRAY_DAEMON_ADDRESS: "xray-daemon:2000"
```

- we can spin up our application and we can check the logs of each of the container. Looking at the xray daemon container logs, we can see the following:

![https://github.com/Ibrahim-saliu/aws-bootcamp-cruddur-2023/blob/main/my_resources/Week2/xray%20daemon%20container%20logs.png](https://github.com/Ibrahim-saliu/aws-bootcamp-cruddur-2023/blob/main/my_resources/Week2/xray%20daemon%20container%20logs.png)

- we can now check or our data in the traces segment of the Xray console of aws

![https://github.com/Ibrahim-saliu/aws-bootcamp-cruddur-2023/blob/main/my_resources/Week2/traces%20in%20aws%20xray%20console.png](https://github.com/Ibrahim-saliu/aws-bootcamp-cruddur-2023/blob/main/my_resources/Week2/traces%20in%20aws%20xray%20console.png)



### Xray Subsegment Implementation
- The issue was that we were not able to generate traces sent to our our xray for the useractivities even though it seems to be working for our home activities.

- we used `xray_recorder.capture ('activities_show')` in our `app.py`
- we also closed the opened subsegment using `xray_recorder.end_segment` in our `user_activities.py`
- Finally, we were able to see the trace of our `mock_data` subsegment in the xray console.

![https://github.com/Ibrahim-saliu/aws-bootcamp-cruddur-2023/blob/main/my_resources/Week2/hitting%20useractivity%20xray.png](https://github.com/Ibrahim-saliu/aws-bootcamp-cruddur-2023/blob/main/my_resources/Week2/hitting%20useractivity%20xray.png)


![https://github.com/Ibrahim-saliu/aws-bootcamp-cruddur-2023/blob/main/my_resources/Week2/subsegment%20owrking.png](https://github.com/Ibrahim-saliu/aws-bootcamp-cruddur-2023/blob/main/my_resources/Week2/subsegment%20owrking.png)


## Instrumenting Cloud watch Logs
- Watchtower is a log handler for AWS cloudwatchlogs [https://pypi.org/project/watchtower/](https://pypi.org/project/watchtower/)

- Following the instructions in the watchtower documentation, we need to install the watchtower in our `requirements.txt` file located in our backend-flask project.

- Then we need to add the following to our `app.py` to configure logger using cloudwatch.

```python
    
# Configuring Logger to Use CloudWatch
LOGGER = logging.getLogger(__name__)
LOGGER.setLevel(logging.DEBUG)
console_handler = logging.StreamHandler()
cw_handler = watchtower.CloudWatchLogHandler(log_group='cruddur')
LOGGER.addHandler(console_handler)
LOGGER.addHandler(cw_handler)
LOGGER.info("some message")
@app.after_request
def after_request(response):
    timestamp = strftime('[%Y-%b-%d %H:%M]')
    LOGGER.error('%s %s %s %s %s %s', timestamp, request.remote_addr, request.method, request.scheme, request.full_path, response.status)
    return response  
```
- Further, we need to set some variables in our `docker-compose.yml` file and start our containers

```sh
    AWS_DEFAULT_REGION: "${AWS_DEFAULT_REGION}"
    AWS_ACCESS_KEY_ID: "${AWS_ACCESS_KEY_ID}"
    AWS_SECRET_ACCESS_KEY: "${AWS_SECRET_ACCESS_KEY}"
```
- When we go to our cloudwatch we can see our logs in the log groups

![https://github.com/Ibrahim-saliu/aws-bootcamp-cruddur-2023/blob/main/my_resources/Week2/cloudwatch_logs.png](https://github.com/Ibrahim-saliu/aws-bootcamp-cruddur-2023/blob/main/my_resources/Week2/cloudwatch_logs.png)

- To minimize spend, we will disable this in our `app.py`.


## Instrumenting Rollbar

- In our `requirments.txt` file, we ned to install `roolbar` and `blinker` and install it using `pip insall -r requirements.txt`

- Next, we will need to set our access token, this can be found on your rollbar for the flask SDK implementation you have chosen. 

```sh
    export ROLLBAR_ACCESS_TOKEN="8thisisnotrightye7gsd7h1c8efa34fab"
    gp env ROLLBAR_ACCESS_TOKEN="8thisisnotrightye7gsd7h1c8efa34fab"
```
- in our `app.py`, we nned to import rollbar
```python
    import os
    import rollbar
    import rollbar.contrib.flask
    from flask import got_request_exception
```

- Next we initialize rollbaras shown below in our `app.py`

```python
rollbar_access_token = os.getenv('ROLLBAR_ACCESS_TOKEN')
@app.before_first_request
def init_rollbar():
    """init rollbar module"""
    rollbar.init(
        # access token
        rollbar_access_token,
        # environment name
        'production',
        # server root directory, makes tracebacks prettier
        root=os.path.dirname(os.path.realpath(__file__)),
        # flask already sets up logging
        allow_logging_basic_config=False)

    # send exceptions from `app` to rollbar, using flask's signal system.
    got_request_exception.connect(rollbar.contrib.flask.report_exception, app)
```
```python
@app.route('/rollbar/test')
def rollbar_test():
    rollbar.report_message('Hello World!', 'warning')
    return "Hello World!" 
```

- Now, we can bring our container up and see if we can hit our `rollbar/test` endpoint

![https://github.com/Ibrahim-saliu/aws-bootcamp-cruddur-2023/blob/main/my_resources/Week2/rollbartest.png](https://github.com/Ibrahim-saliu/aws-bootcamp-cruddur-2023/blob/main/my_resources/Week2/rollbartest.png)

- Ensure that we have added our `ROLLBAR_ACCESS_TOKEN` docker compose as we might run into some error 

- No, after refreshing a couple of times, if we go to our Rollbar item, we can see items in our dashboard.

![https://github.com/Ibrahim-saliu/aws-bootcamp-cruddur-2023/blob/main/my_resources/Week2/rollbartestin%20Rollbar.png](https://github.com/Ibrahim-saliu/aws-bootcamp-cruddur-2023/blob/main/my_resources/Week2/rollbartestin%20Rollbar.png)


### Configure Rollbar to track affected user's information in case of error

- [https://docs.rollbar.com/docs/person-tracking](https://docs.rollbar.com/docs/person-tracking)




    
    
    
    


