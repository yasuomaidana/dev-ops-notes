# Understanding Docker Networking

Docker networking allows containers to communicate with each other, with the host machine, and with external networks. Understanding the different network drivers is key to managing container communication effectively.

---

## Common Network Drivers

Docker comes with several built-in network drivers. These are the most common ones:

### 1. Bridge (Default)
-   **What it is:** A private, internal network created for your containers on a single host.
-   **How it works:** When Docker starts, it creates a default `bridge` network. All containers launched without a `--network` flag are attached to this network. Containers on the same bridge network can communicate with each other using their internal IP addresses or container names.
-   **Use Case:** Ideal for standalone containers that need to communicate on the same host. It's the most common driver.
-   **Note:** For custom bridge networks, DNS resolution between containers works automatically. On the default `bridge` network, you must use the `--link` flag (which is now considered legacy).

### 2. Host
-   **What it is:** This driver removes network isolation between the container and the Docker host.
-   **How it works:** The container shares the host's networking namespace. If you run a container that binds to port 80, it will be accessible on the host's IP at port 80.
-   **Use Case:** When network performance is critical and you don't need network isolation, as it avoids the overhead of NAT (Network Address Translation). For example, a container that needs to handle a large range of ports.

### 3. Overlay
-   **What it is:** An overlay network connects multiple Docker daemons together and enables Swarm services to communicate with each other.
-   **How it works:** It creates a distributed network that "overlays" on top of the host-specific networks, allowing containers on different hosts to communicate directly as if they were on the same machine.
-   **Use Case:** Essential for multi-host communication in a Docker Swarm cluster.

### 4. None
-   **What it is:** Disables all networking for a container.
-   **How it works:** The container is created with its own network stack but is not configured. It has a loopback device but no external network interface.
-   **Use Case:** For containers that do not need network access at all, or when you want to set up a completely custom networking stack.

---

## Basic Network Commands

Here are the essential commands for managing Docker networks.

### `docker network ls`
Lists all networks on the Docker host.

### `docker network create <network_name>`
Creates a new user-defined bridge network. It's best practice to create custom bridge networks for your applications rather than using the default one.
```shell
# Create a new bridge network
docker network create my-app-network
```

### `docker network inspect <network_name_or_id>`
Displays detailed information about a specific network, including which containers are connected to it.

### `docker network connect <network_name> <container_name>`
Connects a running container to a network. A container can be connected to multiple networks.
```shell
docker network connect my-app-network my-container
```

### `docker network disconnect <network_name> <container_name>`
Disconnects a container from a network.

### `docker network rm <network_name_or_id>`
Removes one or more networks. You must first disconnect any containers attached to the network.

---

## Example with Docker Compose

Docker Compose simplifies networking by automatically creating a dedicated bridge network for your application. All services defined in the `docker-compose.yml` file are attached to this network and can communicate using their service names.

```yaml
# docker-compose.yml
version: '3.8'

services:
  db:
    image: postgres
    # The 'db' service is automatically available at the hostname 'db'
    # for other services in this file.

  api:
    image: my-api-image
    ports:
      - "8000:8000"
    # The 'api' service can connect to the database using 'db:5432'

# When you run 'docker-compose up', a network named '<project_name>_default'
# is created and both 'db' and 'api' are attached to it.
```
