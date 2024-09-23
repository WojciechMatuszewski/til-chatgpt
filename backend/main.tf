provider "aws" {
    default_tags {
      tags = {
        app = "til-chatgpt"
      }
    }
}

module "lambda_function" {
    source = "terraform-aws-modules/lambda/aws"

    function_name = "hello"

    handler = "bootstrap"
    runtime = "provided.al2023"
    architectures = ["arm64"]

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
