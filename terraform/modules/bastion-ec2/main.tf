# Security group for bastion host
resource "aws_security_group" "bastion" {
    name        = "${var.tags["Name"]}-bastion-sg"
    description = "Security group for bastion host"
    vpc_id      = var.vpc_id

    # SSH access from anywhere (restrict to your IP in production)
    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # Outbound internet access
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = merge(var.tags, {
        Name = "${var.tags["Name"]}-bastion-sg"
        Type = "bastion"
    })
}

# Bastion host EC2 instance
resource "aws_instance" "bastion" {
    ami                         = var.ami_id
    instance_type               = var.instance_type
    subnet_id                   = var.public_subnet_id
    vpc_security_group_ids      = [aws_security_group.bastion.id]
    key_name                    = var.key_name
    associate_public_ip_address = true

    tags = merge(var.tags, {
        Name = "${var.tags["Name"]}-bastion"
        Type = "bastion"
    })

    # User data to install kubectl and AWS CLI for EKS management
    user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install -y curl
              
              # Install AWS CLI
              curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
              sudo apt install -y unzip
              unzip awscliv2.zip
              sudo ./aws/install

              
              # Install kubectl
              curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
              install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
              
              # Install eksctl
              curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
              mv /tmp/eksctl /usr/local/bin
              
              echo "Bastion host ready for EKS management"
              EOF
}