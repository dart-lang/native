<!--
Thanks for filing a pull request!
-->

## AI policy

Is your PR vibe coded or AI assisted?

- Vibe coded PRs will not be accepted.
- The difference between vibe coding and AI assisted coding is whether you have properly reviewed and cleaned up the output. The raw output of coding agents is typically not up to our quality standards.
- You are responsible for any code you send out, regardless of whether you or your AI wrote each line. "My AI wrote it" is not an excuse for poor quality code.
- You cannot expect a PR reviewer to put more effort into reviewing the code than you did. We have access to coding agents too, so you should ask yourself whether your PR adds value. What makes your PR better than if we were to ask our agents to write it?
- If you repeatedly send us poor quality PRs, we may restrict your access to the repo.

You can delete this section from the PR description once you've read it.

## Description

*Replace this paragraph with a description of what this PR is changing or adding, and **why**. The 'why' is the most important part of the description.*

## Related Issues

*List which issues are fixed by this PR. Use the syntax `Fixes #1234`.*

## PR Checklist

- [ ] I’ve reviewed the [contributor guide](https://github.com/dart-lang/native/blob/main/CONTRIBUTING.md) and applied the relevant portions to this PR.
- [ ] I've run `dart tool/ci.dart --all` locally and resolved all issues identified. This ensures the PR is formatted, has no lint errors, and ran all code generators. This applies to the packages part of the toplevel `pubspec.yaml` workspace.
- [ ] All existing and new tests are passing. I added new tests to check the change I am making.
- [ ] The PR is actually solving the issue. PRs that don't solve the issue will be closed. Please be respectful of the maintainers' time. If it's not clear what the issue is, feel free to ask questions on the GitHub issue before submitting a PR.
- [ ] I have updated `CHANGELOG.md` for the relevant packages. (Not needed for small changes such as doc typos).
- [ ] I have [updated the pubspec package version](https://github.com/dart-lang/sdk/blob/main/docs/External-Package-Maintenance.md#making-a-change) if necessary.
