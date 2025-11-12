# Common Dockerfile Instructions

A quick reference for the most used instructions in a `Dockerfile`.

---

### `FROM`
Specifies the base (parent) image. Every `Dockerfile` must start with this.

**Example:**
```dockerfile
FROM python:3.11-slim
```

---

### `WORKDIR`
Sets the working directory for subsequent instructions (`RUN`, `COPY`, etc.). It's created if it doesn't exist.

**Example:**
```dockerfile
WORKDIR /app
```

---

### `COPY`
Copies files or directories from your local build context into the image.

**Example:**
```dockerfile
# Copy requirements file first for better layer caching
COPY requirements.txt .

# Copy the rest of the application
COPY . .
```

---

### `RUN`
Executes commands in a new layer, typically for installing packages or setting up the environment.

**Example:**
```dockerfile
RUN pip install --no-cache-dir -r requirements.txt
```

---

### `EXPOSE`
Documents which network ports the container listens on at runtime. Does not actually publish the port.

**Example:**
```dockerfile
EXPOSE 8000
```

---

### `ENV`
Sets a persistent environment variable in the image, available during the build and when the container runs.

**Example:**
```dockerfile
ENV PYTHONUNBUFFERED=1
```

---

### `CMD`
Provides the default command and/or parameters for an executing container. Can be easily overridden from the `docker run` command line. A `Dockerfile` should have only one `CMD`.

**Example:**
```dockerfile
# Run the application by default
CMD ["python", "main.py"]
```

---

### `ENTRYPOINT`
Configures the container to run as an executable. It is harder to override than `CMD` and is often used in combination with it.

**Example:**
```dockerfile
# The container will act like the 'gunicorn' executable
ENTRYPOINT ["gunicorn"]

# CMD provides the default arguments to the entrypoint
CMD ["--bind", "0.0.0.0:8000", "my_project.wsgi"]
```
