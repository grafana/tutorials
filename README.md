# Grafana Tutorials

> **Note:** This repository is to be archived.
> Tutorial content will be moved to the project repository that it relates to.
> To find the new location of an existing tutorial, refer to the following table:

| File | New repository |
| ---- | --------------- |
| build-a-data-source-backend-plugin.md | https://github.com/grafana/grafana |
| assets | https://github.com/grafana/grafana |
| build-a-data-source-plugin.md | https://github.com/grafana/grafana |
| build-an-app-plugin.md | https://github.com/grafana/grafana |
| build-a-panel-plugin.md | https://github.com/grafana/grafana |
| build-a-panel-plugin-with-d3.md | https://github.com/grafana/grafana |
| build-a-streaming-data-source-plugin.md | https://github.com/grafana/grafana |
| create-alerts-from-flux-queries.md | https://github.com/grafana/grafana |
| create-users-and-teams.md | https://github.com/grafana/grafana |
| grafana-fundamentals-cloud.md | https://github.com/grafana/cloud-docs (private) |
| grafana-fundamentals.md | https://github.com/grafana/grafana |
| iis.md | https://github.com/grafana/grafana |
| \_index.md | https://github.com/grafana/website (private) |
| install-grafana-on-raspberry-pi.md | https://github.com/grafana/grafana |
| integrate-hubot.md | https://github.com/grafana/grafana |
| provision-dashboards-and-data-sources.md | https://github.com/grafana/grafana |
| run-grafana-behind-a-proxy.md | https://github.com/grafana/grafana |
| shared | https://github.com/grafana/grafana |
| stream-metrics-from-telegraf-to-grafana.md | https://github.com/grafana/grafana |

[![License](https://img.shields.io/github/license/grafana/tutorials)](LICENSE)

[Grafana Tutorials](https://grafana.com/tutorials/) are step-by-step guides that help you make the most of Grafana.

## Use the template to get started writing

If you would like to contribute a tutorial, please use [this template](./TEMPLATE.md) get get started. Name your new file clearly and place it in `tutorials/content/tutorials` alongside the existing files.

## Deploy changes to grafana.com

When a PR is submitted, it must be reviewed by a Grafana employee, because it will ultimately post to the Grafana website. The reviewer will either request/suggest edits or approve and merge on your behalf.

Once the PR is approved and merged to master with changes here, those changes are automatically synched to the `grafana/website` repo on the `master` branch and deployed to the website, typically in a few minutes, but may take longer if there is a queue.

For more information on the general process, see the [main website repo documentation](https://github.com/grafana/website).
