FROM debian:bullseye
## ---- Installating ELK stack ----
# Preparing the environment
RUN apt-get update && apt-get install -y wget sudo gnupg systemctl nginx nginx-full curl vim 
# Preparing the elasticsearch installation
RUN wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg
RUN sudo apt-get install apt-transport-https
RUN echo "deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-8.x.list
RUN sudo apt-get update 
RUN sudo apt-get install elasticsearch > install_output.txt
RUN sudo apt-get install kibana
RUN sudo apt-get install logstash
RUN sudo apt-get install filebeat
## ---- END: Installating ELK stack ----

## ---- Starting the services ----
# Reload the system manager configuration
# RUN sudo systemctl daemon-reload 

# Enable the services
# RUN sudo systemctl enable elasticsearch.service
# RUN sudo systemctl enable filebeat
# RUN sudo systemctl enable logstash.service
# RUN sudo systemctl enable kibana.service

COPY kibana.yml /kibana.yml
COPY filebeat.yaml /filebeat.yml
COPY nginx.conf /nginx.conf


COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 9200 9300 5601 80

# Start the services
# RUN sudo systemctl start elasticsearch.service
# RUN sudo systemctl start filebeat
# RUN sudo systemctl start logstash.service
# RUN sudo systemctl start kibana.service
## ---- END: Starting the services ----
CMD ["/bin/bash", "-c", "/start.sh && exec /bin/bash"]

# CMD ["sh", "-c", "sudo systemctl start elasticsearch.service filebeat logstash.service kibana.service && tail -f /dev/null"]
