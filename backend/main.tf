provider "aws" {
    region = "us-east-1"

    default_tags {
      tags = {
        app = "til-chatgpt"
      }
    }
}

module "lambda_function" {
    source = "terraform-aws-modules/lambda/aws"
    function_name = "something"
    handler = "bootstrap"
    runtime = "provided.al2023"
    architectures = ["arm64"]

    source_path = [
        {

        }
    ]
    # function_name = "${random}"
}
