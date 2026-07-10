## Git Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/):

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Types

- `feat`: A new feature
- `fix`: A bug fix
- `docs`: Documentation only changes
- `style`: Formatting, missing semicolons, etc. (no code change)
- `refactor`: Code change that neither fixes a bug nor adds a feature
- `perf`: Performance improvement
- `test`: Adding or updating tests
- `build`: Changes to build system or external dependencies
- `ci`: Changes to CI configuration
- `chore`: Other changes that don't modify src or test files

### Rules

- Use lowercase for the description: `feat: add user auth` not `feat: Add user auth`
- No period at the end of the description
- Use imperative mood: `fix: resolve race condition` not `fix: resolved race condition`
- Breaking changes must include `BREAKING CHANGE:` in the footer or `!` after the type: `feat!: remove legacy API`
