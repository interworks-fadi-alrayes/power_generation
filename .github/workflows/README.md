# GitHub Actions Workflows

## Schema Cleanup on PR Merge

The `cleanup-schemas-on-pr-merge.yml` workflow automatically deletes development schemas after a PR is merged to main.

### How it works

1. When a PR is merged to `main`, the workflow triggers
2. Extracts the source branch name (e.g., `feature/new-model`)
3. Runs the `delete_dev_schemas_by_branch` dbt macro
4. Finds all schemas in `power_generation_dev` database with the branch name suffix
5. Drops all matching schemas (e.g., `O2_CLEAN_feature_new_model`)

### Required GitHub Secrets

Add these secrets to your repository settings (Settings → Secrets and variables → Actions):

| Secret Name | Description | Example |
|------------|-------------|---------|
| `SNOWFLAKE_ACCOUNT` | Snowflake account identifier | `abc12345.us-east-1` |
| `SNOWFLAKE_USER` | Snowflake username | `dbt_service_user` |
| `SNOWFLAKE_PASSWORD` | Snowflake password | `********` |
| `SNOWFLAKE_ROLE` | Snowflake role with DROP SCHEMA permissions | `DBT_DEV_ROLE` |
| `SNOWFLAKE_WAREHOUSE` | Snowflake warehouse | `DBT_WH` |

### Permissions Required

The Snowflake role must have:
- `USAGE` on database `power_generation_dev`
- `DROP` permission on schemas in `power_generation_dev`
- `USAGE` on the specified warehouse

### Testing the Macro Locally

You can test the cleanup macro locally:

```bash
dbt run-operation delete_dev_schemas_by_branch --args '{branch_name: my-feature-branch}'
```

This will delete all schemas ending with `_my_feature_branch` in the `power_generation_dev` database.
