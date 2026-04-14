# Generate SSH private key for EC2 instances
resource "tls_private_key" "generate" {
    algorithm = var.algorithm
    rsa_bits = var.rsa_bits
}

# Store private key locally for SSH access
resource "local_file" "private_key" {
    content = tls_private_key.generate.private_key_pem
    filename = "${var.key_name}.pem"
}

# Register public key with AWS for EC2 instances
resource "aws_key_pair" "key_pair" {
    key_name = var.key_name
    public_key = tls_private_key.generate.public_key_openssh
}