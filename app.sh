#!/bin/bash
set -e
set -x  # Enable verbose mode
# Function to log commands and their outputs
log_command() {
  command="$1"
  log_file="/home/ec2-user/installation.log"  # Specify the desired path for the log file
  echo "Running command: $command"
  eval "$command" > >(tee -a "$log_file") 2>&1
  echo "Command completed."
}

# Function to install Red Hat packages
install_redhat_packages() {
# Install Red Hat specific packages
log_command "sudo yum update -y"
log_command "sudo yum install -y wget unzip"
# Install Java 11
echo "Installing java11..."
log_command "sudo yum install -y java-11-openjdk-devel"
log_command "echo "export JAVA11_HOME=/usr/lib/jvm/java-11-openjdk" >> ~/.bashrc"
log_command "source ~/.bashrc"
echo "Installing java11 done..."
echo "Installing java 8..."

# Install Java 8
log_command "sudo yum install -y java-1.8.0-openjdk-devel"
log_command "echo "export JAVA8_HOME=/usr/lib/jvm/java-1.8.0-openjdk" >> ~/.bashrc"
log_command "source ~/.bashrc"
echo "Installing java8 done..."

log_command "echo "export DOCKER_JAVA_PATH=usr/lib/jvm/java-1.8.0-openjdk" >> ~/.bashrc"
log_command "source ~/.bashrc"

echo "Installing java17..."
# Install Java 17
log_command "sudo yum install -y java-17-openjdk-devel"
log_command "echo "export SONAR_JAVA_PATH=/usr/lib/jvm/java-17-openjdk" >> ~/.bashrc"
log_command "source ~/.bashrc"
echo "Installing java17 done..."

echo "Installing Git..."

log_command "sudo yum install -y git"
log_command "mkdir github"
log_command "cd github"
log_command "git config --global credential.helper 'cache --timeout=3600'"

# Read Git token from file
log_command "GIT_TOKEN=$(cat "/home/movvamanoj/gitrepo/gittok.txt")"

# Read username from file
log_command "USERNAME=$(cat "/home/movvamanoj/gitrepo/gitusername.txt")"

# Clone the repository using the Git token and username for authentication
log_command "git clone https://${USERNAME}:${GIT_TOKEN}@github.com/movvamanoj/movvaweb.git"
echo "Git installed successfully."

sleep 20
echo "Installing Maven..."

log_command "sudo yum install -y maven"
echo "Maven installed successfully."

sleep 10
echo "Installing Docker..."
# Install Docker dependencies
log_command "sudo yum install -y yum-utils device-mapper-persistent-data lvm2"

# Add Docker repository
log_command "sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo"

# Install Docker
log_command "sudo yum install -y docker-ce docker-ce-cli containerd.io"

# Configure Docker environment for the current session
log_command "sudo usermod -aG docker $USER"
newgrp docker

# Start the Docker daemon
log_command "sudo systemctl start docker"

# Enable Docker service to start on system boot
log_command "sudo systemctl enable docker"
# Wait for Docker to ready
sleep 15

# Verify Docker installation
log_command "docker version"
echo "Docker installed successfully."

echo "Installing Jenkins..."

# Function to install Jenkins
log_command "sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo"
log_command "sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key"
log_command "sudo yum install -y jenkins"
log_command "sudo chown -R jenkins:jenkins /var/lib/jenkins"
log_command "sudo chmod -R 755 /var/lib/jenkins/"
log_command "sudo usermod -aG docker jenkins"
log_command "sudo systemctl daemon-reload"
sleep 15
log_command "sudo systemctl start jenkins"
log_command "sudo systemctl enable jenkins"
log_command "sudo firewall-cmd --permanent --zone=public --add-port=8080/tcp"
sudo firewall-cmd --reload
log_command "sudo firewall-cmd --permanent --zone=public --add-port=8888/tcp"
log_command "sudo firewall-cmd --reload"
  # Wait for Jenkins to ready
sleep 10
jenkins_version=$(sudo systemctl status jenkins | grep -oP 'Jenkins Continuous Integration Server, version \K(\d+\.\d+\.\d+)')
echo "Jenkins version: $jenkins_version"
  
  # Wait for Jenkins to start
sleep 30

# Retrieve the initial one-time password
log_command "jenkins_password=$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)"

# Install default recommended plugins
log_command "sudo java -jar /var/cache/jenkins/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080/ install-plugin --all"

# Start Jenkins
log_command "sudo java -jar /var/cache/jenkins/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080/ safe-restart"

# Wait for Jenkins to restart
sleep 30

# Read admin user credentials from file
credentials_path="/home/movvamanoj/gitrepo/movvaweb/jenkins-credentials.txt"
username=$(grep -oP 'username=\K.*' "$credentials_path")
password=$(grep -oP 'password=\K.*' "$credentials_path")
full_name=$(grep -oP 'full_name=\K.*' "$credentials_path")
email=$(grep -oP 'email=\K.*' "$credentials_path")

# Create admin user
log_command "sudo java -jar /var/cache/jenkins/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080/ -auth admin:"$jenkins_password" create-user "$username" "$password" --full-name "$full_name" --email "$email""
echo "Jenkins installed successfully."

}
if [[ -f /etc/redhat-release ]]; then
  install_redhat_packages
else
  echo "Unsupported operating system."
  exit 1
fi
