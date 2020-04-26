---
title: Create Plugin
---

Tooling for modern web development can be tricky to wrap your head around. While you certainly can write you own webpack configuration, for this guide, you'll be using _grafana-toolkit_.

[grafana-toolkit](https://github.com/grafana/grafana/tree/master/packages/grafana-toolkit) is a CLI application that simplifies Grafana plugin development, so that you can focus on code. The toolkit takes care of building and testing for you.

1\. In the plugin directory, create a plugin from template using the `plugin:create` command:

```
npx @grafana/toolkit plugin:create my-plugin
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

6\. Open Grafana and go to **Configuration** -> **Plugins**. Make sure that your plugin is there.

By default, Grafana logs whenever it discovers a plugin:

```
INFO[01-01|12:00:00] Registering plugin       logger=plugins name=my-plugin
```
