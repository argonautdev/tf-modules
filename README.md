## terragrunt templates

### Requirements

- Keep all modules in a git repo `the git repo has structure modules/aws/module/*.tf`
- Populate template file and keep the structure `account/env/region/infra/*.hcl`

### Running

- Go to main.go and edit the `conf` struct with the values you want to populate. **Make sure to edit the BackendConf which is used to make the connection string for postgres tf**
- Run `go run main.go`
- This will create everything inside `parsed` folder.
- For an environment level job, go into an account level folder and do `terragrunt plan-all` to see the plan. Note plan may shows some errors if
  the dependecy hasn't been applied yet, which in this case is the vpc.
