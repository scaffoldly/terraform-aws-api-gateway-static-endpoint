locals {
  path_parts = split("/", var.path)
}

module "resources" {
  source = "./api_gateway_resources"
  count  = length(local.path_parts)

  api_id          = var.api_id
  parent_path     = "/"
  path_parts      = local.path_parts
  path_part_index = count.index
}

resource "aws_api_gateway_method" "method" {
  rest_api_id          = var.api_id
  resource_id          = module.resources[length(local.path_parts) - 1].resource_id
  http_method          = var.method
  authorization        = "NONE"
  authorization_scopes = []
  request_parameters   = {}
  request_models       = {}
}

resource "aws_api_gateway_integration" "integration" {
  rest_api_id          = var.api_id
  resource_id          = module.resources[length(local.path_parts) - 1].resource_id
  http_method          = aws_api_gateway_method.method.http_method
  type                 = "MOCK"
  passthrough_behavior = "WHEN_NO_MATCH"
  cache_key_parameters = []
  request_parameters   = {}

  request_templates = {
    "application/json" = <<EOF
{"statusCode": 200}
EOF
  }
}

resource "aws_api_gateway_method_response" "response" {
  rest_api_id     = var.api_id
  resource_id     = module.resources[length(local.path_parts) - 1].resource_id
  http_method     = aws_api_gateway_method.method.http_method
  status_code     = 200
  response_models = {}

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "response" {
  rest_api_id       = var.api_id
  resource_id       = module.resources[length(local.path_parts) - 1].resource_id
  http_method       = aws_api_gateway_method.method.http_method
  status_code       = aws_api_gateway_method_response.response.status_code
  selection_pattern = 200

  response_templates = {
    "application/json" = jsonencode(var.response)
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'*'"
    "method.response.header.Access-Control-Allow-Methods" = "'*'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}
