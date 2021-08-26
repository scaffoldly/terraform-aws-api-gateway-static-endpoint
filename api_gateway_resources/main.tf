variable "api_id" {
  type = string
}

variable "parent_path" {
  type = string
}

variable "path_parts" {
  type = list(string)
}

variable "path_part_index" {
  type = number
}

data "aws_api_gateway_resource" "parent_resource" {
  rest_api_id = var.api_id
  path        = var.parent_path
}

resource "aws_api_gateway_resource" "resource" {
  rest_api_id = var.api_id
  parent_id   = data.aws_api_gateway_resource.parent_resource.id
  path_part   = var.path_parts[var.path_part_index]
}

output "resource_id" {
  value = aws_api_gateway_resource.resource.id
}

output "resource_path" {
  value = "${var.parent_path}/${var.path_parts[var.path_part_index]}/"
}
