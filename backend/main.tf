
locals {
  lambda_runtime       = "provided.al2023"
  lambda_architectures = ["arm64"]
}

variable "lambda_function_name" {
  default   = "hello"
  type      = string
  nullable  = false
  sensitive = false
}

provider "aws" {
  default_tags {
    tags = {
      app = "til-chatgpt"
    }
  }
}

module "lambda_function" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = var.lambda_function_name

  handler       = "bootstrap"
  runtime       = local.lambda_runtime
  architectures = local.lambda_architectures

  source_path = [
    {
      path = "${path.module}/cmd/hello",
      commands = [
        "GOOS=linux GOARCH=arm64 CGO_ENABLED=0 go build -o bootstrap main.go",
        ":zip"
      ],
      patterns = [
        "!.*",
        "bootstrap"
      ]
    }
  ]
}


module "eventbridge" {
  source = "terraform-aws-modules/eventbridge/aws"

  attach_lambda_policy = true

  create_bus = false

  lambda_target_arns = [module.lambda_function.lambda_function_arn]

  schedule_groups = {
    dev = {
      name_prefix = "tmp-dev-"
    }
  }

  schedules = {
    lambda-cron = {
      group_name          = "dev"
      schedule_expression = "cron(* * * * ? *)"
      arn                 = module.lambda_function.lambda_function_arn
    }
  }
}

