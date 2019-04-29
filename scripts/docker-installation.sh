#!/bin/bash
sudo echo "Instllaing Docker"
sudo yum install -y yum-utils  device-mapper-persistent-data  lvm2
sudo yum-config-manager --add-repo  https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install -y docker-ce docker-ce-cli containerd.io 
sudo systemctl start docker
sudo docker run hello-world

sudo echo "Adding Insecure registry entry"
sudo   echo "{
     "insecure-registries": [
       "172.30.0.0/16"
     ]
  }" > /etc/docker/daemon.json

sudo systemctl daemon-reload
sudo systemctl restart docker

sudo echo "Checking subset: 172.17.0.0/16"
sudo docker network inspect -f "{{range .IPAM.Config }}{{ .Subnet }}{{end}}" bridge

sudo firewall-cmd --permanent --new-zone dockerc
sudo firewall-cmd --permanent --zone dockerc --add-source 172.17.0.0/16
sudo firewall-cmd --permanent --zone dockerc --add-port 8443/tcp
sudo firewall-cmd --permanent --zone dockerc --add-port 53/udp
sudo firewall-cmd --permanent --zone dockerc --add-port 8053/udp
sudo firewall-cmd --reload