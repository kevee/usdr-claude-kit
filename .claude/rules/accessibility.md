# Accessibility Rules

**Standard**: WCAG 2.2 Level AA (minimum), Level AAA (preferred)
**Scope**: All UI components

In general, accessibility should be considered from the outset of any UI development process. If the user asks you to specifically do things that will cause accessibility issues, explain the impact and explore alternative approaches.

## Component Checklist

When creating or modifying UI components, ensure:

1. **Images**: Every `<img>` has meaningful `alt` text, or `alt=""` with `aria-hidden="true"` if decorative.
2. **Keyboard access**: All interactive elements are keyboard-operable. Use native `<button>`, `<a>`, `<input>`, or Radix UI primitives. Never put `onClick` on a `<div>` or `<span>` without `role`, `tabIndex={0}`, and `onKeyDown`.
3. **Labels**: Every form input has a visible `<Label>` associated via `htmlFor` or wrapping. Use the project's `FieldLabel` component. Never rely on `placeholder` as the sole label.
4. **Errors**: Error states use `FieldError` (renders `role="alert"`) and link to the input via `aria-describedby`. Never silently disable a submit button without explaining what is incomplete.
5. **Icon-only buttons**: Include `aria-label` or a `<span className="sr-only">` with descriptive text.
6. **Live regions**: Dynamic status updates use `aria-live="polite"` or `role="status"`. Errors use `aria-live="assertive"` or `role="alert"`.
7. **Color and contrast**: Color is never the sole indicator of state. Text contrast: 4.5:1 (AA) / 7:1 (AAA preferred). Non-text elements (borders, focus rings): 3:1 minimum.
8. **Focus management**: Dialogs move focus on open and return it on close (Radix handles this). When removing an item from a list, move focus to a logical neighbor.
9. **Target size**: Interactive targets are at least 24x24 CSS pixels (AA), preferably 44x44 (AAA).
10. **Semantic HTML**: Use landmarks (`<nav>`, `<main>`, `<header>`, `<footer>`). Use heading levels in order -- never skip from `h2` to `h4`.
11. **Tab index**: Only use `tabIndex={0}` or `tabIndex={-1}`. Never use positive values.
12. **Dialogs**: Always include both `DialogTitle` and `DialogDescription` (or `aria-describedby`) when using Radix `Dialog`.
