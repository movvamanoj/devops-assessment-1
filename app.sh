#!/bin/bash

# Function to setup the environment
setup_environment() {
  if [[ -f /etc/redhat-release ]]; then
    # Red Hat based systems
    sudo yum update -y
    sudo yum install -y wget unzip
  elif [[ -f /etc/lsb-release ]]; then
    # Ubuntu based systems
    sudo apt-get update
    sudo apt-get install -y wget unzip
  elif [[ -f /etc/system-release ]]; then
    # Amazon Linux
    sudo yum update -y
    sudo yum install -y wget unzip
  fi
}

# Function to install Java 11
install_java_11() {
  if [[ -f /etc/redhat-release ]]; then
    # Red Hat based systems
    sudo yum install -y java-11-openjdk-devel
  elif [[ -f /etc/lsb-release ]]; then
    # Ubuntu based systems
    sudo apt-get install -y openjdk-11-jdk
  elif [[ -f /etc/system-release ]]; then
    # Amazon Linux
    sudo amazon-linux-extras install -y java-openjdk11
  fi
}

# Function to install Java 17
install_java_17() {
  if [[ -f /etc/redhat-release ]]; then
    # Red Hat based systems
    sudo yum install -y java-17-openjdk-devel
  elif [[ -f /etc/lsb-release ]]; then
    # Ubuntu based systems
    sudo apt-get install -y openjdk-17-jdk
  elif [[ -f /etc/system-release ]]; then
    # Amazon Linux
    sudo yum install java-17-amazon-corretto

  fi
}

# Function to install Java 1.8
install_java_1_8() {
  if [[ -f /etc/redhat-release ]]; then
    # Red Hat based systems
    sudo yum install -y java-1.8.0-openjdk-devel
  elif [[ -f /etc/lsb-release ]]; then
    # Ubuntu based systems
    sudo apt-get install -y openjdk-8-jdk
  elif [[ -f /etc/system-release ]]; then
    # Amazon Linux
sudo yum install java-1.8.0-openjdk
  fi
}

# Function to setup Java environment variables
setup_java_environment() {
  echo "export JAVA_HOME=/usr/lib/jvm/java-11-openjdk" >> ~/.bashrc
  echo "export PATH=\$PATH:\$JAVA_HOME/bin" >> ~/.bashrc
  echo "export SONAR_JAVA_PATH=/usr/lib/jvm/java-17-openjdk-17.0.7.0.7-3.el9.x86_64/bin/java" >> ~/.bashrc
  source ~/.bashrc
}

# Function to install Git
install_git() {
  if [[ -f /etc/redhat-release ]]; then
    # Red Hat based systems
    sudo yum install -y git
  elif [[ -f /etc/lsb-release ]]; then
    # Ubuntu based systems
    sudo apt-get install -y git
  elif [[ -f /etc/system-release ]]; then
    # Amazon Linux
    sudo yum install -y git
  fi
}

# Function to configure Git
configure_git() {
  git config --global user.name "movvamanoj"
  git config --global user.email "movvamanoj@gmail.com"
}
# Function to install Maven
install_maven() {
  if [[ -f /etc/redhat-release ]]; then
    # Red Hat based systems
    sudo yum install -y maven
  elif [[ -f /etc/lsb-release ]]; then
    # Ubuntu based systems
    sudo apt-get install -y maven
  elif [[ -f /etc/system-release ]]; then
    # Amazon Linux
    sudo yum install -y maven
  fi
}

# Function to install Docker
install_docker() {
  if [[ -f /etc/redhat-release ]]; then
    # Red Hat based systems
    sudo yum install -y yum-utils
    sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    sudo yum install -y docker-ce docker-ce-cli containerd.io
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo usermod -aG docker jenkins
    sudo usermod -aG docker sonarqube
  elif [[ -f /etc/lsb-release ]]; then
    # Ubuntu based systems
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
  elif [[ -f /etc/system-release ]]; then
    # Amazon Linux
    sudo amazon-linux-extras install -y docker
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo usermod -aG docker jenkins
    sudo usermod -aG docker sonarqube
  fi
}

# Function to install Jenkins
install_jenkins() {
  if [[ -f /etc/redhat-release ]]; then
    # Red Hat based systems
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
  elif [[ -f /etc/lsb-release ]]; then
    # Ubuntu based systems
    wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
    sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
    sudo apt-get update
    sudo apt-get install -y jenkins
    sudo systemctl start jenkins
    sudo systemctl enable jenkins
    sudo usermod -aG docker jenkins
    sudo chown -R jenkins:jenkins /var/lib/jenkins
    sudo chmod -R 755 /var/lib/jenkins/
    sudo ufw allow 8080/tcp
    sudo ufw allow 8888/tcp
  
  elif [[ -f /etc/system-release ]]; then
    # Amazon Linux
    sudo amazon-linux-extras install -y epel
    sudo wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat/jenkins.repo
    sudo rpm --import https://jenkins-ci.org/redhat/jenkins-ci.org.key
    sudo yum install -y jenkins
    sudo firewall-cmd --reload
    sudo systemctl start jenkins
    sudo systemctl enable jenkins
    sudo usermod -aG docker jenkins
    sudo chown -R jenkins:jenkins /var/lib/jenkins
    sudo chmod -R 755 /var/lib/jenkins/
    sudo firewall-cmd --permanent --zone=public --add-port=8080/tcp
    sudo firewall-cmd --permanent --zone=public --add-port=8888/tcp
    sudo firewall-cmd --reload  
  fi
}

# Function to install Postman
install_postman() {
  if [[ -f /etc/redhat-release ]]; then
    # Red Hat based systems
    sudo wget https://dl.pstmn.io/download/latest/linux64 -O postman.tar.gz
    sudo tar -xzf postman.tar.gz -C /opt
    sudo ln -s /opt/Postman/Postman /usr/bin/postman
    rm postman.tar.gz
  elif [[ -f /etc/lsb-release ]]; then
    # Ubuntu based systems
    sudo wget https://dl.pstmn.io/download/latest/linux64 -O postman.tar.gz
    sudo tar -xzf postman.tar.gz -C /opt
    sudo ln -s /opt/Postman/Postman /usr/bin/postman
    rm postman.tar.gz
  elif [[ -f /etc/system-release ]]; then
    # Amazon Linux
    sudo wget https://dl.pstmn.io/download/latest/linux64 -O postman.tar.gz
    sudo tar -xzf postman.tar.gz -C /opt
    sudo ln -s /opt/Postman/Postman /usr/bin/postman
    rm postman.tar.gz
  fi
}

# Function to install SonarQube
install_sonarqube() {
  if [[ -f /etc/redhat-release ]]; then
    # Red Hat based systems
    sudo wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-10.0.0.68432.zip
    sudo unzip sonarqube-10.0.0.68432.zip -d /opt
    sudo ln -s /opt/sonarqube-10.0.0.68432 /opt/sonarqube
    sudo chown -R $USER:$USER /opt/sonarqube
    rm sonarqube-10.0.0.68432.zip
    sudo firewall-cmd --permanent --zone=public --add-port=9000/tcp
    sudo firewall-cmd --reload
    sudo systemctl start sonarqube
    sudo systemctl enable sonarqube
    sudo usermod -aG sonarqube docker
  elif [[ -f /etc/lsb-release ]]; then
    # Ubuntu based systems
    sudo wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-10.0.0.68432.zip
    sudo unzip sonarqube-10.0.0.68432.zip -d /opt
    sudo ln -s /opt/sonarqube-10.0.0.68432 /opt/sonarqube
    sudo chown -R $USER:$USER /opt/sonarqube
    rm sonarqube-10.0.0.68432.zip
    sudo firewall-cmd --permanent --zone=public --add-port=9000/tcp
    sudo firewall-cmd --reload
    sudo systemctl start sonarqube
    sudo systemctl enable sonarqube
    sudo usermod -aG sonarqube docker
  elif [[ -f /etc/system-release ]]; then
    # Amazon Linux
    sudo wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-10.0.0.68432.zip
    sudo unzip sonarqube-10.0.0.68432.zip -d /opt
    sudo ln -s /opt/sonarqube-10.0.0.68432 /opt/sonarqube
    sudo chown -R $USER:$USER /opt/sonarqube
    rm sonarqube-10.0.0.68432.zip
    sudo firewall-cmd --permanent --zone=public --add-port=9000/tcp
    sudo firewall-cmd --reload
    sudo systemctl start sonarqube
    sudo systemctl enable sonarqube
    sudo usermod -aG sonarqube docker
  fi
}
# Main script execution
setup_environment
install_java_11
install_java_17
install_java_1_8
setup_java_environment
install_git
install_maven
install_docker
install_jenkins
install_postman
install_sonarqube
