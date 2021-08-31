resource "aws_api_gateway_resource" "resource" {
  rest_api_id = var.api_id
  parent_id   = var.api_root_resource_id
  path_part   = var.path
}

resource "aws_api_gateway_method" "method" {
  rest_api_id          = var.api_id
  resource_id          = aws_api_gateway_resource.resource.id
  http_method          = var.method
  authorization        = "NONE"
  authorization_scopes = []
  request_parameters   = {}
  request_models       = {}

  depends_on = [
    aws_api_gateway_resource.resource
  ]
}

resource "aws_api_gateway_integration" "integration" {
  rest_api_id          = var.api_id
  resource_id          = aws_api_gateway_resource.resource.id
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

  depends_on = [
    aws_api_gateway_method.method
  ]
}

resource "aws_api_gateway_method_response" "response" {
  rest_api_id     = var.api_id
  resource_id     = aws_api_gateway_resource.resource.id
  http_method     = aws_api_gateway_method.method.http_method
  status_code     = 200
  response_models = {}

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }

  depends_on = [
    aws_api_gateway_integration.integration
  ]
}

resource "aws_api_gateway_integration_response" "response" {
  rest_api_id       = var.api_id
  resource_id       = aws_api_gateway_resource.resource.id
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

  depends_on = [
    aws_api_gateway_method_response.response
  ]
}
