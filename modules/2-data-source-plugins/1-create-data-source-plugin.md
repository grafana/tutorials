# Create a new plugin

Tooling for modern web development can be tricky to wrap your head around. While you certainly could write you own webpack configuration, for this guide, I'm going to use grafana-toolkit.

[grafana-toolkit](https://github.com/grafana/grafana/tree/master/packages/grafana-toolkit) is a CLI application that aims to simplify Grafana plugin development, so that you can focus on code, and the toolkit takes care of building and testing it for us.

1. Create a data source plugin from template, using the `plugin:create` command:

```
npx grafana-toolkit plugin:create codelab2
```

2. Download necessary dependencies:

```
yarn install
```

3. Build the plugin:

```
yarn dev
```

4. Start Grafana to verify your plugin loads correctly.

5. To add the data source, navigate to **Configuration** -> **Data Sources**, and click **Add data source**.

6. Type "codelab2", and select your data source.

7. Click **Save & Test**.
