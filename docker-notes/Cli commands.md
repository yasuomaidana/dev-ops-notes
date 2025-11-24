# Docker CLI Command Summary

A quick reference for the most common Docker commands used in daily development.

---

## Container Lifecycle

### `docker run`
Creates and starts a new container from an image.

**Common Flags:**
-   `-d`: Detached mode (runs in the background).
-   `-p <host_port>:<container_port>`: Maps a port from the host to the container.
-   `-v <host_path>:<container_path>`: Mounts a host directory (volume) into the container.
-   `--name <container_name>`: Assigns a custom name to the container.
-   `--rm`: Automatically removes the container when it exits.
-   `-it`: Interactive mode (connects your terminal to the container's shell).
-   `-e <VAR_NAME>=<value>`: Sets an environment variable inside the container.

**Example:**
```shell
# Run an Nginx container in the background, named "webserver", mapping port 8080
docker run -d --name webserver -p 8080:80 nginx
```

### `docker stop <container_name_or_id>`
Stops a running container gracefully.

### `docker start <container_name_or_id>`
Starts a stopped container.

### `docker restart <container_name_or_id>`
Restarts a container.

### `docker rm <container_name_or_id>`
Removes a stopped container. Use `-f` to force-remove a running container.

---

## Inspecting & Debugging

### `docker ps`
Lists all running containers.
-   `docker ps -a`: Lists all containers, including stopped ones.

### `docker logs <container_name_or_id>`
Fetches the logs from a container.
-   `-f` or `--follow`: Follows the log output in real-time.

### `docker exec -it <container_name_or_id> <command>`
Executes a command inside a running container.
-   **Example (get a shell inside the container):**
    ```shell
    docker exec -it webserver /bin/bash
    ```

---

## Image Management

### `docker build -t <image_name>:<tag> .`
Builds a Docker image from a `Dockerfile` in the current directory.
-   `-t`: Tags the image with a name and optional tag.

### `docker images`
Lists all Docker images on your system.

### `docker rmi <image_name_or_id>`
Removes an image. You must remove all containers using the image first.

### `docker pull <image_name>:<tag>`
Downloads an image from a registry (like Docker Hub).

---

## System & Cleanup

### `docker system prune`
Removes all unused data: stopped containers, dangling images, and unused networks.
-   `docker system prune -a --volumes`: **(Use with caution!)** Removes all unused images (not just dangling ones) and volumes.

---

## Docker Compose
Manages multi-container applications. Commands are run from the directory containing the `docker-compose.yml` file.

### `docker-compose up`
Creates and starts all services defined in the `docker-compose.yml` file.
-   `-d`: Detached mode.
-   `--build`: Forces a rebuild of the images before starting.

### `docker-compose down`
Stops and removes all containers, networks, and volumes created by `up`.
-   `-v`: Removes named volumes.

### `docker-compose ps`
Lists the status of all services.

### `docker-compose logs`
Displays logs from all services.
-   `docker-compose logs -f <service_name>`: Follows logs for a specific service.

### Managing Projects with Names
By default, Docker Compose uses the current directory name for the project. You can override this with the `-p` (project name) flag for easier management.

-   **Start a named project:**
    ```shell
    docker-compose -p my-project-name up -d
    ```

-   **Stop a named project:**
    ```shell
    docker-compose -p my-project-name down
    ```
