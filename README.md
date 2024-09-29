# TIL ChatGPT

## Learnings

- Creating AWS Lambdas with Terraform is much more involved than using Serverless Framework, SAM or CDK. The fact that I'm not familiar with Terraform also plays a role here.

  - Luckily, there is a [AWS Lambda tf module](https://github.com/terraform-aws-modules/terraform-aws-lambda) we could use.

- I might be missing a plugin, but after searching for the solution, I'm still lacking autocomplete for parameters in `.tf` files.

- I though that the `module "SOME_NAME"` is like declaring a reference to a module which I then specify via the `source` URL. When changing the `"SOME_NAME"` I had to re-run `terraform init` command.

  - [According to the documentation](https://developer.hashicorp.com/terraform/language/modules/syntax) this seem to be the case.

  - After re-running the `terraform init` command, I see that **Terraform downloaded the whole module source**. Interestingly, **Terraform does not seem to be de-duplicating modules**.

    - For example, if I have two modules using the `terraform-aws-modules/lambda/aws` source, each of the module will download the `terraform-aws-modules/lambda/aws` locally.

- **Terraform makes API calls to AWS to create all the infrastructure**.

  - This means that doing rollbacks is problematic.

    - Instead of doing rollbacks, **consider _rolling forward_ and correcting any mistake that caused the issue in the first place**.

      - This workflow is a bit different than the one using CloudFormation. CFN will attempt to rollback the change if the change fails _unless_ you tell it not to.

        - With Terraform, that is not the case.

- **You can even write tests in Terraform**. Quite amazing!
