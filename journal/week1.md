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


    FROM python:3.10-slim-buster

    WORKDIR /backend-flask

    COPY requirements.txt requirements.txt
    RUN pip3 install -r requirements.txt

    COPY . .

    ENV FLASK_ENV=development

    EXPOSE ${PORT}
    CMD [ "python3", "-m" , "flask", "run", "--host=0.0.0.0", "--port=4567"]
    
    
    
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

        FROM node:16.18

        ENV PORT=3000

        COPY . /frontend-react-js
        WORKDIR /frontend-react-js
        RUN npm install
        EXPOSE ${PORT}
        CMD ["npm", "start"]
        
        
- create a `compose.yml` file as shown below to run multiple containers at the same time 

  
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
            
    
            
            
    

        
        
        
        


    
    
        
        
        




        





