#!/bin/bash
# Function to check if a package is installed
is_package_installed() {
  local package_name="$1"
  if rpm -q "$package_name" &>/dev/null; then
    return 0 # Package is installed
  else
    return 1 # Package is not installed
  fi
}

# Install Red Hat specific packages
install_redhat_packages() {
  sudo yum update -y
  sudo yum install -y wget unzip

  if ! is_package_installed "java-11-openjdk-devel"; then
    sudo yum install -y java-11-openjdk-devel
    echo "export JAVA_HOME=/usr/lib/jvm/java-11-openjdk" >> ~/.bashrc
  fi

  if ! is_package_installed "java-1.8.0-openjdk-devel"; then
    sudo yum install -y java-1.8.0-openjdk-devel
    echo "export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk" >> ~/.bashrc
  fi

  if ! is_package_installed "java-17-openjdk-devel"; then
    sudo yum install -y java-17-openjdk-devel
    echo "export SONAR_JAVA_PATH=/usr/lib/jvm/java-17-openjdk" >> ~/.bashrc
  fi

  source ~/.bashrc
  
  # Check if pip is installed
if ! command -v pip >/dev/null 2>&1; then
  echo "Pip is not installed. Installing pip..."
  sudo yum install -y python-pip
fi

# Check if boto3 is installed
if ! python -c "import boto3" >/dev/null 2>&1; then
  echo "Boto3 is not installed. Installing boto3..."
  sudo pip install boto3
fi

# Check if yum-utils is installed
if ! command -v yum-utils >/dev/null 2>&1; then
  echo "yum-utils is not installed. Installing yum-utils..."
  sudo yum install -y yum-utils
fi

# Check if hashicorp repository is added
if [[ ! -f /etc/yum.repos.d/hashicorp.repo ]]; then
  echo "HashiCorp repository is not added. Adding the repository..."
  sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
fi

# Check if terraform is installed
if ! command -v terraform >/dev/null 2>&1; then
  echo "Terraform is not installed. Installing terraform..."
  sudo yum -y install terraform
fi

  if ! is_package_installed "git"; then
    sudo yum install -y git
  fi

if [ ! -d "$HOME/github" ]; then
  mkdir "$HOME/github"
  cd "$HOME/github" && git config --global credential.helper 'cache --timeout=3600' && git clone "https://${GIT_USERNAME}:${GIT_TOKEN}@github.com/movvamanoj/movvaweb.git"
fi

  if ! is_package_installed "maven"; then
    sudo yum install -y maven
  fi

  if ! is_package_installed "firewalld"; then
    sudo yum install -y firewalld
    sudo systemctl start firewalld
    sudo systemctl enable firewalld
    sudo systemctl daemon-reload
  fi

  if ! sudo firewall-cmd --list-ports | grep -q "8080/tcp"; then
    sudo firewall-cmd --permanent --zone=public --add-port=8080/tcp
  fi

  if ! sudo firewall-cmd --list-ports | grep -q "8888/tcp"; then
    sudo firewall-cmd --permanent --zone=public --add-port=8888/tcp
  fi

  if ! sudo firewall-cmd --list-ports | grep -q "9000/tcp"; then
    sudo firewall-cmd --permanent --zone=public --add-port=9000/tcp
  fi

  if ! sudo firewall-cmd --list-ports | grep -q "9001/tcp"; then
    sudo firewall-cmd --permanent --zone=public --add-port=9001/tcp
  fi

  sudo firewall-cmd --reload

  if ! is_package_installed "yum-utils"; then
    sudo yum install -y yum-utils device-mapper-persistent-data lvm2
  fi

  if ! is_package_installed "docker-ce"; then
    sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    sudo yum install -y docker-ce docker-ce-cli containerd.io
    sudo usermod -aG docker $USER
    sudo systemctl start docker
    sudo systemctl enable docker
  fi

  docker version
# Install expect the package
	sudo yum install -y expect
	# Verify if expect is installed
	if rpm -q expect >/dev/null; then
	echo "expect installed successfully."
	else
	echo "Failed to install expect."
	fi

  if ! is_package_installed "jenkins"; then
    sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
    sudo rpm --import https://pkg.jenkins.io/redhat/jenkins.io-2023.key
    sudo yum install -y jenkins
    sudo systemctl start jenkins
    sudo systemctl enable jenkins
    sudo chmod -R 755 /var/cache/jenkins
    sudo chown -R jenkins:jenkins /var/cache/jenkins
    sudo chown -R jenkins:jenkins /var/lib/jenkins
    sudo chmod -R 755 /var/lib/jenkins
    # Download jenkins-cli.jar
    sudo wget -O /var/cache/jenkins/war/WEB-INF/jenkins-cli.jar http://localhost:8080/jnlpJars/jenkins-cli.jar

    sudo usermod -aG docker jenkins
    sudo systemctl daemon-reload
    sudo systemctl restart jenkins

    echo "Waiting for Jenkins to start..."
    while ! sudo systemctl is-active --quiet jenkins; do
      sleep 5
    done

    jenkins_version=$(sudo systemctl status jenkins | grep -oP 'Jenkins Continuous Integration Server, version \K(\d+\.\d+\.\d+)')
    echo "Jenkins version: $jenkins_version"

    jenkins_password=$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)
   
    # Use expect to automate login and provide the password
  expect -c "
    spawn java -jar \"$jenkins_cli_path\" -s http://localhost:8080 login
    expect \"Password:\"
    send \"$jenkins_password\r\"
    interact
  "

sudo java -jar /var/cache/jenkins/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080/ install-plugin --all

sudo java -jar /var/cache/jenkins/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080/ -auth admin:${jenkins_password} create-user "admin" "admin" --full-name "admin" --email "info@movva.com"

#sudo java -jar /var/cache/jenkins/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080/ -auth admin:${JENKINS_PASSWORD} create-user ${JENKINS_USERNAME} ${JENKINS_PASSWORD} --full-name ${JENKINS_FULL_NAME} --email ${JENKINS_EMAIL}

    sudo java -jar /var/cache/jenkins/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080/ restart

    sleep 30

    echo "Jenkins installed successfully."
  fi
}

# Main script execution
if [[ -f /etc/redhat-release ]]; then
  install_redhat_packages
else
  echo "Unsupported operating system."
  exit 1
fi
