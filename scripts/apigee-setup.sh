#!/bin/bash
echo "installing istio 1.0.2"
oc login -u system:admin
wget https://github.com/istio/istio/releases/download/1.0.2/istio-1.0.2-linux.tar.gz
tar -xvzf istio-1.0.2-linux.tar.gz
oc apply -f istio-1.0.2/install/kubernetes/helm/istio/templates/crds.yaml
export PATH=$PATH:$(pwd)/istio-1.0.2/bin/
istioctl version 
oc apply -f istio-1.0.2/install/kubernetes/istio-demo.yaml

echo "download directly from raw github istio 1.0.2"
oc login -u system:admin
oc apply -f https://raw.githubusercontent.com/istio/istio/1.0.2/install/kubernetes/helm/istio/templates/crds.yaml

echo "initilizing the environment with apigee's istio and adapter"
mkdir aio   &&
cd aio  &&
wget https://github.com/apigee/istio-mixer-adapter/releases/download/1.0.5/istio-mixer-adapter_1.0.5_linux_64-bit.tar.gz &&
tar -xvzf istio-mixer-adapter_1.0.5_linux_64-bit.tar.gz &&
oc  apply -f samples/istio/istio-demo.yaml  &&
export PATH=$PATH:$(pwd)/aio/  &&
apigee-istio version  &&
apigee-istio provision -f -o mamillarevathi-eval -e test -u mamilla.revathi@tavant.com -p Qwerty@67 > samples/apigee/handler.yaml &&
oc new-project aio  &&
oc adm policy add-scc-to-user privileged -z default -n aio  &&
oc label  namespace aio istio-injection=enabled  &&
oc get pods -w -n istio-system


# #this is for sample apigee istio hello app
# oc apply -f samples/istio/helloworld.yaml &&
# oc expose svc helloworld &&
# oc get route && grep helloworld


# #get istio-proxy port - 31380
# oc -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}'



# #change the namespace/project-name in rules - destination.namespace == <---->
oc apply -f samples/apigee/definitions.yaml 
oc apply -f samples/apigee/handler.yaml 

#change the match operator to only add the rule to movies svc endpoint
spec:
  match: destination.service == "movies.aio.svc.cluster.local"
  
oc apply -f samples/apigee/rule.yaml


# #binding can use simple movies svc name instead of svc_name.namespace.svc.cluster.local 
# apigee-istio bindings add movies hello-istio-product  -o mamillarevathi-eval -e test -u mamilla.revathi@tavant.com -p Qwerty@67


# #kube-inject cmd
# oc apply -f <(istioctl kube-inject -f apigee/Deployment.yml) -n apigee
