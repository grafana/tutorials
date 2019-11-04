# Create a new panel plugin

Tooling for modern web development can be tricky to wrap your head around. While you certainly could write you own webpack configuration, for this guide, I'm going to use grafana-toolkit.

[grafana-toolkit](https://github.com/grafana/grafana/tree/master/packages/grafana-toolkit) is a CLI application that aims to simplify Grafana plugin development, so that you can focus on code, and the toolkit takes care of building and testing it for us.

1. Create a data source plugin from template, using the `plugin:create` command:

```
npx grafana-toolkit plugin:create codelab1
```

2. Download necessary dependencies:

```
yarn install
```

3. Build the plugin:

```
yarn dev
```
