# Git Plugin

The git plugin defines a number of useful aliases and functions for you.

Recently added: Functions for working with git worktrees. Prerequisites: See [this comment section](git.plugin.sh#L401).
- **gwbr**: Display the local branches and mark the active one with "<---" at the end of the line. Also add numbers in front
  of each line which has a worktree assigned.
- **gwl**: Display all branches (as with gwbr) and display all worktrees in a separate section.
- **gst**: Display git status information from various git commands
- **gwa**: Add a new branch and its associated new worktree. Finally, modify the link in the file system to point to the new
  branch.
- **gwc**: Change the worktree, or create one. If a branch with this name already exists, create a worktree with the same name
  and track the existing branch. Finally, modify the link in the file system to point to the new branch.
- **gwr**: Remove a worktree and its associated local and remote branch. Finally, modify the link in the file system to point
  to the initial branch (e.g. "dev").
