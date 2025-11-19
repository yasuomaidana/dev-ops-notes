# Kubernetes Concepts

This document provides an overview of fundamental concepts in Kubernetes.

## Core Concepts

### Cluster
A Kubernetes cluster is a set of nodes that run containerized applications. It's the highest level of abstraction in Kubernetes. A cluster consists of two main types of components: the **Control Plane** and **Worker Nodes**.

- **Control Plane**: The brain of the cluster. It's responsible for making global decisions about the cluster (e.g., scheduling) and detecting and responding to cluster events. The control plane's components include:
    - **kube-apiserver**: Exposes the Kubernetes API. It's the front end for the Kubernetes control plane.
    - **etcd**: A consistent and highly-available key-value store used as Kubernetes' backing store for all cluster data.
    - **kube-scheduler**: Watches for newly created Pods with no assigned node and selects a node for them to run on.
    - **kube-controller-manager**: Runs controller processes. These controllers include the Node controller, Replication controller, Endpoints controller, and Service Account & Token controllers.

- **Worker Node**: A worker machine in Kubernetes, which may be a VM or a physical machine. Each node is managed by the control plane and contains the services necessary to run Pods. Components on a node include:
    - **kubelet**: An agent that runs on each node in the cluster. It makes sure that containers are running in a Pod.
    - **kube-proxy**: A network proxy that runs on each node in your cluster, implementing part of the Kubernetes Service concept.
    - **Container Runtime**: The software that is responsible for running containers (e.g., Docker, containerd).

### Node
A Node is a worker machine in Kubernetes. It's where your application's containers are deployed and run. Each node in the cluster is managed by the control plane.

### Pod
A Pod is the smallest and simplest unit in the Kubernetes object model that you create or deploy. A Pod represents a single instance of a running process in your cluster. Pods contain one or more containers, such as Docker containers. When a Pod runs multiple containers, the containers are managed as a single entity and share the Pod's resources.

### Service
A Service is an abstract way to expose an application running on a set of Pods as a network service. With Kubernetes, you don't need to modify your application to use an unfamiliar service discovery mechanism. Kubernetes gives Pods their own IP addresses and a single DNS name for a set of Pods, and can load-balance across them.

### Deployment
A Deployment provides declarative updates for Pods and ReplicaSets. You describe a desired state in a Deployment, and the Deployment Controller changes the actual state to the desired state at a controlled rate. You can define Deployments to create new ReplicaSets, or to remove existing Deployments and adopt all their resources with new Deployments.

### ReplicaSet
A ReplicaSet's purpose is to maintain a stable set of replica Pods running at any given time. As such, it's often used to guarantee the availability of a specified number of identical Pods.

## Other Important Concepts

### Ingress
An API object that manages external access to the services in a cluster, typically HTTP. Ingress can provide load balancing, SSL termination, and name-based virtual hosting.

### Horizontal Pod Autoscaler (HPA)
Automatically scales the number of pods in a replication controller, deployment, replica set, or stateful set based on observed CPU utilization or with custom metrics.

### Persistent Volume (PV) and Persistent Volume Claim (PVC)
- **Persistent Volume (PV)**: A piece of storage in the cluster that has been provisioned by an administrator or dynamically provisioned using Storage Classes. It is a resource in the cluster just like a node is a cluster resource.
- **Persistent Volume Claim (PVC)**: A request for storage by a user. It is similar to a Pod. Pods consume node resources and PVCs consume PV resources. Pods can request specific levels of resources (CPU and Memory). Claims can request specific size and access modes.