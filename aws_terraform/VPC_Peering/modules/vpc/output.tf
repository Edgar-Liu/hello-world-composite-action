output "vpc_id" {
  value = aws_vpc.main.id
}

output "vpc_web_sg_id" {
  value = aws_security_group.web_sg.id
}