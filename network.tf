resource "aws_vpc" "example" {
	cidr_block = "10.0.0.0/16"
	enable_dns_support = true
	enable_dns_hostnames = true

	tags = {
		Name = "tf_example"
	}
}

# パブリックサブネット
resource "aws_subnet" "public" {
	vpc_id = aws_vpc.example.id
	cidr_block = "10.0.0.0/24"
	map_public_ip_on_launch = true
	availability_zone = "ap-northeast-1a"
}

resource "aws_internet_gateway" "example" {
	vpc_id = aws_vpc.example.id
}

# パブリックサブネット用ルートテーブル
resource "aws_route_table" "public" {
	vpc_id = aws_vpc.example.id
}
# インターネットゲートウェイへのルーティング設定
resource "aws_route" "public" {
	route_table_id = aws_route_table.public.id
	gateway_id = aws_internet_gateway.example.id
	destination_cidr_block = "0.0.0.0/0"
}
# サブネットとルートテーブルの関連づけ（パブリック）
resource "aws_route_table_association" "public" {
	subnet_id = aws_subnet.public.id
	route_table_id = aws_route_table.public.id
}

# プライベートサブネット
resource "aws_subnet" "private" {
	vpc_id = aws_vpc.example.id
	cidr_block = "10.0.64.0/24"
	availability_zone = "ap-northeast-1a"
	map_public_ip_on_launch = false
}
# プライベートサブネット用ルートテーブル
resource "aws_route_table" "private" {
	vpc_id = aws_vpc.example.id
}
# サブネットとルートテーブルの関連づけ（プライベート）
resource "aws_route_table_association" "private" {
	subnet_id = aws_subnet.private.id
	route_table_id = aws_route_table.private.id
}

resource "aws_eip" "nat_gateway" {
	vpc = true
	depends_on = [aws_internet_gateway.example]
}

resource "aws_nat_gateway" "example" {
	allocation_id = aws_eip.nat_gateway.id
	subnet_id = aws_subnet.public.id
	depends_on = [aws_internet_gateway.example]
}

resource "aws_route" "private" {
	route_table_id = aws_route_table.private.id
	nat_gateway_id = aws_nat_gateway.example.id
	destination_cidr_block = "0.0.0.0/0"
}

# ====================
#
# Security Group
#
# ====================
resource "aws_security_group" "example" {
	vpc_id = aws_vpc.example.id
	name   = "example"

	tags = {
	Name = "example"
	}
}

# インバウンドルール(ssh接続用)
resource "aws_security_group_rule" "in_ssh" {
	security_group_id = aws_security_group.example.id
	type              = "ingress"
	cidr_blocks       = ["0.0.0.0/0"]
	from_port         = 22
	to_port           = 22
	protocol          = "tcp"
}

# インバウンドルール(http用)
resource "aws_security_group_rule" "in_http" {
	security_group_id = aws_security_group.example.id
	type              = "ingress"
	cidr_blocks       = ["0.0.0.0/0"]
	from_port         = 80
	to_port           = 80
	protocol          = "tcp"
}

# アウトバウンドルール(全開放)
resource "aws_security_group_rule" "out_all" {
	security_group_id = aws_security_group.example.id
	type              = "egress"
	cidr_blocks       = ["0.0.0.0/0"]
	from_port         = 0
	to_port           = 0
	protocol          = "-1"
}