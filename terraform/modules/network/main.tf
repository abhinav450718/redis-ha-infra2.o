resource "aws_subnet" "public" {
  cidr_block              = var.public_subnet_cidr
  vpc_id                  = aws_vpc.main.id
  availability_zone       = "sa-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private1" {
  cidr_block        = var.private_subnet1_cidr
  vpc_id            = aws_vpc.main.id
  availability_zone = "sa-east-1a"
}

resource "aws_subnet" "private2" {
  cidr_block        = var.private_subnet2_cidr
  vpc_id            = aws_vpc.main.id
  availability_zone = "sa-east-1a"
}
