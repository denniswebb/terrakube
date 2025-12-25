# Quality Gates Checklist

This checklist ensures your contributions meet Terrakube's quality standards before submission. Run these commands to validate your changes before creating a pull request.

---

## Quick Reference

### Frontend Pre-Submission Commands
```bash
cd ui
npm test -- --watchAll=false          # Run all tests
npm test -- --coverage --watchAll=false  # Generate coverage report
npm run lint:check                    # Check for linting issues
npm run lint                          # Auto-fix linting issues
npm run format:check                  # Check formatting
npm run format                        # Auto-fix formatting
npm run build                         # Verify production build
```

### Backend Pre-Submission Commands
```bash
# From project root
mvn clean test                        # Run all unit tests
mvn verify                            # Run tests + integration tests
mvn clean verify                      # Clean build with all tests

# Optional: Check specific module
cd api && mvn test                    # API module tests only
cd registry && mvn test               # Registry module tests only
cd executor && mvn test               # Executor module tests only
```

---

## Complete Quality Gates Checklist

### ✅ Phase 1: Code Quality

#### Frontend (if you modified `ui/` directory)

- [ ] **Run Tests**
  ```bash
  cd ui && npm test -- --watchAll=false
  ```
  - ✅ All tests pass
  - ✅ No new test failures introduced
  - ⚠️ If tests fail, fix issues before proceeding

- [ ] **Check Test Coverage**
  ```bash
  cd ui && npm test -- --coverage --watchAll=false
  ```
  - ✅ Coverage maintained or improved (target: >90%)
  - ✅ New code has corresponding tests
  - 📊 Review coverage report in terminal output

- [ ] **Run Linting**
  ```bash
  cd ui && npm run lint:check
  ```
  - ✅ No new linting errors introduced
  - ✅ Existing warnings not increased
  - 🔧 If issues found, run `npm run lint` to auto-fix

- [ ] **Check Code Formatting**
  ```bash
  cd ui && npm run format:check
  ```
  - ✅ All files properly formatted
  - 🔧 If issues found, run `npm run format` to auto-fix

- [ ] **Verify Production Build**
  ```bash
  cd ui && npm run build
  ```
  - ✅ Build completes without errors
  - ✅ No new build warnings introduced
  - ✅ Bundle size reasonable (check output)

#### Backend (if you modified `api/`, `registry/`, or `executor/` directories)

- [ ] **Run Unit Tests**
  ```bash
  mvn clean test
  ```
  - ✅ All 91+ tests pass
  - ✅ No new test failures
  - ✅ Test execution time reasonable (<2 minutes)

- [ ] **Run Integration Tests**
  ```bash
  mvn clean verify
  ```
  - ✅ All tests pass (unit + integration)
  - ✅ H2 database integration tests succeed
  - ✅ REST API endpoint tests pass
  - ✅ No Spring Boot context failures

- [ ] **Check Code Compilation**
  ```bash
  mvn clean compile
  ```
  - ✅ No compilation errors
  - ✅ No missing imports
  - ✅ All dependencies resolve

- [ ] **Verify Module-Specific Tests** (if you modified specific module)
  ```bash
  # For API changes
  cd api && mvn test

  # For Registry changes
  cd registry && mvn test

  # For Executor changes
  cd executor && mvn test
  ```
  - ✅ Module tests pass independently
  - ✅ No cross-module dependency issues

---

### ✅ Phase 2: Code Review

#### Self-Review Checklist

- [ ] **Code Changes Review**
  - ✅ Reviewed all changes using `git diff`
  - ✅ No debug code left (console.log, System.out.println, etc.)
  - ✅ No commented-out code blocks
  - ✅ No temporary files or test data committed

- [ ] **Code Quality**
  - ✅ Code follows project conventions and patterns
  - ✅ Variable/function names are descriptive
  - ✅ No duplicate code (DRY principle)
  - ✅ Complex logic has comments explaining "why"
  - ✅ No hardcoded values (use constants/config)

- [ ] **TypeScript/Java Specific**
  - ✅ No `any` types in TypeScript (unless absolutely necessary)
  - ✅ Proper type safety maintained
  - ✅ No unused imports
  - ✅ No unused variables
  - ✅ Proper error handling implemented

- [ ] **Testing**
  - ✅ New features have corresponding tests
  - ✅ Bug fixes have regression tests
  - ✅ Edge cases covered
  - ✅ Tests are meaningful (not just for coverage)
  - ✅ Test names clearly describe what's being tested

---

### ✅ Phase 3: Documentation

- [ ] **Code Documentation**
  - ✅ Public APIs have JSDoc/Javadoc comments
  - ✅ Complex algorithms explained
  - ✅ Non-obvious behavior documented
  - ✅ Component props documented (React components)

- [ ] **Update Documentation Files** (if applicable)
  - ✅ README.md updated for new features
  - ✅ CLAUDE.md updated for project conventions
  - ✅ API documentation updated for endpoint changes
  - ✅ Configuration examples updated

- [ ] **Change Description**
  - ✅ Clear commit messages (see Git section below)
  - ✅ PR description explains what/why/how
  - ✅ Screenshots for UI changes
  - ✅ Breaking changes clearly marked

---

### ✅ Phase 4: Git Hygiene

- [ ] **Branch Management**
  ```bash
  git status
  git branch
  ```
  - ✅ Working on feature branch (not main/master)
  - ✅ Branch name descriptive (`feature/add-auth`, `fix/workspace-bug`)
  - ✅ No uncommitted changes in working directory

- [ ] **Commit Quality**
  ```bash
  git log --oneline -5
  ```
  - ✅ Commits are atomic (one logical change per commit)
  - ✅ Commit messages are descriptive
  - ✅ No "WIP", "fix", "update" commit messages
  - ✅ Each commit builds and passes tests

- [ ] **Clean History**
  ```bash
  git diff main...HEAD
  ```
  - ✅ Only intended files changed
  - ✅ No package-lock.json conflicts (frontend)
  - ✅ No accidentally committed files (.env, .DS_Store, etc.)

---

### ✅ Phase 5: Integration Validation

#### Local Integration Testing

- [ ] **Frontend + Backend Integration** (if both modified)
  - ✅ Start backend services locally
  - ✅ Start frontend dev server
  - ✅ Test end-to-end workflow manually
  - ✅ Check browser console for errors
  - ✅ Verify API calls succeed

- [ ] **API Testing with Thunder Client** (if API modified)
  - ✅ Import Thunder Client collections from `/thunder-tests/`
  - ✅ Run relevant API test requests
  - ✅ Verify responses match expected schemas
  - ✅ Check authentication flows work

- [ ] **Database Migrations** (if schema changed)
  - ✅ Liquibase changesets created properly
  - ✅ Migration tested with H2 (tests)
  - ✅ Migration tested with production DB (if applicable)
  - ✅ Rollback scenario considered

---

### ✅ Phase 6: Performance & Security

- [ ] **Performance Considerations**
  - ✅ No obvious performance regressions
  - ✅ Database queries optimized (no N+1 queries)
  - ✅ Frontend bundle size not significantly increased
  - ✅ No unnecessary re-renders (React components)
  - ✅ Expensive operations cached/memoized

- [ ] **Security Review**
  - ✅ No secrets committed (API keys, passwords, tokens)
  - ✅ User input properly validated
  - ✅ SQL injection prevented (parameterized queries)
  - ✅ XSS vulnerabilities addressed
  - ✅ Authentication/authorization checked
  - ✅ CORS policies respected

- [ ] **Accessibility** (for UI changes)
  - ✅ Semantic HTML used
  - ✅ ARIA attributes where needed
  - ✅ Keyboard navigation works
  - ✅ Color contrast sufficient
  - ✅ Screen reader friendly

---

### ✅ Phase 7: CI/CD Preparation

- [ ] **CI/CD Compatibility**
  - ✅ Changes compatible with GitHub Actions workflows
  - ✅ No new environment dependencies
  - ✅ Tests pass in CI environment (not just locally)
  - ✅ Docker builds succeed (if applicable)

- [ ] **Pre-Push Validation**
  ```bash
  # Frontend final check
  cd ui && npm run lint && npm run format && npm test -- --watchAll=false && npm run build

  # Backend final check
  mvn clean verify
  ```
  - ✅ All commands succeed without errors
  - ✅ Ready to push to remote

---

## Quick Validation Scripts

### All Frontend Checks (One Command)
```bash
cd ui && \
  npm test -- --watchAll=false && \
  npm run lint:check && \
  npm run format:check && \
  npm run build && \
  echo "✅ All frontend checks passed!"
```

### All Backend Checks (One Command)
```bash
mvn clean verify && \
  echo "✅ All backend checks passed!"
```

### Full Project Validation
```bash
# From project root
echo "🔍 Running backend tests..." && \
  mvn clean verify && \
  echo "🔍 Running frontend tests..." && \
  cd ui && \
  npm test -- --watchAll=false && \
  npm run lint:check && \
  npm run format:check && \
  npm run build && \
  cd .. && \
  echo "✅ All quality gates passed! Ready to submit PR."
```

---

## Troubleshooting Quality Gate Failures

### Frontend Test Failures
- **Error**: "Cannot find module '@/...'"
  - **Fix**: Check `jest.config.js` path mappings match `tsconfig.json`

- **Error**: Tests timeout
  - **Fix**: Increase Jest timeout in test file: `jest.setTimeout(10000)`

- **Error**: Coverage below threshold
  - **Fix**: Add tests for uncovered lines/branches

### Backend Test Failures
- **Error**: "ClassNotFoundException" or "NoClassDefFoundError"
  - **Fix**: Run `mvn clean install` to rebuild dependencies

- **Error**: H2 database connection issues
  - **Fix**: Check `application-test.properties` configuration

- **Error**: "Port already in use"
  - **Fix**: Kill process using port: `lsof -ti:8080 | xargs kill -9`

### Linting/Formatting Failures
- **Error**: "Unexpected console statement"
  - **Fix**: Replace `console.log()` with proper logging framework

- **Error**: "Unused variable/import"
  - **Fix**: Remove unused code or suppress with `// eslint-disable-line`

- **Error**: Prettier formatting conflicts with ESLint
  - **Fix**: This shouldn't happen (Prettier config integrated). Run `npm run format` then `npm run lint`

### Build Failures
- **Error**: "Module not found" in production build
  - **Fix**: Check import paths are correct (case-sensitive)

- **Error**: TypeScript compilation errors
  - **Fix**: Run `npm run build` to see full error stack, fix type issues

---

## Minimum Required Gates for PR Submission

At minimum, you **MUST** pass these gates before creating a PR:

### Frontend Changes
```bash
cd ui
npm test -- --watchAll=false  # ✅ Required
npm run lint                  # ✅ Required (auto-fix)
npm run format                # ✅ Required (auto-fix)
npm run build                 # ✅ Required
```

### Backend Changes
```bash
mvn clean verify              # ✅ Required
```

### Both Frontend + Backend
```bash
mvn clean verify              # ✅ Backend required
cd ui && npm test -- --watchAll=false && npm run lint && npm run format && npm run build  # ✅ Frontend required
```

---

## Notes

- **CI/CD Current State**: Backend tests run in CI, but frontend tests do not (gap identified in testing-guide.md)
- **Coverage Targets**: Frontend >90%, Backend (current: varies by module)
- **Known Issues**: 371 linting issues and 13 formatting issues exist in current codebase (don't add to them)
- **Test Execution Time**: Frontend ~1-2s, Backend ~49s (normal), full validation <2 minutes

---

## Additional Resources

- [Testing Guide](./testing-guide.md) - Comprehensive testing documentation
- [CONTRIBUTING.md](../CONTRIBUTING.md) - Contribution guidelines
- [GitHub Actions Workflows](../.github/workflows/) - CI/CD configuration
- [Thunder Client Collections](../thunder-tests/) - API testing collections
