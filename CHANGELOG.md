# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-10-08

### Added

- Initial release of terraform-google-dataplex module
- **Manage Lakes Module**: Create and manage Dataplex lakes, zones, and assets
  - Support for RAW and CURATED zones
  - BigQuery and Cloud Storage asset management
  - IAM bindings for lake-level access control
  - Data processing with Spark jobs and tasks
  - KMS encryption support
  - Audit logging configuration
- **Metadata Management Module**: Catalog and glossary management
  - Entry groups for organizing catalog entries
  - Entry types (data assets, tables) with schema definitions
  - Aspect types (data quality, business metadata, lineage)
  - Business glossaries stored in BigQuery
  - Glossary terms with relationships and hierarchies
- **Governance Module**: Data quality and profiling
  - Data quality scans with 5 rule types (NON_NULL, UNIQUENESS, REGEX, RANGE, SET_MEMBERSHIP)
  - Data profiling scans for statistical analysis
  - BigQuery storage for scan results
  - Cloud Monitoring integration (dashboards, alerts, SLOs)
  - Log-based metrics for quality tracking
- Comprehensive examples (basic and complete)
- Module documentation with usage examples
- Enable/disable flags for granular control

### Features

- Variable-driven configuration for all resources
- Support for GCP project, region, and location configuration
- Flexible labeling for all resources
- Integration with BigQuery for data storage
- Integration with Cloud Monitoring for observability

### Requirements

- Terraform >= 1.3
- Google Provider >= 5.0, < 7.0
- Required APIs: dataplex.googleapis.com, bigquery.googleapis.com, monitoring.googleapis.com, logging.googleapis.com
