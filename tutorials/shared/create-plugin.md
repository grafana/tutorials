### The plugin directory

To discover plugins, Grafana scans a _plugin directory_ which location depends on the system your running.

1. Create a directory called `grafana-plugins` in your preferred workspace.
1. Find the `plugins` property in the Grafana configuration file, and set it to the path of your `grafana-plugins` directory.

### grafana-toolkit

Tooling for modern web development can be tricky to wrap your head around. While you certainly can write you own webpack configuration, for this guide, you'll learn how to use _grafana-toolkit_.

[grafana-toolkit](https://github.com/grafana/grafana/tree/master/packages/grafana-toolkit) is a CLI application that aims to simplify Grafana plugin development, so that you can focus on code, and the toolkit takes care of building and testing it for you.

1\. In the plugin directory, create a panel plugin from template using the `plugin:create` command:

```
npx grafana-toolkit plugin:create my-plugin
```

2\. Change directory.

```
cd my-plugin
```

3\. Download necessary dependencies:

```
yarn install
```

4\. Build the plugin:

```
yarn dev
```

5\. Restart the Grafana server for Grafana to discover your plugin.

6\. Open Grafana and go to **Configuration** -> **Plugins**, and make sure that your plugin is there.

By default, Grafana logs whenever it discovers a plugin:

```
INFO[01-01|12:00:00] Registering plugin       logger=plugins name=my-plugin
```
