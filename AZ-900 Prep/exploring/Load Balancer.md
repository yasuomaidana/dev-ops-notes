# Azure Load Balancer

Azure Load Balancer is a foundational service that ensures your applications are both **highly available** and **scalable**. It works by distributing incoming traffic across multiple backend servers, preventing any single server from becoming a bottleneck. This guarantees optimal performance and a seamless experience for your users.

Operating at **Layer 4 (the transport layer)** of the OSI model, Azure Load Balancer acts as a single point of contact for clients. It directs incoming traffic to healthy backend virtual machines (VMs) based on a set of configured rules and health probes.

---

## Key Concepts

### Load Balancer Types

Azure offers two primary types of load balancers to suit different architectural needs:

*   **Public Load Balancer:** This type maps a public IP address to a pool of private VMs. It provides outbound connections for VMs within your virtual network by translating their private IP addresses to its public IP address. This is essential for internet-facing applications.

*   **Internal (or Private) Load Balancer:** This type distributes traffic exclusively *within* a virtual network, using private IP addresses for the frontend. It's the perfect choice for internal line-of-business applications, multi-tier applications, and securing backend services from direct internet exposure.

![Public and Private Load Balancers](../assets/Private%20and%20Public%20LB.png)

### Key Components

An Azure Load Balancer is configured using several key components:

*   **Frontend IP Configuration:** This is the IP address where the load balancer receives incoming traffic. It can be a public or private IP address.
*   **Backend Pool:** A group of VMs or instances in a Virtual Machine Scale Set that will handle the incoming workload.
*   **Health Probes:** These are used to monitor the health of the backend instances. The load balancer only sends traffic to healthy VMs, ensuring high availability.
*   **Load Balancer Rules:** These rules define how incoming traffic on the frontend IP is distributed to the backend pool. They map a specific port on the frontend to a port in the backend pool.
*   **High Availability (HA) Ports:** This is a specific type of load balancer rule that allows you to load balance all traffic on all ports simultaneously. It's designed for scenarios like Network Virtual Appliances (NVAs) inside a virtual network.
*   **Inbound NAT Rules:** These rules forward incoming traffic from a specific frontend port to a *specific* VM in the backend pool. This is often used for remote administration.
*   **Outbound Rules:** These rules allow you to configure Source Network Address Translation (SNAT) for your backend VMs, enabling them to communicate with the internet.

### Distribution Modes

Azure Load Balancer uses a hash-based distribution algorithm. This algorithm uses a "5-tuple hash" to map traffic to available servers. The tuple consists of:

1.  **Source IP address**
2.  **Source port**
3.  **Destination IP address**
4.  **Destination port**
5.  **Protocol**

This ensures that packets from the same session are directed to the same backend instance, providing "stickiness."

![Hash-based distribution](../assets/Hash-based%20distribution.png)

You can also configure **session persistence** (also known as source IP affinity) with different settings:

*   **None (Default):** Any backend instance can handle the request.
*   **Client IP (2-tuple):** Traffic from the same client IP is routed to the same backend instance.
*   **Client IP and Protocol (3-tuple):** Traffic from the same client IP and protocol combination is routed to the same backend instance.

---

## Benefits of Azure Load Balancer

*   **High Availability:** Automatically redirects traffic away from unhealthy or failed VMs, ensuring your application remains online.
*   **Scalability:** Effortlessly scale your application by adding or removing VMs from the backend pool without interrupting service.
*   **Low Latency & High Throughput:** Provides high-performance connections by efficiently distributing traffic.
*   **Security:** Integrates with Network Security Groups (NSGs) to restrict traffic to and from the load balancer, enhancing the security of your application.
*   **Protocol Support:** Supports TCP and UDP protocols, making it suitable for a wide range of applications.

---

## Cross-Region Load Balancing

For global applications, Azure's cross-region load balancer provides a new level of resilience and performance. This is a global Layer 4 load balancer that distributes traffic across multiple regional Azure Load Balancers.

### Key Features

*   **Geo-Redundant High Availability:** Provides instant failover to the next optimal region if one region becomes unavailable.
*   **Ultra-Low Latency:** Uses a geo-proximity load-balancing algorithm to direct users to the closest Azure region, minimizing network latency.
*   **Single Global Endpoint:** Your application can be scaled up or down behind a single, static anycast global IP address.
*   **Client IP Preservation:** The original client IP is preserved at the regional load balancer.

By combining a global load balancer with regional load balancers, you can build highly resilient and performant applications that serve a global audience with minimal downtime and the best possible user experience.

