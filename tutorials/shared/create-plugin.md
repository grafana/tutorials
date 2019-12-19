Every plugin you create requires at least two files, `plugin.json`, and `module.ts`.

- `plugin.json` contains information about your plugin, and tells Grafana about what capabilities the plugin needs.
- `module.ts` is the entry point for your plugin, and where you should export the implementation for your plugin. Your `module.ts` will look differently depending on the type of plugin you're building.

### The plugin directory

To discover plugins, Grafana scans a plugin directory which location depends on the system your running.

On Unix systems, the plugin directory defaults to `/var/lib/grafana/plugins`. If you're building from source, Grafana instead scans the `data/plugins` directory in the repository root directory.

For Grafana to discover your plugin, either create your plugin in the default plugin directory, or reconfigure the location of the plugin directory in the Grafana configuration file.

### grafana-toolkit

Tooling for modern web development can be tricky to wrap your head around. While you certainly can write you own webpack configuration, for this guide, you'll learn how to use _grafana-toolkit_.

[grafana-toolkit](https://github.com/grafana/grafana/tree/master/packages/grafana-toolkit) is a CLI application that aims to simplify Grafana plugin development, so that you can focus on code, and the toolkit takes care of building and testing it for you.

- In the plugin directory, create a panel plugin from template using the `plugin:create` command:

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

- Restart the Grafana server for Grafana to discover your plugin.

By default, Grafana logs whenever it discovers a plugin:

```
INFO[01-01|12:00:00] Registering plugin            logger=plugins name=my-plugin
```

- Open Grafana and go to **Configuration** -> **Plugins**, and make sure that your plugin is there.
