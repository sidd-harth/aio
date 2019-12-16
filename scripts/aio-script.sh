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



sudo passwd
  add a password
su
enter paddword

or simply do 
  sudo -s

echo "Setting up Openshift 3.9"
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

// add imagestream redhat openjdk
oc create -f https://gist.githubusercontent.com/tqvarnst/3ca512b01b7b7c1a1da0532939350e23/raw/1973a8baf6e398f534613108e0ec5a774a76babe/openjdk-s2i-imagestream.json -n openshift

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


echo "Installing Istio and setting up Apigee Account"
oc login -u system:admin
mkdir /home/apigee && cd /home/apigee 
wget https://github.com/apigee/istio-mixer-adapter/releases/download/1.0.5/istio-mixer-adapter_1.0.5_linux_64-bit.tar.gz
tar -xvzf istio-mixer-adapter_1.0.5_linux_64-bit.tar.gz 
export PATH=$PATH:$(pwd)
apigee-istio version
apigee-istio provision -f -o mamillarevathi-eval -e test -u mamilla.revathi@tavant.com -p Qwerty@67 > samples/apigee/handler.yaml 

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






echo "Installing Services"
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

cd /home/services/aio/istio
 oc apply -f destination-rule-movies-v1-v2.yml
 oc apply -f virtual-service-movies-v1_100.yml
 oc apply -f destination-rule-payment-v1-v2.yml
 oc apply -f virtual-service-payment-v1_100.yml
 
 while true; do curl -s http://movies-aio.${gcp_external_IP}.nip.io | grep --color -E 'payment-v2|$' ; sleep .5; done

echo "Simple Routing v1 v2 - round robin  all calls to one version Canary deployment: Split traffic between v1 and v2 - 90 10 - 75 25 - 50 50 - 0 100"
 oc apply -f movies-v2-deployment-injected.yml -n aio

 oc replace -f virtual-service-movies-v1_and_v2_10_90.yml
 oc replace -f virtual-service-movies-v1_and_v2_50_50.yml
 oc replace -f virtual-service-movies-v2_100.yml

 while true; do curl -s http://movies-aio.${gcp_external_IP}.nip.io | grep --color -E 'payment-v2|$' ; sleep .5; done

 oc scale deployment movies-v1 --replicas=0 -n aio

****&&&&&^^^^%%%%%%$$$$$$$$#########@****&&&&&^^^^%%%%%%$$$$$$$$#########@****&&&&&^^^^%%%%%%$$$$$$$$#########@****&&&&&^^^^%%%%%%$$$$$$$$#########@

echo "Advacned Routing"
 oc apply -f /home/services4/aio/kubernetes/kube-injected/payment-v2-deployment-injected.yml -n aio

echo "Mirroring Traffic (Dark Launch)" 
 oc replace -f virtual-service-payment-v1-mirror-v2.yml
 
 while true; do  curl -s http://movies-aio.${gcp_external_IP}.nip.io | grep --color -E 'payment-v2|$' ; sleep .5; done

 oc logs -f $(oc get pods|grep payment-v2|awk '{ print $1 }') -c payment --tail=10
 oc logs -f $(oc get pods|grep payment-v1|awk '{ print $1 }') -c payment --tail=10

****&&&&&^^^^%%%%%%$$$$$$$$#########@****&&&&&^^^^%%%%%%$$$$$$$$#########@****&&&&&^^^^%%%%%%$$$$$$$$#########@****&&&&&^^^^%%%%%%$$$$$$$$#########@

echo "user-agent header (Canary Deployment)"
 oc replace -f virtual-service-firefox-payment-v2.yml
 while true; do  curl -s http://movies-aio.${gcp_external_IP}.nip.io | grep --color -E 'payment-v2|$' ; sleep .5; done
 while true; do  curl -s -A "Firefox" http://movies-aio.${gcp_external_IP}.nip.io | grep --color -E 'payment-v2|$' ; sleep .5; done
 oc delete destinationrule payment && oc delete virtualservice payment

****&&&&&^^^^%%%%%%$$$$$$$$#########@****&&&&&^^^^%%%%%%$$$$$$$$#########@****&&&&&^^^^%%%%%%$$$$$$$$#########@****&&&&&^^^^%%%%%%$$$$$$$$#########@

echo "Load Balancer (multiple replicas and random load balancing)"
 oc scale deployment payment-v2 --replicas=3 -n aio
 oc scale deployment payment-v1 --replicas=2 -n aio
 oc apply -f x-destination-rule-payment_lb_policy_app.yml

 while true; do  curl -s http://movies-aio.${gcp_external_IP}.nip.io | grep --color -E 'payment-v2|$' ; sleep .5; done

 oc scale deployment payment-v2 --replicas=1 -n aio
 oc scale deployment payment-v1 --replicas=1 -n aio
 while true; do  curl -s http://movies-aio.${gcp_external_IP}.nip.io | grep --color -E 'payment-v2|$' ; sleep .5; done
 oc delete destinationrule payment

****&&&&&^^^^%%%%%%$$$$$$$$#########@****&&&&&^^^^%%%%%%$$$$$$$$#########@****&&&&&^^^^%%%%%%$$$$$$$$#########@****&&&&&^^^^%%%%%%$$$$$$$$#########@

echo "Fault Injection HTTP Error 401"
 oc apply -f fi-destination-rule-payment.yml
 oc apply -f fi-virtual-service-payment-401.yml

  while true; do  curl -s http://movies-aio.${gcp_external_IP}.nip.io | grep --color -E 'payment-v2|$' ; sleep .5; done
  while true; do  curl -s http://booking-aio.${gcp_external_IP}.nip.io | grep --color -E 'payment-v2|$' ; sleep .5; done

 oc delete -f fi-virtual-service-payment-401.yml

****&&&&&^^^^%%%%%%$$$$$$$$#########@****&&&&&^^^^%%%%%%$$$$$$$$#########@****&&&&&^^^^%%%%%%$$$$$$$$#########@****&&&&&^^^^%%%%%%$$$$$$$$#########@
 
echo "Circuit Breaker (only requires Destination Rules)"
echo "Siege Installation"
 wget -c https://dl.fedoraproject.org/pub/epel/7/x86_64/Packages/s/siege-4.0.2-2.el7.x86_64.rpm https://dl.fedoraproject.org/pub/epel/7/x86_64/Packages/l/libjoedog-0.1.2-1.el7.x86_64.rpm -P installation/
 rpm -ivh installation/*.rpm
 siege version

echo "Delay and CiruitBreaker - Fail Fast with Max Connections & Max Pending Requests"
  while true; do  curl -s http://movies-aio.${gcp_external_IP}.nip.io | grep --color -E 'payment-v2|$' ; sleep .5; done
 oc apply -f fi-virtual-service-payment-delay.yml
  while true; do time curl -s http://movies.com | grep --color -E 'payment-v2|$' ; sleep .5; done
    siege -r 3 -c 10  -v movies-aio.${gcp_external_IP}.nip.io
 oc replace -f fi-destination-rule-payment_cb_policy.yml
    siege -r 3 -c 10  -v movies-aio.${gcp_external_IP}.nip.io
 oc delete destinationrule payment && oc delete virtualservice payment

****&&&&&^^^^%%%%%%$$$$$$$$#########@****&&&&&^^^^%%%%%%$$$$$$$$#########@****&&&&&^^^^%%%%%%$$$$$$$$#########@****&&&&&^^^^%%%%%%$$$$$$$$#########@

echo "Pool Ejection - Ultimate resilience with retries, circuit breaker, and pool ejection"
 oc scale deployment payment-v2 --replicas=2 -n aio

 oc apply -f cpr-destination-rule-payment-v1-v2.yml
 oc apply -f cpr-virtual-service-payment-v1_and_v2_50_50.yml
  while true; do  curl -s http://movies-aio.${gcp_external_IP}.nip.io | grep --color -E 'payment-v2|$' ; sleep .5; done

 oc exec -it $(oc get pods|grep payment-v2|awk '{ print $1 }'|head -1) -c payment /bin/bash
 curl localhost:8080/misbehave
 exit
   while true; do  curl -s http://movies-aio.${gcp_external_IP}.nip.io  | grep --color -E 'payment-v2|$' ; sleep .5; done

 oc replace -f cpr-destination-rule-payment_pool_ejection.yml
  while true; do  curl -s http://movies-aio.${gcp_external_IP}.nip.io  | grep --color -E 'payment-v2|$' ; sleep .5; done
 oc replace -f cpr-virtual-service-payment_retry.yml
  while true; do  curl -s http://movies-aio.${gcp_external_IP}.nip.io  | grep --color -E 'payment-v2|$' ; sleep .5; done
 oc delete destinationrule payment && oc delete virtualservice payment


 oc exec -it $(oc get pods|grep payment-v2|awk '{ print $1 }'|head -1) -c payment /bin/bash
 curl localhost:8080/behave
 exit
   while true; do  curl -s http://movies-aio.${gcp_external_IP}.nip.io  | grep --color -E 'payment-v2|$' ; sleep .5; done

****&&&&&^^^^%%%%%%$$$$$$$$#########@****&&&&&^^^^%%%%%%$$$$$$$$#########@****&&&&&^^^^%%%%%%$$$$$$$$#########@****&&&&&^^^^%%%%%%$$$$$$$$#########@

echo "Egress"
  make a http call in browser and check payment/httpbin
  curl -s http://payment-aio.${gcp_external_IP}.nip.io/httpbin
  oc apply -f service-entry-egress-httpbin.yml

****&&&&&^^^^%%%%%%$$$$$$$$#########@****&&&&&^^^^%%%%%%$$$$$$$$#########@****&&&&&^^^^%%%%%%$$$$$$$$#########@****&&&&&^^^^%%%%%%$$$$$$$$#########@

echo "Show Jaeger, Grafana, Kiali Prometheus, Kibana"
http://servicegraph-istio-system.35.244.32.156.nip.io/dotviz
http://servicegraph-istio-system.35.244.32.156.nip.io/force/forcegraph.html


echo "check Kibana EFK"
echo "using port forwarding and show Kibana on local machine"

create a route in the webconsole
(oc get route kibana -n logging -o json|sed 's/80/5601/')|oc apply -n logging -f -
oc -n logging port-forward $(oc -n logging get pod -l app=kibana -o jsonpath='{.items[0].metadata.name}') 5601:5601 &
echo "using "

echo "Leave the command running. Press Ctrl-C to exit when done accessing the Kibana UI.
Navigate to the Kibana UI and click the Set up index patterns in the top right.
Use * as the index pattern, and click Next step..
Select @timestamp as the Time Filter field name, and click Create index pattern.
Now click “Discover” on the left menu, and start exploring the logs generated "

echo "Prometheus cmd" 
istio_requests_total
istio_requests_total{destination_service="movies.aio.svc.cluster.local"}
istio_requests_total{destination_service="payment.aio.svc.cluster.local"}
istio_requests_total{destination_service="payment.aio.svc.cluster.local", destination_version="v2"}

echo "Rate of requests over the past 25 minutes to all instances of the payment service: "
rate(istio_requests_total{destination_service=~"payment.*", response_code="200"}[25m])
rate(istio_requests_total{destination_service=~"payment.*", response_code="401"}[25m])
rate(istio_requests_total{destination_service=~"payment.*", response_code="503"}[25m])


echo "Citadel MTLS TLS"

echo "checking un encrypted traffic"
oc project aio

MOVIES_POD=$(oc get pod | grep movies | awk '{ print $1}' ); \
oc exec -it $MOVIES_POD -c istio-proxy /bin/bash
IP=$(ifconfig |grep inet |grep 172.|awk '{ print $2}'|sed -e 's/addr://g'); sudo tcpdump -vvvv -A -i eth0 '((dst port 8080) and (net '$IP'))'

curl -s http://movies-aio.${gcp_external_IP}.nip.io
or make a call in browser

oc project aio
yum install jq -y

oc get deploy -l istio=citadel -n istio-system
oc exec $(oc get pod -l app=movies -o jsonpath={.items..metadata.name}) -c istio-proxy -- ls /etc/certs
oc get secret --all-namespaces | grep istio.io/key-and-cert
oc exec $(oc get pod -l app=movies -o jsonpath={.items..metadata.name}) -c istio-proxy -- cat /etc/certs/cert-chain.pem | openssl x509 -text -noout  | grep Validity -A 2
oc get secret -o json istio.default -n aio | jq -r '.data["cert-chain.pem"]' | base64 --decode | openssl x509 -noout -text
oc exec -it $(oc get pod -l app=movies -o jsonpath={.items..metadata.name}) -c istio-proxy -- ls /etc/certs
oc exec $(oc get pod -l app=movies -o jsonpath={.items..metadata.name}) -c istio-proxy -- cat /etc/certs/cert-chain.pem | openssl x509 -text 
oc exec $(oc get pod -l app=movies -o jsonpath={.items..metadata.name}) -c istio-proxy -- cat /etc/certs/key.pem 
oc exec $(oc get pod -l app=movies -o jsonpath={.items..metadata.name}) -c istio-proxy -- cat /etc/certs/root-cert.pem 



echo "Applying Mutual TLS" 
oc apply -f <(curl https://raw.githubusercontent.com/sidd-harth/aio/master/istio/mtls-auth-enable-STRICT-tls.yml)
oc apply -f <(curl https://raw.githubusercontent.com/sidd-harth/aio/master/istio/mtls-destinationrule-tls.yml)
oc apply -f <(curl https://raw.githubusercontent.com/sidd-harth/aio/master/istio/mtls-gateway-movies.yml)

echo "create an secured route for ingress-gateway in Openshift Webconsole"

echo "Testing Services with mTLS"
oc exec $(oc get pod -l app=movies -o jsonpath={.items..metadata.name}) -c istio-proxy -- curl http://movies:8080/ -s 
  Note that the exit code is 56. The code translates to a failure to receive network data.
oc exec $(oc get pod -l app=movies -o jsonpath={.items..metadata.name}) -c istio-proxy -- curl https://movies:8080/ -s -k
  This time the exit code is 35, which corresponds to a problem occurring somewhere in the SSL/TLS handshake.
oc exec $(oc get pod -l app=movies -o jsonpath={.items..metadata.name})  -c istio-proxy -- curl https://movies:8080/ --key /etc/certs/key.pem --cert /etc/certs/cert-chain.pem --cacert /etc/certs/root-cert.pem -k -s
oc exec $(oc get pod -l app=movies -o jsonpath={.items..metadata.name})  -c istio-proxy -- curl http://movies:8080/ --key /etc/certs/key.pem --cert /etc/certs/cert-chain.pem --cacert /etc/certs/root-cert.pem -k -s

echo "Chekcing Encrypted Traffic"
oc project aio

MOVIES_POD=$(oc get pod | grep movies | awk '{ print $1}' ); \
oc exec -it $MOVIES_POD -c istio-proxy /bin/bash
IP=$(ifconfig |grep inet |grep 172.|awk '{ print $2}'|sed -e 's/addr://g'); sudo tcpdump -vvvv -A -i eth0 '((dst port 8080) and (net '$IP'))'


echo "check kiali for lock symbol" 


echo "Apigee Quota/APIKey"
cd /home/apigee
oc apply -f /home/apigee/samples/apigee/definitions.yaml 
oc apply -f /home/apigee/samples/apigee/handler.yaml 
oc apply -f /home/apigee/apigee-istio-adapter-modified_1.0/samples/apigee/rule.yaml


oc delete -f /home/apigee/samples/apigee/definitions.yaml 
oc delete -f /home/apigee/samples/apigee/handler.yaml 
oc delete -f /home/apigee/apigee-istio-adapter-modified_1.0/samples/apigee/rule.yaml


echo "Deleting configs"
oc project aio
oc delete virtualservice --all && oc delete destinationrules --all && oc delete policy --all && oc delete gateway --all



oc get virtualservice 
oc get destinationrules

 oc get rules --all-namespaces

 oc delete project <project-name>
 oc get virtualservice -ojson

 oc delete virtualservice payment-mirror

 echo "Deleting kiali"
 oc delete all,secrets,sa,configmaps,deployments,ingresses,clusterroles,clusterrolebindings,virtualservices,destinationrules,customresourcedefinitions,templates --selector=app=kiali -n istio-system


*&^%$#@!*&^%$#@!*&^%$#@!*&^%$#@!*&^%$#@!*&^%$#@!*&^%$#@!*&^%$#@!*&^%$#@!*&^%$#@!*&^%$#@!*&^%$#@!*&^%$#@!*&^%$#@!*&^%$#@!*&^%$#@!*&^%$#@!*&^%$#@!*&^%$#@!*&^%$#@!*&^%$#@!*&^%$#@!*&^%$#@!*&^%$#@!*&^%$#@!*&^%$#@!*&^%$#@!*&^%$#@!*&^%$#@!

while true; do curl -s http://movies-aio.${gcp_external_IP}.nip.io | grep --color -E 'payment-v2|$' ; sleep .5; done
while true; do curl -s http://movies-aio.${gcp_external_IP}.nip.io | grep --color -E 'payment-service-VERSION-2|$' ; sleep .5; done




export INGRESS_HOST=$(oc -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
export INGRESS_PORT=$(oc -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].port}')
export SECURE_INGRESS_PORT=$(oc -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].port}')

echo ${INGRESS_HOST} ${INGRESS_PORT} ${SECURE_INGRESS_PORT}


./generate.sh movies-aio.35.244.32.156.nip.io password
mkdir ~+1/movies-cert && mv 1_root 2_intermediate 3_application 4_client ~+1/movies-cert
oc create -n istio-system secret tls istio-ingressgateway-certs --key movies-cert2/3_application/private/movies-aio.35.244.32.156.nip.io.key.pem --cert movies-cert2/3_application/certs/movies-aio.35.244.32.156.nip.io.cert.pem
oc exec -it -n istio-system $(oc -n istio-system get pods -l istio=ingressgateway -o jsonpath='{.items[0].metadata.name}') -- ls -al /etc/istio/ingressgateway-certs

oc apply -f - <<EOF
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: movies-gateway
spec:
  selector:
    istio: ingressgateway # use istio default ingress gateway
  servers:
  - port:
      number: 443
      name: https
      protocol: HTTPS
    tls:
      mode: SIMPLE
      serverCertificate: /etc/istio/ingressgateway-certs/tls.crt
      privateKey: /etc/istio/ingressgateway-certs/tls.key
    hosts:
    - "movies-aio.35.244.32.156.nip.io"
EOF


oc apply -f - <<EOF
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: movies
  namespace: aio
spec:
  hosts:
  - "movies-aio.35.244.32.156.nip.io"
  gateways:
  - movies-gateway
  http:
  - match:
    - uri:
        exact: /
    route:
    - destination:
        port:
          number: 8080
        host: movies
EOF

oc apply -f <(curl https://raw.githubusercontent.com/sidd-harth/aio/master/istio/mtls-auth-enable-STRICT-tls.yml)
oc apply -f <(curl https://raw.githubusercontent.com/sidd-harth/aio/master/istio/mtls-destinationrule-tls.yml)
oc apply -f <(curl https://raw.githubusercontent.com/sidd-harth/aio/master/istio/mtls-gateway-movies.yml)

curl -v -HHost:movies-aio.35.244.32.156.nip.io --resolve movies-aio.35.244.32.156.nip.io:$SECURE_INGRESS_PORT:$INGRESS_HOST --cacert movies-cert2/2_intermediate/certs/ca-chain.cert.pem https://movies-aio.35.244.32.156.nip.io:$SECURE_INGRESS_PORT

RESPONSE
[root@apigee-istio-openshift mtls-certs]# curl -v -HHost:movies-aio.35.244.32.156.nip.io --resolve movies-aio.35.244.32.156.nip.io:$SECURE_INGRESS_PORT:$INGRESS_HOST --cacert movies-cert2/2_intermediate/certs/ca-chain.cert.pem --cert movies-cert2/4_client/certs/movies-aio.35.244.32.156.nip.io.cert.pem --key movies-cert2/4_client/private/movies-aio.35.244.32.156.nip.io.key.pem https://movies-aio.35.244.32.156.nip.io:$SECURE_INGRESS_PORT
* Added movies-aio.35.244.32.156.nip.io:443:172.29.100.36 to DNS cache
* About to connect() to movies-aio.35.244.32.156.nip.io port 443 (#0)
*   Trying 172.29.100.36...
* Connected to movies-aio.35.244.32.156.nip.io (172.29.100.36) port 443 (#0)
* Initializing NSS with certpath: sql:/etc/pki/nssdb
*   CAfile: movies-cert2/2_intermediate/certs/ca-chain.cert.pem
  CApath: none
* SSL connection using TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256
* Server certificate:
*       subject: CN=movies-aio.35.244.32.156.nip.io,O=Dis,L=Springfield,ST=Denial,C=US
*       start date: Apr 10 08:55:39 2019 GMT
*       expire date: Apr 19 08:55:39 2020 GMT
*       common name: movies-aio.35.244.32.156.nip.io
*       issuer: CN=movies-aio.35.244.32.156.nip.io,O=Dis,ST=Denial,C=US
> GET / HTTP/1.1
> User-Agent: curl/7.29.0
> Accept: */*
> Host:movies-aio.35.244.32.156.nip.io
> 
< HTTP/1.1 200 OK
< content-type: text/plain;charset=UTF-8
< content-length: 102
< date: Wed, 10 Apr 2019 10:15:50 GMT
< x-envoy-upstream-service-time: 20
< server: envoy
< 
movies-v1 => booking-ticket-v1 => payment-service-version-1 - pod-ip -  payment-v1-66dc47d49-dpwmp 85
* Connection #0 to host movies-aio.35.244.32.156.nip.io left intact

/////////////////////**********&^%$#@$%^&   MTLS - MUTUALLLLLLLLLLLLLLLLLL

oc create -n istio-system secret generic istio-ingressgateway-ca-certs --from-file=movies-cert2/2_intermediate/certs/ca-chain.cert.pem

change TLS mode from simple to MUTUAL,

oc apply -f - <<EOF
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: movies-gateway
spec:
  selector:
    istio: ingressgateway # use istio default ingress gateway
  servers:
  - port:
      number: 443
      name: https
      protocol: HTTPS
    tls:
      mode: MUTUAL
      serverCertificate: /etc/istio/ingressgateway-certs/tls.crt
      privateKey: /etc/istio/ingressgateway-certs/tls.key
      caCertificates: /etc/istio/ingressgateway-ca-certs/ca-chain.cert.pem
    hosts:
    - "movies-aio.35.244.32.156.nip.io"
EOF



curl -v -HHost:movies-aio.35.244.32.156.nip.io --resolve movies-aio.35.244.32.156.nip.io:$SECURE_INGRESS_PORT:$INGRESS_HOST --cacert movies-cert2/2_intermediate/certs/ca-chain.cert.pem --cert movies-cert2/4_client/certs/movies-aio.35.244.32.156.nip.io.cert.pem --key movies-cert2/4_client/private/movies-aio.35.244.32.156.nip.io.key.pem https://movies-aio.35.244.32.156.nip.io:$SECURE_INGRESS_PORT

RESPONSE
ntermediate/certs/ca-chain.cert.pem --cert movies-cert2/4_client/certs/movies-aio.35.244.32.156.nip.io.cert.pem --key movies-cert2/4_client/private/movies-aio.35.244.32.156.nip.io.key.pem https://movies-aio.35.244.32.156.nip.io
* Added movies-aio.35.244.32.156.nip.io:443:172.29.100.36 to DNS cache
* About to connect() to movies-aio.35.244.32.156.nip.io port 443 (#0)
*   Trying 172.29.100.36...
* Connected to movies-aio.35.244.32.156.nip.io (172.29.100.36) port 443 (#0)
* Initializing NSS with certpath: sql:/etc/pki/nssdb
*   CAfile: movies-cert2/2_intermediate/certs/ca-chain.cert.pem
  CApath: none
* NSS: client certificate from file
*       subject: CN=movies-aio.35.244.32.156.nip.io,O=Dis,L=Springfield,ST=Denial,C=US
*       start date: Apr 10 08:55:42 2019 GMT
*       expire date: Apr 19 08:55:42 2020 GMT
*       common name: movies-aio.35.244.32.156.nip.io
*       issuer: CN=movies-aio.35.244.32.156.nip.io,O=Dis,ST=Denial,C=US
* SSL connection using TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256
* Server certificate:
*       subject: CN=movies-aio.35.244.32.156.nip.io,O=Dis,L=Springfield,ST=Denial,C=US
*       start date: Apr 10 08:55:39 2019 GMT
*       expire date: Apr 19 08:55:39 2020 GMT
*       common name: movies-aio.35.244.32.156.nip.io
*       issuer: CN=movies-aio.35.244.32.156.nip.io,O=Dis,ST=Denial,C=US
> GET / HTTP/1.1
> User-Agent: curl/7.29.0
> Accept: */*
> Host:movies-aio.35.244.32.156.nip.io
> 
< HTTP/1.1 200 OK
< content-type: text/plain;charset=UTF-8
< content-length: 102
< date: Wed, 10 Apr 2019 09:53:03 GMT
< x-envoy-upstream-service-time: 26
< server: envoy
< 
movies-v1 => booking-ticket-v1 => payment-service-version-1 - pod-ip -  payment-v1-66dc47d49-dpwmp 82
* Connection #0 to host movies-aio.35.244.32.156.nip.io left intact



=========

check htttps with gateway and add cors to virtual service in mtls example


apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: customer-gateway
spec:
  selector:
    istio: ingressgateway # use istio default controller
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - "*"
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: customer
  namespace: tutorial
spec:
  hosts:
  - "*"
  gateways:
  - customer-gateway
  http:
  - match:
    - uri:
        exact: /
    route:
    - destination:
        host: customer
        port:
          number: 8080
    corsPolicy:
      allowOrigin:
      - "*"
      allowMethods:
      - GET
      allowHeaders:
      - "*"
allowCredentials: true


///setting up kiali manually 

/*
echo "Install Kiali's configmap"
curl https://raw.githubusercontent.com/kiali/kiali/${VERSION_LABEL}/deploy/openshift/kiali-configmap.yaml | \
  VERSION_LABEL=${VERSION_LABEL} \
  JAEGER_URL=${JAEGER_URL}  \
  GRAFANA_URL=${GRAFANA_URL} envsubst | oc create -n istio-system -f -

echo "Install Kiali's secrets"
curl https://raw.githubusercontent.com/kiali/kiali/${VERSION_LABEL}/deploy/openshift/kiali-secrets.yaml | \
  VERSION_LABEL=${VERSION_LABEL} envsubst | oc create -n istio-system -f -

echo "Deploy Kiali to the cluster"
curl https://raw.githubusercontent.com/kiali/kiali/${VERSION_LABEL}/deploy/openshift/kiali.yaml | \
  VERSION_LABEL=${VERSION_LABEL}  \
  IMAGE_NAME=kiali/kiali \
  IMAGE_VERSION=${VERSION_LABEL}  \
  NAMESPACE=istio-system  \
  VERBOSE_MODE=4  \
  IMAGE_PULL_POLICY_TOKEN="imagePullPolicy: Always" envsubst | oc create -n istio-system -f -
*/


echo "DialogFlow Payment Destinationrule & VirtualService"
     //oc apply -f <(curl -s https://raw.githubusercontent.com/sidd-harth/aio/master/istio/destination-rule-payment-v1-v2.yml)
     //oc apply -f <(curl -s https://raw.githubusercontent.com/sidd-harth/aio/master/istio/dialogFlow-payment-v2.yml)
first both payment v1 and v2 should be runnning
then we will show payment v2 giving misbahevae 503 
route all traffic to payment v1 --- oc apply -f <(curl https://raw.githubusercontent.com/sidd-harth/aio/master/istio/dialogFlow-payment-v1-100.yml)
behave pay v2 200
replace pay vs with cananry vs -- oc apply -f <(curl https://raw.githubusercontent.com/sidd-harth/aio/master/istio/dialogFlow-payment-v2-10.yml)
both v1 and v2 oc delete -f <(curl https://raw.githubusercontent.com/sidd-harth/aio/master/istio/dialogFlow-payment-v2-10.yml)
only v2 both v1 and v2 - oc apply -f <(curl https://raw.githubusercontent.com/sidd-harth/aio/master/istio/dialogFlow-payment-v2.yml)



remove payment v2 service or discontinue traffic to payment v2 service
add payment v2 service to production instance and route only 10% traffic to it. or route only 10% traffic to payment v2
route traffic to payment v1 and v2 service equally
route all traffic to payment v2
