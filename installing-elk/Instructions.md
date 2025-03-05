# Instructions

The easieast way to run elk is using the following command: `curl -fsSL https://elastic.co/start-local | sh`, see more information [here](https://www.elastic.co/guide/en/elasticsearch/reference/current/run-elasticsearch-locally.html)

## In a linux environment[^1]

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

Just run:

```sh
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg
```

[^1]: These instructions can be  fouund [here](https://www.elastic.co/guide/en/elasticsearch/reference/current/deb.html).
