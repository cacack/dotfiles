task default: :all

task all: %i[
  init
  checks
  lint
  test
]

task init: %i[
  init_git_hooks
  install_ansible_roles
]

task checks: %i[
  check_nonascii_filenames
  check_whitespace_errors
]

task lint: %i[
  lint_markdown
  lint_yaml
]

task test: %i[
  lint_ansible
  run_rubocop
  run_shellcheck
]

################################################################################
# Init
task :init_git_hooks do
  puts 'Setting up githooks..'
  sh 'bin/git/init-hooks.sh'
end

task :install_ansible_roles do
  Dir.glob('requirements.y*ml').each do |file|
    if File.readable?(file)
      puts 'Installing Ansible roles..'
      sh "ansible-galaxy install -r #{file}"
    end
  end
end

################################################################################
# Checks
task :check_nonascii_filenames do
  puts 'Checking for non-ASCII filenames..'
  sh 'bin/check_for_nonascii_filenames.sh'
end

task :check_whitespace_errors do
  puts 'Checking for whitespace errors..'
  sh 'bin/check_for_whitespace_errors.sh'
end

################################################################################
# Lint
task :lint_markdown do
  puts 'Linting markdown files..'
  sh 'bin/lint_markdown.sh'
end

task :lint_yaml do
  puts 'Linting yaml files..'
  sh 'bin/lint_yaml.sh'
end

################################################################################
# Tests
task :lint_ansible do
  puts 'Linting ansible code..'
  sh 'bin/lint_ansible.sh'
end

task :run_rubocop do
  puts 'Running rubocop..'
  sh 'bin/run_rubocop.sh'
end

task :run_shellcheck do
  puts 'Running shellcheck..'
  sh 'bin/run_shellcheck.sh'
end
