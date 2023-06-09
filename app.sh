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
  echo "export JAVA17_HOME=/usr/lib/jvm/java-17-openjdk" >> ~/.bashrc
  source ~/.bashrc

  sudo yum install -y git
  mkdir github
  cd github
  git config --global credential.helper cache
  git config --global credential.helper 'cache --timeout=3600'
 # Read Git token from file
  GIT_TOKEN=$(cat "/home/movvamanoj/gitrepo/gittok.txt")
  # Set Git token as environment variable
  export GIT_TOKEN="$GIT_TOKEN"
  git clone https://github.com/movvamanoj/movvaweb.git
  
  sudo yum install -y maven
  sudo yum install -y yum-utils
  sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
  sudo yum install -y docker-ce docker-ce-cli containerd.io
  sudo systemctl start docker
  sudo systemctl enable docker
}

# Function to install Jenkins
install_jenkins() {
  sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
  sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
  sudo yum install -y jenkins
  sudo systemctl daemon-reload
  sudo systemctl start jenkins
  sudo systemctl enable jenkins
  sudo usermod -aG docker jenkins
  sudo chown -R jenkins:jenkins /var/lib/jenkins
  sudo chmod -R 755 /var/lib/jenkins/
  sudo firewall-cmd --permanent --zone=public --add-port=8080/tcp
  sudo firewall-cmd --reload
  sudo firewall-cmd --permanent --zone=public --add-port=8888/tcp
  sudo firewall-cmd --reload

}
if [[ -f /etc/redhat-release ]]; then
  install_redhat_packages
else
  echo "Unsupported operating system."
  exit 1
fi
