# Grafana Tutorials

[![License](https://img.shields.io/github/license/grafana/grafana)](LICENSE)

[Grafana Tutorials](https://grafana.com/tutorials/) are step-by-step guides that help you make the most of Grafana.

## Use the template to get started writing

If you would like to contribute a tutorial, please use [this template](./TEMPLATE.md) get get started. Name your new file clearly and place it in `tutorials/content/tutorials` alongside the existing files.

## Deploy changes to grafana.com

When a PR is submitted, it must be reviewed by a Grafana employee, because it will ultimately post to the Grafana website. The reviewer will either request/suggest edits or approve and merge on your behalf.

Once the PR is approved and merged to master with changes here, those changes are automatically synched to the `grafana/website` repo on the `master` branch and deployed to the website, typically in a few minutes, but may take longer if there is a queue.

For more information on the general process, see the [main website repo documentation](https://github.com/grafana/website).
