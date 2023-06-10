#!/bin/bash
#set -e
#set -x  # Enable verbose mode

# Function to install Red Hat packages
install_redhat_packages() {
# Install Red Hat specific packages
sudo yum update -y

sudo yum install -y wget unzip


sudo yum install -y firewalld
sudo systemctl start firewalld
sudo systemctl enable firewalld
sudo systemctl daemon-reload

sudo firewall-cmd --permanent --zone=public --add-port=8080/tcp
sudo firewall-cmd --reload
sudo firewall-cmd --permanent --zone=public --add-port=8888/tcp
sudo firewall-cmd --reload
sudo firewall-cmd --permanent --zone=public --add-port=9000/tcp
sudo firewall-cmd --reload
sudo firewall-cmd --permanent --zone=public --add-port=9001/tcp
sudo firewall-cmd --reload

# Install Java 11
echo "Installing java11..."
sudo yum install -y java-11-openjdk-devel
echo "export JAVA11_HOME=/usr/lib/jvm/java-11-openjdk" >> ~/.bashrc
source ~/.bashrc
echo "Installing java11 done..."
echo "Installing java 8..."

# Install Java 8
sudo yum install -y java-1.8.0-openjdk-devel
echo "export JAVA8_HOME=/usr/lib/jvm/java-1.8.0-openjdk" >> ~/.bashrc
source ~/.bashrc
echo "Installing java8 done..."

echo "export DOCKER_JAVA_PATH=usr/lib/jvm/java-1.8.0-openjdk" >> ~/.bashrc
source ~/.bashrc

echo "Installing java17..."
# Install Java 17
sudo yum install -y java-17-openjdk-devel
echo "export SONAR_JAVA_PATH=/usr/lib/jvm/java-17-openjdk" >> ~/.bashrc
source ~/.bashrc
echo "Installing java17 done..."

echo "Installing Git..."

sudo yum install -y git
mkdir github
cd github
git config --global credential.helper 'cache --timeout=3600'
git clone https://${GIT_USERNAME}:${GIT_TOKEN}@github.com/movvamanoj/movvaweb.git
echo "Git installed successfully."
sleep 20

echo "Installing Maven..."

sudo yum install -y maven
echo "Maven installed successfully."

sleep 10
echo "Installing Docker..."
# Install Docker dependencies
sudo yum install -y yum-utils device-mapper-persistent-data lvm2

# Add Docker repository
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# Install Docker
sudo yum install -y docker-ce docker-ce-cli containerd.io

# Configure Docker environment for the current session
sudo usermod -aG docker $USER
newgrp docker

# Start the Docker daemon
sudo systemctl start docker

# Enable Docker service to start on system boot
sudo systemctl enable docker
# Wait for Docker to ready
sleep 15

# Verify Docker installation
docker version
echo "Docker installed successfully."

echo "Installing Jenkins..."

# Function to install Jenkins
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
sudo yum install -y jenkins
sudo chown -R jenkins:jenkins /var/lib/jenkins
sudo chmod -R 755 /var/lib/jenkins
sudo usermod -aG docker jenkins
sudo systemctl daemon-reload
sleep 15
sudo systemctl start jenkins
sudo systemctl enable jenkins

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

# Read admin user credentials from Terraform
username=${JENKINS_USERNAME}
password=${JENKINS_PASSWORD}
full_name=${JENKINS_FULL_NAME}
email=${JENKINS_EMAIL}

# Create admin user
sudo java -jar /var/cache/jenkins/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080/ -auth admin:${JENKINS_PASSWORD} create-user ${JENKINS_USERNAME} ${JENKINS_PASSWORD} --full-name ${JENKINS_FULL_NAME} --email ${JENKINS_EMAIL}
echo "Jenkins installed successfully."


}
if [[ -f /etc/redhat-release ]]; then
  install_redhat_packages
else
  echo "Unsupported operating system."
  exit 1
fi
