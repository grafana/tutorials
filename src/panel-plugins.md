summary: Build a panel plugin
id: build-a-panel-plugin
categories: Plugins
tags: beginner
status: Published 
authors: Grafana Labs
Feedback Link: https://github.com/grafana/grafana

# Build a panel plugin

## Overview
Duration: 1

In this codelab, you'll learn how to build a panel plugin.

### What you'll need

- Grafana version 6.4+
- NodeJS
- yarn

## Create a new panel plugin
Duration: 1

Tooling for modern web development can be tricky to wrap your head around. While you certainly could write you own webpack configuration, for this guide, I'm going to use grafana-toolkit.

[grafana-toolkit](https://github.com/grafana/grafana/tree/master/packages/grafana-toolkit) is a CLI application that aims to simplify Grafana plugin development, so that you can focus on code, and the toolkit takes care of building and testing it for us.

- Create a data source plugin from template, using the `plugin:create` command:

```
npx grafana-toolkit plugin:create codelab1
```

- Download necessary dependencies:

```
yarn install
```

- Build the plugin:

```
yarn dev
```
