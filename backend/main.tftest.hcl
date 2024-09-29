
run "example_test" {
    command = plan

    variables {
        lambda_function_name = "foobar"
    }

    assert {
        condition = module.lambda_function.lambda_function_name == var.lambda_function_name
        error_message = "wrong lambda function name!"
    }
}
