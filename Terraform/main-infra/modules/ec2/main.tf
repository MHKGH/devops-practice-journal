resource "aws_key_pair" "ec2_key" {
  key_name   = var.key_pair_name
  public_key = file(var.public_key_path)
}



resource "aws_instance" "jenkins_master" {
  ami                         = var.ami
  instance_type               = var.instance_type
  vpc_security_group_ids      = [var.sg_id]
  subnet_id                   = var.subnet_id
  associate_public_ip_address = true
  key_name                    = aws_key_pair.ec2_key.key_name

  tags = merge(
    var.tags,
    {
      Name = "${var.env}-Jenkins-Master"
    }
  )
}

