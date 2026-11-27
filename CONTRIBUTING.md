# Contributing to FutureBridge AI

## Development Workflow

1. Select a task from the Jira backlog.
2. Review the requirements and acceptance criteria.
3. Create a development branch from main.
4. Implement the required changes.
5. Write and execute relevant tests.
6. Commit changes using Conventional Commits.
7. Push the branch to GitHub.
8. Open a pull request.
9. Review the implementation and resolve feedback.
10. Merge the approved pull request and update the Jira ticket.

## Branch Naming

- feature/FB-123-feature-name
- fix/FB-123-bug-description
- chore/FB-123-maintenance-task
- docs/FB-123-documentation
- refactor/FB-123-refactoring-task

Use the actual Jira issue key when available.

## Commit Convention

Follow the Conventional Commits specification.

Examples:

- feat: add scholarship search
- fix: correct eligibility validation
- docs: update architecture documentation
- chore: initialize monorepo structure
- test: add retrieval evaluation tests
- refactor: improve student profile module

## Quality Requirements

- Keep changes focused and maintainable.
- Follow the established architecture.
- Include relevant automated tests.
- Update documentation when necessary.
- Never commit credentials or sensitive student data.
- Do not merge changes with failing required checks.

## Pull Requests

Every pull request should describe the changes, related Jira issue, testing performed, and any known limitations.