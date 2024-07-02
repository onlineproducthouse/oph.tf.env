#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################

variable "notifications" {
  type = object({
    name                = string
    pipeline_arn        = string
    alert_email_address = string
  })
}

#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

locals {
  pipeline_notification_rules = [
    { name = "pipeline-failed", event_type_id = "codepipeline-pipeline-pipeline-execution-failed" },
    { name = "pipeline-canceled", event_type_id = "codepipeline-pipeline-pipeline-execution-canceled" },
    { name = "pipeline-started", event_type_id = "codepipeline-pipeline-pipeline-execution-started" },
    { name = "pipeline-succeeded", event_type_id = "codepipeline-pipeline-pipeline-execution-succeeded" },
    { name = "pipeline-superseded", event_type_id = "codepipeline-pipeline-pipeline-execution-superseded" },
    { name = "pipeline-approval-failed", event_type_id = "codepipeline-pipeline-manual-approval-failed" },
    { name = "pipeline-approval-needed", event_type_id = "codepipeline-pipeline-manual-approval-needed" },
    { name = "pipeline-approval-succeeded", event_type_id = "codepipeline-pipeline-manual-approval-succeeded" },
  ]
}

resource "aws_sns_topic" "pipeline" {
  name = "${var.notifications.name}-pipeline-alert"
}

data "aws_iam_policy_document" "pipeline" {
  statement {
    actions = ["sns:Publish"]

    principals {
      type        = "Service"
      identifiers = ["codestar-notifications.amazonaws.com"]
    }

    resources = [aws_sns_topic.pipeline.arn]
  }
}

resource "aws_sns_topic_policy" "pipeline" {
  arn    = aws_sns_topic.pipeline.arn
  policy = data.aws_iam_policy_document.pipeline.json
}

resource "aws_codestarnotifications_notification_rule" "pipeline" {
  for_each = {
    for rule in local.pipeline_notification_rules : rule.name => rule
  }

  name           = "${var.notifications.name}-${each.value.name}"
  detail_type    = "BASIC"
  event_type_ids = [each.value.event_type_id]
  resource       = var.notifications.pipeline_arn

  target {
    address = aws_sns_topic.pipeline.arn
    type    = "SNS"
  }
}

resource "aws_sns_topic_subscription" "pipeline" {
  protocol  = "email"
  endpoint  = var.notifications.alert_email_address
  topic_arn = aws_sns_topic.pipeline.arn
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################
