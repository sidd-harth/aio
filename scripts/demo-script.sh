#!/bin/bash

PS1='\[\e[01;36m\]\u\[\e[01;37m\]@\[\e[01;33m\]\H\[\e[01;37m\]:\[\e[01;32m\]\w\[\e[01;37m\]\$\[\033[0;37m\] '


sudo systemctl daemon-reload
sudo systemctl restart docker

sudo -s

echo "activate profile paths for openshift and istio"
source ~/.bash_profile


mkdir /home/oc && cd /home/oc 
wget https://github.com/openshift/origin/releases/download/v3.9.0/openshift-origin-client-tools-v3.9.0-191fece-linux-64bit.tar.gz
tar -xvzf /home/oc/openshift-origin-client-tools-v3.9.0-191fece-linux-64bit.tar.gz
export PATH=/home/oc/openshift-origin-client-tools-v3.9.0-191fece-linux-64bit:$PATH
oc version

echo "GET GCP External IP Address" 
gcp_external_IP=$(curl -H "Metadata-Flavor: Google" http://169.254.169.254/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip)

mkdir /home/installation && mkdir /home/installation/4 && cd /home/installation

oc cluster up --public-hostname=${gcp_external_IP} --host-data-dir=/home/installation/4
oc login -u system:admin
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


echo "Installing Istio"
mkdir /home/istio && cd /home/istio
wget https://github.com/istio/istio/releases/download/1.0.5/istio-1.0.5-linux.tar.gz
tar -xvzf istio-1.0.5-linux.tar.gz
cd /home/istio/istio-1.0.5/bin
export PATH=$PATH:$(pwd)
istioctl version

cd /home/istio
oc apply -f istio-1.0.5/install/kubernetes/helm/istio/templates/crds.yaml
oc apply -f istio-1.0.5/install/kubernetes/istio-demo.yaml



oc get svc istio-ingressgateway -n istio-system

oc apply -f https://raw.githubusercontent.com/sidd-harth/aio/master/istio/expose-prometheus.yml
oc apply -f https://raw.githubusercontent.com/sidd-harth/aio/master/istio/expose-grafana.yml
oc apply -f https://raw.githubusercontent.com/sidd-harth/aio/master/istio/expose-tracing.yml
oc apply -f https://raw.githubusercontent.com/sidd-harth/aio/master/istio/expose-kiali.yml

echo "update ingress gateway svc yaml with"
    - name: http2-prometheus
      nodePort: 31311
      port: 15030
      protocol: TCP
      targetPort: 15030
    - name: http2-grafana
      nodePort: 31312
      port: 15031
      protocol: TCP
      targetPort: 15031
    - name: http2-tracing
      nodePort: 31313
      port: 15032
      protocol: TCP
      targetPort: 15032
    - name: http2-kiali
      nodePort: 31314
      port: 15029
      protocol: TCP
      targetPort: 15029

oc scale deployment istio-ingressgateway --replicas=0 -n istio-system
oc scale deployment istio-ingressgateway --replicas=1 -n istio-system

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

sleep 5

echo "Adding EFK using ISTIO - https://istio.io/docs/tasks/telemetry/logs/fluentd/ "
oc apply -f <(curl https://raw.githubusercontent.com/sidd-harth/aio/master/efk-logging-stack.yaml)
oc apply -f <(curl https://raw.githubusercontent.com/sidd-harth/aio/master/fluentd-istio.yaml)

echo "port-forward kibana"
oc -n logging port-forward $(oc -n logging get pod -l app=kibana -o jsonpath='{.items[0].metadata.name}') 5601:5601

&####################################################################################################################
echo "port-forward UI, Prometheus, Kiali, Grafana, Tracing"
oc -n istio-system port-forward $(oc -n istio-system get pod -l app=grafana -o jsonpath='{.items[0].metadata.name}') 3000:3000
oc -n istio-system port-forward $(oc -n istio-system get pod -l app=jaeger -o jsonpath='{.items[0].metadata.name}') 9898:16686
oc -n istio-system port-forward $(oc -n istio-system get pod -l app=prometheus -o jsonpath='{.items[0].metadata.name}') 9090:9090

oc -n istio-system port-forward $(oc -n istio-system get pod -l app=kiali -o jsonpath='{.items[0].metadata.name}') 2222:20001
oc -n aio port-forward $(oc -n aio get pod -l app=ui -o jsonpath='{.items[0].metadata.name}') 1111:80
&####################################################################################################################


oc new-project manual-injection
oc adm policy add-scc-to-user anyuid -z default -n manual-injection
oc adm policy add-scc-to-user privileged -z default -n manual-injection

oc get namespace -L istio-injection
oc label  namespace manual-injection istio-injection=enabled 
oc label  namespace manual-injection istio-injection-

wget https://raw.githubusercontent.com/sidd-harth/aio/master/kubernetes/openshift/deployment-v1-payment.yml
oc apply -f deployment-v1-payment.yml
curl localhost:8080/ui | json_pp
oc get deployment -o wide

oc apply -f <(istioctl kube-inject -f deployment-v1-payment.yml)

istioctl kube-inject -f deployment-v1-payment.yml > injection.yml
oc describe configmap istio-sidecar-injector -n istio-system

&####################################################################################################################

echo "Installing Services"

echo "Creating Project and enabling istio-injection"
oc new-project aio  
oc adm policy add-scc-to-user privileged -z default -n aio  
oc label  namespace aio istio-injection=enabled 

oc project aio

echo "Deploying Movies Service"
oc apply -f https://raw.githubusercontent.com/sidd-harth/aio/master/kubernetes/kube-injected/movies-v1-deployment-injected.yml -n aio
oc create -f https://raw.githubusercontent.com/sidd-harth/aio/master/kubernetes/kube-injected/movies-service.yml -n aio 
oc expose svc movies -n aio

echo "Deploying Booking Service"
oc apply -f https://raw.githubusercontent.com/sidd-harth/aio/master/kubernetes/kube-injected/booking-v1-deployment-injected.yml -n aio
oc create -f https://raw.githubusercontent.com/sidd-harth/aio/master/kubernetes/kube-injected/booking-service.yml -n aio 
oc expose svc booking -n aio

echo "Deploying Payment Service"
oc apply -f https://raw.githubusercontent.com/sidd-harth/aio/master/kubernetes/kube-injected/payment-v1-deployment-injected.yml -n aio
oc create -f https://raw.githubusercontent.com/sidd-harth/aio/master/kubernetes/kube-injected/payment-service.yml -n aio 
oc expose svc payment -n aio

echo "Deploying UI Service"
oc apply -f https://raw.githubusercontent.com/sidd-harth/aio/master/kubernetes/kube-injected/ui-v1-deployment-injected.yml -n aio
oc create -f https://raw.githubusercontent.com/sidd-harth/aio/master/kubernetes/kube-injected/ui-service.yml -n aio
oc expose svc ui -n aio

oc get routes 

&############################################################################################################################################

echo "https://istio.io/docs/ops/best-practices/traffic-management/"
echo "Default Istio Traffic Routes"
 oc apply -f https://raw.githubusercontent.com/sidd-harth/aio/master/istio/destination-rule-movies-v1-v2.yml
 oc apply -f https://raw.githubusercontent.com/sidd-harth/aio/master/istio/virtual-service-movies-v1_100.yml
 oc apply -f https://raw.githubusercontent.com/sidd-harth/aio/master/istio/destination-rule-payment-v1-v2.yml
 oc apply -f https://raw.githubusercontent.com/sidd-harth/aio/master/istio/virtual-service-payment-v1_100.yml
 
echo "Simple Routing v1 v2 - round robin  all calls to one version Canary deployment: Split traffic between v1 and v2 - 90 10 - 75 25 - 50 50 - 0 100"
 
 oc apply -f https://raw.githubusercontent.com/sidd-harth/aio/master/kubernetes/kube-injected/movies-v2-deployment-injected.yml


 oc replace -f https://raw.githubusercontent.com/sidd-harth/aio/master/istio/virtual-service-movies-v1_and_v2_50_50.yml
 oc replace -f https://raw.githubusercontent.com/sidd-harth/aio/master/istio/virtual-service-movies-v1_and_v2_10_90.yml
 oc replace -f https://raw.githubusercontent.com/sidd-harth/aio/master/istio/virtual-service-movies-v2_100.yml

 echo "check - show UI"

 oc scale deployment movies-v1 --replicas=0 -n aio

&#####################################################################################################################################################

echo "Advacned Routing"
 oc apply -f https://raw.githubusercontent.com/sidd-harth/aio/master/kubernetes/kube-injected/payment-v2-deployment-injected.yml -n aio

echo "Mirroring Traffic (Dark Launch)" 
 oc replace -f https://raw.githubusercontent.com/sidd-harth/aio/master/istio/virtual-service-payment-v1-mirror-v2.yml
 
 while true; do  curl -s http://movies-aio.${gcp_external_IP}.nip.io | grep --color -E 'payment-v2|$' ; sleep .5; done

 oc logs -f $(oc get pods|grep payment-v2|awk '{ print $1 }') -c payment --tail=10
 oc logs -f $(oc get pods|grep payment-v1|awk '{ print $1 }') -c payment --tail=10

&####################################################################################################################################################

echo "user-agent header (Canary Deployment)"
 oc replace -f https://raw.githubusercontent.com/sidd-harth/aio/master/istio/virtual-service-firefox-payment-v2.yml
 while true; do  curl -s -A "Firefox" http://movies-aio.${gcp_external_IP}.nip.io | grep --color -E 'payment-v2|$' ; sleep .5; done
 
 oc replace -f  https://raw.githubusercontent.com/sidd-harth/aio/master/istio/virtual-service-edge-payment-v2.yml
 while true; do  curl -s -A "Edge" http://movies-aio.${gcp_external_IP}.nip.io | grep --color -E 'payment-v2|$' ; sleep .5; done
 while true; do  curl -s http://movies-aio.${gcp_external_IP}.nip.io | grep --color -E 'payment-v2|$' ; sleep .5; done
 
 oc delete destinationrule payment && oc delete virtualservice payment

&####################################################################################################################################################

echo "Load Balancer (multiple replicas and random load balancing)"
 oc scale deployment payment-v2 --replicas=3 -n aio
 oc scale deployment payment-v1 --replicas=2 -n aio
 oc apply -f https://raw.githubusercontent.com/sidd-harth/aio/master/istio/x-destination-rule-payment_lb_policy_app.yml

 while true; do  curl -s http://movies-aio.${gcp_external_IP}.nip.io | grep --color -E 'payment-v2|$' ; sleep .5; done

 oc scale deployment payment-v2 --replicas=1 -n aio
 oc scale deployment payment-v1 --replicas=1 -n aio
 while true; do  curl -s http://movies-aio.${gcp_external_IP}.nip.io | grep --color -E 'payment-v2|$' ; sleep .5; done
 oc delete destinationrule payment

&####################################################################################################################################################

echo "Fault Injection HTTP Error 401"
 oc apply -f https://raw.githubusercontent.com/sidd-harth/aio/master/istio/fi-destination-rule-payment.yml
 oc apply -f https://raw.githubusercontent.com/sidd-harth/aio/master/istio/fi-virtual-service-payment-401.yml

    while true; do  curl -s http://movies-aio.${gcp_external_IP}.nip.io |  grep --color -E '503|$' ; sleep .5; done
    while true; do  curl -s http://booking-aio.${gcp_external_IP}.nip.io | grep --color -E '401|$' ; sleep .5; done

 oc delete virtualservice payment

&####################################################################################################################################################
 
echo "Circuit Breaker (only requires Destination Rules)"
echo "Siege Installation"
 wget -c https://dl.fedoraproject.org/pub/epel/7/x86_64/Packages/s/siege-4.0.2-2.el7.x86_64.rpm https://dl.fedoraproject.org/pub/epel/7/x86_64/Packages/l/libjoedog-0.1.2-1.el7.x86_64.rpm -P installation/
 rpm -ivh installation/*.rpm
 siege version

echo "Delay and CiruitBreaker - Fail Fast with Max Connections & Max Pending Requests"
  while true; do  curl -s http://movies-aio.${gcp_external_IP}.nip.io | grep --color -E 'payment-v2|$' ; sleep .5; done
    siege -r 3 -c 10  -v movies-aio.${gcp_external_IP}.nip.io
    
 oc apply -f https://raw.githubusercontent.com/sidd-harth/aio/master/istio/fi-virtual-service-payment-delay.yml
   while true; do time curl -s http://movies-aio.${gcp_external_IP}.nip.io | grep --color -E 'payment-v2|$' ; sleep .5; done
    siege -r 3 -c 10  -v movies-aio.${gcp_external_IP}.nip.io
    
 oc replace -f https://raw.githubusercontent.com/sidd-harth/aio/master/istio/fi-destination-rule-payment_cb_policy.yml
    siege -r 3 -c 10  -v movies-aio.${gcp_external_IP}.nip.io
    
 oc delete destinationrule payment && oc delete virtualservice payment

&####################################################################################################################################################

echo "Pool Ejection - Ultimate resilience with retries, circuit breaker, and pool ejection"
 oc scale deployment payment-v2 --replicas=2 -n aio

 oc apply -f https://raw.githubusercontent.com/sidd-harth/aio/master/istio/cpr-destination-rule-payment-v1-v2.yml
 oc apply -f https://raw.githubusercontent.com/sidd-harth/aio/master/istio/cpr-virtual-service-payment-v1_and_v2_50_50.yml
  while true; do  curl -s http://movies-aio.${gcp_external_IP}.nip.io | grep --color -E 'payment-v2|$' ; sleep .5; done

 oc exec -it $(oc get pods|grep payment-v2|awk '{ print $1 }'|head -1) -c payment /bin/bash
 curl localhost:8080/misbehave
 exit

   while true; do  curl -s http://movies-aio.${gcp_external_IP}.nip.io  | grep --color -E 'payment-v2|$' ; sleep .5; done

 oc replace -f https://raw.githubusercontent.com/sidd-harth/aio/master/istio/cpr-destination-rule-payment_pool_ejection.yml
 oc replace -f https://raw.githubusercontent.com/sidd-harth/aio/master/istio/cpr-virtual-service-payment_retry.yml
 oc delete destinationrule payment && oc delete virtualservice payment


 oc exec -it $(oc get pods|grep payment-v2|awk '{ print $1 }'|head -1) -c payment /bin/bash
 curl localhost:8080/behave
 exit
   while true; do  curl -s http://movies-aio.${gcp_external_IP}.nip.io  | grep --color -E 'payment-v2|$' ; sleep .5; done

&####################################################################################################################################################

echo "Egress"
  make a http call in browser and check payment/httpbin
  curl -s http://payment-aio.${gcp_external_IP}.nip.io/httpbin
  oc apply -f https://raw.githubusercontent.com/sidd-harth/aio/master/istio/service-entry-egress-httpbin.yml

&####################################################################################################################################################

echo "Show Jaeger, Grafana, Kiali Prometheus, Kibana"
http://servicegraph-istio-system.35.244.32.156.nip.io/dotviz
http://servicegraph-istio-system.35.244.32.156.nip.io/force/forcegraph.html

echo "check Kibana EFK"
echo "using port forwarding and show Kibana on local machine"

create a route in the webconsole
(oc get route kibana -n logging -o json|sed 's/80/5601/')|oc apply -n logging -f -
oc -n logging port-forward $(oc -n logging get pod -l app=kibana -o jsonpath='{.items[0].metadata.name}') 5601:5601
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

&#############################################################################################################################

echo "Deleting configs"
oc project aio
oc delete virtualservice --all && oc delete destinationrules --all && oc delete policy --all && oc delete gateway --all && oc delete serviceentry --all

oc get virtualservice 
oc get destinationrules

 oc get rules --all-namespaces

 oc delete project <project-name>
 oc get virtualservice -ojson

 oc delete virtualservice payment-mirror

 echo "Deleting kiali"
 oc delete all,secrets,sa,configmaps,deployments,ingresses,clusterroles,clusterrolebindings,virtualservices,destinationrules,customresourcedefinitions,templates --selector=app=kiali -n istio-system

echo "delete movies payment v2 fore new demo"
oc delete all -l version=v2 -n aio

&################################################################################################################################################################################

export INGRESS_HOST=$(oc -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
export INGRESS_PORT=$(oc -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].port}')
export SECURE_INGRESS_PORT=$(oc -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].port}')

echo ${INGRESS_HOST} ${INGRESS_PORT} ${SECURE_INGRESS_PORT}

&###############################################################################################################################################################

echo "DialogFlow Payment Destinationrule & VirtualService"

first both payment v1 and v2 should be runnning and apply below destinationrule
  oc scale deployment payment-v2 --replicas=1 -n aio
  oc scale deployment payment-v1 --replicas=1 -n aio
  oc apply -f <(curl -s https://raw.githubusercontent.com/sidd-harth/aio/master/istio/destination-rule-payment-v1-v2.yml)

echo "Show payment v2 giving misbahevae 503" 
route all traffic to payment v1 --- 
oc apply -f <(curl https://raw.githubusercontent.com/sidd-harth/aio/master/istio/dialogFlow-payment-v1-100.yml)


echo "behave pay v2 & rfelace pay vs with cananry vs -- "
  oc apply -f <(curl https://raw.githubusercontent.com/sidd-harth/aio/master/istio/dialogFlow-payment-v2-10.yml)
echo "both v1 and v2"
  oc delete -f <(curl https://raw.githubusercontent.com/sidd-harth/aio/master/istio/dialogFlow-payment-v2-10.yml)
echo "only v2 both v1 and v2 - "
  oc apply -f <(curl https://raw.githubusercontent.com/sidd-harth/aio/master/istio/dialogFlow-payment-v2.yml)



remove payment v2 service or discontinue traffic to payment v2 service
add payment v2 service to production instance and route only 10% traffic to it. or route only 10% traffic to payment v2
route traffic to payment v1 and v2 service equally
route all traffic to payment v2


echo "Remove all related Gateways Virtualservice Destinationrules"
oc delete gateway grafana-gateway kiali-gateway prometheus-gateway tracing-gateway -n istio-system
oc delete virtualservice grafana-vs kiali-vs prometheus-vs tracing-vs -n istio-system 
oc delete destinationrules grafana kiali prometheus tracing -n istio-system 

