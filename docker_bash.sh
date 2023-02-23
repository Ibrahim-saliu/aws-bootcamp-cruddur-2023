#!/bin/bash

echo "Generally, the goal of this script is to execute docker commands to create our backend and frontend. We will also install the required dependencies"

# Defining Variables
export PATHBACKEND="/workspace/aws-bootcamp-cruddur-2023/backend-flask"
export PATHFRONTEND="/workspace/aws-bootcamp-cruddur-2023/frontend-react-js"


# Creating backend

echo "Here, we will install execute docker to create our backend"

docker build -t backend-flask ./backend-flask

# Now, we can run our container
docker run -d -p 4567:4567 -e FRONTEND_URL="*" -e BACKEND_URL="*" backend-flask 


# FRONTEND
#installing requirements for our frontend react
npm install

# building our frontend image
docker build -t frontend-react-js ./frontend-react-js

# Running our front end container 
docker run -d -p 3000:3000 -e FRONTEND_URL="*" -e BACKEND_URL="*" frontend-react-js







