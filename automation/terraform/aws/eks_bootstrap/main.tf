/*
* # A Proof of Concept AWS EKS Bootstrap Module
*/

data "aws_caller_identity" "current" {}

resource "aws_kms_key" "this" {
  policy = <<EOF
  {
      "Version": "2012-10-17",
      "Statement": [
          {
              "Sid": "Enable IAM User Permissions",
              "Effect": "Allow",
              "Principal": {
                  "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
              },
              "Action": "kms:*",
              "Resource": "*"
          },
          {
              "Sid": "Allow access for Key Administrators",
              "Effect": "Allow",
              "Principal": {
                  "AWS": [
                    "${data.aws_caller_identity.current.arn}"
                  ]
              },
              "Action": [
                  "kms:CancelKeyDeletion",
                  "kms:Create*",
                  "kms:Decrypt",
                  "kms:Delete*",
                  "kms:Describe*",
                  "kms:DescribeKey",
                  "kms:Disable*",
                  "kms:Enable*",
                  "kms:Encrypt",
                  "kms:GenerateDataKey*",
                  "kms:Get*",
                  "kms:List*",
                  "kms:Put*",
                  "kms:ReEncrypt*",
                  "kms:Revoke*",
                  "kms:ScheduleKeyDeletion",
                  "kms:TagResource",
                  "kms:UntagResource",
                  "kms:Update*"
              ],
              "Resource": "*"
          },
          {
              "Sid": "Allow use of the key",
              "Effect": "Allow",
              "Principal": {
                  "AWS": "${module.iam_assumable_role_eks_fluxcd_kustomize_controller.iam_role_arn}"
              },
              "Action": [
                  "kms:Encrypt",
                  "kms:Decrypt",
                  "kms:ReEncrypt*",
                  "kms:GenerateDataKey*",
                  "kms:DescribeKey"
              ],
              "Resource": "*"
          }
      ]
  }
  EOF
}

resource "aws_kms_alias" "this" {
  name          = "alias/eks/fluxcd"
  target_key_id = aws_kms_key.this.key_id
}

resource "aws_iam_policy" "eks_fluxcd_kustomize_controller" {
  name = "eks-fluxcd-kustomize-controller"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "kms:Decrypt",
                "kms:DescribeKey"
            ],
            "Effect": "Allow",
            "Resource": "*"
        }
    ]
}
EOF
}

module "iam_assumable_role_eks_fluxcd_kustomize_controller" {
  create_role  = true
  provider_url = replace(var.oidc_provider, "https://", "")
  role_name    = "eks-fluxcd-kustomize-controller"
  source       = "github.com/terraform-aws-modules/terraform-aws-iam.git?ref=v5.14.3//modules/iam-assumable-role-with-oidc"

  oidc_fully_qualified_subjects = [
    "system:serviceaccount:flux-system:kustomize-controller",
  ]

  role_policy_arns = [
    aws_iam_policy.eks_fluxcd_kustomize_controller.arn,
  ]
}

module "iam_assumable_role_eks_ebs_csi_driver" {
  create_role  = true
  provider_url = replace(var.oidc_provider, "https://", "")
  role_name    = "eks-ebs-csi-driver"
  source       = "github.com/terraform-aws-modules/terraform-aws-iam.git?ref=v5.14.3//modules/iam-assumable-role-with-oidc"

  oidc_fully_qualified_audiences = ["sts.amazonaws.com"]
  oidc_fully_qualified_subjects  = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]

  role_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  ]
}

resource "helm_release" "fluxcd" {
  create_namespace = true
  max_history      = 2
  name             = "fluxcd"
  namespace        = "flux-system"

  chart      = "flux2"
  repository = "https://fluxcd-community.github.io/helm-charts"
  version    = "2.6.0"

  values = [<<YAML
  extraObjects:
  - apiVersion: source.toolkit.fluxcd.io/v1beta1
    kind: GitRepository
    metadata:
      name: git-repository
      namespace: flux-system
    spec:
      ignore: |
        # exclude all
        /*
        # include deploy dir
        !/kubernetes
        !/charts
        # exclude file extensions from deploy dir
        /kubernetes/**/*.md
        /kubernetes/**/*.txt
      interval: 1m
      url: ${var.fluxcd_git_repository_url}
      ref:
        branch: ${var.fluxcd_git_repository_branch}

  - apiVersion: kustomize.toolkit.fluxcd.io/v1beta2
    kind: Kustomization
    metadata:
      name: git-repository
      namespace: flux-system
    spec:
      decryption:
        provider: sops
      interval: 1m
      path: ${var.fluxcd_git_repository_path}
      prune: true
      sourceRef:
        kind: GitRepository
        name: git-repository

  kustomizeController:
    serviceAccount:
      annotations:
        eks.amazonaws.com/role-arn: ${module.iam_assumable_role_eks_fluxcd_kustomize_controller.iam_role_arn}
    YAML
  ]
}
