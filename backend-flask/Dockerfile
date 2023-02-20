# This is where our image will be downloaded from. It could be dockerhub
FROM python:3.10-slim-buster

# Inside container
WORKDIR /backend-flask

# Outside Container ---> Inside Container
# this conatines the python library we want to install to run the app
COPY requirements.txt requirements.txt


# Runs inside the Container
# Install the python libraries used for the app
RUN pip3 install -r requirements.txt


# Outside Container ---> Inside Container
# 1st . is the workdir /backend-flask outside the container
# 2nd . is the workdir /backend flask inside the container
COPY . .

# Environment variable set for the enviornment
# Get set inside the container and will remain set while cont is running
ENV FLASK_ENV=development

EXPOSE ${PORT}

# python3 -m flask run --host=0.0.0.0 --port=4567
CMD [ "python3", "-m" , "flask", "run", "--host=0.0.0.0", "--port=4567"]