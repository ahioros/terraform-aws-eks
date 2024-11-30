# Create VPC
resource "aws_vpc" "eks-vpc" {
  cidr_block = local.config.network.cidr_block_vpc
  tags = {
    Name = "EKS-VPC"
  }
}

# Create internet gateway
resource "aws_internet_gateway" "eks-igw" {
  vpc_id = aws_vpc.eks-vpc.id
  tags = {
    Name = "EKS-VPC"
  }
}

# Create private subnet us-east-1a
resource "aws_subnet" "eks-private-subnet-1" {
  vpc_id            = aws_vpc.eks-vpc.id
  cidr_block        = local.config.network.cidr-block-subnets["private-subnet-1"]
  availability_zone = local.config.network.AZs[0]
  tags = {
    Name                              = "EKS-Private-Subnet"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

# Create private subnet us-east-1b
resource "aws_subnet" "eks-private-subnet-2" {
  vpc_id            = aws_vpc.eks-vpc.id
  cidr_block        = local.config.network.cidr-block-subnets["private-subnet-2"]
  availability_zone = local.config.network.AZs[1]
  tags = {
    Name                              = "EKS-Private-Subnet"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

# Create public subnet us-east-1a
resource "aws_subnet" "eks-public-subnet-1" {
  vpc_id                  = aws_vpc.eks-vpc.id
  cidr_block              = local.config.network.cidr-block-subnets["public-subnet-1"]
  availability_zone       = local.config.network.AZs[0]
  map_public_ip_on_launch = true
  tags = {
    Name                     = "EKS-Public-Subnet"
    "kubernetes.io/role/elb" = "1"
  }
}

# Create public subnet us-east-1b
resource "aws_subnet" "eks-public-subnet-2" {
  vpc_id                  = aws_vpc.eks-vpc.id
  cidr_block              = local.config.network.cidr-block-subnets["public-subnet-2"]
  availability_zone       = local.config.network.AZs[1]
  map_public_ip_on_launch = true
  tags = {
    Name                     = "EKS-Public-Subnet"
    "kubernetes.io/role/elb" = "1"
  }
}


# Create NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "EKS-NAT"
  }
}

resource "aws_nat_gateway" "eks-nat-gw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.eks-public-subnet-1.id
  tags = {
    Name = "EKS-NAT"
  }
  depends_on = [aws_internet_gateway.eks-igw]
}

# Route table for private subnet
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.eks-vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.eks-nat-gw.id
  }

  tags = {
    Name = "EKS-Private-Route-Table"
  }
}

# Route table for public subnet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.eks-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks-igw.id
  }

  tags = {
    Name = "EKS-Public-Route-Table"
  }
}

# Routing table association
resource "aws_route_table_association" "private-us-east-1a" {
  subnet_id      = aws_subnet.eks-private-subnet-1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private-us-east-1b" {
  subnet_id      = aws_subnet.eks-private-subnet-2.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "public-us-east-1a" {
  subnet_id      = aws_subnet.eks-public-subnet-1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public-us-east-1b" {
  subnet_id      = aws_subnet.eks-public-subnet-2.id
  route_table_id = aws_route_table.public.id
}
