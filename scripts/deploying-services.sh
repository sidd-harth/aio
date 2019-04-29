#!/bin/bash
sudo -s
echo "Deploying Services"
mkdir /home/services4 && cd /home/services4
git clone https://github.com/sidd-harth/aio
cd aio/kubernetes/kube-injected/

echo "Creating Project and enabling istio-injection"
oc new-project aio  
oc adm policy add-scc-to-user privileged -z default -n aio  
oc label  namespace aio istio-injection=enabled 
#oc get pods -w -n istio-system

oc project aio

echo "Deploying Movies Service"
oc apply -f movies-v1-deployment-injected.yml -n aio
oc create -f movies-service.yml -n aio 
oc expose svc movies -n aio

echo "Deploying Booking Service"
oc apply -f booking-v1-deployment-injected.yml -n aio
oc create -f booking-service.yml -n aio 
oc expose svc booking -n aio

echo "Deploying Payment Service"
oc apply -f payment-v1-deployment-injected.yml -n aio
oc create -f payment-service.yml -n aio 
oc expose svc payment -n aio

echo "Deploying UI Service"
oc apply -f ui-v1-deployment-injected.yml -n aio
oc create -f ui-service.yml -n aio
oc expose svc ui -n aio



oc get routes 
 while true; do curl -s http://movies-aio.${gcp_external_IP}.nip.io | grep --color -E 'payment-v2|$' ; sleep .5; done
