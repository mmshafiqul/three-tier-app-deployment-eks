output "key_name" {
  value       = aws_key_pair.key_pair.key_name
  description = "The name of the AWS key pair"
}

output "private_key_path" {
  value       = local_file.private_key.filename
  description = "Local path to the private key file"
}

output "public_key" {
  value       = tls_private_key.generate.public_key_pem
  description = "The public key in PEM format"
  sensitive   = true
}