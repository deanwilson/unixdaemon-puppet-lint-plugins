#!/bin/bash

repos=$(cat<<all_repos
  puppet-lint-absolute_template_path-check
  puppet-lint-concatenated_template_files-check
  puppet-lint_duplicate_class_parameters-check
  puppet-lint-explicit_hiera_class_param_lookup-check
  puppet-lint-no_cron_resources-check
  puppet-lint-no_erb_template-check
  puppet-lint-no_file_path_attribute-check
  puppet-lint-no_symbolic_file_modes-check
  puppet-lint-template_file_extension-check
  puppet-lint-world_writable_files-check
  puppet-lint-yumrepo_gpgcheck_enabled-check
all_repos
)


for repo in $repos; do
  repo_url="git@github.com:deanwilson/${repo}.git"

  git clone $repo_url
done
