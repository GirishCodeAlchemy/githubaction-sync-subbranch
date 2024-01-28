#!/bin/sh

set -e
echo "========GirishCodeAlchemy==========="

git config --global user.name "github-action-bot"
git config --global user.email "github-action-bot@localhost"
git config --global pull.ff only
git config --global --add safe.directory /github/workspace

# Fetch all branches
git fetch --all

# Loop through all branches
for branch in $(git branch -r | grep -v '\->'); do
  if [ "$branch" != "origin/main" ] && [ "$branch" != "origin/master" ]; then
    # Determine branch name
    branch_name=$(echo $branch | sed 's/origin\///')

    # Check if branches are already in sync
    if git merge-base --is-ancestor main $branch_name; then
      echo "Branch $branch_name is already in sync with main. Nothing to merge."
      continue
    fi

    # Sync branches
    conflict=""
    git checkout $branch_name
    git merge main --no-edit || conflict="$branch_name"

    # Set output variable for conflict
    echo "::set-output name=conflict::$conflict"

    # Determine branch owner
    branch_owner=$(git log --format='%ae' -n 1 $branch_name)

    echo "Branch owner: $branch_owner"

    # Send email notification on merge conflict
    if [ -n "$conflict" ]; then
      echo "Merge conflict in $conflict"
      subject="Merge Conflict in $conflict"

      # Send email notification
      echo "There was a merge conflict when syncing the branch $conflict with main." | mail -s "$subject" $branch_owner
    else
      echo "Merge successful in $branch_name"
      subject="Merge Successful in $branch_name"
      echo "The branch $branch_name was successfully synced with main." | mail -s "$subject" $branch_owner
    fi
  fi
done
