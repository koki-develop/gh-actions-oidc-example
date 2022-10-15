data "http" "github_actions_openid_configuration" {
  url = "https://token.actions.githubusercontent.com/.well-known/openid-configuration"
}


data "tls_certificate" "github_actions" {
  url = jsondecode(data.http.github_actions_openid_configuration.response_body).jwks_uri
}


resource "aws_iam_openid_connect_provider" "github_actions" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = data.tls_certificate.github_actions.certificates[*].sha1_fingerprint
}

data "aws_iam_policy_document" "example_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github_actions.arn]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:koki-develop/gh-actions-oidc-example:*"]
    }
  }
}

resource "aws_iam_role" "example" {
  name               = "oidc-example-role"
  assume_role_policy = data.aws_iam_policy_document.example_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "example_s3_readonly" {
  role       = aws_iam_role.example.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}
