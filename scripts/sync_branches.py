import subprocess


def sync_branches():
    # Fetch all branches
    subprocess.run(["git", "fetch", "--all"])

    # Loop through all remote branches
    branches = subprocess.check_output(["git", "branch", "-r"]).decode("utf-8").split('\n')
    for branch in branches:
        # Extract local branch name from remote branch
        local_branch_name = branch.split('/')[-1].strip()

        print(f"Processing branch {branch} ---->>>>")

        if local_branch_name != "main" and local_branch_name != "master":
            print(f"Syncing branch {local_branch_name}")

            # Check if branches are already in sync
            if subprocess.run(["git", "merge-base", "--is-ancestor", "main", branch]).returncode == 0:
                print(f"Branch {branch} is already in sync with main. Nothing to merge.")
                continue

            # Sync branches
            subprocess.run(["git", "checkout", "main"])
            subprocess.run(["git", "fetch", "origin"])
            subprocess.run(["git", "switch", local_branch_name])
            subprocess.run(["git", "pull"])
            print(f"Syncing the changes from main to branch: {local_branch_name}")
            subprocess.run(["git", "branch"])

            # Merge changes from main to the branch
            conflict = ""
            subprocess.run(["git", "merge", "origin/main"])
            print("get the status--->")
            subprocess.run(["git", "status"])
            print("get the diff--->")
            subprocess.run(["git", "diff"])

            # Push changes to the branch
            subprocess.run(["git", "push", "origin", local_branch_name])

            # Check for conflicts
            if subprocess.run(["git", "status", "--porcelain"]).stdout:
                conflict = local_branch_name

            # Set output variable for conflict
            print(f"get the status--->{conflict}")
            print("get the config--->")
            subprocess.run(["git", "config", "--list", "--show-origin"])

            # Determine branch owner
            branch_owner = subprocess.check_output(["git", "log", "--format='%ae'", "-n", "1", local_branch_name]).decode("utf-8").strip()
            print(f"Branch owner: {branch_owner}")

            # Send email notification on merge conflict
            if conflict:
                print(f"Merge conflict in {conflict}")
                # Uncomment the following lines when you are ready to send emails
                # subject = f"Merge Conflict in {conflict}"
                # body = f"There was a merge conflict when syncing the branch {conflict} with main."
                # subprocess.run(["mail", "-s", subject, branch_owner], input=body.encode("utf-8"))
            else:
                print(f"Merge successful in {local_branch_name}")
                # Uncomment the following lines when you are ready to send emails
                # subject = f"Merge Successful in {local_branch_name}"
                # body = f"The branch {local_branch_name} was successfully synced with main."
                # subprocess.run(["mail", "-s", subject, branch_owner], input=body.encode("utf-8"))


if __name__ == "__main__":
    sync_branches()
