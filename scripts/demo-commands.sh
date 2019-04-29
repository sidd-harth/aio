echo "Simple Routing v1 v2 - round robin  all calls to one version Canary deployment: Split traffic between v1 and v2 - 90 10 - 75 25 - 50 50 - 0 100"
 oc apply -f movies-v2-deployment-injected.yml -n aio
 
cd /home/services/aio/istio
 oc apply -f destination-rule-movies-v1-v2.yml
 oc apply -f virtual-service-movies-v1_100.yml
 while true; do curl -s http://movies-aio.${gcp_external_IP}.nip.io | grep --color -E 'payment-v2|$' ; sleep .5; done

 oc replace -f virtual-service-movies-v1_and_v2_10_90.yml
 oc replace -f virtual-service-movies-v1_and_v2_50_50.yml
 oc replace -f virtual-service-movies-v2_100.yml

 while true; do curl -s http://movies-aio.${gcp_external_IP}.nip.io | grep --color -E 'payment-v2|$' ; sleep .5; done

 oc scale deployment movies-v1 --replicas=0 -n aio

****&&&&&^^^^%%%%%%$$$$$$$$#########@****&&&&&^^^^%%%%%%$$$$$$$$#########@****&&&&&^^^^%%%%%%$$$$$$$$#########@****&&&&&^^^^%%%%%%$$$$$$$$#########@

echo "Advacned Routing"
 oc apply -f /home/services4/aio/kubernetes/kube-injected/payment-v2-deployment-injected.yml -n aio

echo "Mirroring Traffic (Dark Launch)" 
 oc apply -f destination-rule-payment-v1-v2.yml
 oc apply -f virtual-service-payment-v1-mirror-v2.yml
 
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