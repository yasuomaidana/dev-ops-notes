# Hello K3s

K3s is a lightweight, certified Kubernetes distribution developed by Rancher (now part of SUSE). It's designed to be a single binary under 100MB that is simple to install and operate. For data engineers, K3s provides a resource-efficient local Kubernetes environment for development, testing, and even for edge computing scenarios. Here's a beginner's guide to getting started with K3s:

1.  **Installation**: Start by installing K3s on your development machine. The official method for Linux is a convenient script:
    ```bash
    curl -sfL https://get.k3s.io | sh -
    ```
    For other operating systems like macOS or Windows, you might run K3s in a Docker container. See the section below for more details.

2.  **No Hypervisor Needed**: Unlike Minikube, K3s can run directly on your machine without needing a separate hypervisor like VirtualBox or Hyper-V. It runs as a single process, making it very lightweight.

3.  **Start the Cluster**: The installation script automatically starts the K3s service. You can check its status with:
    ```bash
    sudo systemctl status k3s
    ```

4.  **Verify Cluster Status**: After installation, you can verify that your single-node cluster is running correctly using the bundled `kubectl`:
    ```bash
    sudo k3s kubectl get nodes
    ```

5.  **Use kubectl**: K3s includes its own `kubectl`. To use it, you can either prefix your commands with `sudo k3s` or configure your local `kubectl` to point to the K3s cluster. The K3s kubeconfig file is located at `/etc/rancher/k3s/k3s.yaml`. You can use it by setting the `KUBECONFIG` environment variable:
    ```bash
    export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
    kubectl get pods --all-namespaces
    ```

6.  **Deploy Data Workflows**: Create and deploy your data processing workflows using standard Kubernetes manifests or Helm charts. You can define pods, services, and other resources just as you would in any Kubernetes cluster.

7.  **Data Tools and Services**: Install any data engineering tools or services you need within your K3s cluster. This can include databases, message brokers, or data processing frameworks like Apache Spark or Flink.

8.  **Testing and Debugging**: Use K3s to test and debug your data workflows locally. Its fast startup time and low resource usage make it ideal for quick iterations during the development process.

9.  **Resource Management**: K3s is designed to be lean, which is excellent for understanding how your applications behave in resource-constrained environments, a common scenario in edge computing.

10. **Learning and Documentation**: Familiarize yourself with Kubernetes concepts, as K3s is a fully compliant Kubernetes distribution. Explore the official K3s and Kubernetes documentation to deepen your understanding.

## Running K3s with Docker

For macOS and Windows users, or for anyone who wants an isolated environment without installing K3s directly on the host, running K3s in a Docker container is an excellent option.

1.  **Start the K3s Server**: Run the following command to start a K3s server in a Docker container.
    ```bash
    docker run -d --name k3s-server -p 6443:6443 --privileged rancher/k3s:latest server
    ```
    - `-d`: Runs the container in detached mode.
    - `--name k3s-server`: Assigns a name to the container for easy reference.
    - `-p 6443:6443`: Maps the Kubernetes API server port from the container to your host.
    - `--privileged`: This is necessary for K3s to function correctly within the container.

2.  **Get the Kubeconfig**: To interact with your new cluster using `kubectl` from your host machine, you need the kubeconfig file.
    ```bash
    docker exec k3s-server cat /etc/rancher/k3s/k3s.yaml > k3s.yaml
    ```
    Then, edit the `k3s.yaml` file and replace `127.0.0.1` with your machine's actual IP address or hostname if you are accessing it from another machine. For local access, `127.0.0.1` is fine.

3.  **Use the Kubeconfig**:
    ```bash
    export KUBECONFIG=$(pwd)/k3s.yaml
    kubectl get nodes
    ```

4.  **Stopping and Cleaning Up**: To stop and remove the cluster, simply stop and remove the Docker container.
    ```bash
    docker stop k3s-server
    docker rm k3s-server
    rm k3s.yaml
    ```

K3s is a powerful tool for data engineers who need a fast, simple, and lightweight Kubernetes environment. It allows you to develop, test, and optimize your data workflows locally before deploying them to a full-scale production cluster.

For more information on getting started with K3s, check out the official website:
[K3s.io](https://k3s.io/)