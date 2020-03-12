# Grafana Tutorials

[![License](https://img.shields.io/github/license/grafana/grafana)](LICENSE)

[Grafana Tutorials](https://grafana.com/tutorials/) are step-by-step guides that help you make the most of Grafana.

**Important:** This project is in early development, and is not fit for production use. The tutorials are based on experimental APIs, which are subject to change.

## Requirements

Docker >= 2.1.0.3

## Build the tutorials

1. Run `make tutorials`. This launches a preview of the website at `http://localhost:3002/tutorials/` which will refresh automatically when changes to content in the `content/tutorials` directory are made.

## Deploy changes to grafana.com

When a PR is merged to master with changes in the `content/tutorials` directory, those changes are automatically synched to the grafana/website repo on the `tutorials-sync` branch.

In order to make those changes live, open a PR in the website repo that merges the `tutorials-sync` branch into `master`. Then follow the publishing guidelines in that repo.

## Resources

- [Google Codelabs Tools](https://github.com/googlecodelabs/tools)
- [Google Developer Codelabs](https://codelabs.developers.google.com/)
- [Ubuntu Tutorials](https://tutorials.ubuntu.com/)
