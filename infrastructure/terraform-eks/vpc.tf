resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "fintech-eks-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "fintech-igw"
  }
}

resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name                                    = "public-subnet-1"
    "kubernetes.io/role/elb"                = "1"
    "kubernetes.io/cluster/fintech-cluster" = "shared"
  }
}

resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = true

  tags = {
    Name                                    = "public-subnet-2"
    "kubernetes.io/role/elb"                = "1"
    "kubernetes.io/cluster/fintech-cluster" = "shared"
  }
}

resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    Name                                    = "private-subnet-1"
    "kubernetes.io/role/elb"                = "1"
    "kubernetes.io/cluster/fintech-cluster" = "shared"
  }
}

resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "ap-south-1b"

  tags = {
    Name                                    = "private-subnet-2"
    "kubernetes.io/role/elb"                = "1"
    "kubernetes.io/cluster/fintech-cluster" = "shared"
  }
}




resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}


# =====================================================
# NEW: NAT Gateway (The bridge for Private Subnets)
# =====================================================

# 1. Elastic IP (Static IP for the NAT Gateway)
resource "aws_eip" "nat" {
  domain = "vpc"
  
  tags = {
    Name = "fintech-nat-eip"
  }
}

# 2. The NAT Gateway (Must live in a PUBLIC Subnet)
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_1.id  # It sits in the public lobby

  tags = {
    Name = "fintech-nat-gw"
  }

  # Wait for the Internet Gateway to exist first
  depends_on = [aws_internet_gateway.igw]
}

# 3. Private Route Table (The Map for Private Nodes)
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"             # All outbound traffic...
    nat_gateway_id = aws_nat_gateway.main.id # ...goes to NAT Gateway
  }

  tags = {
    Name = "private-route-table"
  }
}

# 4. Associate Private Subnets with the new Route Table
resource "aws_route_table_association" "private_1" {
  subnet_id      = aws_subnet.private_1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_2" {
  subnet_id      = aws_subnet.private_2.id
  route_table_id = aws_route_table.private.id
}