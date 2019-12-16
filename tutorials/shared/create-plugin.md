Every plugin you create requires at least two files, `plugin.json`, and `module.ts`.

- `plugin.json` contains information about your plugin, and tells Grafana about what capabilities the plugin needs.
- `module.ts` is the entry point for your plugin, and where you should export the implementation for your plugin. Your `module.ts` will look differently depending on the type of plugin you're building.

All Grafana plugins needs to be located in `/var/lib/grafana/plugins` or `data/plugins`. Therefore, we recommend to move to one of these directories before following with the next steps.

### grafana-toolkit

Tooling for modern web development can be tricky to wrap your head around. While you certainly can write you own webpack configuration, for this guide, you'll learn how to use _grafana-toolkit_.

[grafana-toolkit](https://github.com/grafana/grafana/tree/master/packages/grafana-toolkit) is a CLI application that aims to simplify Grafana plugin development, so that you can focus on code, and the toolkit takes care of building and testing it for you.

- Create a panel plugin from template, using the `plugin:create` command:

```
npx grafana-toolkit plugin:create my-plugin
```

- Change directory.

```
cd my-plugin
```

- Download necessary dependencies:

```
yarn install
```

- Build the plugin:

```
yarn dev
```
