#! /bin/bash
# Instance Identity Metadata Reference - https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instance-identity-documents.html
sudo yum update -y
sudo yum install -y httpd
sudo systemctl enable httpd
sudo service httpd start  
sudo echo '<h1>Hello MANOJKUMAR MOVVA, Your New APP Ready</h1>' | sudo tee /var/www/html/index.html
sudo mkdir /var/www/html/app1
sudo echo '<!DOCTYPE html> <html> <body style="background-color:rgb(250, 210, 210);"> <h1>OneMuthoot - APP-1</h1> <p>Terraform Demo</p> <p>Application Version: V1</p> </body></html>' | sudo tee /var/www/html/app1/index.html
sudo curl http://169.254.169.254/latest/dynamic/instance-identity/document -o /var/www/html/app1/metadata.html
#########################################################################################################
# Install Java 8 Development Kit
    sudo yum install -y java-1.8.0-openjdk-devel
    
    # Install Docker dependencies
    sudo yum install -y yum-utils device-mapper-persistent-data lvm2
    
    # Add Docker repository
    sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    
    # Install Docker
    sudo yum install -y docker-ce docker-ce-cli containerd.io
    
    # Start Docker service
    sudo systemctl start docker
    
    # Enable Docker service to start on boot
    sudo systemctl enable docker
    
    # Add the current user to the docker group
    sudo usermod -aG docker ec2-user
    
    # Pull and run the Docker image from Docker Hub
    sudo docker run -d -p 8080:8080 movvamanojaws/my-app
    ########################################################################################################################

