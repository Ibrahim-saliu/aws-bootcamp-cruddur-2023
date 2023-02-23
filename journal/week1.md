# Week 1 — App Containerization
### James Spurin/ Edith Puclla
--------------------------
why is container important / whay are we containerizing our applicatons
- more portable , less configuration
- closer to the end environmnet you will deploy later on into
- you dont destroy your native enviornment
- keeps your working enviornmnet consistent
- can run application on various environments


** linux server.io --- must checkout ** 

- Docker hub is a regisrty for docker to host container images
    - you can pull images and you can push images 
    - Free to use
    - ** check out Open Conatiner initiative **
    - ** check out jfrog **


## Insructions
- Created a Dockerfile in the backend directory with the content below

```yml
        FROM python:3.10-slim-buster

        WORKDIR /backend-flask

        COPY requirements.txt requirements.txt
        RUN pip3 install -r requirements.txt

        COPY . .

        ENV FLASK_ENV=development

        EXPOSE ${PORT}
        CMD [ "python3", "-m" , "flask", "run", "--host=0.0.0.0", "--port=4567"]
```   
    
    
** Note ** : In the doker hub registry, there is a scratch images which can be used to build an images from scratch. an example is the Debian image built from scratch. This is referred to as "no- op". 
    - EACH command in a dockerfile creates a layer. 
    - Union File system : One merged layer
        - ** Check out some dockerfile and try to understand what they do and where things come from **

### CMD section -- to run locally
- This is used to run flask, you can test on the command line
        cd <workdir>/backend-flask
        pip install -r requirments.txt
        
        # this is running flask "-m=module", binding to 0.0.0.0(everything address), start on 4567
        python3 -m flask run --host=0.0.0.0 --port=4567
        
unlock the port 4567 in the port section.
    
everytime you refresh the page, you can see a corrsponding request link in the terminal. this shows the server is working and receiving request links 

** you may want to add **

The exercise shows the need for docker has it would set all the variables essentail for making our app run seuccessfully. The error we encountered is because we are yet to set the enviornment variable :`FRONTEND_URL and BACKEND_URL` in our `app.py`

We could solve our issue by setting the app `env_vars` in gitpos environment to `"*"`

        export FRONTEND_URL="*"
        export BACKEND_URL="*"


## Building our Docker Image from the DockerFile
- unset your set `env_vars`
- `cd` into the project dir `/workspace/aws-bootcamp-cruddur-2023`
        
        # Docker, build the image in the /backend-flask/Dockerfile using the tag (-t) backend-flask
        
        docker build -t backend-flask ./backend-flask
        
        # we can now check our image using: 
        
        docker images 
        
### Run our container 
Observe your port is indicested as not filled
        
        docker run -p 4567:4567 backend-flask
        
Observe your port is now indicating as filled
    
If ypu go to the browser, you should see a `404` error

Again, why we get the error is because we are yet to set our `env_vars` (remember we deleted it)

we need to set while we run the run the container but first, we can inspect further by looking at the logs which an be found here :


Another option would be to use the attache shell option to be able to check if our `env_vars` is set.



Now, that we are sure that our `env_vars` are missing, we can set it using 

        docker run -p 4567:4567 -e FRONTEND_URL="*" -e BACKEND_URL="*" backend-flask
        
        
### FrontEnd Configuration 

- `cd` to your project dir and `cd` into frontend-react-js

- run `npm install`

- create a `Dockerfile` using the contents below:

```yml
        FROM node:16.18

        ENV PORT=3000

        COPY . /frontend-react-js
        WORKDIR /frontend-react-js
        RUN npm install
        EXPOSE ${PORT}
        CMD ["npm", "start"]
```
        
- create a `compose.yml` file as shown below to run multiple containers at the same time 

```yml
  
        version: "3.8"
        services:
          backend-flask:
            environment:
              FRONTEND_URL: "https://3000-${GITPOD_WORKSPACE_ID}.${GITPOD_WORKSPACE_CLUSTER_HOST}"
              BACKEND_URL: "https://4567-${GITPOD_WORKSPACE_ID}.${GITPOD_WORKSPACE_CLUSTER_HOST}"
            build: ./backend-flask
            ports:
              - "4567:4567"
            volumes:
              - ./backend-flask:/backend-flask
          frontend-react-js:
            environment:
              REACT_APP_BACKEND_URL: "https://4567-${GITPOD_WORKSPACE_ID}.${GITPOD_WORKSPACE_CLUSTER_HOST}"
            build: ./frontend-react-js
            ports:
              - "3000:3000"
            volumes:
              - ./frontend-react-js:/frontend-react-js

        # the name flag is a hack to change the default prepend folder
        # name when outputting the image names
        networks: 
          internal-network:
            driver: bridge
            name: cruddur
```

- execute `docker compose up` or use the GUI in VS code to execute `docker compose up`

- notice the port 3000 is now visible in your port section. also, youb can see the containers also in the containers section of the vscode. 

- ensure the port 3000 is unlocked and click on the link associated with the 3000. You should now see the cruddur homepage:


### Spend Consideration -- Chirag week1 videos
- Gitpod - 50 hrs, 4 cores, 8gb ram and 30 gb storage
    - do not open multiple envs at the same time.
    
- Code spaces - github
    - 60 hrs - 2core, 8gb ram and 15 gb storage
    
- cloud9
    - using ec2, free if t2.micro
    


### Security Consideration -- Ashish week1 videos 
- Docker and Host confg

- Securing images

- Secret managements

- Applicatoin security

- Data Security

- Monitoring Conatiners

- Compliance Framework

- SECURING YOUR DOCKER COMPOSE
    - identify snyk opensource security
    - use a secret manager e.g AWS secret manager, AWS Key vault, Hashicorp vault
    - inspect image -- AWS inspector, Clair
    - use snyk for image vulnearbility scanning
            
            # check the snyk cli documentation
            snyk container test image_name
            
    
    
### Creating a new notification feature (Backend and Frontend)
#### Uisng the OPENAPI extension on gitpod

- On launching my gitpod workspace and having all extensions loaded on the side bar, I was able to click on the OPENAPI exetension and already see the APIs without any issues once I had already open the `openapi-3.0.yml` file
        
- OPENAPI : It is standard for deifining openapi

- Following Andrew Brown's video, I wa able to set up a new readme.io free account and created a project named `awsbootcamp`, imported the API and created a documentation page. I executed the command below

```sh

            npm install rdme@latest -gnpm install rdme@latest -g
            rdme openapi --version=v1.0\
            --key=rdme_xn8s9hc7775b4d5aafbe22a640315e9768fe566dd5388bf914e89d8045bc3a5983dc9c
        
            # to update my OPENAPI definition, I will execute 
            rdme openapi backend-flask/openapi-3.0.yml --key=<key> --id=63f522f08c61eb0072a0f665
```  

### MAIN Action
- Bring up the application using `docker compose up`
- make sure the ports are visible and unlocked(made public)
- Observe the port 3000 with the state "not served" - this is because the `npm install` required for the front end was not done. You can chec this by checking the log files of the container which states that the react-scripts were not found


![]()

1[]()


- run a `docker compose down` to bring down and remove the running containers
- move into your frontend-react-js directory and execute `npm install`
- run a `docker compose up`
- make sure the ports are visible and unlocked(made public)
- you can now click on the browser link associated with port 3000 and see the CRUDDUR homepage

- sign up using your desired name, email and password. 
- enter the email and an hardcoded `1234` OTP. 
- you can now see your home page on the CRUDDUR app.

![]()



##### we will now add an emdpoint to our app's backend
- open the `openapi-3.0.yml` go to openapi 
- Check out the openAPI notification documentation page

- Use the OPENAPI extension to create new link called `/api/activities/notifications`. This will creata new section in the `openapi-30.yml` file as shown

```yml      
        /api/activities/notifications: 
          get:
            description: 'Return a feed of activity for all that I follow'
            tags:
              - activities
            parameters: []
            responses:
              '200':
                description: OK
                content:
                  application/json:
                    schema:
                      type: array
                      items: 
                      $ref: '#/components/schemas/Activity'
```



- in the backend-flask dir, open the `app.py` and add the following

            @app.route("/api/activities/notifications", methods=['GET'])
            def data_home():
                data = NotificationsActivities.run()
                return data, 200 

- create a new file in the dir called `notification_activities.py`
- populate the file with following :

```python
        `from datetime import datetime, timedelta, timezone
        class NotificationsActivities:
            def run():
                now = datetime.now(timezone.utc).astimezone()
                results = [{
                  'uuid': '68f126b0-1ceb-4a33-88be-d90fa7109eee',
                  'handle':  'Ibrahim Saliu',
                  'message': 'I am loving the aws bootcamp!',
                  'created_at': (now - timedelta(days=2)).isoformat(),
                  'expires_at': (now + timedelta(days=5)).isoformat(),
                  'likes_count': 5,
                  'replies_count': 1,
                  'reposts_count': 0,
                  'replies': [{
                    'uuid': '26e12864-1c26-5c3a-9658-97a10f8fea67',
                    'reply_to_activity_uuid': '68f126b0-1ceb-4a33-88be-d90fa7109eee',
                    'handle':  'Worf',
                    'message': 'This post has no honor!',
                    'likes_count': 0,
                    'replies_count': 0,
                    'reposts_count': 0,
                    'created_at': (now - timedelta(days=2)).isoformat()
                  }],
                },
                ]
                return results`
```
                
- update the improt section of your app.py to include `notifications_activities`
            
            from services.notifications_activities import *

- Spin up the applications and click the browser link. You will observer that the notification endpoint is working

![]()



##### we will now add an emdpoint to our app's backend

- open up th `APP.js` file and update it with 
            
            import NotificationActivityPage from './pages/NotificationActivityPage';
            
            
            {
            path: "/notifications",
            element: <NotificationActivityPage />
            },


- create 2 new files `NotficationActivityPage.js` and `NotificationActivityPage.css`

- Copy the content of the `HomeFeedPage.js` and update it to fit the neotification requirements

- Go to the `DesktopNavigation.js` file and check if it contains entry for the notification.

- Reload your (frontend) homepage in the browser and you can see activity in the Notification bar.


![]()



## Dynamo DB Postgres vs Docker

- DynamoDB local is an emulation of running dynamoDB on your machine. You can interact with it and its alot faster.

    From [https://github.com/100DaysOfCloud/challenge-dynamodb-local](https://github.com/100DaysOfCloud/challenge-dynamodb-local)

```sh
        aws dynamodb create-table     --endpoint-url http://localhost:8000     --table-name Music     --attribute-definitions         AttributeName=Artist,AttributeType=S         AttributeName=SongTitle,AttributeType=S     --key-schema AttributeName=Artist,KeyType=HASH AttributeName=SongTitle,KeyType=RANGE     --provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1     --table-class STANDARD
        3  aws dynamodb put-item     --endpoint-url http://localhost:8000     --table-name Music     --item         '{"Artist": {"S": "No One You Know"}, "SongTitle": {"S": "Call Me Today"}, "AlbumTitle": {"S": "Somewhat Famous"}}'     --return-consumed-capacity TOTAL  
        4  aws dynamodb list-tables --endpoint-url http://localhost:8000
        5  aws dynamodb scan --table-name Music --query "Items" --endpoint-url http://localhost:8000
```






#### Best Practices when asking for help
- Add enough and clear details
- show proof of effort in understanding and tackling said issue
- provide affected code (back tick your code - use mark up language principles)
- use [gist.github.com](gist.github.com) for large blocks of codes
- You can also use your repo
- ALways consider your team and collaboration potentials and efforts
- You can use the inspect function on your browser -- very helpful
- Use breakpoints in your code



### STRETCH ASSIGNMENTS

#### Run the dockerfile CMD as an external script
- With little bash scripting knowledge, I googled some examples and was able to create a bash script named `docker_bash.sh` which I used to create and run containers

### Push and tag an image to DockerHub
- First I tagged the image using the command below 
```sh
    docker tag frontend-react-js:latest oriade/aws_bootcamp:latest
```
- Logged into DockerHub
- Created a new Repo

![]()
- connected to my repo via gitpod using the docker exetnsion. I provided my dockerHub user id and an access key generated from my account.
- The connection could have also been done using `docker login -U oriade` at the terminal.

- Then I pushed my image on the terminal using `docker image push` and I could see my pused image in the docker extension panel.

![]()

![]()


### Install Docker on your localmachine and get the same containers running

- I had already installed docker on my machine 
- I made a clone of my github repo to have the correct documents
```sh
    git clone https://github.com/Ibrahim-saliu/aws-bootcamp-cruddur-2023.git
```
- i did a list of existing images on my local machine 

![]()
- Then I buit my images

![]()
- I did a new image listing 

![]()
- I ran my containers from the built images passing the env variables

![]()







