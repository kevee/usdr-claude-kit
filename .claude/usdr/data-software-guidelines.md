<!-- Synced from https://policies.usdigitalresponse.org/data-and-software-guidelines.md?displayAgentInstructions=false — do not edit by hand; run scripts/sync-usdr-docs.sh. -->

# Data and Software Guidelines

> This document describes how we manage data and write software at U.S. Digital Response ("USDR"). If you have a good reason to request diverging from these policies, we need to hear from you at <tools-admins@usdigitalresponse.org>.

## Guiding Principles

#### Open and Accessible by Default

USDR data, code, documentation, and projects are open and accessible by default. USDR efforts are meant to be replicated, reused, adapted, and otherwise available for collaboration. USDR data, code, documentation, and projects should be easily discoverable, and projects with a website should dedicate a public-facing point of contact with whom potential collaborators can get in touch with questions.

#### Clear Status

Because our data and software are open by default, it’s important to communicate whether and how they are maintained. If a project no longer has an active maintainer, it should message that clearly by having notices at the top of documentation or otherwise being marked as archived.

## Data Guidelines

Given the nature of COVID-19 relief work and close collaboration with government partners, data is a critical component of many USDR projects. In all cases (even when the data itself has restricted access for good reasons), the use cases, access restrictions, and descriptions of any relevant datasets should be well-documented and shared openly. Note that some government partners may ask you to comply with specific data requirements — please share and review any such agreements with <tools-admins@usdigitalresponse.org>.

### Open Data

Data used for USDR projects should be available in open and machine-readable formats wherever possible. The potential use cases, access mechanisms and descriptions of the data should be well-documented and made available with a [Creative Commons Zero](https://creativecommons.org/share-your-work/public-domain/cc0/) (CC0) license.

If the data is sensitive (e.g., PII, PHI, proprietary data, etc.) and access must be restricted, those reasons should be clearly explained in the documentation and the storage compliant with regulatory guidelines. Whenever applicable, the data should be accessible (via API or clear export pipelines) and made available to trusted government partners. All data collection, storage, retention, and access controls should be designed with privacy and security in mind.

### USDR Team Data

For information on data retention and use, see our [Privacy Policy](https://policies.usdigitalresponse.org/privacy-policy#what-personal-information-do-we-collect) and other resources shared on <http://www.usdigitalresponse.org/>.

## Software Guidelines

> If you’re starting a new repository, use [USDR’s template repository for public code](https://github.com/usdigitalresponse/template-public-code). It addresses most of these requirements right from the start.

### Source Control

[The U.S. Digital Response GitHub organization](https://github.com/usdigitalresponse) houses any USDR repositories, and — as needed — forks of software developed elsewhere. If you have already started a project in another repository, please fork or move it into this organization and resume work here. For questions or access to our repository, email <tools-admins@usdigitalresponse.org>.

When assisting government partners through staff augmentation to perform software development, we recognize that source control is rare, and that we are unlikely to be in a position to influence licensing decisions. Whenever possible, we should encourage partners to develop in accessible GitHub accounts or make documentation publicly available.

### Licensing

For a project that originated elsewhere but will be built with active collaboration from USDR (e.g. relies on connections to our government partners for user research and feedback, has volunteer support), the work must be published under [an OSI-approved license](https://opensource.org/licenses), a [Creative Commons Zero license](https://creativecommons.org/choose/zero/), or committed to the public domain.

Projects originating with USDR must be licensed under the [Apache 2.0 License](https://opensource.org/licenses/Apache-2.0). (If for some reason the Apache 2.0 license is not an approved partner license, use the [MIT License](https://opensource.org/licenses/MIT).)

Projects originating with USDR that are *not* software (e.g. documentation-only repositories or GitBooks) should use the [Creative Commons Attribution 4.0 License (CC BY 4.0)](https://creativecommons.org/licenses/by/4.0/) unless there is a specific reason to choose a different license.

### Repository Standards

If you are creating a new repository to host code, please use the [template-public-code](https://github.com/usdigitalresponse/template-public-code) template. It’ll get you started with most of these standards. All repositories in USDR's GitHub organization should have:

* A **repository description**, which should be brief. Set this by clicking the gear icon in the top right of a repository on GitHub.
* `README.md` file, identifying the purpose of the software and its creators, linking to documentation, providing screenshots (if relevant), a link to an example instance of the software (if relevant), a link to API documentation (if relevant), and a link to the license file. If the software is the work of an organization, also provide a link back to a page on that organization’s website to demonstrate the software’s provenance.
* `LICENSE` file, specifying the full licensing terms.
* `CODE_OF_CONDUCT.md` file, defining the standards for the community, per [GitHub’s specs](https://help.github.com/en/github/building-a-strong-community/adding-a-code-of-conduct-to-your-project). USDR-originated projects should use the [Contributor Covenant](https://www.contributor-covenant.org/version/1/4/code-of-conduct/code_of_conduct.txt).
* `CONTRIBUTING.md` file, describing how to contribute to the project (if, indeed, contributions are welcome). It should make clear that all contributors’ work, when incorporated, will be released under the repo's license.

### Documentation

All dependencies must be listed and the licenses documented. (This can be done in the form of a machine-readable manifest, e.g. `package.json`, `requirements.txt`, `composer.json`, etc.) Major functionality in the software/source code must be documented. Individual methods should be documented inline using comments that permit the use of documentation-generation tools, such as [JSDoc](https://jsdoc.app/).

Make sure to document external services the software depends on as well, e.g. public or private APIs, error tracking services like Sentry, metrics tools like DataDog, etc.

The `README.md` file should provide (or link to) step-by-step instructions for running the software locally, and likewise provide step-by-step instructions for deploying to a production or hosted environment. When relevant, infrastructure should be defined as code, e.g. `Render.yaml`, Terraform, or Kubernetes YAML specs.

### Commits

Commit messages should contain:

1. A single line summary of the change. Imagine some future engineer is skimming down a list of commits; will your summary tell them enough to decide whether they need to read it in detail?
2. A description that includes, at least, the goal (the "why" not "what") of the change. Depending on complexity you might also include a description of how it works, alternative approaches that were rejected, benchmarks etc.

### Code Review and Automated Testing

**Code review** ensures we don’t have a single point of failure, have a shared understanding of how our systems work, and maintain a consistent level of quality across the codebase. All software commits should be reviewed by another engineer, e.g via a pull request. Given the time sensitivity of our work, responding to assigned reviews should be everyone’s top priority (i.e., review first, do your own work second).

**Security review and threat modeling** ensures that we consider all of the security risks that an application may face. Before going live with a project, please reach out in the #questions-security Slack channel to request review of your project.

**Automated testing** ensures we can move fast with safety. However, effective testing is a substantial time commitment that needs to be weighed against our need to ship as fast as possible. Use good judgment here, and consider a) the consequences of something failing, b) how fragile it’s likely to be, and c) how much time investment is needed to correctly test the component.

**Automated security testing** ensures that we protect the applications we create and the data they will collect. All repositories hosting code must have Dependabot alerts and Dependabot security updates enabled (or an alternative security tool, like Snyk). Turn these on in the “Code security and analysis” section of a repo’s settings.\
We strongly recommend [configuring Dependabot dependency updates](https://docs.github.com/en/code-security/dependabot/dependabot-version-updates/about-dependabot-version-updates) (in addition to security updates, above), and require it for any longer-term project with staff engineering support.

## Contact Us

If you have any questions or concerns about these guidelines, contact us at <info@usdigitalresponse.org>.
