#!/bin/bash

# Function to install Red Hat packages
install_redhat_packages() {
  # Install Red Hat specific packages
  sudo yum update -y
  sudo yum install -y wget unzip
   # Install Java 11
  sudo yum install -y java-11-openjdk-devel
  echo "export JAVA11_HOME=/usr/lib/jvm/java-11-openjdk" >> ~/.bashrc
  source ~/.bashrc

  # Install Java 8
  sudo yum install -y java-1.8.0-openjdk-devel
  echo "export JAVA8_HOME=/usr/lib/jvm/java-1.8.0-openjdk" >> ~/.bashrc
  source ~/.bashrc

  # Install Java 17
  sudo yum install -y java-17-openjdk-devel
  echo "export SONAR_JAVA_PATH=/usr/lib/jvm/java-17-openjdk" >> ~/.bashrc
  source ~/.bashrc
sleep 10
sudo yum install -y git
cd  
mkdir github
cd github
git config --global credential.helper 'cache --timeout=3600'

# Read Git token from file
GIT_TOKEN=$(cat "/home/movvamanoj/gitrepo/gittok.txt")

# Read username from file
USERNAME=$(cat "/home/movvamanoj/gitrepo/gitusername.txt")

# Clone the repository using the Git token and username for authentication
git clone https://${USERNAME}:${GIT_TOKEN}@github.com/movvamanoj/movvaweb.git

 sleep 30
sudo yum install -y maven
sleep 10
# Install Docker dependencies
sudo yum install -y yum-utils device-mapper-persistent-data lvm2

# Add Docker repository
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# Install Docker
sudo yum install -y docker-ce docker-ce-cli containerd.io

# Configure Docker environment for the current session
sudo usermod -aG docker $USER
newgrp docker

# Start Docker service
sudo systemctl start docker
# Stop the Docker daemon
sudo systemctl stop docker

# Create or modify the Docker daemon configuration file
sudo tee /etc/docker/daemon.json > /dev/null <<EOF
{
  "hosts": ["tcp://0.0.0.0:8888"]
}
EOF
# Start the Docker daemon
sudo systemctl start docker

# Enable Docker service to start on system boot
sudo systemctl enable docker
# Wait for Docker to ready
sleep 15

# Verify Docker installation
docker version


# Function to install Jenkins
  sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
  sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
  sudo yum install -y jenkins
  sudo chown -R jenkins:jenkins /var/lib/jenkins
  sudo chmod -R 755 /var/lib/jenkins/
  sudo usermod -aG docker jenkins
  sudo systemctl daemon-reload
  sleep 15
  sudo systemctl start jenkins
  sudo systemctl enable jenkins
  sudo firewall-cmd --permanent --zone=public --add-port=8080/tcp
  sudo firewall-cmd --reload
  sudo firewall-cmd --permanent --zone=public --add-port=8888/tcp
  sudo firewall-cmd --reload
  # Wait for Jenkins to ready
  sleep 10
  jenkins_version=$(sudo systemctl status jenkins | grep -oP 'Jenkins Continuous Integration Server, version \K(\d+\.\d+\.\d+)')
  echo "Jenkins version: $jenkins_version"
  
  # Wait for Jenkins to start
sleep 30

# Retrieve the initial one-time password
jenkins_password=$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)

# Install default recommended plugins
sudo java -jar /var/cache/jenkins/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080/ install-plugin --all

# Start Jenkins
sudo java -jar /var/cache/jenkins/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080/ safe-restart

# Wait for Jenkins to restart
sleep 30

# Read admin user credentials from file
credentials_path="/home/movvamanoj/gitrepo/movvaweb/jenkins-credentials.txt"
username=$(grep -oP 'username=\K.*' "$credentials_path")
password=$(grep -oP 'password=\K.*' "$credentials_path")
full_name=$(grep -oP 'full_name=\K.*' "$credentials_path")
email=$(grep -oP 'email=\K.*' "$credentials_path")

# Create admin user
sudo java -jar /var/cache/jenkins/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080/ -auth admin:"$jenkins_password" create-user "$username" "$password" --full-name "$full_name" --email "$email"
}
if [[ -f /etc/redhat-release ]]; then
  install_redhat_packages
else
  echo "Unsupported operating system."
  exit 1
fi
