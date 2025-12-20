# write a docker file for the given requirements
# Create a Dockerfile with the following content:
FROM python:3.8-slim

WORKDIR /app

COPY requirements.txt /app/

RUN pip install -r requirements.txt

COPY . /app/

CMD ["python", "app.py"]

# This Dockerfile will use the Python 3.8 slim image as the base image, set the working directory to /app, copy the requirements.txt file to the container, install the dependencies specified in requirements.txt, copy the rest of the application code to the container, and run the app.py script as the default command.
# The Dockerfile should be named Dockerfile and should be placed in the root directory of the project.