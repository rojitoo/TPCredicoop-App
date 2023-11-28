# Use an official Python runtime as a parent image
FROM python:3.9-slim

# Install ping
RUN apt-get update && apt-get install -y iputils-ping

# Set the working directory to /app
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY . /app

# Update and upgrade Debian packages, install necessary dependencies
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        gcc \
        default-libmysqlclient-dev \
        pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Install Flask and the MySQL client for Python
RUN pip install Flask mysqlclient pymysql

# Install pytest for testing
RUN pip install pytest

# Make port 5000 available to the world outside this container
EXPOSE 5000

# Define environment variable
ENV NAME World

# Run app.py when the container launches
CMD ["python", "app.py"]
