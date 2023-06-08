#!/bin/bash
# Function to install Red Hat packages
install_redhat_packages() {
  # Install Red Hat specific packages
  sudo yum update -y
  sudo yum install -y wget unzip
  sudo yum install -y java-11-openjdk-devel
  sudo yum install -y java-17-openjdk-devel
  sudo yum install -y java-1.8.0-openjdk-devel
  sudo yum install -y git
  sudo yum install -y maven
  # Install Docker
  sudo yum install -y yum-utils
  sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
  sudo yum install -y docker-ce docker-ce-cli containerd.io
  sudo systemctl start docker
  sudo systemctl enable docker
  sudo usermod -aG docker jenkins
  sudo usermod -aG docker sonarqube
  # Install Jenkins
  sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
  sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
  sudo yum install -y jenkins
  sudo systemctl start jenkins
  sudo systemctl enable jenkins
  sudo usermod -aG docker jenkins
  sudo chown -R jenkins:jenkins /var/lib/jenkins
  sudo chmod -R 755 /var/lib/jenkins/
  sudo firewall-cmd --permanent --zone=public --add-port=8080/tcp
  sudo firewall-cmd --permanent --zone=public --add-port=8888/tcp
  sudo firewall-cmd --reload
  # Install Postman
  sudo wget https://dl.pstmn.io/download/latest/linux64 -O postman.tar.gz
  sudo tar -xzf postman.tar.gz -C /opt
  sudo ln -s /opt/Postman/Postman /usr/bin/postman
  rm postman.tar.gz
  # Install SonarQube
  sudo wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-10.0.0.68432.zip
  sudo unzip sonarqube-10.0.0.68432.zip -d /opt
  sudo ln -s /opt/sonarqube-10.0.0.68432 /opt/sonarqube
  sudo chown -R $USER:$USER /opt/sonarqube
  rm sonarqube-10.0.0.68432.zip
  sudo firewall-cmd --permanent --zone=public --add-port=9000/tcp
  sudo firewall-cmd --reload
    sudo /opt/sonarqube/bin/linux-x86-64/sonar.sh start
  sudo usermod -aG sonarqube docker
  sudo systemctl enable sonarqube
  }

# Function to install Ubuntu packages
install_ubuntu_packages() {
  # Install Ubuntu specific packages
  sudo apt-get update
  sudo apt-get install -y wget unzip
  sudo apt-get install -y openjdk-11-jdk
  sudo apt-get install -y openjdk-17-jdk
  sudo apt-get install -y openjdk-8-jdk
  sudo apt-get install -y git
  sudo apt-get install -y maven
  # Install Docker
  sudo apt-get update
  sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
  echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get update
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io
  sudo systemctl start docker
  sudo systemctl enable docker
  sudo usermod -aG docker jenkins
  sudo usermod -aG docker sonarqube
  # Install Jenkins
  wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
  sudo sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
  sudo apt-get update
  sudo apt-get install -y jenkins
  sudo systemctl start jenkins
  sudo systemctl enable jenkins
  sudo usermod -aG docker jenkins
  sudo chown -R jenkins:jenkins /var/lib/jenkins
  sudo chmod -R 755 /var/lib/jenkins/
  sudo ufw allow 8080
  sudo ufw allow 8888
  # Install Postman
  wget https://dl.pstmn.io/download/latest/linux64 -O postman.tar.gz
  sudo tar -xzf postman.tar.gz -C /opt
  sudo ln -s /opt/Postman/Postman /usr/bin/postman
  rm postman.tar.gz
  # Install SonarQube
  wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-10.0.0.68432.zip
  sudo unzip sonarqube-10.0.0.68432.zip -d /opt
  sudo ln -s /opt/sonarqube-10.0.0.68432 /opt/sonarqube
  sudo chown -R $USER:$USER /opt/sonarqube
  rm sonarqube-10.0.0.68432.zip
  sudo ufw allow 9000
  sudo /opt/sonarqube/bin/linux-x86-64/sonar.sh start
  sudo usermod -aG sonarqube docker
  sudo systemctl enable sonarqube
  }

# Function to install Amazon Linux packages
install_amazon_packages() {
  # Install Amazon Linux specific packages
  
  sudo yum update -y
  sudo yum install -y wget unzip
  sudo amazon-linux-extras install -y java-openjdk11
  sudo amazon-linux-extras install -y java-openjdk17
  sudo amazon-linux-extras install -y java-openjdk8
  # Function to setup Java environment variables
  setup_java_environment() {
  echo "export JAVA_HOME=/usr/lib/jvm/java-11-openjdk" >> ~/.bashrc
  echo "export PATH=\$PATH:\$JAVA_HOME/bin" >> ~/.bashrc
  echo "export SONAR_JAVA_PATH=/usr/lib/jvm/java-17-openjdk-17.0.7.0.7-3.el9.x86_64/bin/java" >> ~/.bashrc
  source ~/.bashrc
}
  sudo yum install -y git
  sudo yum install -y maven
  # Install Docker
  sudo amazon-linux-extras install -y docker
  sudo systemctl start docker
  sudo systemctl enable docker
  sudo usermod -aG docker jenkins
  sudo usermod -aG docker sonarqube
  # Install Jenkins
  sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
  sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
  sudo yum install -y jenkins
  sudo systemctl start jenkins
  sudo systemctl enable jenkins
  sudo usermod -aG docker jenkins
  sudo chown -R jenkins:jenkins /var/lib/jenkins
  sudo chmod -R 755 /var/lib/jenkins/
  sudo firewall-cmd --permanent --zone=public --add-port=8080/tcp
  sudo firewall-cmd --permanent --zone=public --add-port=8888/tcp
  sudo firewall-cmd --reload
  # Install Postman
  sudo wget https://dl.pstmn.io/download/latest/linux64 -O postman.tar.gz
  sudo tar -xzf postman.tar.gz -C /opt
  sudo ln -s /opt/Postman/Postman /usr/bin/postman
  rm postman.tar.gz
  # Install SonarQube
  sudo wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-10.0.0.68432.zip
  sudo unzip sonarqube-10.0.0.68432.zip -d /opt
  sudo ln -s /opt/sonarqube-10.0.0.68432 /opt/sonarqube
  sudo chown -R $USER:$USER /opt/sonarqube
  rm sonarqube-10.0.0.68432.zip
  sudo firewall-cmd --permanent --zone=public --add-port=9000/tcp
  sudo firewall-cmd --reload
  sudo /opt/sonarqube/bin/linux-x86-64/sonar.sh start
  sudo usermod -aG sonarqube docker
  sudo systemctl enable sonarqube
}

# Main script execution
if [[ -f /etc/redhat-release ]]; then
  install_redhat_packages
elif [[ -f /etc/lsb-release ]]; then
  install_ubuntu_packages
elif [[ -f /etc/system-release ]]; then
  install_amazon_packages
else
  echo "Unsupported operating system."
  exit 1
fi
