#!/bin/bash

git clone https://github.com/sidd-harth/aio

oc login -u system:admin

echo "Changining work directory"
cd aio/kubernetes/kube-injected

oc project aio

echo "Deploying Movies Services"
oc apply -f movies-v1-deployment-injected.yml -n aio

oc create -f movies-service.yml -n aio 
oc expose svc movies -n aio

echo "Deploying Booking Services"
oc apply -f booking-v1-deployment-injected.yml -n aio
oc create -f booking-service.yml -n aio 
oc expose svc booking -n aio

echo "Deploying Payment Services"
oc apply -f payment-v1-deployment-injected.yml -n aio

oc create -f payment-service.yml -n aio 
oc expose svc payment -n aio

echo "Deploying UI Services"
oc apply -f ui-v1-deployment-injected.yml -n aio
oc create -f ui-service.yml -n aio
oc expose svc ui -n aio


oc apply -f movies-v2-deployment-injected.yml -n aio

oc apply -f payment-v2-deployment-injected.yml -n aio
