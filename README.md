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
