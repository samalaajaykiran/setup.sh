docker setup.sh

#!/bin/bash

# Universal function for clean text rectangles without using echo -e flags
log_step() {
    local text=" STATUS: $1 "
    local len=${#text}
    
    # Generate exact width border lines
    local border=$(printf '%*s' "$((len + 4))" '' | tr ' ' ' ')

    printf "\n"
    printf "\e[1;47;30m%s\e[0m\n" "${border}"
    printf "\e[1;47;30m# %s #\e[0m\n" "${text}"
    printf "\e[1;47;30m%s\e[0m\n" "${border}"
    printf "\n"

}
log_step "Manual approval for execution is not necessary"

export SYSTEMD_PAGER=cat
export DEBIAN_FRONTEND=noninteractive

sudo apt update

log_step "Removing previous non-related files"
sudo apt remove -y $(dpkg --get-selections docker.io docker-compose docker-compose-v2 docker-doc podman-docker containerd runc | cut -f1)

log_step "Adding Docker's official GPG key"
sudo apt update -y
sudo apt install -y ca-certificates curl 

sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

sudo apt update -y

log_step "Installing Docker engine suite"
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

log_step "Starting Docker services"
sudo systemctl enable docker
sudo systemctl start docker

log_step "Checking active service status"
sudo systemctl status docker --no-pager

log_step "Check the docker version below"
sudo docker --version

log_step "Running a container with hello-world image"
sudo docker run hello-world

log_step "Everything is fine, now you are ready to proceed further"


EOF
