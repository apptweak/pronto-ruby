Your all-in-one ruby Pronto runner.

This is a reduced-scope fork of (AdWerx/pronto-ruby)[https://github.com/AdWerx/pronto-ruby], it only focus on Ruby, removing all of npm-related lints.

This [GitHub Action](https://github.com/features/actions) runs [Pronto](https://github.com/prontolabs/pronto) [runners](https://github.com/prontolabs/pronto#runners) on your Ruby project diffs and reports back with a [GitHub Check Run](https://developer.github.com/apps/quickstart-guides/creating-ci-tests-with-the-checks-api/).

![check runs](static/checkrun.png)

![annotations](static/annotations.png)

# Runners

The docker image of this Action includes the following [Pronto Runners](https://github.com/prontolabs/pronto#runners):

- brakeman
- bundler_audit
- fasterer
- flay
- rails_best_practices
- rails_schema
- reek
- rubocop
- stylelint

# Inputs

| name      | description                                                                                          | default         |
| --------- | ---------------------------------------------------------------------------------------------------- | --------------- |
| `runners` | Space-separated list of pronto runners to run. Must be the preinstalled runners from the list above. | `rubocop`       |
| `target`  | The git target pronto will diff against (`-c`)                                                       | `origin/master` |

# Secrets

A GitHub token is available by default when using actions, but you must include it in the `env` map for this Action to use when creating a check run.

Be sure to include the ENV variable in your job step:

```yaml
  - uses: apptweak/pronto-ruby
    env:
      GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

That's it!

# Configuration

Pronto can be configured via the `.pronto.yml` configuration file in your repo.

# Example

With the defaults (only rubocop):

```yaml
name: Pronto

on:
  - push
  - pull_request

jobs:
  run:
    permissions:
      checks: write
      contents: read
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          ref: ${{ github.event.pull_request.head.sha }} # checkout HEAD commit instead of merge commit
          fetch-depth: 50 # If your repository has long-living PRs, this might need to be higher
      - run: git fetch origin main
      - uses: apptweak/pronto-ruby@use_head_commit
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          target: origin/main
```

With specific runners:

```yaml
name: Pronto
# ...
      with:
        runners: >-
          rubocop rails_schema yamllint
```

### Development / Contributions

See [CONTRIBUTING.md](./CONTRIBUTING.md)
