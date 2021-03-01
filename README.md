# Grafana Tutorials

[![License](https://img.shields.io/github/license/grafana/grafana)](LICENSE)

[Grafana Tutorials](https://grafana.com/tutorials/) are step-by-step guides that help you make the most of Grafana.

## Requirements

Docker >= 2.1.0.3

## Build the tutorials

1. Run `make tutorials`. This launches a preview of the website at `http://localhost:3002/tutorials/` which will refresh automatically when changes to content in the `content/tutorials` directory are made.

## Deploy changes to grafana.com

When a PR is merged to master with changes in the `content/tutorials` directory, those changes are automatically synched to the grafana/website repo on the `master` branch.

For information on how to make the changes live, refer to [Publishing](https://github.com/grafana/website#publishing).
