# Private Route Table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-private-rt"
  })
}

# Associate route table with subnets
resource "aws_route_table_association" "private" {
  count          = var.availability_zones_count
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

# Add route table for public subnets
resource "aws_route_table" "public" {
  vpc_id = aws_ssm_parameter.vpc_id.value

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_ssm_parameter.igw_id.value
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-public-rt"
  })
}
# Associate route table with public subnets
resource "aws_route_table_association" "public" {
  count          = var.availability_zones_count
  subnet_id      = split(",", data.aws_ssm_parameter.public_subnet_ids.value)[count.index]
  route_table_id = aws_ssm_parameter.public_rt_id.value
}