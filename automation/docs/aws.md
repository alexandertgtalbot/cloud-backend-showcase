# Overview

# Bootstrap Management (root) Account:

1. (Optional) Log in to your root account using the root user and create an IAM user to be used for managing AWS Organization entities, e.g. Organisational Units (OUs) and Accounts.
    - Head to the IAM section e.g. https://us-east-1.console.aws.amazon.com/iamv2/home
    - Click on Users (left menu).
    - Click add users (top right).
    - Provide a username, e.g. Montgomery.Burns
    - Click Next.
    - Select "Attach policies directly".
    - Click "Create policy" (this will open a new tab).
    - Select JSON.
    - Apply the following policy:
      ```
        {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Sid": "AllowManageDynamoDB",
                    "Effect": "Allow",
                    "Action": [
                        "dynamodb:BatchGetItem",
                        "dynamodb:BatchWriteItem",
                        "dynamodb:CreateTable",
                        "dynamodb:DeleteItem",
                        "dynamodb:DeleteTable",
                        "dynamodb:Describe*",
                        "dynamodb:Get*",
                        "dynamodb:List*",
                        "dynamodb:PutItem",
                        "dynamodb:Query",
                        "dynamodb:Scan",
                        "dynamodb:UpdateItem",
                        "dynamodb:UpdateTable"
                    ],
                    "Resource": "*"
                },
                {
                    "Sid": "OrganizationAdmin",
                    "Effect": "Allow",
                    "Action": [
                        "organizations:AttachPolicy",
                        "organizations:CreateAccount",
                        "organizations:CreateOrganizationalUnit",
                        "organizations:CreatePolicy",
                        "organizations:DeleteOrganizationalUnit",
                        "organizations:DeletePolicy",
                        "organizations:DeregisterDelegatedAdministrator",
                        "organizations:DescribeAccount",
                        "organizations:DescribeCreateAccountStatus",
                        "organizations:DescribeEffectivePolicy",
                        "organizations:DescribeOrganization",
                        "organizations:DescribeOrganizationalUnit",
                        "organizations:DescribePolicy",
                        "organizations:DetachPolicy",
                        "organizations:DisableAWSServiceAccess",
                        "organizations:DisablePolicyType",
                        "organizations:EnableAWSServiceAccess",
                        "organizations:EnableAllFeatures",
                        "organizations:EnablePolicyType",
                        "organizations:ListAWSServiceAccessForOrganization",
                        "organizations:ListAccounts",
                        "organizations:ListAccountsForParent",
                        "organizations:ListChildren",
                        "organizations:ListCreateAccountStatus",
                        "organizations:ListDelegatedAdministrators",
                        "organizations:ListDelegatedServicesForAccount",
                        "organizations:ListOrganizationalUnitsForParent",
                        "organizations:ListParents",
                        "organizations:ListPolicies",
                        "organizations:ListPoliciesForTarget",
                        "organizations:ListRoots",
                        "organizations:ListTagsForResource",
                        "organizations:ListTargetsForPolicy",
                        "organizations:MoveAccount",
                        "organizations:RegisterDelegatedAdministrator",
                        "organizations:TagResource",
                        "organizations:UntagResource",
                        "organizations:UpdateOrganizationalUnit",
                        "organizations:UpdatePolicy"
                    ],
                    "Resource": "*"
                },
                {
                    "Sid": "KMSAdmin",
                    "Effect": "Allow",
                    "Action": [
                        "kms:Create*",
                        "kms:Describe*",
                        "kms:Enable*",
                        "kms:List*",
                        "kms:Put*",
                        "kms:Update*",
                        "kms:Revoke*",
                        "kms:Disable*",
                        "kms:Get*",
                        "kms:Delete*",
                        "kms:TagResource",
                        "kms:UntagResource",
                        "kms:ScheduleKeyDeletion",
                        "kms:CancelKeyDeletion"
                    ],
                    "Resource": "*"
                },
                {
                    "Sid": "S3Admin",
                    "Effect": "Allow",
                    "Action": [
                        "s3:*"
                    ],
                    "Resource": "*"
                },
                {
                    "Sid": "AllowAssumeRole",
                    "Effect": "Allow",
                    "Action": "sts:AssumeRole",
                    "Resource": "*"
                }
            ]
        }
      ```

      - Set "Policy name" to "OrganizationAdmin".
      - Click "Create policy".
      - Go back to the previous tab (IAM Users).
      - Click refresh to the left of "Create policy" (top right).
      - In search paste "OrganizationAdmin".
      - Tick the checkbox next to "OrganizationAdmin".
      - Click "Next".
      - Click "Create user".
      - Click on the IAM User, e.g. Montgomery.Burns.
      - Click on the "Security credentials" tab.
      - Scroll down to "Access keys" and click "Create access key".
      - Select "Command Line Interface (CLI)".
      - Click the checkbox at the bottom of the page to confirm understanding.
      - Click "Next".
      - Click "Create access key".
      - Take a copy of the access key ID and secret access key.
      - Click "Done"
      - At this point take note of the Root Account ID (click the dropdown top right), e.g. 123456789012, as this will be used to configure the Terragrunt `root.hcl` config file.

  **Note:** These steps serve as a quickstart to deployment and should be replaced with a more secure approach in the future, e.g. using AWS SSO.

2. Create an AWS Organization:
    - Go to the Organizations section e.g. https://us-east-1.console.aws.amazon.com/organizations/v2/home?region=us-east-1#.
    - Click "Create an organization".
    - Under "Organizational structure" and the under "Root" take note of the six character Root ID, e.g. o-XXXX.
      This too will be used to update the root configuration.
    - Go to [Organization Policies](https://us-east-1.console.aws.amazon.com/organizations/v2/home/policies).
    - Go to "Service control policies" end click "Enable service control policies".
    - Go to [Organization Policies](https://us-east-1.console.aws.amazon.com/organizations/v2/home/policies).
    - Go to "Tag policies" end click "Enable tag policies".

3. Apply AWS Organization resources:
    - `cd mev-boost-relay-deployment/terragrunt/aws/organization/acme-inc/`
    - `AWS_ACCESS_KEY_ID='XXXXXXX' AWS_SECRET_ACCESS_KEY='XXXXXXX' tg run-all apply`

      **Note:** The AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY are the ones created in step 1 above OR alternatively provided to you by your AWS administrator.

4. Configure AWS CLI to use the Organization Admin IAM User:
    - Edit `~/.aws/credentials` so as to match the following:
        ```
        [default]
        aws_access_key_id = XXXXXXX
        aws_secret_access_key = XXXXXXX
        ```

    - Edit `~/.aws/config` so as to match the following:
        ```
        [default]
        region = us-east-2

        [profile acme-north-america-dev-mev-boost-relay-bootstrapper]
        role_arn = arn:aws:iam::XXXXXXXX:role/bootstrapper
        source_profile = default
        ```

        The Account ID (XXXXXXXX) for `role_arn` can be obtained by running the following:
        - `cd mev-boost-relay-deployment/terragrunt/aws/organization/acme-inc/north-america/mev-boost-relay/dev/account`
        - `AWS_ACCESS_KEY_ID='XXXXXXX' AWS_SECRET_ACCESS_KEY='XXXXXXX' tg run-all output`
        
            where `id` is the Account ID.

5. Apply AWS Organization resources:
    - `cd mev-boost-relay-deployment/terragrunt/aws/services`
    - `AWS_ACCESS_KEY_ID='XXXXXXX' AWS_SECRET_ACCESS_KEY='XXXXXXX' tg run-all apply`

      **Issues:**
        - `mev-boost-relay-deployment/terraform/acme-inc/eks_bootstrap/main.tf` needs more work to achieve full automation. Currently `extraObjects` for the FluxCD Helm release need to be commented out so the the CRDs are created before these objects are created.
           Kubernetes manifests for the `extraObjects` should be added and dependencies defined on the helm_release resource.
        - Currently the helm provider relies on token generation when connecting to control plan, this in turn forces a dependency on the required profile being configured, see point 4 above, this is less than ideal from a GitHub Actions point of view.

6. At this point FluxCD is install on the cluster and will begin deploying all K8s resources for it's configured environment, e.g. `mev-boost-relay-deployment/kubernetes/dev`.
   This should result in the MEV Boost Relay stack, and dependencies, being deployed.
   The deployments have minimum configurations derived from public documentation and currently do not run as expected.
   Improvements to configurations should be made.