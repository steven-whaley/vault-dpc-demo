output "myapp_public_ip" {
  description = "Public IP of the myapp EC2 instance"
  value       = aws_instance.myapp.public_ip
}