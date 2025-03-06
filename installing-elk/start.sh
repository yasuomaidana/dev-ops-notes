## ---- Starting the services ----
# Reload the system manager configuration
sudo systemctl daemon-reload 

# Enable the services
sudo systemctl enable elasticsearch.service
sudo systemctl enable filebeat
sudo systemctl enable logstash.service
sudo systemctl enable kibana.service

## Generating backup of the configuration files
mv /etc/kibana/kibana.yml /etc/kibana/kibana.yml.bak
mv /etc/filebeat/filebeat.yml /etc/filebeat/filebeat.yml.bak
mv /etc/elasticsearch/elasticsearch.yml /etc/elasticsearch/elasticsearch.yml.bak

## Copying the configuration files
mv /kibana.yml /etc/kibana/kibana.yml
mv /filebeat.yml /etc/filebeat/filebeat.yml
mv /elasticsearch.yml /etc/elasticsearch/elasticsearch.yml
mv /nginx.conf /etc/logstash/conf.d/nginx.conf


sudo chown root:kibana /etc/kibana/kibana.yml
sudo chmod 660 /etc/kibana/kibana.yml
sudo chmod 2750 /etc/kibana/kibana.yml
sudo chmod 2750 /etc/kibana

cd /etc && chmod 2750 kibana
cd ..

echo cat install_output.txt | grep "The generated password for the elastic built-in superuser is : "

# Start the services
sudo systemctl start elasticsearch.service 
sudo systemctl start filebeat 
sudo systemctl start logstash.service 
sudo systemctl start kibana.service
sudo systemctl start nginx

echo "All services started successfully"

ps aux 