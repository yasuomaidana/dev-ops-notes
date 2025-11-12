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

### `COPY <source> <destination>`
Copies files or directories from your local build context (`<source>`) into the image (`<destination>`).

-   `<source>`: The path to the file(s) or directory(ies) on your local machine relative to the Dockerfile's location.
-   `<destination>`: The absolute path inside the container where the files will be copied. If it's a relative path, it's relative to the `WORKDIR`.

**Example:**
```dockerfile
# Copy requirements.txt from the build context to the current WORKDIR (e.g., /app) in the image
COPY requirements.txt .

# Copy all files and directories from the build context to /app in the image
COPY . .
```

---

### `RUN`
Executes commands in a new layer during the image build process. This is typically used for installing packages, compiling code, or setting up the environment. Each `RUN` instruction creates a new image layer.

**Example:**
```dockerfile
RUN apt-get update && apt-get install -y git
RUN pip install --no-cache-dir -r requirements.txt
```

---

### `EXPOSE <port>`
Informs Docker that the container listens on the specified network port(s) at runtime. It acts as documentation and does **not** actually publish the port.

-   To make the port accessible from the host, you must explicitly publish it using the `-p` flag with `docker run` (e.g., `docker run -p 8080:8000 my_image`).
    -   `8080:8000` means host port `8080` maps to container port `8000`. The `EXPOSE 8000` instruction in the Dockerfile indicates that the application inside the container expects traffic on port `8000`.

**Example:**
```dockerfile
EXPOSE 8000
```

---

### `ENV`
Sets a persistent environment variable in the image. These variables are available during the build process and when the container runs.

**Example:**
```dockerfile
ENV PYTHONUNBUFFERED=1
ENV APP_VERSION=1.0.0
```

---

### `CMD`
Provides the default command and/or parameters for an executing container. There can only be one `CMD` instruction in a Dockerfile. If you specify multiple, only the last one takes effect.

-   It's easily overridden by providing arguments to `docker run`.
-   Often used to provide default arguments to an `ENTRYPOINT` instruction.

**Example:**
```dockerfile
# Run the application by default
CMD ["python", "main.py"]
```

---

### `ENTRYPOINT`
Configures a container to run as an executable. It specifies the command that will always be executed when the container starts.

-   It's harder to override than `CMD`.
-   Arguments passed to `docker run` are appended to the `ENTRYPOINT` command.
-   Often used in combination with `CMD` where `ENTRYPOINT` defines the fixed executable and `CMD` provides default parameters to that executable.

**Example:**
```dockerfile
# The container will act like the 'gunicorn' executable
ENTRYPOINT ["gunicorn"]

# CMD provides the default arguments to the entrypoint
CMD ["--bind", "0.0.0.0:8000", "my_project.wsgi"]
```

---

## Understanding `RUN`, `CMD`, and `ENTRYPOINT`

These three instructions are often confused, but they serve distinct purposes:

-   **`RUN`**:
    -   **When executed:** During the **image build** process.
    -   **Purpose:** To execute commands that create layers in the image (e.g., install software, compile code, create directories). Each `RUN` command adds a new layer.
    -   **Example:** `RUN apt-get update && apt-get install -y curl`

-   **`CMD`**:
    -   **When executed:** When the container **starts**, if no command is specified with `docker run`.
    -   **Purpose:** To provide default arguments for an `ENTRYPOINT` or to execute a default command.
    -   **Overridable:** Easily overridden by arguments passed to `docker run`.
    -   **Example:** `CMD ["python", "app.py"]` (runs `app.py` by default)

-   **`ENTRYPOINT`**:
    -   **When executed:** When the container **starts**.
    -   **Purpose:** To configure the container as an executable. The `ENTRYPOINT` command is the fixed part of the container's runtime command.
    -   **Overridable:** Harder to override (requires `docker run --entrypoint ...`).
    -   **Interaction with `CMD`:** `CMD` provides default arguments to the `ENTRYPOINT`. The values from `CMD` are appended to the `ENTRYPOINT` array. These arguments can be easily overridden from the `docker run` command line.
    -   **Example:**
        ```dockerfile
        # Dockerfile
        ENTRYPOINT ["ping", "-c", "4"]
        CMD ["localhost"]
        ```
        -   Running `docker run <image>` executes `ping -c 4 localhost`.
        -   Running `docker run <image> google.com` overrides the `CMD` and executes `ping -c 4 google.com`.
---

## Why `WORKDIR` is Preferred Over `RUN cd`

This is a critical concept related to how Docker builds images in layers.

Each `RUN` instruction is executed in a **new, separate shell session** on a new layer. The state from one `RUN` command (like changing a directory with `cd`) **does not persist** to the next one.

### Incorrect Approach: `RUN cd`
```dockerfile
# This does NOT work as you might expect
RUN cd /app
RUN pwd 
```
-   The second `RUN pwd` command will print `/`, not `/app`. This is because the `cd /app` command only affected its own layer, which was immediately committed. The next layer starts fresh from the default directory (`/`).

### Correct Approach: `WORKDIR`
The `WORKDIR` instruction sets a **persistent** working directory for all subsequent instructions (`RUN`, `COPY`, `CMD`, `ENTRYPOINT`, etc.) in the Dockerfile.

```dockerfile
# This is the correct and reliable way
WORKDIR /app
RUN pwd
```
-   The `RUN pwd` command will correctly print `/app`, because the `WORKDIR` instruction modified the state for all future layers.

**Key Benefits of `WORKDIR`:**
-   **Reliability:** It guarantees that subsequent commands are run in the correct directory.
-   **Clarity:** It makes the Dockerfile easier to read and understand.
-   **Efficiency:** It avoids having to chain commands together with `&&` (e.g., `RUN cd /app && ./do_something.sh`), which can become messy.
