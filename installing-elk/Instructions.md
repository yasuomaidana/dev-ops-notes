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
