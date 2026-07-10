# USDR Claude Code starter kit

A starter [Claude Code](https://claude.ai/code) configuration for U.S. Digital Response (USDR) staff and volunteers. It ships a `.claude/` setup that loads USDR's operating guidelines into every session, so the assistant works within our data, software, and security standards by default.

**Please review USDR’s general guidelines for software & data, too: https://policies.usdigitalresponse.org/data-and-software-guidelines**

[![Code of Conduct](https://img.shields.io/badge/%E2%9D%A4-code%20of%20conduct-blue.svg?style=flat)](./CODE_OF_CONDUCT.md)

## What's in here

The heart of the kit is `.claude/CLAUDE.md`, which Claude Code reads at the start of every session in this repo. It imports three USDR policy docs so their full text is always in context:

- **Data and Software Guidelines ---** how we manage data and write software.
- **Community Oath ---** the values and commitments we hold ourselves to.
- **Security Protocol ---** the security practices every volunteer follows.

These live under `.claude/usdr/` and load through `@` imports in `CLAUDE.md`. Because the imports are file paths, the docs have to be real files on disk — which is why we vendor them here rather than link out.

## Keeping the USDR docs current

The three files under `.claude/usdr/` are **auto-synced** from the published source at [policies.usdigitalresponse.org](https://policies.usdigitalresponse.org), so don't hand-edit them — the sync will overwrite your changes. Each file carries a comment at the top noting where it came from.

A weekly [GitHub Action](.github/workflows/sync-usdr-docs.yml) fetches the latest published version, strips the GitBook-only markup, and commits the result only when something actually changed. You can also trigger it on demand from the **Actions** tab with **Run workflow**.

To refresh the docs locally, run the same script the Action uses:

```sh
bash scripts/sync-usdr-docs.sh
```

**Note:** The Action needs this repo pushed to GitHub to run. If you're setting it up fresh, create the remote under the [`usdigitalresponse`](https://github.com/usdigitalresponse) org and push.

## License

See USDR's [Data and Software Guidelines](.claude/usdr/data-software-guidelines.md) for licensing standards.
