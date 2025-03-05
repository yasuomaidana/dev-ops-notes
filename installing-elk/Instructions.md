# Instructions

The easieast way to run elk is using the following command: `curl -fsSL https://elastic.co/start-local | sh`, see more information [here](https://www.elastic.co/guide/en/elasticsearch/reference/current/run-elasticsearch-locally.html)

## Installing ELK stack

The ELK stack is a collection of three open-source products — Elasticsearch, Logstash, and Kibana — all developed, managed, and maintained by Elastic. The stack is used for searching, analyzing, and visualizing log data in real-time.

- **Elasticsearch**: A search and analytics engine. It is used for storing, searching, and analyzing big volumes of data quickly and in near real-time. Elasticsearch is the heart of the ELK stack.

- **Logstash**: A server-side data processing pipeline that ingests data from multiple sources simultaneously, transforms it, and then sends it to a “stash” like Elasticsearch. It is used for collecting, parsing, and storing logs for future use.

- **Kibana**: A data visualization and exploration tool used for log and time-series analytics, application monitoring, and operational intelligence use cases. It provides powerful and easy-to-use features such as histograms, line graphs, pie charts, and maps.

- **Filebeat**: A lightweight shipper for forwarding and centralizing log data. Installed as an agent on your servers, Filebeat monitors the log files or locations that you specify, collects log events, and forwards them either to Elasticsearch or Logstash for indexing.

We call it the ELK stack because it is an acronym of the three main components: Elasticsearch, Logstash, and Kibana. Filebeat is often included in the stack, but the original name remains ELK.

### Installing elastic a debian environment[^1]

1. Download and store GPG key for elastic search

    - `wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg`

    - `wget`: A command-line utility to download files from the web.
    - `q`: Quiet mode, suppresses output.
    - `O -`: Outputs the downloaded content to standard output (stdout) instead of saving it to a file.
    - `https://artifacts.elastic.co/GPG-KEY-elasticsearch`: The URL from which the GPG key is being downloaded.

2. Take the output of the previous command and pass it as input to the following command. Use pipe `|` operator

3. Install and specify where the output file where the binary key will be stored. `sudo gpg --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg`

    - `sudo`: Runs the command with superuser (root) privileges.
    - `gpg`: The GNU Privacy Guard, a tool for secure communication and data storage.
    - `-dearmor`: Converts the ASCII-armored GPG key to binary format.
    - `-o` /usr/share/keyrings/elasticsearch-keyring.gpg: Specifies the output file where the binary key will be saved.

4. Install `apt-transport-https`, which is a package for Debian-based systems (like Ubuntu) that allows the apt package manager to access repositories over the HTTPS protocol. By default, apt can handle HTTP, FTP, and file URIs, but not HTTPS. `sudo apt-get install apt-transport-https`

5. Save the repository definition to  `/etc/apt/sources.list.d/elastic-8.x.list`. To do this, run `echo "deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-8.x.list`

6. Install elastic search `sudo apt-get update && sudo apt-get install elasticsearch`

> Be careful to save the generated password, in this example we will pipe the output and save it into `install_output.txt`. But please be careful, you must follow

Just run:

```sh
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg

sudo apt-get install apt-transport-https
echo "deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-8.x.list

sudo apt-get update && sudo apt-get install elasticsearch | grep "The generated password for the elastic built-in superuser is" > install_output.txt
```

### Install kibana

After installing elastic. You only need to run `sudo apt-get install kibana`

### Install logstash

`sudo apt-get install logstash`

### Install filebeat

`sudo apt-get install filebeat`

[^1]: These instructions can be  found [here](https://www.elastic.co/guide/en/elasticsearch/reference/current/deb.html).

## Additional packages

- **`systemctl`** is a command-line utility in Linux used to control the systemd system and service manager. It allows you to manage services, check their status, enable or disable them at startup, and perform various other system-related tasks. Important commands:

  - Start a service: `sudo systemctl start`
  - Stop a service: `sudo systemctl stop <service-name>`
  - Enable a service to start at boot: `sudo systemctl enable <service-name>`
  - List all active services: `sudo systemctl list-units --type=service --state=active`

- **ngnix** is

## Starting the services

1. Run `sudo systemctl daemon-reload`, which is used to reload the systemd manager configuration. This is necessary when you have made changes to unit files (such as service files) or other configuration files that systemd uses to manage services.

2. Enable all services by running

```sh
sudo systemctl enable elasticsearch.service

sudo systemctl enable filebeat

sudo systemctl enable logstash.service

sudo systemctl enable kibana.service
```

3. Start all the services. Please before starting the service, ensure they are not running yet.

```sh
sudo systemctl start elasticsearch.service

sudo systemctl start filebeat

sudo systemctl start logstash.service

sudo systemctl start kibana.service
```

> You can check if they are running using `ps aux | grep elastic`. You can change `elastic` by any service you want to check if is running.

## Checking with ngnix

Nginx (pronounced "engine-x") is a high-performance HTTP server and reverse proxy, as well as an IMAP/POP3 proxy server. It is known for its stability, rich feature set, simple configuration, and low resource consumption.

In the context of the ELK stack, Nginx can be used as a reverse proxy to manage and distribute incoming traffic to the various components of the stack, such as Elasticsearch, Logstash, and Kibana. This setup can help improve security, load balancing, and performance by handling client requests more efficiently and providing an additional layer of protection.

For example, you can configure Nginx to route requests to Kibana, allowing you to access the Kibana dashboard through a specific URL while securing it with SSL/TLS and basic authentication.

Check logs:

- `cat /var/log/nginx/access.log`
- `cat /var/log/nginx/error.log`

Check if running

`ps aux | grep nginx`

<!-- TODO: Add explanation about how to expose kibana, remember change the host in the kibana.yaml -->
