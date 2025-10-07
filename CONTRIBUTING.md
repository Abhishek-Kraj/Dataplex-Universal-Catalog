# Contributing

This document provides guidelines for contributing to the terraform-google-dataplex module.

## Code of Conduct

This project follows the organization's code of conduct. Please be respectful and professional in all interactions.

## How to Contribute

### Reporting Issues

- Check if the issue already exists before creating a new one
- Provide clear description of the problem
- Include Terraform version, provider version, and relevant configuration
- Add steps to reproduce the issue
- Include error messages and logs

### Submitting Changes

1. **Fork the repository** and create a feature branch
   ```bash
   git checkout -b feature/my-new-feature
   ```

2. **Make your changes** following the coding standards below

3. **Test your changes** thoroughly
   - Validate Terraform syntax: `terraform validate`
   - Format code: `terraform fmt -recursive`
   - Test with examples in `examples/` directory

4. **Commit your changes** with clear commit messages
   ```bash
   git commit -m "Add feature: description of changes"
   ```

5. **Push to your fork** and submit a pull request
   ```bash
   git push origin feature/my-new-feature
   ```

## Coding Standards

### Terraform Style Guide

- Use **2 spaces** for indentation (not tabs)
- Keep line length under **120 characters** where possible
- Use **snake_case** for resource names, variables, and outputs
- Add **descriptions** to all variables and outputs
- Use **type constraints** for all variables
- Include **default values** where appropriate

### File Organization

```
module/
├── main.tf          # Primary resource definitions
├── variables.tf     # Input variables
├── outputs.tf       # Output values
├── versions.tf      # Terraform and provider version constraints
└── README.md        # Module documentation
```

### Resource Naming

- Resource names should be descriptive and follow Google Cloud naming conventions
- Use singular names for single resources: `google_dataplex_lake.lake`
- Use plural names for multiple resources: `google_dataplex_zone.zones`
- Prefix internal resources with `_` if needed

### Variables

- Group related variables together
- Required variables should not have defaults
- Optional variables should have sensible defaults
- Use `optional()` for nested optional attributes
- Add validation rules where appropriate

Example:
```hcl
variable "project_id" {
  description = "The GCP project ID"
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_id))
    error_message = "Project ID must be 6-30 characters, lowercase letters, digits, or hyphens."
  }
}
```

### Outputs

- Output values should be meaningful and reusable
- Add descriptions explaining what each output contains
- Use `sensitive = true` for sensitive values

### Comments

- Add comments for complex logic
- Use `#` for single-line comments
- Use header blocks to organize sections:

```hcl
# ==============================================================================
# SECTION NAME
# ==============================================================================
```

## Documentation

### Module README

Each module should have a comprehensive README including:
- Description of what the module does
- Features list
- Usage examples
- Variable documentation (auto-generated with terraform-docs)
- Output documentation (auto-generated with terraform-docs)
- Requirements (Terraform version, provider versions, APIs)

### Inline Documentation

- Add resource descriptions explaining purpose
- Document non-obvious configuration choices
- Include links to official Google Cloud documentation

## Testing

### Manual Testing

1. Navigate to an example directory:
   ```bash
   cd examples/basic
   ```

2. Initialize Terraform:
   ```bash
   terraform init
   ```

3. Plan the changes:
   ```bash
   terraform plan
   ```

4. Apply if plan looks correct:
   ```bash
   terraform apply
   ```

5. Verify resources in GCP Console

6. Clean up:
   ```bash
   terraform destroy
   ```

### Validation Checks

Before submitting a PR, run:

```bash
# Format all Terraform files
terraform fmt -recursive

# Validate configuration
cd examples/basic
terraform init
terraform validate
```

## Review Process

1. Pull requests require review from module maintainers
2. All CI checks must pass
3. Code must follow style guidelines
4. Documentation must be updated
5. Examples should demonstrate new features

## Module Structure Guidelines

### Submodules

- Keep submodules focused on specific functionality
- Submodules should be independently usable
- Minimize dependencies between submodules
- Document submodule usage separately

### Enable Flags

- Use `enable_*` variables to toggle features
- Set sensible defaults (typically `true`)
- Document what enabling each feature does

### Resource Creation

- Use `count` or `for_each` for conditional resources
- Avoid `count` based on list length (use `for_each` instead)
- Use locals for complex transformations

## Getting Help

- Check existing issues and documentation
- Ask questions in pull request comments
- Contact module maintainers for guidance

## License

By contributing, you agree that your contributions will be licensed under the Apache License 2.0.
