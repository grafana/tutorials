## Create a new panel plugin

Duration: 1

Tooling for modern web development can be tricky to wrap your head around. While you certainly could write you own webpack configuration, for this guide, I'm going to use grafana-toolkit.

[grafana-toolkit](https://github.com/grafana/grafana/tree/master/packages/grafana-toolkit) is a CLI application that aims to simplify Grafana plugin development, so that you can focus on code, and the toolkit takes care of building and testing it for us.

All Grafana plugins needs to be located in `/var/lib/grafana/plugins` or `data/plugins`. Therefore, we recommend to move to one of these directories before following with the next steps.

- Create a panel plugin from template, using the `plugin:create` command:

```
npx grafana-toolkit plugin:create codelab1
```

- Change directory.

```
cd codelab1
```

- Download necessary dependencies:

```
yarn install
```

- Build the plugin:

```
yarn dev
```
