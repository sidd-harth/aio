#!/bin/bash
echo "Installing Istio and setting up Apigee Account"
sudo -s
oc login -u system:admin
mkdir /home/apigee && cd /home/apigee 
wget https://github.com/apigee/istio-mixer-adapter/releases/download/1.0.5/istio-mixer-adapter_1.0.5_linux_64-bit.tar.gz
tar -xvzf istio-mixer-adapter_1.0.5_linux_64-bit.tar.gz 
export PATH=$PATH:$(pwd)
apigee-istio version
apigee-istio provision -f -o {organization} -e {environment} -u {user-email} -p {user-password} > samples/apigee/handler.yaml 

cd /home/apigee 
wget https://github.com/sidd-harth/apigee-istio-adapter/archive/modified_1.0.tar.gz
tar -xvzf /home/apigee/modified_1.0.tar.gz
cd apigee-istio-adapter-modified_1.0
oc apply -f samples/istio/crds.yaml
oc apply -f samples/istio/istio-demo.yaml

echo "180 seconds wait time for Lazyyy Istio-System Pods"
sleep 180
oc get pods -n istio-system

echo "Exposing Istio Routes"
oc expose svc istio-ingressgateway -n istio-system &&
oc expose svc servicegraph -n istio-system &&
oc expose svc grafana -n istio-system &&
oc expose svc prometheus -n istio-system &&
oc expose svc tracing -n istio-system 

echo "Kiali Dashboard - Define URLS for Jaeger and Grafana"
export JAEGER_URL="http://tracing-istio-system.${gcp_external_IP}.nip.io" \
export GRAFANA_URL="http://grafana-istio-system.${gcp_external_IP}.nip.io" \
export IMAGE_VERSION="v0.16.0" \
export VERSION_LABEL="v0.16.0" \
export AUTH_STRATEGY="anonymous"

bash <(curl -L https://raw.githubusercontent.com/sidd-harth/aio/master/kiali-setup.sh)

echo "Create a new Kiali Route for the port 443"
(oc get route kiali -n istio-system -o json|sed 's/80/443/')|oc apply -n istio-system -f -

//// (oc get route movies -n aio -o json|sed 's/80/443/')|oc apply -n aio -f -
//// (oc get route movies -n aio -o json|sed 's/80/443/')|oc apply -n aio -f -

sleep 5


echo "Adding EFK using ISTIO - https://istio.io/docs/tasks/telemetry/logs/fluentd/ "
oc apply -f <(curl https://raw.githubusercontent.com/sidd-harth/aio/master/efk-logging-stack.yaml)
oc apply -f <(curl https://raw.githubusercontent.com/sidd-harth/aio/master/fluentd-istio.yaml)



echo "Apigee Quota/APIKey"
cd /home/apigee
oc apply -f /home/apigee/samples/apigee/definitions.yaml 
oc apply -f /home/apigee/samples/apigee/handler.yaml 

echo "Docker Apigee Istio Openshift Installation Successful"
