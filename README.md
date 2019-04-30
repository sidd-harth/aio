## *** !!! Work in Progress - it will not digest if consumed :E !!! ****


# AIO - Apigee Istio Openshift Demo
This repository includes the instructions and scripts for running and understanding Istio Service Mesh. 

![Demo Architecture](demo-architecture2.gif)

## Prerequisites
* GCP Free Trial Account
* Apigee Trial Account
* Knowledge on Docker, Microservice Architecture and PaaS platforms

## Setting up GCP VM Instance
1. After creating an GCP Account, [create a new VM in Compute Engine](https://cloud.google.com/compute/docs/quickstart-linux). I have used this config, `n1-highcpu-8 - CentOS7 Compute Engine - 8vCPU, 7GB memory, 100GB storage`. 
2. By default Openshift's `pods-per-core` is set to `10`. So in my case I could deploy a total of 80 pods.
3. Reserve a [Static Internal IP Address](https://cloud.google.com/compute/docs/ip-addresses/reserve-static-internal-ip-address) and [Static External IP Address](https://cloud.google.com/compute/docs/ip-addresses/reserve-static-external-ip-address) for the VM Instance.
4. [Create a Firewall Rule](https://cloud.google.com/vpc/docs/using-firewalls) to allow access to all ports exposed by the VM Instance.
5. Add the above created Rule as a [Network tag](https://cloud.google.com/vpc/docs/add-remove-network-tags#adding_new_tags_to_vm_instances) to VM Instance.

## Installing Docker in VM Instance
* We will install `Docker` and use it to run Openshift PaaS platform as a Docker container.
* Within scripts folder run all the commands in [docker-installation.sh](https://github.com/sidd-harth/aio/blob/master/scripts/docker-installation.sh)

## Installing Openshift in VM Instance as a Docker Container
* We will download Openshift Client and use it to run a `oc cluster up` command to install Openshift.
* Within scripts folder run all the commands in [openshift-installation.sh](https://github.com/sidd-harth/aio/blob/master/scripts/openshift-installation.sh)

## Setting up Istio + Apigee Adapter in Openshift as a Kubernetes Project
* Within scripts folder go to [istio-apigee-installation.sh](https://github.com/sidd-harth/aio/blob/master/scripts/istio-apigee-installation.sh) and edit line 10 to replace your `Apigee - organization, environment & credentials`.
* We will use `Apigee Istio Mixer Adapter` to setup Istio in Openshift.
* Run all the commands in [istio-apigee-installation.sh](https://github.com/sidd-harth/aio/blob/master/scripts/istio-apigee-installation.sh)
* Wait till all the `pods` are up and running from `istio-system` namespace - `oc get pods -n istio-system`

## Deploying the Demo Services
* All the services are deployed using pre-built docker images from `siddharth67` Docker repo.
* Within scripts folder run all the commands in [deploying-services.sh](https://github.com/sidd-harth/aio/blob/master/scripts/deploying-services.sh)
* Wait till all the `pods` are up and running from `aio` namespace - `oc get pods -n aio`

## Testing the Services 
* Run `oc get routes -n aio` and copy any one of the route and test them in Browser or use a cURL Command,
```
curl http://movies-aio.xx.xxx.xx.xx.nip.io
```

## Test Istio Service Mesh Features
* Explore [demo-commands.sh](https://github.com/sidd-harth/aio/blob/master/scripts/demo-commands.sh)
* Follow the instructions and test the functionalities.

## Check the Telemetry Data
* Run `oc get routes -n istio-system` 
* Check sample [images](https://github.com/sidd-harth/aio/tree/master/images)

## License
This project is licensed under the MIT License - see the [LICENSE.md](https://github.com/sidd-harth/aio/blob/master/LICENSE) file for details

## Acknowledgments
* All the below docs and demos have helped me to understand and create this project. 
* I might have missed few of them, will add them as I remember.
* https://istio.io/
* https://developers.redhat.com
* https://blog.openshift.com/istio-on-openshift/
* http://blog.christianposta.com/istio-workshop/slides/
* https://docs.apigee.com/api-platform/istio-adapter/concepts
* Istio: Canaries and Kubernetes, Microservices and Service Mesh by BurrSutter
