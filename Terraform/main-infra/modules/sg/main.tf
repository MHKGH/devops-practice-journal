resource "aws_security_group" "allow_ssh" {
    vpc_id = var.vpc_id
    name = var.sg_name

    tags = {
      Name = "Jenkins-SG"
    }

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [var.ingress_cidr_block]

    }

    ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = [var.ingress_cidr_block]

    }
    
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

  
}