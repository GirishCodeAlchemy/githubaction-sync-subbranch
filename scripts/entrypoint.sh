#!/bin/sh

set -e
echo "========GirishCodeAlchemy==========="

# Set global Git configurations
git config --global user.name "github-action-bot"
git config --global user.email "github-action-bot@localhost"
git config --global pull.rebase false
git config --global push.default tracking

git config --global --add safe.directory /github/workspace

# Fetch all branches
git fetch --all

# Loop through all remote branches
for branch_name in $(git branch -r | grep -v '\->'); do
  # Extract local branch name from remote branch
  local_branch_name=$(echo $branch_name | sed 's/origin\///')

  if [ "$local_branch_name" != "main" ] && [ "$local_branch_name" != "master" ]; then
    echo "Syncing branch $local_branch_name"

    # Check if branches are already in sync
    if git merge-base --is-ancestor main $branch_name; then
      echo "Branch $branch_name is already in sync with main. Nothing to merge."
      continue
    fi

    # Sync branches
    conflict=""
    git switch $local_branch_name
    git pull --rebase origin $local_branch_name || conflict="$local_branch_name"
    git status
    echo "Syncing the changes from main to branch: $local_branch_name"
    git fetch origin main
    git branch
    git merge origin/main --no-edit --allow-unrelated-histories|| conflict="$local_branch_name"
    echo "get the status--->"
    git status
    echo "get the diff--->"
    git diff
    echo "get the config--->"
    git config --list --show-origin
    git push origin $local_branch_name || conflict="$local_branch_name"

    # Set output variable for conflict
    echo "::set-output name=conflict::$conflict"

    # Determine branch owner
    branch_owner=$(git log --format='%ae' -n 1 $local_branch_name)

    echo "Branch owner: $branch_owner"

    # Send email notification on merge conflict
    if [ -n "$conflict" ]; then
      echo "Merge conflict in $conflict"
      # Uncomment the following lines when you are ready to send emails
      # subject="Merge Conflict in $conflict"
      # echo "There was a merge conflict when syncing the branch $conflict with main." | mail -s "$subject" $branch_owner
    else
      echo "Merge successful in $branch_name"
      # Uncomment the following lines when you are ready to send emails
      # subject="Merge Successful in $local_branch_name"
      # echo "The branch $local_branch_name was successfully synced with main." | mail -s "$subject" $branch_owner
    fi
  fi
done
