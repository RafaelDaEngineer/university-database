# University Database

A comprehensive database system for managing university operations including students, courses, instructors, and administrative data.

## Table of Contents
- [Overview](#overview)
- [Getting Started](#getting-started)
- [Project Structure](#project-structure)
- [Editing Instructions](#editing-instructions)
- [Contributing](#contributing)

## Overview
This project provides a complete database schema and management system for a university environment.

## Getting Started

### Prerequisites
- Database management system (MySQL, PostgreSQL, or similar)
- Git for version control
- Text editor or IDE (VS Code recommended)

### Installation
1. Clone the repository
```bash
git clone <repository-url>
cd conceptual-model
```

2. Set up your database connection
3. Run the initial schema scripts

### Docker
1. Start the DB
```bash
docker-compose up -d
```
2. Enter Docker instance shell
```bash
docker exec -it iv1351_db /bin/bash
```
3. Return to Mac
```bash
exit
```
3. Shut down the DB
```bash
docker-compose down
````

## Editing Instructions for the Group

### Before Making Changes
1. **Pull the latest changes** before you start working:
```bash
git pull origin main
```

2. **Create a new branch** for your changes:
```bash
git checkout -b feature/your-feature-name
```

### Making Changes
1. **Open the project** in your preferred editor
2. **Make your edits** to the relevant files
3. **Test your changes** thoroughly before committing
4. **Save all files** before committing

### Committing Your Work
1. **Check what files changed**:
```bash
git status
```

2. **Add your changes**:
```bash
git add .
# or add specific files
git add path/to/file
```

3. **Commit with a clear message**:
```bash
git commit -m "Brief description of what you changed"
```

### Sharing Your Changes
1. **Push your branch** to the repository:
```bash
git push origin feature/your-feature-name
```

2. **Create a Pull Request** on GitHub for team review
3. **Wait for approval** before merging

### Best Practices
- ✅ Always pull before you start working
- ✅ Use descriptive commit messages
- ✅ Test your changes before pushing
- ✅ Create separate branches for different features
- ✅ Ask for help if you're unsure
- ❌ Don't commit directly to the main branch
- ❌ Don't commit incomplete or broken code
- ❌ Don't ignore merge conflicts

### Common Commands Quick Reference
```bash
# Check current branch
git branch

# Switch to existing branch
git checkout branch-name

# See commit history
git log --oneline

# Undo uncommitted changes
git checkout -- filename

# Update your branch with main
git merge main
```

---
**Last Updated:** [Date]

