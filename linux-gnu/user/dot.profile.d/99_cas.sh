# Only execute if at CAS.
[ -e ~/.cas ] || return

which git-ls-projects >/dev/null 2>/dev/null || export PATH=$PATH:/home/cac21/.cas-git-tools/bin

export http_proxy="http://cac21:junk@websensep-wcg.intra.cas.org:8080"
