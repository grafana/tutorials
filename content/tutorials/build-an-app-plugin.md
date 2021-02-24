---
title: Build an app plugin
summary: Learn at how to create an app for Grafana.
id: build-an-app-plugin
categories: ["plugins"]
tags: ["beginner"]
status: Published
authors: ["grafana_labs"]
Feedback Link: https://github.com/grafana/tutorials/issues/new
weight: 50
draft: true
---

{{< tutorials/step title="Introduction" >}}

App plugins are Grafana plugins that can bundle data source and panel plugins within one package. They also enable the plugin author to create custom pages within Grafana. The custom pages enable the plugin author to include things like documentation, sign-up forms, or to control other services with HTTP requests.

Data source and panel plugins will show up like normal plugins. The app pages will be available in the main menu.

{{% class "prerequisite-section" %}}
### Prerequisites

- Grafana 7.0
- NodeJS 12.x
- yarn
{{% /class %}}
{{< /tutorials/step >}}
{{< tutorials/step title="Set up your environment" >}}

{{< tutorials/shared "set-up-environment" >}}

{{< /tutorials/step >}}
{{< tutorials/step title="Create a new plugin" >}}

{{< tutorials/shared "create-plugin" >}}

{{< /tutorials/step >}}
{{< tutorials/step title="Anatomy of a plugin" >}}

{{< tutorials/shared "plugin-anatomy" >}}

{{< /tutorials/step >}}
{{< tutorials/step title="App plugins" >}}

App plugins let you bundle resources such as dashboards, panels, and data sources into a single plugin.

Any resource you want to include needs to be added to the `includes` property in the `plugin.json` file.

App plugins need to be enabled before you can use them. Once they're enabled, they'll show up in the Grafana side menu.

To add a resource to your app plugin, you need to include it to the `plugin.json`.

Plugins that are included in an app plugin are available like any other plugin.

Dashboards and pages can be added to the app menu by setting `addToNav` to `true`.

By setting `"defaultNav": true`, users can navigate to the dashboard by clicking the app icon in the side menu.


#### Enable an app plugin

TODO: How do you enable an app plugin?

{{< /tutorials/step >}}
{{< tutorials/step title="Add a custom page" >}}

App plugins let you extend the Grafana user interface through the use of _custom pages_.

Any requests sent to `/a/<plugin-id>`, e.g. `/a/myorgid-simple-app/`, are routed to the _root page_ of the app plugin.

The root page is a React component that returns the content for a given route.

While you're free to implement your own routing, in this tutorial you'll use a tab-based navigation page that you can use by calling `onNavChange`.

Let's add a tab for managing server instances.

1. In `src/RootPage.tsx`, add another tab by adding another `NavModelItem` to the `tabs` array.

   **RootPage.tsx**

   ```ts
   const TAB_ID_INSTANCES = 'instances';
   ```

   ```ts
   tabs.push({
     text: 'Instances',
     icon: 'fa fa-fw fa-file-text-o',
     url: pathWithoutLeadingSlash + '?tab=' + TAB_ID_INSTANCES,
     id: TAB_ID_INSTANCES,
   });
   ```

1. Create a React component for the tab content.

   ```tsx
   const Instances = () => <p>My instances</p>;
   ```

1. Render the tab content. The `query.tab` contains the id for the active tab. You can use it to decide which component to render.

   ```ts
   return (
     <div>
     {query.tab === TAB_ID_INSTANCES ?? <Instances />}
     </div>
   );
   ```

1. Add the page to the app menu, by including it in `plugin.json`. This will be the main view of the app, so we'll set `defaultNav` to let users quickly get to it by clicking the app icon in the side menu.

   **plugin.json**

   ```json
   "includes": [
     {
       "type": "page",
       "name": "Instances",
       "path": "/a/myorgid-simple-app?tab=instances",
       "role": "Viewer",
       "addToNav": true,
       "defaultNav": true
     }
   ]
   ```

> **Note:** While `page` includes typically reference pages created by the app, you can set `path` to any URL, internal or external. Try setting `path` to `https://grafana.com`.

{{< /tutorials/step >}}
{{< tutorials/step title="Configure the app" >}}

Let's add a new configuration page where users are able to configure default zone and regions for any instances they create.

1. In `module.ts`, add new configuration page using the `addConfigPage` method.

   - `body` is the React component that renders the page content.

   **module.ts**

   ```ts
   .addConfigPage({
     title: 'Defaults',
     icon: 'fa fa-info',
     body: DefaultsConfigPage,
     id: 'defaults',
   })
   ```

{{< /tutorials/step >}}
{{< tutorials/step title="Add a dashboard" >}}

#### Include a dashboard in your app

1. In `src/`, create a new directory called `dashboards`.
1. Create a file called `overview.json` in the `dashboards` directory.
1. Copy the JSON definition for the dashboard you want to include and paste it into `overview.json`. If you don't have one available, you can find a sample dashboard at the end of this step.
1. In `plugin.json`, add the following object to the `includes` property.
   - The `name` of the dashboard needs to be the same as the `title` in the dashboard JSON model.
   - `path` points out the file that contains the dashboard definition, relative to the `plugin.json` file.

   ```json
   "includes": [
     {
       "type": "dashboard",
       "name": "System overview",
       "path": "dashboards/overview.json",
       "addToNav": true
     }
   ]
   ```

1. Save and restart Grafana to load the new changes.

{{< /tutorials/step >}}
{{< tutorials/step title="Bundle a plugin" >}}

An app plugin can contain panel and data source plugins that get installed along with the app plugin.

In this step, you'll add a data source to your app plugin. You can add panel plugins the same way by changing `datasource` to `panel`.

1. In `src/`, create a new directory called `datasources`.
1. Create a new data source using Grafana Toolkit in a temporary directory.

   ```
   mkdir tmp
   cd tmp
   npx @grafana/toolkit plugin:create my-datasource
   ```

1. Move the `src` directory in the data source plugin to `src/datasources`, and rename it to `my-datasource`.

   ```
   mv ./my-datasource/src ../src/datasources/my-datasource
   ```

Any bundled plugins are built along with the app plugin. Grafana looks for any subdirectory containing a `plugin.json` file and attempts to load a plugin in that directory.

To let users know that your plugin bundles other plugins, you can optionally display it on the plugin configuration page. This is not done automatically, so you need to add it to the `plugin.json`.

1. Include the data source in the `plugin.json`. The `name` property is only used for displaying in the Grafana UI.

   ```json
   "includes": [
     {
       "type": "datasource",
       "name": "My data source"
     }
   ]
   ```

#### Import dashboards automatically

TODO: How do you auto-import dashboards (if possible)?

#### Include external plugins

If you want to let users know that your app requires an existing plugin, you can add it as a dependency in `plugin.json`. Note that they'll still need to install it themselves.

```json
"dependencies": {
  "plugins": [
    {
      "type": "panel",
      "name": "Worldmap Panel",
      "id": "grafana-worldmap-panel",
      "version": "^0.3.2"
    }
  ]
}
```

{{< /tutorials/step >}}
{{< tutorials/step title="Congratulations" >}}

Congratulations, you made it to the end of this tutorial!

{{< /tutorials/step >}}

