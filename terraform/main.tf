provider "aws" {
  region = var.aws_region
}

# Criando o papel de execução (IAM Role) para a Lambda
resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# Adicionando uma política para permitir que a Lambda escreva logs no CloudWatch
resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Criando a função Lambda
resource "aws_lambda_function" "tf_lambda" {
  filename         = "${path.module}/../.bin/lambda_compact.zip"
  function_name    = "my-lambda-function"
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "lambda_binary"
  source_code_hash = filebase64sha256("${path.module}/../.bin/lambda_compact.zip")
  runtime          = "provided.al2023"  # Updated runtime to provided.al2
}

# Criando o API Gateway REST API
resource "aws_api_gateway_rest_api" "my_api" {
  name = "MyAPIGateway"
}

# Criando o recurso de caminho para a API 
resource "aws_api_gateway_resource" "my_resource" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  parent_id   = aws_api_gateway_rest_api.my_api.root_resource_id
  path_part   = "lambda"
}

# Criando o método GET para o recurso
resource "aws_api_gateway_method" "get_method" {
  rest_api_id   = aws_api_gateway_rest_api.my_api.id
  resource_id   = aws_api_gateway_resource.my_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

# Integrando o método GET com a função Lambda
resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.my_api.id
  resource_id             = aws_api_gateway_resource.my_resource.id
  http_method             = aws_api_gateway_method.get_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.tf_lambda.invoke_arn # Change here
}

# Configurando a autorização de invocação da API Gateway para Lambda
resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.tf_lambda.function_name # Change here
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.my_api.execution_arn}/*/*"
}

# Configurando o deployment da API
resource "aws_api_gateway_deployment" "api_deployment" {
  depends_on = [
    aws_api_gateway_integration.lambda_integration
  ]
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  stage_name  = "prod"
}

output "api_url" {
  value = "${aws_api_gateway_deployment.api_deployment.invoke_url}/lambda"
}
