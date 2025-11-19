# Kubernetes concepts

1. **Cluster**: A Kubernetes cluster is a set of nodes that run containerized applications. It consists of a control
   plane and one or more compute machines, or nodes. The control plane is responsible for maintaining the desired state
   of the cluster, such as which applications are running and which container images they use. Nodes are the worker
   machines that run the applications.

2. **Deploy**: You can deploy applications on Kubernetes using Deployments. A Deployment is a Kubernetes object that
   manages a set of identical pods. Pods are the smallest deployable units of computing that you can create and manage
   in Kubernetes. A ReplicaSet is a Kubernetes object that ensures that a specified number of pod replicas are running
   at any given time.

3. **Explore**: You can explore applications running on Kubernetes using `kubectl`, the Kubernetes command-line tool.
    * `kubectl get <resource>`: Lists resources of a given type.
    * `kubectl describe <resource> <resource-name>`: Shows detailed information about a specific resource.
    * `kubectl logs <pod-name>`: Prints the logs for a pod.

4. **Expose**: You can expose your application to the internet so that users can access it.
    * **Service**: An abstract way to expose an application running on a set of Pods as a network service.
    * **NodePort**: Exposes the Service on each Node’s IP at a static port (the `NodePort`).
    * **LoadBalancer**: Exposes the Service externally using a cloud provider’s load balancer.
    * **Ingress**: An API object that manages external access to the services in a cluster, typically HTTP. Ingress may
      provide load balancing, SSL termination, and name-based virtual hosting.

5. **Scale**: You can scale your application by increasing or decreasing the number of replicas.
    * `kubectl scale deployment <deployment-name> --replicas=<number-of-replicas>`: Manually scales a deployment.
    * **Horizontal Pod Autoscaler (HPA)**: Automatically scales the number of pods in a replication controller,
      deployment, replica set or stateful set based on observed CPU utilization.

6. **Iterate**: You can update your application by applying a new version of the container image. Kubernetes Deployments
   allow for rolling updates, which means you can update your application without any downtime. During a rolling update,
   the Deployment ensures that only a certain number of pods are down at the same time and that new pods are created to
   replace the old ones.


## Concepts:

Cluster:
Node: 
Pod: