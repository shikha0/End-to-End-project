resource aws_vpc "main" {
    cidr_block = var.cidr
    instance_tenancy = var.tenancy
    tags = {
        name = "VPC-EKS"
    }
}

resource "aws_subnet" "private_subnet"{
    count = length(var.private_subnet)
    depends_on = [ aws_vpc.main ]
    vpc_id = aws_vpc.main.id
    cidr_block = var.private_subnet[count.index]
    availability_zone = var.azs_private[count.index]
    tags = {
        name = "private-subnet[count.index]"
    }

}

resource "aws_subnet" "public_subnet"{
    count = length(var.public_subnet)
    depends_on = [ aws_vpc.main ] 
    vpc_id = aws_vpc.main.id
    cidr_block = var.public_subnet[count.index]
    availability_zone = var.azs_public[count.index]
    tags = {
        name = "public-subnet[count.index]"
    }

}

resource "aws_internet_gateway" "main" {
    depends_on = [ aws_vpc.main ]
    vpc_id = aws_vpc.main.id
    tags = {
        name = "main-igw"
    }
}

resource "aws_eip" "eip" {
    tags = {
        name = "eip"
    }
}

resource "aws_nat_gateway" "main" {
    depends_on = [ aws_vpc.main ]
    allocation_id = aws_eip.eip.id
    subnet_id = aws_subnet.public_subnet[0].id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }
}

resource "aws_route_table" "public" {
    depends_on = [ aws_vpc.main ]
    vpc_id = aws_vpc.main.id
    count = length(var.public_subnet)
    route {
      cidr_block = "0.0.0.0/0"
       gateway_id = aws_internet_gateway.main.id
    } 
    tags = {
        name = "public-route-table"
    }
}

resource "aws_route_table_association" "private" {
  depends_on = [ aws_vpc.main ]
  count = length(var.private_subnet) 
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private.id

}

resource "aws_route_table_association" "public" {
  depends_on = [ aws_vpc.main ]
  count = length(var.public_subnet) 
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id =  aws_route_table.public[0].id
}



