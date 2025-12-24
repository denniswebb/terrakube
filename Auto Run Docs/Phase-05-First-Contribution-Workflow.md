# Phase 05: Making Your First Contribution

This phase guides you through the complete contribution workflow - from identifying an issue to submitting a pull request. You'll make a small, safe improvement to validate your setup and understand the contribution process before tackling larger issues.

## Tasks

- [ ] Review the project's CONTRIBUTING.md file (if it exists) to understand contribution guidelines and code of conduct
- [ ] Ensure you're on the main/master branch and it's up to date with `git checkout main && git pull origin main`
- [ ] Create a new feature branch for your first contribution with `git checkout -b fix/your-first-improvement`
- [ ] Identify a small UI improvement opportunity (e.g., better error message, loading indicator, button label clarity)
- [ ] Make the minimal code change required for this improvement in the appropriate frontend component
- [ ] Run frontend tests with `npm test` to ensure no existing tests break
- [ ] Add or update a test for your change if appropriate (component test or updated snapshot)
- [ ] Run the development server with `npm start` and manually verify your change works as expected
- [ ] Take a before/after screenshot or note the improvement for your pull request description
- [ ] Run linting and formatting tools to ensure code style compliance
- [ ] Stage your changes with `git add` for only the files you intentionally modified
- [ ] Create a descriptive commit message following the project's commit conventions (check git log for examples)
- [ ] Push your branch to your fork with `git push origin fix/your-first-improvement`
- [ ] Create a draft pull request on GitHub with a clear description of the problem and your solution
- [ ] Review your own pull request diff to catch any unintended changes before marking it ready for review
- [ ] Document the contribution process you followed in contribution-workflow.md in Auto Run Docs for future reference