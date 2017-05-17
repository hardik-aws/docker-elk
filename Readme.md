# About

This repository provide sample code to deploy elk stack with version 5.3 of elasticsearch,logstash and Kibana

# Requirements

1. Install [Docker](http://docker.io).
3. Clone this repository

# Increase `vm.max_map_count` on your host

You need to increase the `vm.max_map_count` kernel setting on your Docker host.
To do this follow the recommended instructions from the Elastic documentation: [Install Elasticsearch with Docker](https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html#docker-cli-run-prod-mode)

# Setup

## How to deploy in local ?

### build image
```bash
$ cd <root of repository>
$ docker build -t elk:latest .
```

### run docker container
```bash
$ docker run -d -p 5601:5601 elk:latest
```
Once your yask is in running state try open URL of [Kibana](http://localhost:5601) and [LogStash](http://localhost:5000)

## run elk using Amazon ECS

### create a ECR repository to store image
to create a docker image go to AWS console > EC2 Container Service > Repositories

#### build image : 
```bash
$ cd <root of repository>
$ docker build -t elk:latest .
```
### push image to ECR :

#### login
```bash
$ aws ecr get-login --region <aws-region>
```
This will provide you a long login command for AWS (Note : this will expiry after 8 hrs so you need to relogin)

#### tag Image
```bash
$ docker tag elk:latest <ecr-reposiotory-url>:latest
```

#### push image
```bash
$ docker push <ecr-reposiotory-url>:latest
```
#### create a task defination 
sample file for the ECS task defination is provided in the folder ecs inside this repostitory, you need to change some value in that defination

```bash
	"containerDefinitions": [{
		"volumesFrom": [],
		"memory": 1024, <<< change the RAM based on your requirment
		"extraHosts": null,
		"dnsServers": null,
		"disableNetworking": null,
		"dnsSearchDomains": null,
```

```bash
		"workingDirectory": null,
		"readonlyRootFilesystem": null,
		"image": "123456789123.dkr.ecr.us-east-1.amazonaws.com/elk:latest", <<< change image with URL of your own ECR image
		"command": null,
```

once you made all require change go to AWS console > EC2 Container Service > Task Definitions and Create a Task Definition

#### create a Service

to create a service go to Newely created task defination and from Actions menu create service 

Fill below value based on you requirment and Create Service 
```bash
Cluster
Service name
Number of tasks
Minimum healthy percent
Maximum percent
```
Once Done new service will be added with number of task in your selected cluster

#### Check ELK

Once your yask is in running state try open URL of [Kibana](http://localhost:5601) and [LogStash](http://localhost:5000),if you can see kibana index page and 'ok' on logstash URL all is woerking fine.next step is to test and send log using your application
