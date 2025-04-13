#!/usr/bin/env python3

import os
from github import Github

def get_fix_attempt_number():
    """Get the current fix attempt number from git history and PRs."""
    try:
        g = Github(os.environ['GITHUB_TOKEN'])
        repo = g.get_repo(f"{g.get_user().login}/ViniDriveOps")
        
        # Check open PRs
        attempt = 1
        for pr in repo.get_pulls(state='all', sort='created', direction='desc'):
            if pr.title.startswith('AI: Fix attempt #'):
                current = int(pr.title.split('#')[1].split()[0])
                attempt = max(attempt, current + 1)
                break
        
        return attempt
    except Exception:
        return 1

if __name__ == '__main__':
    attempt = get_fix_attempt_number()
    print(attempt)
