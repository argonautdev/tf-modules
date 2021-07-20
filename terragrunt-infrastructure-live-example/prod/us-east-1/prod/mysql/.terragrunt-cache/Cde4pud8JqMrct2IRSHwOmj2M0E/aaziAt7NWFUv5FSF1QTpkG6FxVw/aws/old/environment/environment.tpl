#
# Environment Resource: Top level constitutes of 
# * AWS VPC
# * AWS Subnets
# * AWS Internet Gateway
# * Route Table
#


resource "aws_vpc" "{{.Name}}-{{.UID}}" {
  cidr_block = "10.0.0.0/16"
  tags = tomap({
    "Name" = "{{.Name}}-{{.UID}}",
    }
  )
}

resource "aws_subnet" "{{.Name}}-{{.UID}}-subnet" {
  count = 2
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = "10.0.${count.index}.0/24"
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.{{.Name}}-{{.UID}}.id

  tags = tomap({
    "Name" = "{{.Name}}",
    }
  )
}

resource "aws_internet_gateway" "{{.Name}}-{{.UID}}-ig" {
  vpc_id = aws_vpc.{{.Name}}-{{.UID}}.id

  tags = {
    Name = "{{.Name}}-{{.UID}}"
  }
}

resource "aws_route_table" "{{.Name}}-{{.UID}}-rt" {
  vpc_id = aws_vpc.{{.Name}}-{{.UID}}.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.{{.Name}}-{{.UID}}-ig.id
  }
}

resource "aws_route_table_association" "{{.Name}}-{{.UID}}" {
  count = 1
  subnet_id      = aws_subnet.{{.Name}}-{{.UID}}-subnet.*.id[count.index]
  route_table_id = aws_route_table.{{.Name}}-{{.UID}}-rt.id
}