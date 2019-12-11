summary: Getting started
id: getting-started
categories: Plugins
tags: beginner
status: Published
authors: Grafana Labs
Feedback Link: https://github.com/grafana/grafana

# Getting started

## Plugin structure

Duration: 1

Every plugin you create requires at least two files, `plugin.json`, and `module.ts`.

### `plugin.json`

`plugin.json` contains information about your plugin, and tells Grafana about what capabilities the plugin needs.

**plugin.json**

```json
{
  "id": "<your-github-handle>-my-datasource",
  "name": "My Data Source",
  "type": "datasource",
  "metrics": true,

  "info": {
    "description": "My very own data source",
    "author": {
      "name": "...",
      "url": "..."
    },
    "keywords": [],
    "version": "1.0.0",
    "updated": "2019-09-10"
  },

  "dependencies": {
    "grafanaVersion": "3.x.x",
    "plugins": []
  }
}
```

### `module.ts`

`module.ts` is the entry point for your plugin, and where you should export the implementation for your plugin. Your `module.ts` will look differently depending on the type of plugin you're building.

### Directory structure

## Configure Grafana for plugin development

Duration: 1

There are three ways Grafana can find your plugin:

1. If you've already set up Grafana for development, you can place your plugin in `data/plugins` in the root directory of the project.
1. If you've installed Grafana, the plugin path is defined in the Grafana config file.
1. Define the plugin path in the Grafana config file.

Positive
: If you're on a Linux system, consider creating a symlink from your preferred project directory to the plugin directory.
