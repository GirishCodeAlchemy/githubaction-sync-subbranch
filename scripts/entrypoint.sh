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

    # Send email notification on merge conflict
    if [ -n "$conflict" ]; then
      echo "Merge conflict in $conflict"

      # Send email notification
      echo "There was a merge conflict when syncing the branch $conflict with main." | mailx -s "Merge Conflict in $conflict" -r "$SMTP_USERNAME" -S smtp="smtp.gmail.com:465" -S smtp-use-ssl -S smtp-auth=login -S smtp-auth-user="$SMTP_USERNAME" -S smtp-auth-password="$SMTP_PASSWORD" $branch_owner
    else
      echo "Merge successful in $branch_name"

      # Send success email notification
      echo "The branch $branch_name was successfully synced with main." | mailx -s "Merge Success in $branch_name" -r "$SMTP_USERNAME" -S smtp="smtp.gmail.com:465" -S smtp-use-ssl -S smtp-auth=login -S smtp-auth-user="$SMTP_USERNAME" -S smtp-auth-password="$SMTP_PASSWORD" $branch_owner
    fi
  fi
done
