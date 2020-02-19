summary: Learn how to create an app plugin.
id: build-an-app-plugin
categories: Plugins
tags: intermediate
status: Published
authors: Grafana Labs
Feedback Link: https://github.com/grafana/tutorials/issues/new

# Build an app plugin

## Introduction

Duration: 1

An app plugin lets you offer a complete monitoring experience, by bundling plugins along with custom pages. Custom pages lets you add sign-up forms, documentation, or even control panels to manage external services.

### What you'll build

In this tutorial, you'll build an app plugin that bundles a data source, panel, dashboard, as well as a custom page.

### What you'll learn

- How to build an app plugin.

### What you'll need

- Grafana version 7.0+
- NodeJS
- yarn

## Set up your environment

Duration: 1

[[**import** [set-up-environment](shared/set-up-environment.md)]]

## Create a new plugin

Duration: 1

[[**import** [create-plugin](shared/create-plugin.md)]]

## Anatomy of a plugin

Duration: 1

[[**import** [plugin-anatomy](shared/plugin-anatomy.md)]]

## App plugins

App plugins is a special type of plugin that lets you bundle other plugins to create a complete experience.

One such an example is the [Grafana App for Kubernetes](https://grafana.com/grafana/plugins/grafana-kubernetes-app).

In the next step, you'll learn how to bundle resources within your Grafana app, such as dashboards and other plugins.

## Bundle resources

For every type of resource you want to bundle, create a subdirectory:

```shell
src/
  dashboards/
    stats.json
  datasources/
    my-datasource/
      plugin.json
  panels/
    my-panel/
      plugin.json
  plugin.json
```

The `includes` field in `plugin.json` defines all resources to bundle with the app.

### Dashboards

```json
"includes": [
  {
    "type": "dashboard",
    "name": "Lots of Stats",
    "path": "dashboards/stats.json"
  }
]
```

### Data sources

```json
"includes": [
  {
    "type": "datasource",
    "name": "My data source"
  }
]
```

### Panels

```json
"includes": [
  {
    "type": "panel",
    "name": "My panel"
  }
]
```

## Create custom pages

App plugins also allows you to create custom pages.

### Root page

The root page is a ReactJS component that extends [AppRootProps](https://github.com/grafana/grafana/blob/45b7de1910819ad0faa7a8aeac2481e675870ad9/packages/grafana-data/src/types/app.ts#L11).

```tsx
import { AppRootProps } from '@grafana/data';

interface Props extends AppRootProps {}

export class MyRootPage<MyAppSettings> extends PureComponent<Props> {
    // ...
}
```

- Configure your app to use the root page:

```tsx
export const plugin = new AppPlugin<MyAppSettings>()
  .setRootPage(MyRootPage);
```

### Config pages

A config page is a ReactJS component that extends [PluginConfigPageProps](https://github.com/grafana/grafana/blob/df1d43167af035c6819923ecce135056f37c79c2/packages/grafana-data/src/types/plugin.ts#L111-L114).

```tsx
import { PluginConfigPageProps, AppPluginMeta } from '@grafana/data';

interface Props extends PluginConfigPageProps<AppPluginMeta<MyAppSettings>> {}

export class MyPage extends PureComponent<Props> {
    // ...
}
```

- Then add your config page to the root page:

```tsx
export const plugin = new AppPlugin<MyAppSettings>()
  .setRootPage(MyRootPage)
  .addConfigPage({
    title: 'My Page',
    icon: 'fa fa-info',
    body: MyPage,
    id: 'my-page',
  });
```

## Congratulations

Congratulations, you made it to the end of this tutorial!
