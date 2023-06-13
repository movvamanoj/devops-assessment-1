#!/bin/bash
# Set the environment variables
my_cred_content=$(terraform output -raw my_cred_content)
export GIT_USERNAME=$(grep -oP 'git_username=\K.*' <<< "$(terraform output -raw data.local_file.my_cred)")
export GIT_TOKEN=$(grep -oP 'git_token=\K.*' <<< "$(terraform output -raw data.local_file.my_cred)")
export DOCKER_USERNAME=$(grep -oP 'docker_username=\K.*' <<< "$(terraform output -raw data.local_file.my_cred)")
export DOCKER_PASSWORD=$(grep -oP 'docker_password=\K.*' <<< "$(terraform output -raw data.local_file.my_cred)")
export JENKINS_USERNAME=$(grep -oP 'jenkins_username=\K.*' <<< "$(terraform output -raw data.local_file.my_cred)")
export JENKINS_PASSWORD=$(grep -oP 'jenkins_password=\K.*' <<< "$(terraform output -raw data.local_file.my_cred)")
export JENKINS_FULL_NAME=$(grep -oP 'full_name=\K.*' <<< "$(terraform output -raw data.local_file.my_cred)")
export JENKINS_EMAIL=$(grep -oP 'email=\K.*' <<< "$(terraform output -raw data.local_file.my_cred)")
export SONARQUBE_USERNAME=$(grep -oP 'sonarqube_username=\K.*' <<< "$(terraform output -raw data.local_file.my_cred)")
export SONARQUBE_PASSWORD=$(grep -oP 'sonarqube_password=\K.*' <<< "$(terraform output -raw data.local_file.my_cred)")
# Call your bash script here, passing the environment variables
./app.sh "$GIT_USERNAME" "$GIT_TOKEN" "$DOCKER_USERNAME" "$DOCKER_PASSWORD" "$JENKINS_USERNAME" "$JENKINS_PASSWORD" "$JENKINS_FULL_NAME" "$JENKINS_EMAIL" "$SONARQUBE_USERNAME" "$SONARQUBE_PASSWORD"

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

  if ! is_package_installed "git"; then
    sudo yum install -y git
  fi


# Get GitHub username and token from arguments
github_username=$1
github_token=$2

# Clone the repository
if [ ! -d "$HOME/github" ]; then
  mkdir "$HOME/github"
  cd "$HOME/github" && git config --global credential.helper 'cache --timeout=3600' && git clone "https://${github_username}:${github_token}@github.com/movvamanoj/movvaweb.git"
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

# Install expect package
sudo yum install -y expect

# Verify if expect is installed
if rpm -q expect >/dev/null; then
  echo "expect installed successfully."
else
  echo "Failed to install expect."
fi

if ! is_package_installed "jenkins"; then
  jenkins_repo_url="https://pkg.jenkins.io/redhat/jenkins.repo"
  sudo curl "$jenkins_repo_url" -o /etc/yum.repos.d/jenkins.repo
  sudo rpm --import https://pkg.jenkins.io/redhat/jenkins.io-2023.key
  sudo yum install -y jenkins
  sudo systemctl start jenkins
  sudo systemctl enable jenkins
  jenkins_cli_url="http://localhost:8080/jnlpJars/jenkins-cli.jar"
  jenkins_cli_path="jenkins_cli_path="/var/lib/jenkins/jenkins-cli.jar"
  sudo curl -fsSL "$jenkins_cli_url" -o "$jenkins_cli_path"
  sudo chown jenkins:jenkins "$jenkins_cli_path"
  sudo chmod 755 "$jenkins_cli_path"
echo "Waiting for Jenkins to start..."
  while ! sudo systemctl is-active --quiet jenkins; do
    sleep 5
  done
  sudo chown -R jenkins:jenkins /var/lib/jenkins
  sudo chmod -R 755 /var/lib/jenkins
  sudo usermod -aG docker jenkins
  sudo systemctl daemon-reload
  sudo systemctl restart jenkins

  echo "Waiting for Jenkins to Re-Start..."
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

    sudo java -jar "$jenkins_cli_path" -s http://localhost:8080/ install-plugin --all

    sudo java -jar "$jenkins_cli_path" -s http://localhost:8080/ -auth admin:${JENKINS_PASSWORD} create-user ${JENKINS_USERNAME} ${JENKINS_PASSWORD} --full-name ${JENKINS_FULL_NAME} --email ${JENKINS_EMAIL}

    sudo java -jar "$jenkins_cli_path" -s http://localhost:8080/ restart

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
