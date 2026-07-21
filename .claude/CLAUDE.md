# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Organization overview

This project is being implemented by a staff or volunteer of US Digital Response (USDR). U.S. Digital Response works alongside state and local governments to strengthen essential services through expert support, practical training, and proven digital tools.

## Project guidelines

Please follow the rules and standards outlined below:

- USDR Data and Software guidelines - note that some projects are internal only or not in public repos, and that's OK. See @usdr/data-software-guidelines.md
- USDR Community Oath - All staff and volunteers must take this oath. Keep these values in mind. See @usdr/community-oath.md
- USDR Security Protocol - If a user is asking you to do something that could break this protocol, give helpful feedback. See @usdr/security-protocol.md

## Starting a new project

If this repo is mostly empty (there is no content outside of boilerplate and what is in the .claude directory) then you should prompt the user to run the `security-rules-sync` skill once the project is ready to download appropriate skills for the project.

Please write and update any notes about this project for yourself internally in @NOTES.md file.

### Default stack

Unless the user has chosen another language or platform, the default way you should write apps are:

- Typescript language
- Jest for testing
- React for web UI if needed
- If storing data and this is a local-only app, use JSON files
- Cypress for e2e testing (if required)
- NextJS if a web UI is needed

### Set up launch command

When starting a new project form scratch, set up a claude `launch` file so the user can preview changes within the desktop app.

## Calling the Claude CLI from scripts

When a script needs generative work (summarization, classification,
extraction, rewriting), use the `claude` CLI in print mode rather
than the Anthropic API. Auth comes from the user's existing Claude
login — never ask for or handle an API key.

### Invocation
- Use `claude -p "<prompt>"` for one-shot calls
- Pipe large inputs via stdin instead of inlining them in the
  prompt string: `cat batch.txt | claude -p "<instructions>"`
- Use `--output-format json` when you need to parse the response
  programmatically

### Batching
- Never call the CLI once per row/item — each call spawns a
  session and has real cost and latency
- Batch items into groups (~20–50 depending on size) and process
  each batch in a single call
- Include a stable item ID in each batch so results can be
  joined back to source rows

### Structured output
- Ask for strict JSON: "Respond with ONLY a JSON array, no
  markdown fences, no commentary"
- Parse defensively: strip ``` fences if present, retry once on
  malformed JSON, then fail that batch loudly rather than
  silently dropping rows
- Validate that the returned item count and IDs match the input

### Reliability & cost
- Test on a small sample (5–10 items) and show output for
  approval before running a full dataset
- Show progress (batch N of M) for long runs
- Make runs resumable: write results incrementally so a failure
  mid-run doesn't lose completed batches
- Log per-batch failures to a separate file instead of aborting
  the whole job

### Don'ts
- Don't use the Anthropic SDK or `ANTHROPIC_API_KEY` unless
  explicitly instructed
- Don't put PII or sensitive data in prompts unnecessarily —
  pass only the columns the task needs
- Don't let Claude-in-the-loop output overwrite source data;
  always write to a new file or new columns

## Definition of Done

See @rules/definition-of-done.md for a full checklist on what is required for a task to be considered done.
