#!/usr/bin/env bash

# set -x
set -e
clear

# Tools used
#  - gcloud
#  - kubectl
#  - openssl

# ===================
#   Variables
# ===================
#### CHANGE_ME
PROJECT_NAME="$GCP_PROJECT_ID"

# GCP auth login key
GCP_ACCOUNT_KEY="$GCP_SERVICE_ACCOUNT_KEY"

# Cluster name
K8S_CLUSTERNAME="$PROJECT_NAME-gke"

# Cluster node size
K8S_NODE_COUNT='3'

# Cluster Version : 1.10.9-gke.5 , 1.11.6-gke.2
K8S_VERSION="1.11.6-gke.2"

# Primary asia for Master
GCP_ZONE='australia-southeast1-a'

# Other regions for Workers for HA
# Expecting:    --additional-zones "us-central1-b","us-central1-c" \
OTHER_GCP_ZONE='australia-southeast1-b,australia-southeast1-c'

# n1-standard-1=(1*vCPU+3.75GB), n2-standard-2=2*vCPUs+7.5GB, n2-standard-4=4*vCPUs+15GB
MACHINE_SIZE='n1-standard-1'
MACHINE_ROOT_DISK_SIZE_GB='100'

# Randomly generate the password
JENKINSPASSWORD=$(openssl rand -base64 12)

# Or use Static
# JENKINSPASSWORD='Static-password-goes-here'
JENKINS_DISK_REGION='australia-southeast1'

# ----------------
# Static Variables
# ----------------
#  - These should not need to be adjusted/configured
RUNMODE="$1"

# Terminal colours
#TC_RED='\033[0;31m' # Red
#TC_RESET='\033[0m'  # No Color

#TC Colours
  # Black        0;30     Dark Gray     1;30
  # Red          0;31     Light Red     1;31
  # Green        0;32     Light Green   1;32
  # Brown/Orange 0;33     Yellow        1;33
  # Blue         0;34     Light Blue    1;34
  # Purple       0;35     Light Purple  1;35
  # Cyan         0;36     Light Cyan    1;36
  # Light Gray   0;37     White         1;37

# ===================
#   Functions
# ===================
for file in ./scripts/*; do
  source "$file"
done

# ===================
#   Main Code
# ===================

echo ''
echo '| ============================= |'
echo ''
echo ''
echo 'Start to build a kubernetes cluster on GCP'

# Selected run mode
case "$RUNMODE" in

  initialise)
    gcloud-login
    initialise-gcloud
    preflight-tests
    ;;

  create)
    gcloud-login
    preflight-tests
    update-gcloud
    create-k8s-cluster
    check-cluster-health
    create-default-namespaces
    install-and-config-jenkins
    install-and-config-nexus
    install-load-balancing
    ;;

  create-k8s-cluster)
    gcloud-login
    create-k8s-cluster
    check-cluster-health
    create-default-namespaces
    ;;

  delete-k8s-cluster)
    gcloud-login
    delete-cluster
    ;;

  deploy-jenkins)
    gcloud-login
    install-and-config-jenkins
    ;;

  remove-jenkins)
    gcloud-login
    remove-jenkins
    ;;

  deploy-nexus)
    gcloud-login
    install-and-config-nexus
    ;;

  remove-nexus)
    gcloud-login
    remove-nexus
    ;;

  deploy-lb)
    gcloud-login
    install-load-balancing
    ;;

  remove-lb)
    gcloud-login
    remove-lb
    ;;


  get-creds)
    gcloud-login
    get-k8s-creds
    ;;

  DESTORY)
    while true; do
        read -p "Are you sure to delete all resources (y/n)?  " yn
        case $yn in
            [Yy]* )
              echo -e '\033[0;31mDeleting the entire project now \033[1;25m'
              remove-jenkins
              remove-nexus
              remove-lb
              delete-cluster
              exit 0
              break;;
            [Nn]* )
              exit 1;;
            * ) echo "Please answer yes or no.";;
        esac
    done
    ;;

  *)
    echo 'Please select a runmode, only one mode can be selected and the mode names are case-sensitive.'
    echo ''
    echo "  $0 runmode"
    echo ''
    echo 'List of runmodes are:'
    echo '---------------------'
    echo ''
    echo ''
    echo '  RUNMODE:                                  DESCRIPTION:'
    echo ''
    echo '  gcloud-login                              Perform gcloud login'
    echo '  initialise-gcloud                         Initialise gcloud command tools'
    echo '  create                                    This creates an k8s cluster on GCP then deploys Jenkins'
    echo '  create-k8s-cluster                        Creates a empty Container Engine k8s cluster in multiple zones within minutes'
    echo '  get-creds                                 Get the kubernetes creditials for kubectl'
    echo '  delete-k8s-cluster                        Deletes the cluster from Container Engine'
    echo '  deploy-jenkins                            Deploys Jenkins Master and Slave onto existing Container Engine cluster'
    echo '  remove-jenkins                            Undeploys/removes Jenkins deployment/secrets and ingress'
    echo ''
    echo '  DESTORY                                   This removes the entire project in one clean swoop, so good for temp environments / testing this script (dangerous!!)'
    echo ''
esac

# EOF
