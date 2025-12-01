# Understanding Multi-Stage Builds

A multi-stage build uses multiple `FROM` instructions in a single Dockerfile. This allows you to use a large image with all the necessary build tools and dependencies (like compilers, SDKs, or `node_modules`) in an early stage, and then copy *only* the final application artifacts into a small, clean, production-ready image in a later stage.

This is the modern, recommended way to build small and secure Docker images.

### How It Works
1.  **Stage 1: The "Builder"**
    -   You start with a full-featured image (e.g., `node:18`, `golang:1.19`) and give it a name using `AS <name>` (e.g., `AS builder`).
    -   In this stage, you copy your source code, install all dependencies, and build your application. This stage will be large and contain many files not needed at runtime.

2.  **Stage 2: The "Final" Image**
    -   You start a new stage with a second `FROM` instruction, typically using a minimal base image (e.g., `nginx:alpine`, `python:3.11-slim`).
    -   You use the special `COPY --from=<name>` instruction to copy *only* the compiled code or necessary assets from the "builder" stage into this new, clean stage.

The "builder" stage and all its intermediate files are discarded, leaving you with only the small, optimized final image.

### Example: Building a React App
```dockerfile
# ----------------------------------------------------------------
# Stage 1: Build the React application (The "Builder" stage)
# ----------------------------------------------------------------
FROM node:18 AS builder

WORKDIR /app

# Copy package files and install dependencies
COPY package.json yarn.lock ./
RUN yarn install

# Copy the rest of the source code and build the application
COPY . .
RUN yarn build

# --------------------------------------------------------------------
# Stage 2: Serve the built assets with Nginx (The "Final" stage)
# --------------------------------------------------------------------
FROM nginx:1.23-alpine

# The '----' lines are just comments for readability. They are not required.

# Copy the static build files from the 'builder' stage
COPY --from=builder /app/build /usr/nginx/html

# Expose port 80 and start Nginx
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```
In this example, the final image contains only Nginx and the static HTML/JS/CSS files. It does **not** contain Node.js, `node_modules`, or the original React source code, making it significantly smaller and more secure.
