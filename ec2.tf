# AMI
# 最新版のAmazonLinux2のAMI情報
data "aws_ami" "example" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "block-device-mapping.volume-type"
    values = ["gp2"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

# EC2
resource "aws_instance" "example" {
  ami                    = data.aws_ami.example.image_id
  vpc_security_group_ids = [aws_security_group.example.id]
  subnet_id              = aws_subnet.public.id
  key_name               = aws_key_pair.example.id
  instance_type          = "t2.micro"
  user_data              = file("./docker_install.sh")

  tags = {
    Name = "tf-example"
  }
}

# EIP
resource "aws_eip" "example" {
  instance   = aws_instance.example.id
  vpc        = true
  depends_on = [aws_internet_gateway.example]
}

# Key Pair
resource "aws_key_pair" "example" {
  key_name   = "example"
  public_key = file("./id_rsa.pub")
}
