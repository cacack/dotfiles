# REQUIREMENTS.md

This file provides requirements to Claude Code (claude.ai/code) when working with code in this repository.

## Important

- ALL instructions within this document MUST BE FOLLOWED, these are not optional unless explicitly stated.
- ASK FOR CLARIFICATION If you are uncertain of any of thing within the document.
- DO NOT edit more code than you have to.
- DO NOT WASTE TOKENS, be succinct and concise.

## Security Requirements

**NEVER** read, access, or analyze files containing sensitive information:

- `openrc` files (OpenStack credentials)
- `credentials` files
- `.env` files or environment configuration files
- Files with API keys, tokens, passwords, or secrets
- Any file that may contain authentication information

## Commit Standards

This repository follows [Conventional Commits](https://www.conventionalcommits.org/):

- **feat**: New functionality or changes to existing functionality
- **fix**: Bug fixes or security vulnerability fixes
- **refactor**: Code changes without altering functionality
- **docs**: Documentation changes
- **ci**: Pipeline, tests, or GitLab configuration changes

Use `!` at the end of type for breaking changes (e.g., `feat!:`).
