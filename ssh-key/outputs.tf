output "public_key_openssh" {
  description = "Generated SSH public key in OpenSSH format"
  value       = tls_private_key.main.public_key_openssh
}

output "private_key_pem" {
  description = "Generated SSH private key"
  value       = tls_private_key.main.private_key_pem
  sensitive   = true
}