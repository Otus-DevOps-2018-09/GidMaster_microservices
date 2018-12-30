# Deploy

## Content:
<!--ts-->
* [Preparation.](#pre-install)
* [First option.](#packer-terraform-ansible)
* [Second option.](#terraform-ansible)
<!--te-->
## Pre-install.
Requiremnets:
 - packer
 - terraform
 - ansible

**You should create and fill variable for terraform and ansible configuration. Based on example files.**

**You should have valid ansible vault key.**

## Packer. Terraform. Ansible.
1. Go to directory `docker-monolith/infra/packer`.
2. Apply command `packer build`. It creates `baked` image with pre-installed docker called `docker-base`.
3. Go to directory `docker-monolith/infra/terraform`.
4. Apply command `terraform apply`. It creates VM instances with installed docker. **Make sure that `variable disk_image` is set to `docker-base` in `terraform.tfvars` file.**
5. Go to directory `docker-monolith/infra/ansible`.
6. Apply command `ansible-playbook playbooks/deploy.yml`. It deploys Application.
7. Profit. 
## Terraform. Ansible.
1. Go to directory `docker-monolith/infra/terraform`.
2. Apply command `terraform apply`. It creates VM instances with installed docker. **Make sure that `variable disk_image` is set to `docker-base` in `terraform.tfvars` file.**
3. Go to directory `docker-monolith/infra/ansible`.
4. Apply command `ansible-playbook playbooks/site.yml`. It deploys Application.
5. Profit. 
