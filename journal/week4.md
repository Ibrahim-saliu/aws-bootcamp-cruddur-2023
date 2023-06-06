# Week 4 — Postgres and RDS - Andrew Brown

- Firstly, it might help to already spin up an RDS instance because it takes a bit of time before it spins up

- 

```sh 
    aws rds create-db-instance \
  --db-instance-identifier cruddur-db-instance \
  --db-instance-class db.t3.micro \
  --engine postgres \
  --engine-version  14.6 \
  --master-username admin \
  --master-user-password blahblahblah \
  --allocated-storage 20 \
  --availability-zone us-east-1a \
  --backup-retention-period 0 \
  --port 5432 \
  --no-multi-az \
  --db-name cruddur \
  --storage-type gp2 \
  --publicly-accessible \
  --storage-encrypted \
  --enable-performance-insights \
  --performance-insights-retention-period 7 \
  --no-deletion-protection

```

- We need to ensure that our `gitpod.yaml` and our `compose.yml` has the neecessary configurations for the postgres. 

`gitpod.yml`
```yaml
    - name: postgres
      init: |
      curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc|sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/postgresql.gpg
      echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" |sudo tee  /etc/apt/sources.list.d/pgdg.list
      sudo apt update
      sudo apt install -y postgresql-client-13 libpq-dev 

```

`compose.yml`
```yaml
    db:
    image: postgres:13-alpine
    restart: always
    environment:
      - POSTGRES_USER=poskqreq
      - POSTGRES_PASSWORD=blahblah
    ports:
      - '5432:5432'
    volumes: 
      - db:/var/lib/postgresql/data

```


- Lets try to connect to Postgres DB client

```sh
    psql -U postgres --host localhost
    ## it will prompt you for a passowrd, it will be the password set in your compose.yml
```

- Here are some common psotgres commands 

```sql
\x on -- expanded display when looking at data
\q -- Quit PSQL
\l -- List all databases
\c database_name -- Connect to a specific database
\dt -- List all tables in the current database
\d table_name -- Describe a specific table
\du -- List all users and their roles
\dn -- List all schemas in the current database
CREATE DATABASE database_name; -- Create a new database
DROP DATABASE database_name; -- Delete a database
CREATE TABLE table_name (column1 datatype1, column2 datatype2, ...); -- Create a new table
DROP TABLE table_name; -- Delete a table
SELECT column1, column2, ... FROM table_name WHERE condition; -- Select data from a table
INSERT INTO table_name (column1, column2, ...) VALUES (value1, value2, ...); -- Insert data into a table
UPDATE table_name SET column1 = value1, column2 = value2, ... WHERE condition; -- Update data in a table
DELETE FROM table_name WHERE condition; -- Delete data from a table
```


- Some of the good practices when setting up a DB is to set the correct `encoding` and also `timezone`. How to solve these can be found in the `awscli` documentation.


- We can now create a `db` named `cruddur` using the `CREATE DATABASE cruddur;`

- We can list and see our `db` using `\l`

![]()


- we will create a folder in our `backend-flask` folder and create a new file named `schema.sql` in which we will continue to write into and update as we proceed.


- We will execute the  `schema.sql` as follows on our terminal. **We need to be in our backend dir!!**

```sh
    psql cruddur < db/schema.sql -h localhost -U postgres
```

![CREATE EXTENSION]()

- To ease our logging in experience, we can set an environmental variable with our login details and just call thet whenever we need to log into our db

```sh 
export CONNECTION_URL="postgresql://poskqreq:blahblah@localhost:5432/cruddur"

gitpod /workspace/aws-bootcamp-cruddur-2023/backend-flask (main) $ psql $CONNECTION_URL
psql (13.10 (Ubuntu 13.10-1.pgdg20.04+1))
Type "help" for help.

cruddur=#

```

### lets play with bash

- Create a folder `bin` in the `backend-flask` and create 3 files name `db-create`, `db-drop` and `db-schema-load`

- add the following to the `db-drop` and execute the script using `./db-drop`

```sh 
#! /usr/bin/bash

echo "db-drop"
NO_DB_CONNECTION_URL=$(sed 's/\/cruddur//g' <<<"$CONNECTION_URL")
psql $NO_DB_CONNECTION_URL -c "DROP DATABASE cruddur;"

```
![DROP DATABASE]()


- We can now create our `cruddur` db using the `db-create` scripts as follows

```sh 
#! /usr/bin/bash

echo "db-create"
NO_DB_CONNECTION_URL=$(sed 's/\/cruddur//g' <<<"$CONNECTION_URL")
psql $NO_DB_CONNECTION_URL -c "CREATE DATABASE cruddur;"

```
![CREATE DATABASE]()


- Add th following to the `db-schema-load` and execute as follows

```sh 
#! /usr/bin/bash

CYAN='\033[1;36m'
NO_COLOR='\033[0m'
LABEL="db-schema-load"
printf "${CYAN}== ${LABEL}${NO_COLOR}\n"

schema_path=$(realpath .)/db/schema.sql
echo "schema_path is: "$schema_path


if [ "$1" = "prod" ]; then
  echo "Running in PROD mode with PROD key"
  CON_URL=$PROD_CONNECTION_URL
else
  CON_URL=$CONNECTION_URL
fi

psql $CON_URL cruddur < $schema_path
```

![CREATE EXTENSION]()


- Next, we can create tables in our `schema.sql` by updating it with the following code and executing our `db-schema-load`

```sql
DROP TABLE IF EXISTS public.users;
DROP TABLE IF EXISTS public.activities;
  CREATE TABLE public.users (
  uuid UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  display_name text,
  handle text,
  cognito_user_id text,
  created_at TIMESTAMP default current_timestamp NOT NULL
);

  CREATE TABLE public.activities (
  uuid UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  message text NOT NULL,
  replies_count integer DEFAULT 0,
  reposts_count integer DEFAULT 0,
  likes_count integer DEFAULT 0,
  reply_to_activity_uuid integer,
  expires_at TIMESTAMP,
  created_at TIMESTAMP default current_timestamp NOT NULL
);

```

![CREATE TABLE]()


- Let's create a connection script `db-connect` to connect to our db

```sh
#! /usr/bin/bash

echo "connecting to db"

psql $CONNECTION_URL
```

![]()

- We can see our table using `\dt`

![TABLE LIST]()


- Create a `/bin/db-seed` file and add the following
```sh
#! /usr/bin/bash

CYAN='\033[1;36m'
NO_COLOR='\033[0m'
LABEL="db-seed"
printf "${CYAN}== ${LABEL}${NO_COLOR}\n"

seed_path=$(realpath .)/db/seed.sql
echo "seed_path is: "$seed_path


if [ "$1" = "prod" ]; then
  echo "Running in PROD mode with PROD key"
  CON_URL=$PROD_CONNECTION_URL
else
  CON_URL=$CONNECTION_URL
fi

psql $CON_URL cruddur < $seed_path
```

- Create a `/db/seed.sql` file and add the following to insert data into our created tables
```sql
-- this file was manually created
INSERT INTO public.users (display_name, handle, cognito_user_id)
VALUES
  ('Ibrahim Saliu', 'ibrahim' ,'MOCK'),
  ('Andrew Brown', 'andrewbrown' ,'MOCK'),
  ('Andrew Bayko', 'bayko' ,'MOCK');

INSERT INTO public.activities (user_uuid, message, expires_at)
VALUES
  (
    (SELECT uuid from public.users WHERE users.handle = 'andrewbrown' LIMIT 1),
    'This was imported as seed data!',
    current_timestamp + interval '10 day'
  )
```

- Next we load our schema and insert out tables by executing `./bin/db-schema-load` and `./bin/db-seed`

![INSERT TABLE]()


- With `\x on` executed to enable Expanded display, we can describe our tables 
```sql
select * from activities;
```

![DESCRIBE TABLE]()

![DESCRIBE TABLE 2]()


- Next, to know the active connections/sessions to our db, we will create a newscript `bin/db-sessions`
```sh
#! /usr/bin/bash

CYAN='\033[1;36m'
NO_COLOR='\033[0m'
LABEL="db-sessions"
printf "${CYAN}== ${LABEL}${NO_COLOR}\n"

if [ "$1" = "prod" ]; then
  echo "Running in PROD mode with PROD key"
  URL=$PROD_CONNECTION_URL
else
  URL=$CONNECTION_URL
fi

NO_DB_URL=$(sed 's/\/cruddur//g' <<<"$URL")
psql $NO_DB_URL -c "select pid as process_id, \
       usename as user,  \
       datname as db, \
       client_addr, \
       application_name as app,\
       state \
from pg_stat_activity;"
```

![ACTIVE CONNECTIONS]()

- We can automate our interaction and setup with the db by creating a `db-setup` script with the following content 
```sh 
#! /usr/bin/bash


CYAN='\033[1;36m'
NO_COLOR='\033[0m'
LABEL="db-setup"
printf "${CYAN}== ${LABEL}${NO_COLOR}\n"

bin_path=$(realpath .)/bin

source "$bin_path/db-drop"
source "$bin_path/db-create"
source "$bin_path/db-schema-load"
source "$bin_path/db-seed"
```

![DB SETUP]()

- Next, we will install the driver for our PostgreSQL , we need to add `psycopg[binary]` and `psycopg[pool]` to our `requirements.txt`
[https://www.psycopg.org/psycopg3/docs/basic/install.html](https://www.psycopg.org/psycopg3/docs/basic/install.html)

- We create a new file `db.py` in our `backend-flask/lib` folder
```python
from psycopg_pool import ConnectionPool
import os


def query_wrap_object(template):
  sql = f"""
  (SELECT COALESCE(row_to_json(object_row),'{{}}'::json) FROM (
  {template}
  ) object_row);
  """
  return sql

def query_wrap_array(template):
  sql = f"""
  (SELECT COALESCE(array_to_json(array_agg(row_to_json(array_row))),'[]'::json) FROM (
  {template}
  ) array_row);
  """
  return sql

connection_url = os.getenv("CONNECTION_URL")
pool = ConnectionPool(connection_url)


```
- We need to add `CONNECTION_URL` in our `docker compose.yml` file

- `home_activities.py` should be updated as follows :

```python
from datetime import datetime, timedelta, timezone
from opentelemetry import trace
import logging

from lib.db import pool, query_wrap_array

tracer = trace.get_tracer("home_activities")


class HomeActivities:
  def run(cognito_user_id=None):
    #logger.info("HomeActivities")
    with tracer.start_as_current_span("home-activities-mock-data"):
      span = trace.get_current_span()
      now = datetime.now(timezone.utc).astimezone()
      span.set_attribute("app.now", now.isoformat())
   
      sql = query_wrap_array("""
        SELECT
          activities.uuid,
          users.display_name,
          users.handle,
          activities.message,
          activities.replies_count,
          activities.reposts_count,
          activities.likes_count,
          activities.reply_to_activity_uuid,
          activities.expires_at,
          activities.created_at
        FROM public.activities
        LEFT JOIN public.users ON users.uuid = activities.user_uuid
        ORDER BY activities.created_at DESC
      """)
      print("SQL-----------------")
      print(sql)
      print("SQL-----------------")
      with pool.connection() as conn:
        with conn.cursor() as cur:
          cur.execute(sql)
                # this will return a tuple
                # the first field being the data
          json = cur.fetchone()
      print("FFFFFFFFFFFFXXXXXXXX")
      print("XXXXXXXXXXXX")
      print(json[0])
      return json[0]
```


- NEXT, we can try to connect to our RDS in aws,  using the `psql PROD_CONNECTION_URL`. its normal to run into an error as we need to update security group's inbound traffic rule. We will add allow traffic for our gitpod IP . we can user `curl  ifconfig.me` to get the IP address
After updating the security rule, we can connect 

![PROD_CONNECTION]()


![PROD_CONNECT_TABLE]()

- There is a limitation in the sense that everytime, we launch our gitpod environment, the IP will change, so we can fix that by using the script below to update our security groups accordingly
```sh
export DB_SG_ID="sg-0678454548524"
gp env DB_SG_ID="sg-0678454548524"
export DB_SG_RULE_ID="sgr-gefyehged673763fe"
gp env DB_SG_RULE_ID="sgr-gefyehged673763fe"
#DB_SG_ID = security group ID
#DB_SG_RULE_ID = security group rule ID


aws ec2 modify-security-group-rules \
    --group-id $DB_SG_ID \
    --security-group-rules "SecurityGroupRuleId=$DB_SG_RULE_ID,SecurityGroupRule={Description=GITPOD,IpProtocol=tcp,FromPort=5432,ToPort=5432,CidrIpv4=$GITPOD_IP/32}"
```

#### COGNITO POST CONFRIMATION LAMBDA

- We need to create a `lambda function` in our AWS console 

![CREATE_LAMBDA]()


- Paste teh following code in the created function:

```python
    import json
import psycopg2

def lambda_handler(event, context):
    user = event['request']['userAttributes']
    print("********* User Attributes**********")
    print(user)
    user_display_name   = user["name"]
    user_email          = user["email"]
    user_handle         = user["preferred_username"]
    user_cognito_id     = user["sub"]

    try:
        conn = psycopg2.connect(os.getenv("CONNECTION_URL"))
        cur = conn.cursor()

        sql = f"""
            INSERT INTO users (
                display_name, 
                handle,
                email,
                cognito_user_id
                ) 
            VALUES (
                {user_display_name}, 
                {user_email},
                {user_handle},
                {user_cognito_id}
                )"
        """
        cur.execute(sql)
        conn.commit() 

    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
        
    finally:
        if conn is not None:
            cur.close()
            conn.close()
            print('Database connection closed.')

    return event
            
```
- ADD AN `ENV_VAR` for `PROD_CONNECTION_URL`

- Next, we need to add a layer using custom 
[https://github.com/jetbridge/psycopg2-lambda-layer](https://github.com/jetbridge/psycopg2-lambda-layer)

- We need to add a lambda trigger in cognito

![ADD LAMBDA TRIGGER]


- We need to add our function in the same Security group as our RDS and attach a policy that will allow our VPC to be linked with out lambda function.

- We can now sign up, check our logs in cloud watch and log into our PROD DB to see our user data

![USER DATA]()


#### Creating Activities 

