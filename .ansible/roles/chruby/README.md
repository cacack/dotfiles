# Ansible chruby

## Available configuration variables

**For chruby itfelf**
```
chruby_chruby_version: 0.3.9
chruby_chruby_checksum: 7220a96e355b8a613929881c091ca85ec809153988d7d691299e0a16806b42fd
chruby_chruby_exec_command: /usr/local/bin/chruby-exec
```

**For ruby-install**
```
chruby_ruby_install_version: 0.5.0
chruby_ruby_install_checksum: aa4448c2c356510cc7c2505961961a17bd3f3435842831e04c8516eb703afd19.
chruby_ruby_install_command: /usr/local/bin/ruby-install
```

**The ruby version to be installed and used**
```
chruby_ruby_version: ruby-2.1.5
```

**These ruby versions will be removed if they are found**
```
outdated_ruby_versions:
  - ruby-2.1.5
```
