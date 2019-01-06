# GidMaster_microservices

## Content:
<!--ts-->
* [Task Description.](#task-description)
    * [Homework 1. Docker.](#homework-1-docker)
    * [Homework 2. Docker.](#homework-2-docker)
    * [Homework 3. Docker.](#homework-3-docker)
    * [Homework 4. Docker.]($homework-4-docker)
    * [Homework 5. GitLab CI.]($homework-5-gitlab-ci)
    * [Homework 6. GitLab CI.]($homework-6-gitlab-ci)
    * [Homework 7. Monitoring.]($homework-7-monitoring)
* [Remarks.](#remarks)
<!--te-->
## Task Description.
### Homework 1. Docker.
1. Integrated repository into Travis CI and Slack.
2. Played a little bit with docker.

### Homework 2. Docker.
1. Studied docker foundations. Docker-machine. Docker registry. Dockerfile
2. Installed docker machine and created VM on GCP.
3. Made my own image.
4. Pushed it on DockerHub.
#### Homework 2. Task with *.
1. Made Terraform instructions to create docker host. Number of docker hosts can be set in `variable.tf` file.
2. Made ansible playbooks for docker installation and application deployment. Used ansible-galaxy role `nickjj.docker` for docker installation. Used dynamic inventory. Used ansible-vault to store sensetive data.
3. Made "`baked`" image with installed docker by packer.
### Homework 3. Docker.
1. Studied about microservicers (a litle).
2. Created docker netework, and network alias for microcesriveces.
3. Updated and optimazed images.
4. Created volume for DB, to save messages.
#### Homework 3. Task with *
1. Played a little with network alias.
### Homework 4. Docker.
1. Studied about docker network types.
2. Studied about docker-compose utility.
3. Made docker-compose file to run applications.
4. Studied about docker-compose `.env` file.
#### Project base name.
There are two ways to do this.

Set the environment variable with
```bash
export COMPOSE_PROJECT_NAME=foo
```
or by starting your stack with the -p switch
`docker-compose -p foo build` or `docker-compose -p foo up`
#### Homework 4. Task with *
It's quite tricky. According to conversation on Slack this deployment should use only in `development` environment - not in `production`.
To remake application without rebuild container image we should use additional volumes in `docker-compose.override.yml` where we put updated source files. 

In case of using docker-machine we should copy source files to remote machine. Copy the source files to docker-host machine by docker-machine scp -r . docker-host: In docker-host don't forget to copy src from /home/docker-user/ to your user home directory with project path, for example - /home/your_user/user_microservices/src.
### Homework 5. GitLab-CI.
1. Installer GitLab-CI on cloud macine.
2. Installed runner.
3. Run simple test for reddit application.
#### Homework 5. Task with *.
1. Used autoscalling with docker-machine. Followed next [instructions](https://docs.gitlab.com/runner/executors/docker_machine.html).
    * Created new host using gcloud util.
    * Installed `gitlab-runner`.
    * Installed docker-machine and created local docker-machine with GCloud driver.
2. Configured integration with Slack messager.
### Homework 6. GitLab-CI.
1. Studied about environments in GitLab-CI.
2. Made `Development`, `Stage`, `Production` environments. Made different pipelines for different environments.
3. Made instructions for dynamic enviroment creation. Tested.
### Homework 7. Monitoring.
1. Prometheus. Run, configuration, Get started with Web UI
    1. Created firewall rules for application and prometheus:
    ```bash
    gcloud compute firewall-rules create prometheus-default --allow tcp:9090
    gcloud compute firewall-rules create puma-default --allow tcp:9292 
    ```
    2. Created and used docker-host:
    ```bash
    docker-machine create --driver google \
    --google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \
    --google-project <Project-ID> \
    --google-machine-type n1-standard-1 \
    --google-zone europe-west1-b \
    docker-host 

    eval $(docker-machine env docker-host)
    ```
    3. Run prometheus with default settings:
    ```bash
     docker run --rm -p 9090:9090 -d --name prometheus prom/prometheus:v2.1.0
    ```
    4. Looked on some metrics. Got information about metric format.

    `prometheus_build_info{branch="HEAD",goversion="go1.9.1",instance="localhost:9090", job="prometheus", revision="3a7c51ab70fc7615cd318204d3aa7c078b7c5b20",version="1.8.1"}`

    `prometheus_build_info` - metric's ID. There is ID of collected information

    `branch=`  `job=` and any `<label>=` - Label. Label in this case provides extra information about collected metric.

    `go1.9.1` ans any key value. This is metrics value.
    
    5. Studied some basic information about `Targets`.

    Prometheus uses systems or processes as a tergets for monitoring.

    6. Stoped prometheus container.
    7. Re-organized folder structure. `docker-monolith` folder, `docker-compose` and `.env` (include example) files moved to `docker` folder. Created `monitoring` folder
    8. Created `Dockerfile` in monitoring/prometheus:
    ```dockerfile
    FROM prom/prometheus:v2.1.0
    ADD prometheus.yml /etc/prometheus/
    ```
    9. Created `prometheus.yml` in monitoring/prometheus:
    ```yaml
    ---
    global:
     scrape_interval: '5s'
    scrape_configs:
     - job_name: 'prometheus'
     static_configs:
     - targets:
     - 'localhost:9090'
     - job_name: 'ui'
     static_configs:
     - targets:
     - 'ui:9292'
     - job_name: 'comment'
     static_configs:
     - targets:
     - 'comment:9292'

    ```
    10. Made docker image:
    ```bash
    export USER_NAME=username
    docker build -t $USER_NAME/prometheus .
    ```
    11. Re-builded microservice images:
    ```bash
    for i in ui post-py comment; do cd src/$i; bash docker_build.sh; cd -; done
    ```
    12. Updated `docker/docker-compose.yml`. Added prometheus service:
    ```yaml
    services:
    ...
      prometheus:
        image: ${USERNAME}/prometheus
        ports:
          - '9090:9090'
        volumes:
          - prometheus_data:/prometheus
        command:
          - '--config.file=/etc/prometheus/prometheus.yml'
          - '--storage.tsdb.path=/prometheus'
          - '--storage.tsdb.retention=1d'
    volumes:
      prometheus_data:
    ```
    13. Commented build command in other services.
    14. Run `docker-compose up -d`
2. Looked how works build-in healthchecks in services. Used browser <docker-host>:9090
3. Collecting host metrics.
    1. Studied about exporters.
    2. Configured `node-exporter` in docker/docker-compose.yml:
    ```yaml
    services:
    ...
      node-exporter:
        image: prom/node-exporter:v0.15.2
        user: root
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro
    command:
      - '--path.procfs=/host/proc'
      - '--path.sysfs=/host/sys'
      - '--collector.filesystem.ignored-mount-points="^/(sys|proc|dev|host|etc)($$|/)"'
    ```
    3. Updated `prometheus.yml` in monitoring\prometheus for collecting data from node-exporter:
    ```yaml
    scrape_configs:
    ...
    - job_name: 'node'
      static_configs:
        - targets:
          - 'node-exporter:9100'
    ```
    4. create new Docker image with prometheus in `monitoring/prometheus`:
    ```bash
    docker build -t $USER_NAME/prometheus .
    ```
    5. restart services with docker-compose:
    ```bash
    docker-compose down
    docker-compose up -d 
    ```
    6. Saw some new metrics from node exporter. Web UI <docker-host>:9090
#### Homework 7. 1st task with *.
Added MongoDB monitoring. Used `percona/mongodb_exporter`.
1. Make `/monitoring/mongodb_exporter` directory
2. Creat Dockerfile:
```Dockerfile
FROM golang:1.9

ENV APPPATH $GOPATH/src/github.com/percona/mongodb_exporter
WORKDIR $APPPATH

RUN git clone "https://github.com/percona/mongodb_exporter" "$APPPATH" \
    && go get -d && go build -o /bin/mongodb_exporter \
    && rm -rf "$GOPATH"

EXPOSE 9216

ENTRYPOINT [ "/bin/mongodb_exporter" ]
```
3. Create image:
```bash
docker build -t $USER_NAME/mongodb_exporter .
```
4. Modify `monitoring\prometheus\prometheus.yml`. Added mongodb_exporter 
```yaml
scrape_configs:
...
  - job_name: 'mongodb'
    static_configs:
      - targets:
        - 'mongo-exporter:9216'
```
5. Re-create prometheus image:
```bash
docker build -t $USER_NAME/prometheus .
``` 
6. Modify docker\docker-compose.yml. Added new service mongodb_exporter
```yaml
services:
...
  mongo-exporter:
     image: ${USERNAME}/mongo-exporter
     ports:
       - '9216:9216'
     networks:
       - backend
     environment:
       - MONGODB_URL=mongodb://post_db:27017

```
7. Re-run services:
```bash
docker-compose down
docker-compose up -d 
```
8. Check new metrics via Web UI.
####Homework 7. 2nd task with *.
I've completed the task with two variants. Use cloudprober and blackbox-exporter. Im my opinion `cloudprober` easy to understand and configuration. All configurations presented as is in current sections. Usually we do the same steps that we did in previous task:
1. Create Dockerfile.
2. Create configuration file.
3. Create image.
4. Update `prometheus` image.
5. Update `docker-compose` file.
6. Restart service.
####Homework 7. 3rd task with *.
Made Makefile for make utility. Created two targets: build and push.
```makefile
build: comment post ui cloudprober prometheus blackbox-exporter
push: push_comment push_post push_ui push_cloudprober push_blackbox-exporter

comment:
        cd src/comment && bash docker_build.sh

post:
        cd src/post-py && bash docker_build.sh

ui:
        cd src/ui && bash docker_build.sh

cloudprober:
        cd monitoring/cloudprober && docker build -t ${USER_NAME}/cloudprober .

prometheus:
        cd monitoring/prometheus && docker build -t ${USER_NAME}/prometheus .

blackbox-exporter:
        cd monitoring/prometheus && docker build -t ${USER_NAME}/blackbox-exporter .

push_comment:
        docker push ${USER_NAME}/comment

push_post:
        docker push ${USER_NAME}/post

push_ui:
        docker push ${USER_NAME}/ui

push_cloudprober:
        docker push ${USER_NAME}/cloudprober

push_prometheus:
        docker push ${USER_NAME}/prometheus

push_blackbox-exporter:
        docker push  ${USER_NAME}/blackbox-exporter

```

## Remarks.
1. Quite interesting command:
    ```bash
    docker system df
    ```

   It shows how many disk space used by images, containers and volumes. And show how many of them (images, containers and volumes) can be deleted.
2. Small description of output for next commands:
    ```bash
    docker run --rm -ti tehbilly/htop
    ```
    ```bash
    docker run --rm --pid host -ti tehbilly/htop
    ```
    As we see difference between command is `--pid host` argument. According docker's documentation:
    ```
    --pid=""  : Set the PID (Process) Namespace mode for the container,
             'container:<name|id>': joins another container's PID namespace
             'host': use the host's PID namespace inside the container
    ```
    It means that for `docker run --rm -ti tehbilly/htop` we see only container mapped PID's. And for `docker run --rm --pid host -ti tehbilly/htop ` - PID's of host machine.
3. To use python vitrualenv and run ansible modules into specific virtual environment. We need to add such derective on any level (playbook, role or task level):
    ```yaml
    vars:
      ansible_python_interpreter: "/usr/bin/env python-docker"
    ```
4. If you use ansible with encrypted data by ansible-vault as provisioner in packer configuration you should add path to vault key into provisioner section.
    ```json
    "provisioners": [
      {
      "type": "ansible",
      "playbook_file": "../ansible/playbooks/packer_docker.yml",
      "extra_arguments": ["--vault-password-file", "~/.ansible/vault.key"]
      }
    ]
    ```

