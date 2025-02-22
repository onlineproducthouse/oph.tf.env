locals {
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid : "ReadOnlyAccessToQueryDetails",
        Effect : "Allow",
        Action : [
          "ec2:Describe*"
        ],
        Resource : "*"
      },
      {
        Sid : "CreateNewInstances",
        Effect : "Allow",
        Action : "ec2:RunInstances",
        Resource : [
          "arn:aws:ec2:*:*:subnet/*",
          "arn:aws:ec2:*:*:instance/*",
          "arn:aws:ec2:*:*:volume/*",
          "arn:aws:ec2:*:*:network-interface/*",
          "arn:aws:ec2:*:*:key-pair/*",
          "arn:aws:ec2:*:*:security-group/*",
          "arn:aws:ec2:*:*:image/*"
        ]
      },
      {
        Sid : "AbilityToAutoTagNewInstancesAndVolumesCreatedByScaleGrid",
        Effect : "Allow",
        Action : [
          "ec2:CreateTags"
        ],
        Resource : "arn:aws:ec2:*:*:*/*",
        Condition : {
          "ForAnyValue:StringEquals" : {
            "ec2:CreateAction" : [
              "CreateVolume",
              "RunInstances"
            ]
          },
          "ForAnyValue:StringLike" : {
            "aws:TagKeys" : [
              "DBProvider",
              "Name",
              "MongoProvider"
            ]
          }
        }
      },
      {
        Sid : "FullAccessOnResourcesTaggedAsCreatedByScaleGrid",
        Effect : "Allow",
        Action : [
          "ec2:*"
        ],
        Resource : "arn:aws:ec2:*:*:*/*",
        Condition : {
          StringLike : {
            "ec2:ResourceTag/DBProvider" : "ScaleGrid"
          }
        }
      },
      {
        Sid : "ModifyInstanceAttributeDoesNotSupportResource",
        Effect : "Allow",
        Action : [
          "ec2:ModifyInstanceAttribute"
        ],
        Resource : "*"
      },
      {
        Sid : "CreateNewVolumesAndSnapshotAndSecurityGroup",
        Effect : "Allow",
        Action : [
          "ec2:CreateVolume",
          "ec2:ModifyVolume",
          "ec2:CreateSecurityGroup",
          "ec2:CreateSnapshot",
          "ec2:CopySnapshot",
          "ec2:DeleteSnapshot"
        ],
        Resource : "*"
      },
      {
        Sid : "CreateTagsOnGroupsAndSnapshotSinceTheyCannotBeAutoTaggedOnCreation",
        Effect : "Allow",
        Action : [
          "ec2:CreateTags"
        ],
        Resource : [
          "arn:aws:ec2:*:*:snapshot/*",
          "arn:aws:ec2:*:*:security-group/*"
        ]
      },
      {
        Sid : "KeyPairActionsWithDeleteOptional",
        Effect : "Allow",
        Action : [
          "ec2:DescribeKeyPairs",
          "ec2:CreateKeyPair",
          "ec2:DeleteKeyPair"
        ],
        Resource : "*"
      },
      {
        Action : "s3:*",
        Effect : "Allow",
        Resource : "*"
      }
    ]
  })
}
