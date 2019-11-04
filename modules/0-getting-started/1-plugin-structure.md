# Plugin structure

Every plugin you create requires at least two files, `plugin.json`, and `module.ts`.

## `plugin.json`

`plugin.json` contains information about your plugin, and tells Grafana about what capabilities the plugin needs.

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

## `module.ts`

`module.ts` is the entry point for your plugin, and where you should export the implementation for your plugin. Your `module.ts` will look differently depending on the type of plugin you're building.

## Directory structure
