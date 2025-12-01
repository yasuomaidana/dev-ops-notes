# Overriding the Default Command in Docker Compose

When working with Docker Compose, you often need to run specific commands when your service's container starts. You can achieve this using the `command` and `entrypoint` keywords in your `docker-compose.yml` file.

## Using `command`

The `command` keyword overrides the default command for the container. The default command is specified by the container image's `CMD` or `ENTRYPOINT` instruction.

Here's an example of how to use `command` in your `docker-compose.yml`:

```yaml
version: '3.8'
services:
  my-service:
    image: ubuntu
    command: ["/bin/bash", "-c", "echo 'Hello from the container!' && sleep 3600"]
```

In this example, when the `my-service` container starts, it will execute the specified command, printing a message and then sleeping.

## Using `entrypoint`

The `entrypoint` keyword overrides the default entrypoint for the container. The entrypoint is the executable that is run when the container starts.

Here's an example of how to use `entrypoint`:

```yaml
version: '3.8'
services:
  my-service:
    image: python:3.9-alpine
    entrypoint: python
    command: ["-c", "print('Hello from Python!')"]
```

In this case, the `entrypoint` is set to `python`, and the `command` provides the arguments to the entrypoint. The container will run `python -c "print('Hello from Python!')"`.

## `entrypoint` vs. `command`

-   `entrypoint` specifies the main executable for the container.
-   `command` provides the default arguments for the `entrypoint`. If you specify a `command` in your `docker-compose.yml`, it will override the default `CMD` in the Dockerfile.

By using `command` and `entrypoint` in your `docker-compose.yml` file, you can customize the behavior of your services to fit your specific needs.
