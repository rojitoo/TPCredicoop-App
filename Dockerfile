FROM python:3.9-slim

# Instalamos ping
RUN apt-get update && apt-get install -y iputils-ping

# Seteamos el directorio de trabajo a /app
WORKDIR /app

COPY . /app

# Update de los paquetes e instalación de dependencias necesarias.
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        gcc \
        default-libmysqlclient-dev \
        pkg-config \
    && apt-get upgrade -y \
    && rm -rf /var/lib/apt/lists/*
    
# Instalamos Flask y el cliente de MySQL para Python
RUN pip install Flask mysqlclient pymysql

# Instalamos pytest
RUN pip install pytest

# exponemos el puerto 
EXPOSE 5000

# Definimos una variable de entorno
ENV NAME World

# Cambiamos los permisos de la carpeta /app para que sea escribible por todos
RUN chmod -R 777 /app

# Corremos app.py cuando el container se inicia
CMD ["python", "/app/app-python/app.py"]
