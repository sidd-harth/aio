#!/bin/bash
echo "Setting up Openshift 3.9"
sudo -s
yum install -y wget 
yum install -y git
mkdir /home/oc && cd /home/oc 
wget https://github.com/openshift/origin/releases/download/v3.9.0/openshift-origin-client-tools-v3.9.0-191fece-linux-64bit.tar.gz
tar -xvzf /home/oc/openshift-origin-client-tools-v3.9.0-191fece-linux-64bit.tar.gz
export PATH=/home/oc/openshift-origin-client-tools-v3.9.0-191fece-linux-64bit:$PATH
oc version

echo "GET GCP External IP Address" 
gcp_external_IP=$(curl -H "Metadata-Flavor: Google" http://169.254.169.254/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip)

mkdir /home/installation && mkdir /home/installation/etcd10 && cd /home/installation

oc cluster up --public-hostname=${gcp_external_IP} --metrics  --host-data-dir=/home/installation/etcd10
oc login -u system:admin

//creating an admin role to login into webconsole
oc create clusterrolebinding registry-controller --clusterrole=cluster-admin --user=admin

oc adm policy add-scc-to-user anyuid -z istio-ingress-service-account -n istio-system &&
oc adm policy add-scc-to-user anyuid -z default -n istio-system &&
oc adm policy add-scc-to-user anyuid -z prometheus -n istio-system &&
oc adm policy add-scc-to-user anyuid -z istio-egressgateway-service-account -n istio-system &&
oc adm policy add-scc-to-user anyuid -z istio-citadel-service-account -n istio-system &&
oc adm policy add-scc-to-user anyuid -z istio-ingressgateway-service-account -n istio-system &&
oc adm policy add-scc-to-user anyuid -z istio-cleanup-old-ca-service-account -n istio-system &&
oc adm policy add-scc-to-user anyuid -z istio-mixer-post-install-account -n istio-system &&
oc adm policy add-scc-to-user anyuid -z istio-mixer-service-account -n istio-system &&
oc adm policy add-scc-to-user anyuid -z istio-pilot-service-account -n istio-system &&
oc adm policy add-scc-to-user anyuid -z istio-sidecar-injector-service-account -n istio-system &&
oc adm policy add-cluster-role-to-user cluster-admin -z istio-galley-service-account -n istio-system &&
oc adm policy add-scc-to-user anyuid -z cluster-local-gateway-service-account -n istio-system &&
oc adm policy add-scc-to-user anyuid -z istio-galley-service-account -n istio-system
