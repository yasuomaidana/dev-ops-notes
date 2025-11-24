# Docker Compose

Docker Compose is a tool for defining and running multi-container Docker applications. With Compose, you use a YAML file to configure your application's services, networks, and volumes. Then, with a single command, you can create and start all the services from your configuration.

## 1. Compose Files

Docker Compose uses a YAML file, typically named `docker-compose.yml`, to define a multi-container application. This file acts as the single source of truth for your application's stack.

**Example `docker-compose.yml`:**
```yaml
version: '3.8'
services:
  # Service definitions will go here
```

## 2. Service Definitions

Inside the `docker-compose.yml` file, you define individual `services`. Each service corresponds to a container and is configured with a container image, ports, environment variables, and other settings.

**Example:** Let's define a web server and a Redis database.

```yaml
version: '3.8'
services:
  web:
    image: nginx:latest
    ports:
      - "8080:80"
  redis:
    image: "redis:alpine"
```

In this example:
- We have two services: `web` and `redis`.
- The `web` service uses the latest `nginx` image and maps port 8080 on the host to port 80 in the container.
- The `redis` service uses the `redis:alpine` image.

## 3. Networking and Volumes

Docker Compose simplifies networking and data persistence. You can create custom networks for your services to communicate and use volumes to persist data outside of a container's lifecycle.

**Example:** Let's add a custom network and a volume for our Redis database to persist data.

```yaml
version: '3.8'
services:
  web:
    image: nginx:latest
    ports:
      - "8080:80"
    networks:
      - app-network
  redis:
    image: "redis:alpine"
    networks:
      - app-network
    volumes:
      - redis-data:/data

networks:
  app-network:
    driver: bridge

volumes:
  redis-data:
```
- Both services are now connected to a custom `app-network`.
- The `redis` service will store its data in the `redis-data` volume. Docker Compose manages this volume.

## 4. Dependency Management

You can control the startup order of your services using the `depends_on` option. This is useful when one service needs another to be running before it starts.

**Example:** Ensure the `redis` service starts before the `web` service.

```yaml
version: '3.8'
services:
  web:
    image: nginx:latest
    ports:
      - "8080:80"
    networks:
      - app-network
    depends_on:
      - redis
  redis:
    image: "redis:alpine"
    networks:
      - app-network
    volumes:
      - redis-data:/data

networks:
  app-network:
    driver: bridge

volumes:
  redis-data:
```
**Note:** `depends_on` does not wait for a service to be "ready", only for it to have started. For more control, you might need to use a wrapper script or a tool like `wait-for-it.sh`.

## 5. Launching the Application

To start your application, navigate to the directory containing your `docker-compose.yml` file and use the following command:

```bash
docker-compose up
```

This command will build (if necessary), create, and start all the containers. To run them in the background, use the `-d` (detached) flag:

```bash
docker-compose up -d
```

To stop and remove all the containers, networks, and volumes defined in your `docker-compose.yml`, use:

```bash
docker-compose down
```

## 6. Scaling and Management

You can easily scale a service to run multiple instances. For example, to run three instances of your `web` service:

```bash
docker-compose up --scale web=3 -d
```

Docker Compose will create three `web` containers and load-balance traffic between them if the setup involves a reverse proxy.

## 7. Environment Configuration

You can use a `.env` file to manage environment-specific variables. This file should be in the same directory as your `docker-compose.yml`.

**Example `.env` file:**
```
WEB_PORT=8080
```

Now, you can use these variables in your `docker-compose.yml`:

```yaml
version: '3.8'
services:
  web:
    image: nginx:latest
    ports:
      - "${WEB_PORT}:80"
    networks:
      - app-network
    depends_on:
      - redis
  # ... rest of the services
```
When you run `docker-compose up`, it will automatically read the `.env` file and substitute the variables. This is great for keeping sensitive information or environment-specific settings out of your main configuration file.

## 8. Running a custom name docker compose file

By default, Docker Compose looks for a file named `docker-compose.yml`. If you want to use a different file, you can specify it with the `-f` flag.

**Example:** Let's say you have a `custom-docker-compose.yml` in the `flask-example` directory.

```bash
docker-compose -f custom-docker-compose.yml up
```

This command will start the services defined in `custom-docker-compose.yml`.

## 9. Shutting down and Turning on a specific service

You can manage individual services within your Docker Compose setup.

To start a specific service:
```bash
docker-compose up -d <service_name>
```

To stop a specific service:
```bash
docker-compose stop <service_name>
```

To restart a specific service:
```bash
docker-compose restart <service_name>
```

For example, to restart only the `web` service from our previous examples:
```bash
docker-compose restart web
```

## 10. Using Dockerfiles for services

Instead of using a pre-built image from a registry, you can have Docker Compose build an image from a Dockerfile. This is done using the `build` context.

**Example:** Let's use the `flask-example` application. The `docker-compose.yml` would look like this:

```yaml
version: '3.8'
services:
  web:
    build: ./flask-example
    ports:
      - "5000:5000"
  redis:
    image: "redis:alpine"
```

In this case, Docker Compose will look for a `Dockerfile` in the `flask-example` directory, build an image from it, and then start the `web` service container.

The `Dockerfile` for the `flask-example` might look something like this:

```dockerfile
# Use an official Python runtime as a parent image
FROM python:3.8-slim

# Set the working directory in the container
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY . /app

# Install any needed packages specified in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Make port 5000 available to the world outside this container
EXPOSE 5000

# Define environment variable
ENV NAME World

# Run app.py when the container launches
CMD ["python", "main.py"]
```
This setup allows you to integrate your custom application builds directly into your multi-container environment defined by Docker Compose.
