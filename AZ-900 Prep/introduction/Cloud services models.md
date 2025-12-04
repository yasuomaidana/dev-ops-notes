# Cloud services models

![responsibilities](../assets/Responsibilities.png)

## Cloud Deployment Options

Another critical factor for businesses to decide on is the array of deployment choices at their disposal.

### Public Cloud

A public cloud is owned and operated by a third-party cloud service provider (like Microsoft Azure) that delivers
computing resources over the Internet.

* **Management**: The cloud provider owns and manages all the software, hardware, and infrastructure.
* **Access**: Users access services and manage their accounts using a web browser.
* **Benefits**: Offers lower costs, scalability, and ease of use.
* **Azure Example**: Azure Public Cloud provides a vast range of services (virtual machines, storage, databases)
  accessible over the internet from data centers around the globe.

### Private Cloud

A private cloud refers to cloud computing resources used exclusively by a single organization.

* **Location**: Can be located at an organization's on-premises data center or hosted by a third-party service provider.
* **Benefits**: Offers greater control, security, and customization.
* **Drawbacks**: May incur higher upfront costs.
* **Azure Example**: Azure offers private cloud options like **Azure Dedicated Host** (running VMs on single-tenant
  physical servers) and **Azure Stack** (deploying Azure services on your own infrastructure).

### Hybrid Cloud

Hybrid clouds combine public and private clouds, using technology that enables the sharing of data and applications
between them.

* **Benefits**: Provides flexibility by allowing companies to leverage the benefits of both public and private clouds.
  For example, storing sensitive data in a private cloud while using a public cloud for scalable, less critical
  workloads.
* **Azure Example**: **Azure Arc** extends Azure management and governance to any infrastructure, whether it's in Azure,
  on-premises, or in other clouds.

| Public cloud                                                          | Private cloud                                                      | Hybrid cloud                                                      |
|-----------------------------------------------------------------------|--------------------------------------------------------------------|-------------------------------------------------------------------|
| No capital expenditures to scale up                                   | Organizations have complete control over resources and security    | Provides the most flexibility                                     |
| Applications can be quickly provisioned and deprovisioned             | Data is not collocated with other organizations’ data              | Organizations determine where to run their applications           |
| Organizations pay only for what they use                              | Hardware must be purchased for startup and maintenance             | Organizations control security, compliance, or legal requirements |
| Organizations don’t have complete control over resources and security | Organizations are responsible for hardware maintenance and updates |                                                                   |

---

## Choosing the Right Cloud Service Model

The best cloud service model for your business depends heavily on your specific requirements. Here are key factors to
consider:

### IaaS (Infrastructure as a Service)

* **Choose for**: Granular control and customization.
* **Description**: IaaS provides the fundamental building blocks of computing infrastructure (virtualized servers,
  storage, networking). It offers the highest level of flexibility and management control over your IT resources.
* **Use Case**: When you need full control to customize and manage your virtualized resources according to specific
  needs.

### PaaS (Platform as a Service)

* **Choose for**: Accelerating development and innovation.
* **Description**: PaaS removes the need for you to manage the underlying infrastructure (hardware and operating
  systems) and allows you to focus on the deployment and management of your applications.
* **Use Case**: When your goal is to speed up application development and reduce time-to-market. Azure PaaS offerings
  abstract away infrastructure tasks so developers can focus on building and deploying code.

### SaaS (Software as a Service)

* **Choose for**: Easy access and scalability.
* **Description**: SaaS provides you with a completed product that is run and managed by the service provider. You just
  use the software, typically via a web browser, without worrying about any infrastructure or application management.
* **Use Case**: When you want ready-to-use, scalable, and cost-effective software solutions that adapt to changing
  business needs with minimal management overhead.

---

## Acronyms

* **IaaS**: Infrastructure as a Service
* **PaaS**: Platform as a Service
* **SaaS**: Software as a Service
