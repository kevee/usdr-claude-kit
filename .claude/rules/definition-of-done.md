# Definition of Done

Before considering any task complete, verify each item below. These are not optional -- skip an item only when it genuinely does not apply (e.g., a pure documentation change has no tests to update).

## 1. Tests are updated

- **Unit tests**: When updating any business logic or utility functions, ensure corresponding unit tests are updated or added. Run the individual test file to confirm it passes.
- **E2E tests**: When changing a user-facing page or workflow, update or add Cypress specs, if present.
- **Both**: A change that touches both backend logic and UI should have both unit and E2E coverage.

## 2. Critical user flows have at least 80% test coverage

When modifying code in critical user flows, check that the changed files maintain at least 80% line coverage. If coverage drops below that threshold, add tests to bring it back up.

## 3. Accessibility passes

- Run `/accessibility` on changed files (or the relevant directory) and resolve any errors before completing work.
- If the change involves UI, verify it follows the checklist in `.claude/rules/accessibility.md`.

## 4. Documentation is updated

When a code change affects any of the following, update the corresponding docs:

- **README.md**: setup instructions, environment variables, new commands, architecture changes
- **CLAUDE.md**: new patterns, commands, or architectural decisions that Claude should know about
- **Documentation** (`docs/`): API references, usage guides, and other technical documentation

The standing rule: whenever you update documentation, also check if the main README needs a corresponding update.

## Version History

- **v1.0.0** - Initial definition of done
