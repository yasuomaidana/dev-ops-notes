# Introduction to high availability in Azure

High availability (HA) in Azure refers to the ability of a system to remain operational and accessible for a significant period, minimizing downtime and ensuring continuous service. Azure provides various features and services to help you design and implement highly available solutions.

## Key Concepts for High Availability

1.  **Redundancy**: Having duplicate components or systems to take over if one fails. This is a fundamental principle of HA.
2.  **Fault Tolerance**: The ability of a system to continue operating without interruption when one or more of its components fail.
3.  **Disaster Recovery (DR)**: A set of policies, tools, and procedures that enable the recovery or continuation of vital technology infrastructure and systems following a natural or human-induced disaster. HA focuses on preventing downtime, while DR focuses on recovering from it.
4.  **Recovery Time Objective (RTO)**: The maximum acceptable duration of time that a computer, system, network, or application can be down after a disaster.
5.  **Recovery Point Objective (RPO)**: The maximum acceptable amount of data loss measured in time. For example, if your RPO is one hour, you can afford to lose at most one hour of data.
6.  **Fast failovers**: The ability of a system to quickly switch to a redundant or standby component when the primary component fails, minimizing service interruption.
7.  **Single Point of Failure (SPoF)**: A part of a system that, if it fails, will stop the entire system from working. Identifying and eliminating SPoFs is crucial for high availability.

## Azure Services for High Availability

Azure offers several services and features that contribute to building highly available applications.

### 1. Azure Regions and Geographies

*   **Regions**: A geographic area on the planet containing at least one, but potentially multiple, datacenters that are networked together with a low-latency network. Deploying resources across multiple regions provides protection against region-wide outages.
*   **Geographies**: A discrete market, typically containing two or more regions, that preserves data residency and compliance boundaries. Geographies are fault-tolerant to withstand complete region failure.

### 2. Availability Zones

*   **Availability Zones**: Unique physical locations within an Azure region. Each zone is made up of one or more datacenters equipped with independent power, cooling, and networking. By deploying your applications across multiple Availability Zones, you can protect against datacenter failures. If one zone goes down, your application in other zones remains available.

### 3. Availability Sets

*   **Availability Sets**: A logical grouping capability for isolating VM resources from each other when they're deployed. Azure ensures that the VMs you place within an Availability Set run across multiple isolated hardware nodes in a datacenter. This protects your application from planned maintenance and unplanned hardware failures.
    *   **Fault Domains**: A logical grouping of underlying hardware that shares a common power source and network switch. VMs in different fault domains are physically separated.
    *   **Update Domains**: A logical grouping of underlying hardware that can be rebooted at the same time during planned maintenance. VMs in different update domains are updated sequentially.

### 4. Load Balancers

*   **Azure Load Balancer**: Distributes incoming network traffic across multiple virtual machines or services. This ensures that no single server becomes a bottleneck and that if one server fails, traffic is automatically redirected to healthy servers.
*   **Azure Application Gateway**: A web traffic load balancer that enables you to manage traffic to your web applications. It provides application-level routing and other features like Web Application Firewall (WAF) for enhanced security.
*   **Azure Front Door**: A global, scalable entry-point that uses the Microsoft global edge network to create fast, secure, and widely scalable web applications. It provides global load balancing and site acceleration.

### 5. Database High Availability

*   **Azure SQL Database**: Offers built-in high availability with automatic backups, replication, and failover capabilities. You can choose different service tiers (e.g., Business Critical) for higher availability guarantees.
*   **Azure Cosmos DB**: A globally distributed, multi-model database service that offers turnkey global distribution and multi-region write capabilities, providing high availability and low-latency access worldwide.

### 6. Storage High Availability

*   **Azure Storage Redundancy**: Azure Storage offers various redundancy options to ensure data durability and availability:
    *   **Locally Redundant Storage (LRS)**: Replicates your data three times within a single datacenter.
    *   **Zone-Redundant Storage (ZRS)**: Replicates your data across three Azure Availability Zones in the primary region.
    *   **Geo-Redundant Storage (GRS)**: Replicates your data to a secondary region hundreds of miles away from the primary region.
    *   **Geo-Zone-Redundant Storage (GZRS)**: Combines the high availability of ZRS with the disaster recovery capabilities of GRS.

## Designing for High Availability

When designing for high availability in Azure, consider the following:

*   **Distribute Resources**: Spread your application components across multiple Availability Zones and/or regions.
*   **Implement Redundancy**: Use redundant services for compute, storage, and networking.
*   **Automate Failover**: Configure services to automatically fail over to healthy instances or regions in case of an outage.
*   **Monitor and Alert**: Continuously monitor the health of your application and infrastructure, and set up alerts for potential issues.
*   **Backup and Restore**: Implement a robust backup and restore strategy to recover data in case of corruption or loss.
*   **Test Regularly**: Periodically test your high availability and disaster recovery plans to ensure they work as expected.

## Glossary

| Abbreviation | Full Form                          |
|:-------------|:-----------------------------------|
| OSI          | Open Systems Interconnection       |
| VM           | Virtual Machine                    |
| TCP          | Transmission Control Protocol      |
| UDP          | User Datagram Protocol             |
| HTTP         | Hypertext Transfer Protocol        |
| HTTPS        | Hypertext Transfer Protocol Secure |
| NAT          | Network Address Translation        |
| SHA256       | Secure Hash Algorithm 256          |
| TLS          | Transport Layer Security           |
| HA           | High Availability                  |
| NSG          | Network Security Group             |
| SKU          | Stock Keeping Unit                 |
| IPv4         | Internet Protocol version 4        |
| IPv6         | Internet Protocol version 6        |
| CLI          | Command-Line Interface             |
| API          | Application Programming Interface  |
| IP           | Internet Protocol                  |
