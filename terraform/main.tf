provider "aws" {
  region = "us-east-1" 
}

#### iam 
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

#### lambda 
data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.module}/../lambda/lambda_handler.py"
  output_path = "${path.module}/lambda_function_lambda.zip"
}

resource "aws_lambda_function" "lambda" {
  function_name    = "python_terraform_lambda"
  role             = aws_iam_role.iam_for_lambda.arn
  filename         = "${path.module}/lambda_function_lambda.zip"
  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "python3.10"
  handler = "lambda_handler.lambda_handler"
        environment {
            variables = {
                DYNAMO_TABLE = "PassengerProb"
            }
        }
}

#### dynamodb 
resource "aws_iam_role_policy_attachment" "dynamo_access" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

resource "aws_dynamodb_table" "passenger_prob" {
  name         = "PassengerProb"
  billing_mode = "PAY_PER_REQUEST"

  hash_key     = "PassengerId"

  attribute {
    name = "PassengerId"
    type = "S"
  }
}

## api gateway
resource "aws_api_gateway_rest_api" "api" {
  name        = "titanic_api"
  description = "API Titanic Case"
  body       = file("${path.module}/../openapi/api.yaml")
}

resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.api.id

  depends_on = [
    aws_api_gateway_rest_api.api
  ]
}

resource "aws_lambda_permission" "allow_apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

resource "aws_api_gateway_stage" "prod" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = "prod"
  deployment_id = aws_api_gateway_deployment.deployment.id
}

output "api_url" {
  value = aws_api_gateway_stage.prod.invoke_url
}