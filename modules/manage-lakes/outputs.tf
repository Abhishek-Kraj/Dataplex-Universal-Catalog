output "lakes" {
  description = "Map of lake IDs to their details"
  value       = try(module.manage[0].lakes, {})
}

output "zones" {
  description = "Map of zone IDs to their details"
  value       = try(module.manage[0].zones, {})
}

output "assets" {
  description = "Map of asset IDs to their details"
  value       = try(module.manage[0].assets, {})
}

output "iam_bindings" {
  description = "IAM binding details"
  value       = try(module.secure[0].iam_bindings, {})
}

output "spark_jobs" {
  description = "Map of Spark job IDs to their details"
  value       = try(module.process[0].spark_jobs, {})
}

output "task_ids" {
  description = "Map of task IDs"
  value       = try(module.process[0].task_ids, {})
}
