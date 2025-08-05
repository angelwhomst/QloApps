# 🚀 Team Git Workflow Guide

This guide helps our team collaborate smoothly using Git inside the Docker-based dev environment.

---

## 1. Initial Setup (First Time Only)

- Clone the remote repository inside your container or use VS Code’s Git integration.
- Set your Git user info:
  ```sh
  git config --global user.name "Your Name"
  git config --global user.email "your@email.com"
  ```

---

## 2. Daily Workflow

### a. Start of Day: Sync with Remote

- Always pull the latest changes before starting work:
  ```sh
  git pull origin main
  ```

### b. Create a Feature or Bugfix Branch

- Create a new branch for your work:
  ```sh
  git checkout -b feature/short-description
  ```
- Use descriptive branch names, e.g., `feature/housekeeping-ui`, `bugfix/login-error`.

### c. Make Changes and Commit Often

- Work on your code.
- Stage and commit your changes frequently:
  ```sh
  git add .
  git commit -m "Short, clear message about what you changed"
  ```

### d. Push Your Branch to Remote

- Push your branch so others can see your work:
  ```sh
  git push origin feature/short-description
  ```

### e. Sync Regularly

- If you work for a while, regularly pull the latest changes from `main` to avoid conflicts:
  ```sh
  git checkout main
  git pull origin main
  git checkout feature/short-description
  git merge main
  ```
- Resolve any conflicts, commit, and continue.

### f. End of Day: Push Your Work

- Always push your latest commits before stopping work to avoid losing progress.

---

## 3. General Tips

- **Never leave uncommitted work** in the container—always commit and push.
- **Communicate**: Let teammates know what branch you’re working on.
- **Review PRs**: Review and test teammates’ pull requests before merging.
- **Delete merged branches**: Clean up old branches after merging.

---

## 4. Common Commands Reference

```sh
# Check current branch
git branch

# Switch branches
git checkout branch-name

# See changes
git status
git diff

# Stage files
git add file.php

# Commit
git commit -m "Describe your change"

# Push
git push origin branch-name

# Pull
git pull origin branch-name
```

---

## 5. Open the GitHub Repo in Your Browser

```sh
$BROWSER https://github.com/angelwhomst/QloApps
```

---

**Summary:**  
- Pull before you start, branch for each feature, commit and push often, and use PRs for merging.
- Always push your work before stopping or deleting the container.