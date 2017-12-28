# githooks

A [githook][] wrapper and a set of hooks which enforce good practices.

## Setup

1. Run the initalization script. This will symlink a bunch of stuff in
   `.git/hooks/` to the wrapper script.

    ```
    bin/git/init-hooks
    ```

1. Profit!  The checks are ran when you run `git commit ...`.  You will be
   alerted to any bad practices and the commit will be aborted.

## Attributes

[sjungwirth/githooks](https://github.com/sjungwirth/githooks)

[githook]: https://git-scm.com/docs/githooks
