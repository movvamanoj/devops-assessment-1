#!/bin/bash
LOG_FILE="$HOME/ec2-user//logfile.log"

# Function to execute a command and log the output
execute_command() {
  local cmd=$@
  echo "Executing: $cmd"
  eval $cmd 2>&1 | tee -a $LOG_FILE
  local exit_code=${PIPESTATUS[0]}
  if [ $exit_code -eq 0 ]; then
    echo "Command executed successfully."
  else
    echo "Command failed with exit code $exit_code. Check $LOG_FILE for details."
  fi
  return $exit_code
}
# Install Red Hat specific packages
install_redhat_packages() {
  execute_command "sudo yum update -y"
  execute_command "sudo yum install -y wget unzip"

  execute_command "sudo yum install -y java-11-openjdk-devel"
  echo "export JAVA_HOME=/usr/lib/jvm/java-11-openjdk" >> ~/.bashrc

  execute_command "sudo yum install -y java-1.8.0-openjdk-devel"
  echo "export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk" >> ~/.bashrc

  execute_command "sudo yum install -y java-17-openjdk-devel"
  echo "export SONAR_JAVA_PATH=/usr/lib/jvm/java-17-openjdk" >> ~/.bashrc

  execute_command "source ~/.bashrc"

  execute_command "sudo yum install -y git"
  execute_command "mkdir github"
  execute_command "cd github && git config --global credential.helper 'cache --timeout=3600' && git clone https://${GIT_USERNAME}:${GIT_TOKEN}@github.com/movvamanoj/movvaweb.git"

  execute_command "sudo yum install -y maven"

  execute_command "sudo yum install -y firewalld"
  execute_command "sudo systemctl start firewalld"
  execute_command "sudo systemctl enable firewalld"
  execute_command "sudo systemctl daemon-reload"

  execute_command "sudo firewall-cmd --permanent --zone=public --add-port=8080/tcp"
  execute_command "sudo firewall-cmd --permanent --zone=public --add-port=8888/tcp"
  execute_command "sudo firewall-cmd --permanent --zone=public --add-port=9000/tcp"
  execute_command "sudo firewall-cmd --permanent --zone=public --add-port=9001/tcp"
  execute_command "sudo firewall-cmd --reload"

  execute_command "sudo yum install -y yum-utils device-mapper-persistent-data lvm2"
  execute_command "sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo"
  execute_command "sudo yum install -y docker-ce docker-ce-cli containerd.io"
  execute_command "sudo usermod -aG docker $USER"
  execute_command "sudo systemctl start docker"
  execute_command "sudo systemctl enable docker"

  execute_command "docker version"

  execute_command "sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo"
  execute_command "sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key"
  execute_command "sudo yum install -y jenkins"
  execute_command "sudo chown -R jenkins:jenkins /var/lib/jenkins"
  execute_command "sudo chmod -R 755 /var/lib/jenkins"
  execute_command "sudo usermod -aG docker jenkins"
  sudo chown jenkins:jenkins /var/cache/jenkins/war/WEB-INF/jenkins-cli.jar
  sudo chmod 755 /var/cache/jenkins/war/WEB-INF/jenkins-cli.jar
  execute_command "sudo systemctl daemon-reload"
  execute_command "sudo systemctl start jenkins"
  execute_command "sudo systemctl enable jenkins"

  echo "Waiting for Jenkins to start..."
  while ! sudo systemctl is-active --quiet jenkins; do
    sleep 5
  done
  
  jenkins_version=$(sudo systemctl status jenkins | grep -oP 'Jenkins Continuous Integration Server, version \K(\d+\.\d+\.\d+)')
  echo "Jenkins version: $jenkins_version"

  execute_command "jenkins_password=$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)"

  execute_command "sudo java -jar /var/cache/jenkins/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080/ install-plugin --all"

  execute_command "sudo java -jar /var/cache/jenkins/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080/ -auth admin:${JENKINS_PASSWORD} create-user ${JENKINS_USERNAME} ${JENKINS_PASSWORD} --full-name ${JENKINS_FULL_NAME} --email ${JENKINS_EMAIL}"

  execute_command "sudo java -jar /var/cache/jenkins/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080/ restart"

  sleep 30

  echo "Jenkins installed successfully."
}

# Main script execution
if [[ -f /etc/redhat-release ]]; then
  # Redirect all script output to the log file and display it on the console
  exec > >(tee -a "$LOG_FILE") 2>&1
  install_redhat_packages
else
  echo "Unsupported operating system."
  exit 1
fi
