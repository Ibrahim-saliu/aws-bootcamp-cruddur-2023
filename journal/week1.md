# Week 1 — App Containerization

## NOTES During the LiveStream

### James Spurin/ Edith Puclla
-------------------------------
Why is container important / why are we containerizing our applicatons
- It is more portable and requires less configuration
- It is closer to the end environmnet we will deploy later on into
- We dont need to risk destroying our native enviornment
- Keeps our working enviornmnet consistent
- We can run application on various environments


#### Some container registry example
** linux server.io --- must checkout ** 

- Docker hub is a regisrty for docker to host container images
    - we can pull images and you can push images 
    - Free to use
    - Some things to note
        ** need to check out Open Conatiner initiative **
        ** need to check out jfrog **


## Insructions
- Create a Dockerfile in the backend directory with the content below

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
    
    
** Note ** : In the doker hub registry, there is a scratch images which can be used to build images from scratch. An example is the Debian image built from scratch. This is referred to as **no-op**. 
- EACH `command` in a dockerfile creates a layer. 
- Union File system : One merged layer
- **TODO** = Check out some dockerfile and try to understand what they do and where things come from.

### CMD section -- to run locally
- This is used to run flask, you can test on the command line
```sh
        cd <workdir>/backend-flask
        pip install -r requirments.txt
        
        # this is running flask "-m=module", binding to 0.0.0.0(everything address), start on 4567
        python3 -m flask run --host=0.0.0.0 --port=4567
 ```
 
- Go to th Port sections and unlock the port 4567 in the port section.

    
- Everytime you refresh the page, you can see a corrsponding request link in the terminal. this shows the server is working and receiving request links 

![](https://github.com/Ibrahim-saliu/aws-bootcamp-cruddur-2023/blob/main/my_resources/week1/requests%20to%20server.png)

![](https://github.com/Ibrahim-saliu/aws-bootcamp-cruddur-2023/blob/main/my_resources/week1/requests%20to%20server2%20.png)

This exercise shows the need for docker has it would set all the variables essential for making our app run seccessfully. The error we encountered is because we are yet to set the enviornment variable :`FRONTEND_URL and BACKEND_URL` in our `app.py`

We could solve our issue by setting the app `env_vars` in gitpos environment to `"*"`

```sh
        export FRONTEND_URL="*"
        export BACKEND_URL="*"
```

![](https://github.com/Ibrahim-saliu/aws-bootcamp-cruddur-2023/blob/main/my_resources/week1/page_working_aftersetting_env.png)

## Building our Docker Image from the DockerFile
- Unset your set `env_vars`

- `cd` into the project dir `/workspace/aws-bootcamp-cruddur-2023`

```sh       
        # Docker, build the image in the /backend-flask/Dockerfile using the tag (-t) backend-flask
        
        docker build -t backend-flask ./backend-flask
```

![](https://github.com/Ibrahim-saliu/aws-bootcamp-cruddur-2023/blob/main/my_resources/week1/dockerbuild1.png)


```sh        
        # we can now check our image using: 
        
        docker images 
```
    
![](https://github.com/Ibrahim-saliu/aws-bootcamp-cruddur-2023/blob/main/my_resources/week1/docker_images.png)


### Run our container 
- Observe your port is indicated as not filled

![](https://github.com/Ibrahim-saliu/aws-bootcamp-cruddur-2023/blob/main/my_resources/week1/container_running_portempty.png)


```sh
        docker run -p 4567:4567 backend-flask
```        

- Observe your port is now indicating as filled
    
- If you go to the browser, you should see a `404` error - that is good

![](https://github.com/Ibrahim-saliu/aws-bootcamp-cruddur-2023/blob/main/my_resources/week1/unlocking_port.png)

- Again, why we get the error is because we are yet to set our `env_vars` (remember we deleted it)

- We need to set then while we run the container but first, we can inspect further by looking at the logs which an be found here :

![](https://github.com/Ibrahim-saliu/aws-bootcamp-cruddur-2023/blob/main/my_resources/week1/view_logs1.png)


Another option would be to use the attache shell option to be able to check if our `env_vars` is set.


![](https://github.com/Ibrahim-saliu/aws-bootcamp-cruddur-2023/blob/main/my_resources/week1/view_logs2.png)



Now, that we are sure that our `env_vars` are missing, we can set it using 

```sh
        docker run -p 4567:4567 -e FRONTEND_URL="*" -e BACKEND_URL="*" backend-flask
```      
        
        
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

![](https://github.com/Ibrahim-saliu/aws-bootcamp-cruddur-2023/blob/main/my_resources/week1/dockercomposeup_GUI.png)

- notice the port 3000 is now visible in your port section. also, you can see the containers also in the containers section of the vscode. 

- ensure the port 3000 is unlocked and click on the link associated with the 3000. You should now see the cruddur homepage:

![](https://github.com/Ibrahim-saliu/aws-bootcamp-cruddur-2023/blob/main/my_resources/week1/cruddur_homepage.png)


### Spend Consideration -- Chirag week1 videos
- Gitpod - 50 hrs, 4 cores, 8gb ram and 30 gb storage
    - do not open multiple envs at the same time.
    
- Code spaces - github
    - 60 hrs - 2core, 8gb ram and 15 gb storage
    
- Cloud9
    - using ec2, free if t2.micro
    


### Security Consideration -- Ashish week1 videos 
- Docker and Host confg

- Securing images

- Secret managements

- Applicatoin security

- Data Security

- Monitoring Conatiners

- Compliance Framework

- Securing your docker-compose file

    - identify snyk opensource security
    - use a secret manager e.g AWS secret manager, AWS Key vault, Hashicorp vault
    - inspect image -- AWS inspector, Clair
    - use snyk for image vulnearbility scanning
            
    ```sh        
    # check the snyk cli documentation
            snyk container test image_name
            
    ```
    
    
### Creating a new notification feature (Backend and Frontend)

#### Uisng the OPENAPI extension on gitpod

- On launching my gitpod workspace and having all extensions loaded on the side bar, I was able to click on the OPENAPI exetension and already see the APIs without any issues once I had already open the `openapi-3.0.yml` file
        
- OPENAPI : It is standard for defining openapi (a specification for a machine-readable interface definition language for describing, producing, consuming and visualizing RESTful web services)

- Following Andrew Brown's video, I was able to set up a new readme.io free account and created a project named `awsbootcamp`, imported the API and created a documentation page. I executed the command below

```sh

            npm install rdme@latest -gnpm install rdme@latest -g
            rdme openapi --version=v1.0\
            --key=rdme_xn8s9hc7775b4d5aafbe22a640315e9768fe566dd5388bf914e89d8045bc3a5983dc9c
        
            # to update my OPENAPI definition, I will execute 
            rdme openapi backend-flask/openapi-3.0.yml --key=<key> --id=63f522f08c61eb0072a0f665
```  

![](https://github.com/Ibrahim-saliu/aws-bootcamp-cruddur-2023/blob/main/my_resources/week1/Readme.io_project_apidocpage.png)

### MAIN Action
- Bring up the application using `docker compose up`
- make sure the ports are visible and unlocked(made public)
- Observe the port 3000 with the state "not served" - this is because the `npm install` required for the front end was not done. 

![](https://github.com/Ibrahim-saliu/aws-bootcamp-cruddur-2023/blob/main/my_resources/week1/front-end%20error%20npm%20install.png)


You can check this by checking the log files of the container which states that the react-scripts were not found

![](https://github.com/Ibrahim-saliu/aws-bootcamp-cruddur-2023/blob/main/my_resources/week1/npm%20error%20log%202.png)


- run a `docker compose down` to bring down and remove the running containers
- move into your frontend-react-js directory and execute `npm install`
- run a `docker compose up`
- make sure the ports are visible and unlocked(made public)
- you can now click on the browser link associated with port 3000 and see the CRUDDUR homepage

![](https://github.com/Ibrahim-saliu/aws-bootcamp-cruddur-2023/blob/main/my_resources/week1/cruddur_homepage.png)

- sign up using your desired name, email and password. 
- enter the email and an hardcoded `1234` OTP. 
- you can now see your home page on the CRUDDUR app.

![](https://github.com/Ibrahim-saliu/aws-bootcamp-cruddur-2023/blob/main/my_resources/week1/cruddur_homepageafterijoining.png)



#### We will now add an emdpoint to our app's backend
- open the `openapi-3.0.yml` go to openapi 
- Check out the openAPI notification documentation page

- Use the OPENAPI extension to create new link called `/api/activities/notifications`. This will creat new section in the `openapi-30.yml` file as shown

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



- In the backend-flask dir, open the `app.py` and add the following

 ```python         
            @app.route("/api/activities/notifications", methods=['GET'])
            def data_home():
                data = NotificationsActivities.run()
                return data, 200 
```

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
                
- update the import section of your `app.py` to include `notifications_activities`
            
```python
        from services.notifications_activities import *
```

- Spin up the applications and click the browser link. You will observer that the notification endpoint is working

![](https://github.com/Ibrahim-saliu/aws-bootcamp-cruddur-2023/blob/main/my_resources/week1/notification%20endpoint.png)



##### we will now add an endpoint to our app's frontend

- open up th `APP.js` file and update it with 
            
```js
            import NotificationActivityPage from './pages/NotificationActivityPage';
            {
            path: "/notifications",
            element: <NotificationActivityPage />
            }
```

- create 2 new files `NotficationActivityPage.js` and `NotificationActivityPage.css`

- Copy the content of the `HomeFeedPage.js` and update it to fit the neotification requirements

- Go to the `DesktopNavigation.js` file and check if it contains entry for the notification.

- Reload your (frontend) homepage in the browser and you can see activity in the Notification bar.


![](https://github.com/Ibrahim-saliu/aws-bootcamp-cruddur-2023/blob/main/my_resources/week1/notification_works%20.png)



## Dynamo DB Postgres vs Docker

- DynamoDB local is an emulation of running dynamoDB on your machine. You can interact with it and its alot faster.

    From [https://github.com/100DaysOfCloud/challenge-dynamodb-local](https://github.com/100DaysOfCloud/challenge-dynamodb-local)

```sh
        aws dynamodb create-table     --endpoint-url http://localhost:8000     --table-name Music     --attribute-definitions         AttributeName=Artist,AttributeType=S         AttributeName=SongTitle,AttributeType=S     --key-schema AttributeName=Artist,KeyType=HASH AttributeName=SongTitle,KeyType=RANGE     --provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1     --table-class STANDARD
        
        aws dynamodb put-item     --endpoint-url http://localhost:8000     --table-name Music     --item         '{"Artist": {"S": "No One You Know"}, "SongTitle": {"S": "Call Me Today"}, "AlbumTitle": {"S": "Somewhat Famous"}}'     --return-consumed-capacity TOTAL  
        
        aws dynamodb list-tables --endpoint-url http://localhost:8000
        
        aws dynamodb scan --table-name Music --query "Items" --endpoint-url http://localhost:8000
```




## Best Practices when asking for help
- Add enough and clear details
- show proof of effort in understanding and tackling said issue
- Provide affected code block (back tick your code - use mark up language principles)
- Use [gist.github.com](gist.github.com) for large blocks of codes
- You can also use your repo for reference purposes
- Always consider your team, collaboration potentials and efforts
- You can use the inspect function on your browser -- very helpful
- Use breakpoints in your code



### STRETCH ASSIGNMENTS

#### Run the dockerfile CMD as an external script
- With little bash scripting knowledge, I googled some examples and was able to create a bash script named [docker_bash.sh](https://github.com/Ibrahim-saliu/aws-bootcamp-cruddur-2023/blob/main/docker_bash.sh) which I used to create and run containers.


### Push and tag an image to DockerHub
- First I tagged the image using the command below 

```sh
    docker tag frontend-react-js:latest oriade/aws_bootcamp:latest
```

- Logged into DockerHub

- Created a new Repo

![](https://github.com/Ibrahim-saliu/aws-bootcamp-cruddur-2023/blob/main/my_resources/week1/dockerhub_repo.png)

- connected to my repo via gitpod using the docker exetnsion. I provided my dockerHub user id and an access key generated from my account.

- The connection could have also been done using `docker login -U oriade` at the terminal.

- Then I pushed my image on the terminal using `docker image push` and I could see my pused image in the docker extension panel.

![](https://github.com/Ibrahim-saliu/aws-bootcamp-cruddur-2023/blob/main/my_resources/week1/pushingmy%20image.png)

![](https://github.com/Ibrahim-saliu/aws-bootcamp-cruddur-2023/blob/main/my_resources/week1/pushingmy%20image2.png)

![](https://github.com/Ibrahim-saliu/aws-bootcamp-cruddur-2023/blob/main/my_resources/week1/pushingmy%20image3.png)


### Install Docker on your localmachine and get the same containers running

- I had already installed docker on my machine 
- I made a clone of my github repo to have the correct documents

```sh
    git clone https://github.com/Ibrahim-saliu/aws-bootcamp-cruddur-2023.git
```

![](https://github.com/Ibrahim-saliu/aws-bootcamp-cruddur-2023/blob/main/my_resources/week1/cloneddir.png)

- i did a list of existing images on my local machine 

![](https://github.com/Ibrahim-saliu/aws-bootcamp-cruddur-2023/blob/main/my_resources/week1/list%20of%20existing%20images.png)
- Then I buit my images

![](https://github.com/Ibrahim-saliu/aws-bootcamp-cruddur-2023/blob/main/my_resources/week1/buildingfrontend%20and%20backend.png)
- I did a new image listing 

![](https://github.com/Ibrahim-saliu/aws-bootcamp-cruddur-2023/blob/main/my_resources/week1/new%20docker%20image%20listing.png)
- I ran my containers from the built images passing the env variables

![](https://github.com/Ibrahim-saliu/aws-bootcamp-cruddur-2023/blob/main/my_resources/week1/cruddur_running-on%20my%20local%20host.png)


#### Launch an EC2 instance that has docker installed, and pull a container to demonstrate you can run your own docker processes

- I launched a new EC2 instance called aws_bootcamp (Linux t2.micro). I created a key pair whic which I was able to connect using the OpenSSH client on my local machine

```sh

    C:\Users\Ibrahim S Saliu\Downloads>ssh -i "aws_bootcamp_hostkey.pem" ec2-user@ec2-100-25-118-118.compute-1.amazonaws.com
The authenticity of host 'ec2-100-25-118-118.compute-1.amazonaws.com (100.25.118.118)' can't be established.
ED25519 key fingerprint is SHA256:BhW/9ll4HdIL2ULngSgkJhk8fnFPUVrIr4BT0nxOza4.
This key is not known by any other names
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added 'ec2-100-25-118-118.compute-1.amazonaws.com' (ED25519) to the list of known hosts.

       __|  __|_  )
       _|  (     /   Amazon Linux 2 AMI
      ___|\___|___|

https://aws.amazon.com/amazon-linux-2/
No packages needed for security; 5 packages available
Run "sudo yum update" to apply all updates.
[root@ip-100-11-xx-000 ~]$
```

- I ran docker command but it was not installed yet, so I installed docker on it using the Amazon Linux 2 using the information found here: [https://www.cyberciti.biz/faq/how-to-install-docker-on-amazon-linux-2/](https://www.cyberciti.biz/faq/how-to-install-docker-on-amazon-linux-2/).

```sh
    sudo yum update
    sudo yum search docker
    sudo yum info docker
    sudo yum install docker
```

- Now, I have docker running on my EC2 machine

```sh
[root@ip-100-11-xx-000 ~]$ docker

Usage:  docker [OPTIONS] COMMAND

A self-sufficient runtime for containers

Options:
      --config string      Location of client config files (default "/home/root/.docker")
  -c, --context string     Name of the context to use to connect to the daemon (overrides DOCKER_HOST env var and default context set with "docker
                           context use")
  -D, --debug              Enable debug mode
  -H, --host list          Daemon socket(s) to connect to
  
```

- Then I pulled the frontend-react-js image I had pushed from my gitpod into my Docker Hub repository

```sh
[root@ip-100-11-xx-000 ~]$ sudo docker pull oriade/aws_bootcamp
Using default tag: latest
latest: Pulling from oriade/aws_bootcamp
620af4e91dbf: Pull complete
fae29f309a72: Pull complete
28fca74d99b6: Pull complete
0b5db87f5b42: Pull complete
fa488706ea13: Pull complete
0380b9b3282f: Pull complete
383dfecd3687: Pull complete
ca59981dc274: Pull complete
4fa5c4b55a85: Pull complete
74c331b0bc07: Pull complete
3119e7eb8dd7: Pull complete
Digest: sha256:07bf67cf31eb515036dc49f688aac42773f81322e5f3ba7787f8fb8477f3b54c
Status: Downloaded newer image for oriade/aws_bootcamp:latest
docker.io/oriade/aws_bootcamp:latest
[root@ip-100-11-xx-000 ~]$ sudo docker images
REPOSITORY            TAG       IMAGE ID       CREATED        SIZE
oriade/aws_bootcamp   latest    c9f24eaddb07   13 hours ago   1.15GB
alpine                latest    b2aa39c304c2   12 days ago    7.05MB
```

- I ran the container and was able to load the CRUDDUR homepage.

![](https://github.com/Ibrahim-saliu/aws-bootcamp-cruddur-2023/blob/main/my_resources/week1/running%20Cruddur%20in%20my%20EC2%20instance.png)
- Then I stopped and terminated my provisioned EC2 instance.


#### AN OBSERVATION WAS THAT I COULD NOT SEE THE CRUDS ON THE CRUDDUR HOMEPAGE WHEN I RAN IT ON MY LOCAL HOST ON ON THE EC2 INSTANCE even though I USED THE SAME IMAGE.





