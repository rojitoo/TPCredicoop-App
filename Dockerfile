FROM python:3.9-slim

# Instalamos ping
RUN apt-get update && apt-get install -y iputils-ping

# Seteamos el directorio de trabajo a /app
WORKDIR /app

COPY . /app

# Update de los paquetes e instalación de dependencias necesarias.

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        gcc \
        default-libmysqlclient-dev \
        pkg-config \
    && rm -rf /var/lib/apt/lists/*
    
# Instalamos Flask y el cliente de MySQL para Python
RUN pip install Flask mysqlclient pymysql

# Instalamos pytest
RUN pip install pytest

# exponemos el puerto 
EXPOSE 5000

# Definimos una variable de entorno
ENV NAME World

# Corremos app.py cuando el container se inicia
CMD ["python", "/app/app.py"]
