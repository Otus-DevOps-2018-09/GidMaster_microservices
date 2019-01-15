# GidMaster_microservices

## Content:
<!--ts-->
* [Task Description.](#task-description)
    * [Homework 1. Docker.](#homework-1-docker)
    * [Homework 2. Docker.](#homework-2-docker)
    * [Homework 3. Docker.](#homework-3-docker)
    * [Homework 4. Docker.]($homework-4-docker)
    * [Homework 5. GitLab CI.](#homework-5-gitlab-ci)
    * [Homework 6. GitLab CI.](#homework-6-gitlab-ci)
    * [Homework 7. Monitoring.](#homework-7-monitoring)
    * [Homework 8. Monitoring.](#homework-8-monitoring)
    * [Homework 9. Logging](#homework-9-logging)
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
#### Homework 7. 2nd task with *.
I've completed the task with two variants. Use cloudprober and blackbox-exporter. Im my opinion `cloudprober` easy to understand and configuration. All configurations presented as is in current sections. Usually we do the same steps that we did in previous task:
1. Create Dockerfile.
2. Create configuration file.
3. Create image.
4. Update `prometheus` image.
5. Update `docker-compose` file.
6. Restart service.
#### Homework 7. 3rd task with *.
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
### Homework 8. Monitoring.
1. Monitoring Docker containers.
    1. Separate `docker-compose.yml` to `docker-compose.yml` and `docker-compose-monitoring.yml`
    2. Configure cAdvisor service in `docker-compose-monitoring.yml`:
    ```yaml
    services:
    ...
      cadvisor:
      image: google/cadvisor:v0.29.0
      volumes:
        - '/:/rootfs:ro'
        - '/var/run:/var/run:rw'
        - '/sys:/sys:ro'
        - '/var/lib/docker/:/var/lib/docker:ro'
      ports:
        - '8080:8080'
      networks:
        - backend    
    ```
    3. Add `cadvisor` job into prometheus config:
    ```yaml
    scrape_configs:
    ...
      - job_name: 'cadvisor'
      static_configs:
      - targets:
        - 'cadvisor:8080'     
    ```
    4. Rebuild prometheus image
    ```bash
    export USER_NAME=username
    cd monitoring/prometheus
    docker build -t $USER_NAME/prometheus .
    ```
    5. Run services:
    ```bash
    cd ../../docker
    docker-compose up -d 
    docker-compose -f docker-compose-monitoring.yml up -d
    ```
    6. Look cAdvisor metrics through WebUI.
2. Metrics Vizualization.
    1. Add Grafana service:
    ```yaml
    services:
    ...
      grafana:
        image: grafana/grafana:5.0.0
        volumes:
          - grafana_data:/var/lib/grafana
        environment:
          - GF_SECURITY_ADMIN_USER=admin
          - GF_SECURITY_ADMIN_PASSWORD=secret
        depends_on:
          - prometheus
        ports:
          - 3000:3000
        networks:
          - backend 
    ```
    2. Re-Run services:
    ```bash
    cd docker
    docker-compose -f docker-compose-monitoring.yml up -d
    ```
    3. Look at grafana interface. Use admin/secret to login.
    4. Configure our prometheus server as datasource:
    ![datasorce pic from grafana](datasorce.png)
    5. Import dashbord from grafana.com and saved JSON into `monitoring/grafana/dashboards`
4. Collecting application&business metrics.
    1. Add business and application metrics.
    2. Studied about percentiles, histograms, rate function and quitiles.
5. Alerting configuration.
    1. Make a alertmanager image:
    ```dockerfile
    FROM prom/alertmanager:v0.14.0
    ADD config.yml /etc/alertmanager/ 
    ```
    2. Add configuratinon for slack notificationis.
    ```yaml
    global:
      slack_api_url:    'https://hooks.slack.com/services/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'

    route:
      receiver: 'slack-notifications'

    receivers:
    - name: 'slack-notifications'
      slack_configs:
      - channel: '#konstantin_syrovatsky'
    - name: 'email-notifications'
      email_configs:
      - to: 'team-X+alerts@example.org'
    ```
    Also added mail notofications for task with *
    3. Make image of alertmamager:
    ```bash
    docker build -t $USER_NAME/alertmanager .
    ```
    4. Add configuration to `docker-compose-monitoring.yml` file:
    ```yaml
    services:
    ...
      alertmanager:
      image: ${USER_NAME}/alertmanager
      command:
        - '--config.file=/etc/alertmanager/config.yml'
      ports:
        - 9093:9093
      networks:
        - backend
    ```
    5. Configure alert rules in `monitoring/prometheus/alerts.yml`:
    ```yaml
    groups:
      - name: alert.rules
        rules:
        - alert: InstanceDown
          expr: up == 0
          for: 1m
          labels:
            severity: page
          annotations:
            description: '{{ $labels.instance }} of job {{  $labels.job }} has been down for more than 1 minute'
            summary: 'Instance {{ $labels.instance }} down'
        - alert: 95PercentileResponse
          expr: histogram_quantile(0.95, sum(rate   (ui_request_response_time_bucket{instance="ui:9292",}[5m])) by (le)) > 1
          for: 1m
          labels:
            severity: page
          annotations:
            description: "Response is to long"
            summary: "UI problems"
    ```
    Also added configuration for task with *.
    6. Update prometheus `Dockerfile` (monitoring/prometheus/Dockerfile):
    ```dockerfile
    FROM prom/prometheus:v2.1.0
    ADD prometheus.yml /etc/prometheus/
    ADD alerts.yml /etc/prometheus/
    ```
    7. Add information about alerts into prometheus config and re-build prometius image:
    ```yaml
    global:
      scrape_interval: '5s'
    ...
    rule_files:
      - "alerts.yml"
    alerting:
      alertmanagers:
        - scheme: http
      static_configs:
        - targets:
          - "alertmanager:9093"     
    ```
    ```bash
    docker build -t $USER_NAME/prometheus .
    ```
    8. Check alerting service work.
6. Tasks with * 

### Homework 9. Logging.
#### Preparations.
Prepeare new VM instance.
```bash
$ export GOOGLE_PROJECT=<Project-ID>
$ docker-machine create --driver google \
 --google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \
 --google-machine-type n1-standard-1 \
 --google-open-port 5601/tcp \
 --google-open-port 9292/tcp \
 --google-open-port 9411/tcp \
 logging 
```
Connect to them and check IP
```bash
eval $(docker-machine env logging)
docker-machine ip logging
```
Update application sources.
```bash
wget -O reddit-microservices https://github.com/express42/reddit/archive/microservices.zip
mv src src-old
unzip reddit-microservices && mv reddit-microservices src
mv src-old/ui/Dockerfile src/ui/Dockerfile 
mv src-old/comment/Dockerfile src/comment/Dockerfile 
mv src-old/post-py/Dockerfile src/post-py/Dockerfile 
```
Build images from new sources:
```bash
for i in ui post-py comment; do cd src/$i; bash docker_build.sh; cd -; done
```
#### Logging Docker containers.
Make a new `docker-compose` file in docker directory:
```yaml
version: '3'
services:
  fluentd:
    image: ${USERNAME}/fluentd
    ports:
      - "24224:24224"
      - "24224:24224/udp"

  elasticsearch:
    image: elasticsearch:6.4.0 #latest tag not supported
    expose:
      - 9200
    ports:
      - "9200:9200"

  kibana:
    image: kibana:6.4.0 #latest tag not supported
    ports:
      - "5601:5601"
```
Make a new directory `logging/fluentd`:
```bash
mkdir logging && touch logging/fluentd/Dockerfile
```
Dockerfile
```dockerfile
FROM fluent/fluentd:v0.12
RUN gem install fluent-plugin-elasticsearch --no-rdoc --no-ri --version 1.9.5
RUN gem install fluent-plugin-grok-parser --no-rdoc --no-ri --version 1.0.0
ADD fluent.conf /fluentd/etc
```
Add `fluentd.conf` configuration file:
```conf
<source>
 @type forward
 port 24224
 bind 0.0.0.0
</source>
<match *.**>
 @type copy
 <store>
 @type elasticsearch
 host elasticsearch
 port 9200
 logstash_format true
 logstash_prefix fluentd
 logstash_dateformat %Y%m%d
 include_tag_key true
 type_name access_log
 tag_key @log_name
 flush_interval 1s
 </store>
 <store>
 @type stdout
 </store>
</match> 
```
Make Docker image for fluentd:
```bash
docker build -t $USER_NAME/fluentd .
```
Change into .env files images' tag to `logging`
Run application:
```bash
cd docker
docker-compose up -d
```
Look on docker logs (do command in `docker` folder):
```bash
docker-compose logs -f post 
```
it looks like when you make posts:
```json
post_1     | {"event": "post_create", "level": "info", "message": "Successfully created a new post", "params": {"link": "https://google.com", "title": "Google."}, "request_id": "26c8bd82-2fbb-44eb-b076-f81398ff42e0", "service": "post", "timestamp": "2019-01-13 07:39:59"}
post_1     | {"addr": "192.168.10.2", "event": "request", "level": "info", "method": "POST", "path": "/add_post?", "request_id": "26c8bd82-2fbb-44eb-b076-f81398ff42e0", "response_status": 200, "service": "post", "timestamp": "2019-01-13 07:39:59"}
post_1     | {"event": "find_all_posts", "level": "info", "message": "Successfully retrieved all posts from the database", "params": {}, "request_id": "4ad4a589-1c8d-424c-a3a3-2bcf0c9265f4", "service": "post", "timestamp": "2019-01-13 07:40:00"}
post_1     | {"addr": "192.168.10.2", "event": "request", "level": "info", "method": "GET", "path": "/posts?", "request_id": "4ad4a589-1c8d-424c-a3a3-2bcf0c9265f4", "response_status": 200, "service": "post", "timestamp": "2019-01-13 07:40:00"}
```
Lets modify logging drivar for post service. Change it form JSOn to Fluentd
```yaml
…
  post:
…
    logging:
    driver: "fluentd"
    options:
      fluentd-address: localhost:24224
      tag: service.post 
```
Run logging infrastructure:
```bash
docker-compose -f docker-compose-logging.yml up -d
docker-compose down
docker-compose up -d 
```
Wait a little. And look on KIBANA interface.
#### Filtering in Fluentd.

Used diffirent format of filtering:

**JSON Filter**
```
<filter service.post>
 @type parser
 format json
 key_name log
</filter> 
```
**RegEx filter**
```
<filter service.ui>
 @type parser
 format /\[(?<time>[^\]]*)\] (?<level>\S+) (?<user>\S+)[\W]*service=(?<service>\S+)[\W]*event=(?<event>\S+)[\W]*(?:path=(?<path>\S+)[\W]*)?request_id=(?<request_id>\S+)[\W]*(?:remote_addr=(?<remote_addr>\S+)[\W]*)?(?:method= (?<method>\S+)[\W]*)?(?:response_status=(?<response_status>\S+)[\W]*)?(?:message='(?<message>[^\']*)[\W]*)?/
 key_name log
</filter> 
```
**grok filter templates**
```
<filter service.ui>
 @type parser
 format grok
 grok_pattern %{RUBY_LOGGER}
key_name log
</filter> 
```
```
<filter service.ui>
 @type parser
 format grok
 grok_pattern service=%{WORD:service} \| event=%{WORD:event} \| request_id=%{GREEDYDATA:request_id} \| message='%{GREEDYDATA:message}'
 key_name message
 reserve_data true
</filter> 
```
#### Tracing
Add new zipkin service to logging and rerun docker-compose
```yaml
services:
 zipkin:
 image: openzipkin/zipkin
 ports:
 - "9411:9411"
 networks:
 - frontend
 - backend
networks:
 backend:
 frontend:
```
```bash
docker-compose -f docker-compose-logging.yml -f docker-compose.yml down
docker-compose -f docker-compose-logging.yml -f docker-compose.yml up -d
```
look closer to zipkin WEB UI.

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
5. To run elasticsearch you need to modify docker-host machine [link](https://github.com/docker-library/elasticsearch/issues/111)
```bash
sudo sysctl -w vm.max_map_count=262144
```

