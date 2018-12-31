# GidMaster_microservices

## Content:
<!--ts-->
* [Task Description.](#task-description)
    * [Homework 1. Docker.](#homework-1-docker)
    * [Homework 2. Docker.](#homework-2-docker)
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

