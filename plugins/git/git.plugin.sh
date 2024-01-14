#! bash oh-my-bash.module
#
# Functions
#

# The name of the current branch
# Back-compatibility wrapper for when this function was defined here in
# the plugin, before being pulled in to core lib/git.zsh as git_current_branch()
# to fix the core -> git plugin dependency.
function current_branch() {
  git_current_branch
}
# The list of remotes
function current_repository() {
  if ! $_omb_git_git_cmd rev-parse --is-inside-work-tree &> /dev/null; then
    return
  fi
  echo $($_omb_git_git_cmd remote -v | cut -d':' -f 2)
}
# Warn if the current branch is a WIP
function work_in_progress() {
  if $(git log -n 1 2>/dev/null | grep -q -c "\-\-wip\-\-"); then
    echo "WIP!!"
  fi
}

# Check for develop and similarly named branches
function git_develop_branch() {
  command git rev-parse --git-dir &>/dev/null || return
  local branch
  for branch in dev devel development; do
    if command git show-ref -q --verify refs/heads/"$branch"; then
      echo "$branch"
      return
    fi
  done
  echo develop
}

# Check if main exists and use instead of master
function git_main_branch() {
  command git rev-parse --git-dir &>/dev/null || return
  local ref
  for ref in refs/{heads,remotes/{origin,upstream}}/{main,trunk,mainline,default}; do
    if command git show-ref -q --verify "$ref"; then
      echo "${ref##*/}"
      return
    fi
  done
  echo master
}

#
# Aliases
#
# From Oh-My-Zsh:
# https://github.com/ohmyzsh/ohmyzsh/blob/f36c6db0eac17b022eee87411e6996a5f5fc8457/plugins/git/git.plugin.zsh
#

alias g='command git'

alias ga='command git add'
alias gaa='command git add --all'
alias gapa='command git add --patch'
alias gau='command git add --update'
alias gav='command git add --verbose'
alias gwip='command git add -A; command git rm $(git ls-files --deleted) 2> /dev/null; command git commit --no-verify --no-gpg-sign --message "--wip-- [skip ci]"'

alias gam='command git am'
alias gama='command git am --abort'
alias gamc='command git am --continue'
alias gamscp='command git am --show-current-patch'
alias gams='command git am --skip'

alias gap='command git apply'
alias gapt='command git apply --3way'

alias gbl='command git blame -b -w'

alias gb='command git branch'
alias gbD='command git branch --delete --force'
alias gba='command git branch -a'
alias gbd='command git branch -d'
alias gbda='command git branch --no-color --merged | command grep -vE "^([+*]|\s*($(git_main_branch)|$(git_develop_branch))\s*$)" | command xargs git branch --delete 2>/dev/null'
alias gbg='LANG=C command git branch -vv | grep ": gone\]"'
alias gbgD='LANG=C command git branch --no-color -vv | grep ": gone\]" | awk '"'"'{print $1}'"'"' | command xargs git branch -D'
alias gbgd='LANG=C command git branch --no-color -vv | grep ": gone\]" | awk '"'"'{print $1}'"'"' | command xargs git branch -d'
alias gbm='command git branch --move'
alias gbnm='command git branch --no-merged'
alias gbr='command git branch --remote'
alias gbsc='command git branch --show-current'
alias ggsup='command git branch --set-upstream-to="origin/$(git_current_branch)"'

alias gbs='command git bisect'
alias gbsb='command git bisect bad'
alias gbsg='command git bisect good'
alias gbsn='command git bisect new'
alias gbso='command git bisect old'
alias gbsr='command git bisect reset'
alias gbss='command git bisect start'

alias gcb='command git checkout -b'
alias gcd='command git checkout "$(git_develop_branch)"'
alias gcm='command git checkout "$(git_main_branch)"'
alias gco='command git checkout'
alias gcor='command git checkout --recurse-submodules'

alias gcp='command git cherry-pick'
alias gcpa='command git cherry-pick --abort'
alias gcpc='command git cherry-pick --continue'
alias gcps='command git cherry-pick -s'

alias gcl='command git clone --recursive'
function gccd() {
  command git clone --recurse-submodules "$@"
  local lastarg=$_
  [[ -d $lastarg ]] && cd "$lastarg" && return
  lastarg=${lastarg##*/}
  cd "${lastarg%.git}"
}
#compdef _git gccd=git-clone

alias gclean='command git clean -fd'

alias gc!='command git commit --verbose --amend'
alias gc='command git commit --verbose'
alias gca!='command git commit --verbose --all --amend'
alias gca='command git commit --verbose --all'
alias gcam='command git commit --all --message'
alias gcan!='command git commit --verbose --all --no-edit --amend'
alias gcans!='command git commit --verbose --all --signoff --no-edit --amend'
alias gcas='command git commit --all --signoff'
alias gcasm='command git commit --all --signoff --message'
alias gcmsg='command git commit --message'
alias gcn!='command git commit --verbose --no-edit --amend'
alias gcs='command git commit --gpg-sign'
alias gcsm='command git commit --signoff --message'
alias gcss='command git commit --gpg-sign --signoff'
alias gcssm='command git commit --gpg-sign --signoff --message'

alias gcf='command git config --list'

alias gdct='command git describe --tags `git rev-list --tags --max-count=1`'

alias gd='command git diff'
alias gdca='command git diff --cached'
alias gdcw='command git diff --cached --word-diff'
alias gds='command git diff --staged'
alias gdw='command git diff --word-diff'
alias gdup='command git diff @{upstream}'
function gdnolock() {
  command git diff "$@" ":(exclude)package-lock.json" ":(exclude)*.lock"
}
#compdef _git gdnolock=git-diff
function gdv {
  command git diff -w "$@" | view -
}
#compdef _git gdv=git-diff

alias gdt='command git diff-tree --no-commit-id --name-only -r'

alias gdtool='command git difftool -d'

alias gf='command git fetch'
alias gfa='command git fetch --all --prune'
alias gfo='command git fetch origin'
# jobs=<n> was added in git 2.8
# alias gfa='git fetch --all --prune --jobs=10' \

alias gg='command git gui citool'
alias gga='command git gui citool --amend'

alias ghh='command git help'

alias glg='command git log --stat'
alias glgg='command git log --graph'
alias glgga='command git log --graph --decorate --all'
alias glgm='command git log --graph --max-count=10'
alias glgp='command git log --stat -p'
alias glo='command git log --oneline --decorate'
alias glod='command git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset"'
alias glods='command git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset" --date=short'
alias glog='command git log --oneline --decorate --graph'
alias gloga='command git log --oneline --decorate --graph --all'
alias glol='command git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset"'
alias glola='command git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset" --all'
alias glols='command git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset" --stat'
# Pretty log messages
function _git_log_prettily(){
  if [[ $1 ]]; then
    command git log --pretty="$1"
  fi
}
alias glp='_git_log_prettily'
#compdef _git glp=git-log

alias gignored='command git ls-files -v | grep "^[[:lower:]]"'
alias gfg='command git ls-files | grep'

alias gm='command git merge'
alias gma='command git merge --abort'
alias gmom='command git merge "origin/$(git_main_branch)"'
alias gms='command git merge --squash'
alias gmum='command git merge "upstream/$(git_main_branch)"'

alias gmt='command git mergetool --no-prompt' # deprecate?
alias gmtvim='command git mergetool --no-prompt --tool=vimdiff' # deprecate?
alias gmtl='command git mergetool --no-prompt'
alias gmtlvim='command git mergetool --no-prompt --tool=vimdiff'

alias ggpull='command git pull origin "$(git_current_branch)"'
alias ggpur='ggu'
alias gl='command git pull'
alias gluc='command git pull upstream "$(git_current_branch)"'
alias glum='command git pull upstream "$(git_main_branch)"'
alias gpr='command git pull --rebase'
alias gup='command git pull --rebase'
alias gupa='command git pull --rebase --autostash'
alias gupav='command git pull --rebase --autostash --verbose'
alias gupom='command git pull --rebase origin "$(git_main_branch)"'
alias gupomi='command git pull --rebase=interactive origin "$(git_main_branch)"'
alias gupv='command git pull --rebase --verbose'
function ggl {
  if (($# != 0 && $# != 1)); then
    command git pull origin "$*"
  else
    local b=
    (($# == 0)) && b=$(git_current_branch)
    command git pull origin "${b:-$1}"
  fi
}
function ggu {
  local b=
  (($# != 1)) && b=$(git_current_branch)
  command git pull --rebase origin "${b:-$1}"
}
#compdef _git ggl=git-checkout
#compdef _git ggpull=git-checkout
#compdef _git ggpur=git-checkout
#compdef _git ggu=git-checkout

alias ggpush='command git push origin "$(git_current_branch)"'
alias gp='command git push'
alias gpd='command git push --dry-run'
alias gpf!='command git push --force'
alias gpf='command git push --force-with-lease'
alias gpoat='command git push origin --all && command git push origin --tags'
alias gpod='command git push origin --delete'
alias gpsup='command git push --set-upstream origin "$(git_current_branch)"'
alias gpsupf='command git push --set-upstream origin "$(git_current_branch)" --force-with-lease'
alias gpu='command git push upstream'
alias gpv='command git push --verbose'
#is-at-least 2.30 "$git_version" && alias gpf='git push --force-with-lease --force-if-includes'
#is-at-least 2.30 "$git_version" && alias gpsupf='git push --set-upstream origin "$(git_current_branch)" --force-with-lease --force-if-includes'
function ggf {
  (($# != 1)) && local b=$(git_current_branch)
  command git push --force origin "${b:=$1}"
}
function ggfl {
  (($# != 1)) && local b=$(git_current_branch)
  command git push --force-with-lease origin "${b:=$1}"
}
function ggp {
  if (($# != 0 && $# != 1)); then
    command git push origin "$*"
  else
    (($# == 0)) && local b=$(git_current_branch)
    command git push origin "${b:=$1}"
  fi
}
function ggpnp {
  if (($# == 0)); then
    ggl && ggp
  else
    ggl "$*" && ggp "$*"
  fi
}
#compdef _git ggf=git-checkout
#compdef _git ggfl=git-checkout
#compdef _git ggp=git-checkout
#compdef _git ggpnp=git-checkout
#compdef _git ggpush=git-checkout
#compdef _git gpoat=git-push

alias grb='command git rebase'
alias grba='command git rebase --abort'
alias grbc='command git rebase --continue'
alias grbi='command git rebase --interactive'
alias grbo='command git rebase --onto'
alias grbs='command git rebase --skip'
alias grbd='command git rebase "$(git_develop_branch)"'
alias grbm='command git rebase "$(git_main_branch)"'
alias grbom='command git rebase "origin/$(git_main_branch)"'

alias gr='command git remote'
alias gra='command git remote add'
alias grmv='command git remote rename'
alias grrm='command git remote remove'
alias grset='command git remote set-url'
alias grup='command git remote update'
alias grv='command git remote --verbose'

alias gpristine='command git reset --hard && command git clean --force -dfx'
alias grh='command git reset'
alias grhh='command git reset --hard'
alias grhk='command git reset --keep'
alias grhs='command git reset --soft'
alias groh='command git reset "origin/$(git_current_branch)" --hard'
alias grt='cd $(command git rev-parse --show-toplevel || echo ".")'
alias gru='command git reset --'

alias grs='command git restore'
alias grss='command git restore --source'
alias grst='command git restore --staged'

alias gunwip='command git rev-list --max-count=1 --format="%s" HEAD | grep -q "\--wip--" && command git reset HEAD~1'
alias grev='command git revert'

alias grm='command git rm'
alias grmc='command git rm --cached'

alias gcount='command git shortlog --summary --numbered'
#compdef _git gcount complete -F _git gcount

alias gsh='command git show'
alias gsps='command git show --pretty=short --show-signature'

alias gsta='command git stash save'
alias gstaa='command git stash apply'
alias gstall='command git stash --all'
alias gstc='command git stash clear'
alias gstd='command git stash drop'
alias gstl='command git stash list'
alias gstp='command git stash pop'
alias gsts='command git stash show'
alias gstu='gsta --include-untracked'
#is-at-least 2.13 "$git_version" && alias gsta='command git stash push'

alias gsb='command git status --short --branch'
alias gss='command git status --short'
#alias gst='command git status'

alias gsi='command git submodule init'
alias gsu='command git submodule update'

alias git-svn-dcommit-push='command git svn dcommit && command git push github "$(git_main_branch):svntrunk"'
alias gsd='command git svn dcommit'
alias gsr='command git svn rebase'
#compdef _git git-svn-dcommit-push=git

alias gsw='command git switch'
alias gswc='command git switch --create'
alias gswd='command git switch "$(git_develop_branch)"'
alias gswm='command git switch "$(git_main_branch)"'

alias gta='command git tag --annotate'
alias gts='command git tag --sign'
alias gtv='command git tag | sort -V'
function gtl {
  command git tag --sort=-v:refname -n --list "$1*"
}
#compdef _git gtl=git-tag

alias gignore='command git update-index --assume-unchanged'
alias gunignore='command git update-index --no-assume-unchanged'

alias gwch='command git whatchanged -p --abbrev-commit --pretty=medium'

alias gwt='command git worktree'
alias gwta='command git worktree add'
alias gwtls='command git worktree list'
alias gwtmv='command git worktree move'
alias gwtrm='command git worktree remove'

alias gw='git worktree'

# gwbr: Display the local branches and mark the active ones with "<---" at the end of the line. Also add numbers in front
#       of each line which has a worktree assigned.
function gwbr {
   git branch | awk 'NF!=2{printf ("    %s\n", $0)}NF==2{n++; if ($1=="*"){printf ("  %1s %s <---\n", n, $0)}; if ($1!="*"){printf ("  %1s %s\n", n, $0)}}'
}

# gst  Display git status information from various git commands
function gst {
   LESS_SAVE=${LESS}
   unset LESS
   echo "Remotes:"
   git remote -v
   echo ""
   echo "Branches:"
   git branch -av
   echo "Worktrees:"
   gwbr
   echo ""
   echo "Status:"
   git status
   echo ""
   LESS=${LESS_SAVE}
}

# For the git worktree functions to work, the following needs to be prepared:
# 0 - The git repo has a branch named "dev" or another main intgration branch set in the variable INITIAL_BRANCH.
# 1 - In your top level development directory (sample: ~/github), clone the repo as follows:
#   $ _GIT_TOP_DIR=~/github
#   $ _GIT_ORG=example-org
#   $ _GIT_REPO=example-repo
#   $ _DATE=$(date +%Y-%m-%d)
#   $ cd ${_GIT_TOP_DIR}
#   $ git clone -b dev git@github.com:${_GIT_ORG}/${_GIT_REPO}.git ${_GIT_REPO}-${_DATE}/dev
#   This will create a new directory with the name of the repo plus a date (or any other) string
#   and a subdirectory for the initial worktree, named dev.
#   Note: The name of the new directory must be different from the repo name so that we can later use
#   the name of the repo in the top level development directory as a link which points to the correct
#   development directory of the repo.
# 2 - In the directory which holds the dev directory, create a link with the name of the repo, pointing
#   to the dev directory. The gwc function can modify this link to a diffent worktree.
#   $ cd ${_GIT_TOP_DIR}/${_GIT_REPO}-${_DATE}
#   $ ln -s dev ${_GIT_REPO}
#   After that, the directory of the repo will have the following content:
#   $ ls -l
#   drwxr-xr-x. 1 user01 user01 252 Jan 12 12:00 dev
#   lrwxrwxrwx. 1 user01 user01   3 Jan 12 12:00 example-repo -> dev
# 3 - For using the repo as usual, create a link named like the repo, pointing to the correct subdirectory:
#   $ cd ${_GIT_TOP_DIR}
#   $ ln -s ${_GIT_REPO}-${_DATE}/${_GIT_REPO} ${_GIT_REPO}
#   $ ls -l
#   drwxr-xr-x. 1 user01 user01 252 Jan 12 12:00 example-repo -> example-repo-2024-01-12/example-repo
#   lrwxrwxrwx. 1 user01 user01   3 Jan 12 12:00 example-repo-2024-01-12
# 4 - Change the directory to the repo, verify that you are really in the correct subdirectory, and start your work:
#   $ cd ${_GIT_REPO}
#   $ pwd -P
#   /home/user01/github/example-repo-2024-01-12/dev

# gwl: List all branches and worktrees. Branches with associated worktrees are displayed with a single digit number
#      in the first column. The current worktree is marked with "<---" at the end of the line.
function gwl ()
{
   LESS_SAVE=${LESS}
   unset LESS
   printf "Repo: "
   _REPO=$(git remote -v | awk '/origin/&&/fetch/{gsub ("\\.git", ""); b=split ($2, a, "/"); print a[2]}')
   echo ${_REPO}
   echo "Branches:"
   gwbr
   echo "Worktrees:"
   git worktree list | awk '{b=split ($1, a, "/"); printf ("  %s/%s  %s %s\n", a[b-1], a[b], $(NF-1), $NF)}'
   LESS=${LESS_SAVE}
}

# Helper function for gwa and gwc, for creating a new worktree.
function gwa_do ()
{
   INITIAL_BRANCH=${INITIAL_BRANCH:="dev"}
   _WORKTREE=$1
   _DIR_REL=$(git status | awk '/On branch/{print $NF}')
   _CD_DIR=$(pwd -P | awk '{split($0, a, "'${_DIR_REL}'"); printf ("%s'${_DIR_REL}'\n", a[1], a[2])}')
   cd ${_CD_DIR}/../${INITIAL_BRANCH}
# Is there already a branch with the name of the new worktree? If yes, we create the worktree based on that branch.
# If not, we create a new one.
   _BRANCH=$(git branch | awk '$NF=="'${_WORKTREE}'"{print "'${_WORKTREE}'"}')
   if [[ "${_BRANCH}." == "." ]]; then
      echo "Press RETURN to create worktree and branch ${_WORKTREE}, based on ${INITIAL_BRANCH} (q to quit):"
      read _ANSWER
      if [[ "${_ANSWER}." == "q." ]]; then
         return 2
      fi
      git worktree add ../${_WORKTREE}
   else
      echo "Press RETURN to create worktree to track branch ${_WORKTREE} (q to quit):"
      read _ANSWER
      if [[ "${_ANSWER}." == "q." ]]; then
         return 2
      fi
      git worktree add ../${_WORKTREE} ${_WORKTREE}
   fi
}

function gw_link ()
{
# Helper function for gwa and gwc, for modifying the link of the repo name to the correct worktree.
# Attention: We need to be in the correct physical directory of the repo and then cd one level up.
   INITIAL_BRANCH=${INITIAL_BRANCH:="dev"}
   _DIR_REL=$(git status | awk '/On branch/{print $NF}')
   _CD_DIR=$(pwd -P | awk '{split($0, a, "'${_DIR_REL}'"); printf ("%s'${_DIR_REL}'\n", a[1], a[2])}')
   _WORKTREE=$1
   cd ${_CD_DIR}/..
   rm ${_REPO}
   ln -s ${_WORKTREE} ${_REPO}
   echo "Repo link in '$(pwd)' is now set to:"
   ls -l ${_REPO}
   cd ${_WORKTREE}
   gwbr
}

# gwa: Add a new branch and its associated worktree.
# Attention: Before using the function gwa for adding a new worktree and branch, make sure your dev tree is clean.
# Unlike when using "git branch -c", modified files will not be part of the new branch. But after creating the new worktree,
# you can copy files from the initial directory over to the new one.
function gwa ()
{
   INITIAL_BRANCH=${INITIAL_BRANCH:="dev"}
   LESS_SAVE=${LESS}
   unset LESS
   printf "Repo: "
   _REPO=$(git remote -v | awk '/origin/&&/fetch/{gsub ("\\.git", ""); b=split ($2, a, "/"); print a[2]}')
   echo ${_REPO}
   echo "Branches:"
   gwbr
   echo
   _WORKTREE=$1
   if [[ ${_WORKTREE}. == "." ]]; then
      echo "Enter the name of the worktree to create, based on ${INITIAL_BRANCH} (RETURN or 'q' to quit):"
      read _WORKTREE
   fi
   if [[ ${_WORKTREE}. != "." ]] && [[ ${_WORKTREE}. != "q." ]]; then
      gwa_do ${_WORKTREE}
      _RET=$?
      if [[ ${_RET} != 2 ]]; then
         gw_link ${_WORKTREE}
      fi
   fi
   LESS=${LESS_SAVE}
}

# gwc: Change the worktree, or create one. Without an argument, it displays the current branch and worktree and
#      asks for the number or name of an existing worktree, or asks you to provide the name of a new worktree.
#      You can skip this step by providing the number or name of an existing worktree, e.g. "gwc 1" or "gwc dev",
#      or by providing the name of a new worktree. The new worktree can be either based on an existing branch,
#      or it can be the name of a new worktree and branch. After the worktree has changed or has been created,
#      the link to the repo is also changed to the directory of the new worktree, and finally all branches and
#      worktrees are displayed with the new worktree being marked with "<---" at the end of the line.
#      Attention: Mixing a a worktree environment with a non-worktree environment is not recommended. If you do
#      so anyway, make sure you are in the main worktree (e.g. the dev worktree/branch) before creating a new
#      worktree. Otherwise, the worktrees may no longer correspond to the branches with the same name.
function gwc ()
{
   REMOTE_NAME=${REMOTE_NAME:="origin"}
   INITIAL_BRANCH=${INITIAL_BRANCH:="dev"}
   LESS_SAVE=${LESS}
   unset LESS
   printf "Repo: "
   _REPO=$(git remote -v | awk '/'${REMOTE_NAME}'/&&/fetch/{gsub ("\\.git", ""); b=split ($2, a, "/"); print a[2]}')
   echo ${_REPO}
   echo "Branches:"
   gwbr
   echo
   _ARG=$1
# No argument was provided -> request it:
   if [[ ${_ARG}. == "." ]]; then
      echo "Enter number or name of branch to change to, or name of branch to create (RETURN or 'q' to quit):"
      read _NUM
      if [[ ${_NUM}. == "." ]] || [[ ${_NUM}. == "q." ]]; then
         LESS=${LESS_SAVE}
         return
      fi
# The argument is a number:
      if [ ${_NUM} -eq ${_NUM} ] 2>/dev/null; then
         _WORKTREE=$(git branch | awk 'NF==2{a++; if (a=='${_NUM}'){print $NF}}')
         if [[ "${_WORKTREE}." == "." ]]; then
            echo "No worktree with number '${_NUM}'."
            LESS=${LESS_SAVE}
            return
         fi
         gw_link ${_WORKTREE}
      else
# The argument is a string:
         _ARG=${_NUM}
         _WORKTREE_TEST=$(git worktree list | awk '$NF=="['${_ARG}']"{print "'${_ARG}'"}')
# There is no worktree with that name -> Create one:
         if [[ "${_WORKTREE_TEST}." == "." ]]; then
            _WORKTREE=${_ARG}
            gwa_do ${_WORKTREE}
            _RET=$?
            if [[ ${_RET} != 2 ]]; then
               gw_link ${_WORKTREE}
            fi
# There is already a worktree with that name -> Switch to it:
         else
            _WORKTREE=${_ARG}
            cd ../${_WORKTREE}
            gw_link ${_WORKTREE}
         fi
      fi
# An argument was provided and it is a number:
   elif [ ${_ARG} -eq ${_ARG} ] 2>/dev/null; then
      _NUM=${_ARG}
      _WORKTREE=$(git branch | awk 'NF==2{a++; if (a=='${_NUM}'){print $NF}}')
      if [[ "${_WORKTREE}." == "." ]]; then
         echo "No worktree with number '${_NUM}'. Worktree not changed."
         return
      fi
      gw_link ${_WORKTREE}
# An argument was provided and it is a string:
   else
      _WORKTREE_TEST=$(git worktree list | awk '$NF=="['${_ARG}']"{print "'${_ARG}'"}')
# There is no worktree with that name -> Create one:
      if [[ "${_WORKTREE_TEST}." == "." ]]; then
         _WORKTREE=${_ARG}
         gwa_do ${_WORKTREE}
         _RET=$?
         if [[ ${_RET} != 2 ]]; then
            gw_link ${_WORKTREE}
         fi
# There is already a worktree with that name -> Switch to it:
      else
         _WORKTREE=${_ARG}
         cd ../${_WORKTREE}
         gw_link ${_WORKTREE}
      fi
   fi
   LESS=${LESS_SAVE}
}

# gwr: Remove a worktree. Without argument, it displays the current branch and worktree and asks for
#      the number or name of an existing worktree to be removed. You can skip this step by providing
#      the number or name of an existing worktree, e.g. "gwr 2" or "gwr issue-01". After the confirmation
#      prompt has been confirmed (by pressing RETURN), the current worktree is first changed to the
#      initial worktree (e.g. "dev") and then the worktree and its associated local and remote branches
#      are removed. Finally, all branches and worktrees are displayed with the new initial worktree being
#      marked with "<---" at the end of the line.
function gwr ()
{
   REMOTE_NAME=${REMOTE_NAME:="origin"}
   INITIAL_BRANCH=${INITIAL_BRANCH:="dev"}
   LESS_SAVE=${LESS}
   unset LESS
   printf "Repo: "
   _REPO=$(git remote -v | awk '/'${REMOTE_NAME}'/&&/fetch/{gsub ("\\.git", ""); b=split ($2, a, "/"); print a[2]}')
   echo ${_REPO}
   echo "Branches:"
   gwbr
   _ARG=$1
   if [[ ${_ARG}. == "." ]]; then
      echo "Enter number or name of the worktree to remove (will cd to '${INITIAL_BRANCH}' first; RETURN or 'q' to quit):"
      read _NUM
      if [[ ${_NUM}. == "." ]] || [[ ${_NUM}. == "q." ]]; then
         LESS=${LESS_SAVE}
         return
      fi
      _WORKTREE=$(git branch | awk 'NF==2{a++; if (a=='${_NUM}'){print $NF}}')
   elif [ ${_ARG} -eq ${_ARG} ] 2>/dev/null; then
      _NUM=${_ARG}
      _WORKTREE=$(git branch | awk 'NF==2{a++; if (a=='${_NUM}'){print $NF}}')
   else
      _WORKTREE=$(git worktree list | awk '$NF=="['${_ARG}']"{print "'${_ARG}'"}')
   fi
   if [[ "${_WORKTREE}." == "." ]]; then
      echo "No worktree with name or number '${_ARG}'."
      gwbr
      return
   fi
   echo "Press RETURN to remove worktree and branch '${_WORKTREE}' (will cd to '${INITIAL_BRANCH}' first):"
   read _ANSWER
# Attention: We need to be in the correct physical directory of the repo and then cd one level up.
   _DIR_REL=$(git status | awk '/On branch/{print $NF}')
   _CD_DIR=$(pwd -P | awk '{split($0, a, "'${_DIR_REL}'"); printf ("%s'${_DIR_REL}'\n", a[1], a[2])}')
   cd ${_CD_DIR}/../${INITIAL_BRANCH}
   git worktree remove ${_WORKTREE}
   git branch -d ${_WORKTREE}
   _REMOTE_BRANCH=$(git branch -r | awk '/'${REMOTE_NAME}'/&&/'${_WORKTREE}'/{print}')
   if [[ "${_REMOTE_BRANCH}." != "." ]]; then
      git branch -dr ${_REMOTE_BRANCH}
   fi
   cd ..
   rm ${_REPO}
   ln -s ${INITIAL_BRANCH} ${_REPO}
   echo "Repo link in '$(pwd)' is now set to:"
   ls -l ${_REPO}
   cd ${INITIAL_BRANCH}
   gwbr
   LESS=${LESS_SAVE}
}

alias gk='\gitk --all --branches'
alias gke='\gitk --all $(git log --walk-reflogs --pretty=%h)'
# alias gk='\gitk --all --branches &!'
# alias gke='\gitk --all $(git log --walk-reflogs --pretty=%h) &!'
#compdef _git gk='command gitk'
#compdef _git gke='command gitk'
