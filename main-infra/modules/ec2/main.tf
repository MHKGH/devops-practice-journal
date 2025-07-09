resource "aws_instance" "jenkins_master" {
    ami= var.ami
    instance_type = var.instance_type
    key_name = var.key_name
    vpc_security_group_ids = [var.sg_id]
    subnet_id = var.subnet_id
    associate_public_ip_address = true

    tags = {
      Name = "Jenkins-Master"
      Environment = "Dev"
    }
  
}