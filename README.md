# GidMaster_microservices

## Content:
<!--ts-->
* [Task Description.](#task-description)
    * [Homework 1. Docker.](#homework-1-docker)
    * [Homework 2. Docker.](#homework-2-docker)
    * [Homework 3. Docker.](#homework-3-docker)
    * [Homework 4. Docker.]($homework-4-docker)
    * [Homework 5. GitLab CI.]($homework-5-gitlab-ci)
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
#### Homework 5. GitLab-CI.
1. Installer GitLab-CI on cloud macine.
2. Installed runner.
3. Run simple test for reddit application.
#### Homework 5. Task with *.
1. Used autoscalling with docker-machine. Followed next [instructions](https://docs.gitlab.com/runner/executors/docker_machine.html).
    * Created new host using gcloud util.
    * Installed `gitlab-runner`.
    * Installed docker-machine and created local docker-machine with GCloud driver.
2. Configured integration with Slack messager.

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
