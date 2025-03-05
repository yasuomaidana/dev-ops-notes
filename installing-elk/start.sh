## ---- Starting the services ----
# Reload the system manager configuration
sudo systemctl daemon-reload 

# Enable the services
sudo systemctl enable elasticsearch.service
sudo systemctl enable filebeat
sudo systemctl enable logstash.service
sudo systemctl enable kibana.service

mv /etc/kibana/kibana.yml /etc/kibana/kibana.yml.bak
# mv /etc/elasticsearch/elasticsearch.yml /etc/elasticsearch/elasticsearch.yml.bak
# mv /elasticsearch.yml /etc/elasticsearch/elasticsearch.yml
mv /kibana.yml /etc/kibana/kibana.yml

# Start the services
sudo systemctl start elasticsearch.service 
sudo systemctl start filebeat 
sudo systemctl start logstash.service 
sudo systemctl start kibana.service
sudo systemctl start nginx

echo "All services started successfully"

ps aux 