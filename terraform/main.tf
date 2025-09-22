provider "aws" {
  region = var.aws_region
}

# Security Group
resource "aws_security_group" "app_sg" {
  name        = "app-sg"
  description = "Allow SSH and HTTP"
}

# Allow SSH
resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.app_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

# Allow HTTP (port 80)
resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.app_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

# Allow all outbound
resource "aws_vpc_security_group_egress_rule" "allow_all_outbound" {
  security_group_id = aws_security_group.app_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# EC2 Instance
resource "aws_instance" "app_server" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install -y openjdk-21-jdk maven git

              cd /home/ubuntu
              git clone https://github.com/Trainings-TechEazy/test-repo-for-devops.git
              cd test-repo-for-devops

              # Build the project (skip tests for speed)
              mvn clean package -DskipTests

              # Find the jar file (ignore .original)
              JAR_FILE=$(ls target/*.jar | grep -v original | head -n 1)

              # Create a systemd service
              echo "[Unit]
              Description=Spring Boot App
              After=network.target

              [Service]
              User=root
              WorkingDirectory=/home/ubuntu/test-repo-for-devops
              ExecStart=/usr/bin/java -jar $JAR_FILE --server.port=80
              Restart=always
              StandardOutput=append:/home/ubuntu/test-repo-for-devops/app.log
              StandardError=append:/home/ubuntu/test-repo-for-devops/app-error.log

              [Install]
              WantedBy=multi-user.target" | sudo tee /etc/systemd/system/hellomvc.service

              # Start and enable the service
              sudo systemctl daemon-reload
              sudo systemctl enable hellomvc
              sudo systemctl start hellomvc

              sudo shutdown -h +120 "Shutting down to save costs"
              EOF

  tags = {
    Name = "TechEazyApp"
  }
}

# Outputs
output "public_ip" {
  value = aws_instance.app_server.public_ip
}

output "app_url" {
  value = "http://${aws_instance.app_server.public_ip}"
}

