---
title: Install a plugin
summary: Learn how to install one of the many plugins developed by the Grafana community.
id: install-a-plugin
categories: ["plugins"]
tags: beginner
status: Published
authors: Grafana Labs
Feedback Link: https://github.com/grafana/tutorials/issues/new
weight: 30
draft: true
---

{{< tutorials/step title="Introduction" >}}

Grafana plugins lets you extend and customize your Grafana experience. Familiarize yourself with the [official Grafana plugins page](https://grafana.com/grafana/plugins) to find and install new plugins.

In this tutorial, you'll:

- Install a plugin on Hosted Grafana
- Install a plugin on local Grafana

### Prerequisites

- Grafana 7.0

{{< /tutorials/step >}}
{{< tutorials/step title="Explore available plugins" >}}

To browse all available plugins, check out the [Plugins](https://grafana.com/grafana/plugins) page. There you can find both official plugins by Grafana, as well as plugins built by the community.

There are three types of plugins:

- [Panel plugins](https://grafana.com/grafana/plugins?type=panel) provides new types of visualizations, such as [world maps](https://grafana.com/grafana/plugins/grafana-worldmap-panel).
- [Data sources plugins](https://grafana.com/grafana/plugins?type=datasource) add support for additional data sources, such as [Google BigQuery](https://grafana.com/grafana/plugins/doitintl-bigquery-datasource).
- [Application plugins](https://grafana.com/grafana/plugins?type=app) bundles data sources and dashboards with custom pages to offer a complete monitoring experience, such as the [Kubernetes application](https://grafana.com/grafana/plugins/grafana-kubernetes-app).

{{< /tutorials/step >}}
{{< tutorials/step title="Install a plugin on Hosted Grafana" >}}

Let's add support for visualizing maps, by installing the [Worldmap Panel plugin](https://grafana.com/grafana/plugins/grafana-worldmap-panel).

To install a plugin:

- Browse to the [Worldmap Panel plugin page](https://grafana.com/grafana/plugins/grafana-worldmap-panel).
- Click **Install plugin** on the right side of the plugin overview.
- Find the instance you want to install the plugin for, and click **Install Now**.

> It may take a minute for your plugin to become available. If you can't see the plugin right away, check back again once your instance has restarted.

Let's try out the new plugin!

- Browse to your Hosted Grafana instance.
- In the sidebar, hover the cursor over the **Configuration** (gear) icon, and click **Plugins**.
- In the search box, enter "world" to find your new plugin.
- Click the **Worldmap Panel** plugin for more details on how to use it.

Once installed, panel plugins become available as visualizations when configuring your panel. Let's try out the new panel plugin by adding a world map to a dashboard.

- Create a new dashboard by hovering the cursor over the **Create** (plus) icon in the sidebar, and clicking **Dashboard**.
- Click **Choose visualization** and select the **Worldmap Panel** from the list of visualizations.

To remove a plugin:

- Browse to the [Worldmap Panel plugin page](https://grafana.com/grafana/plugins/grafana-worldmap-panel).
- Click the **Installation** tab, and find the instance where you installed the plugin.
- Click **Remove plugin** and confirm that you want to delete the plugin by clicking **Confirm delete**.

> It may take a minute before the plugin is removed. If the plugin is still in the plugin list, check back again once your instance has restarted.

{{< /tutorials/step >}}
{{< tutorials/step title="Install a plugin on local Grafana" >}}

To manage plugins on a local instance of Grafana, we recommend the [Grafana command-line tool](https://grafana.com/docs/grafana/latest/administration/cli).

The command-line tool comes bundled with Grafana and is intended to be run on the same machine that the Grafana server is running on.

Let's use the command-line tool to install the [Worldmap Panel](https://grafana.com/grafana/plugins/grafana-worldmap-panel).

- To install the Worldmap Panel plugin, enter the following in your terminal:

```
grafana-cli plugins install grafana-worldmap-panel
```

Installed plugins end up in the Grafana [plugin directory](https://grafana.com/docs/grafana/latest/installation/configuration/#plugins).

> Don't have internet access? You can also download the plugin as a `.zip` file from the following URL: `https://grafana.com/api/plugins/<plugin-id>/versions/<version>/download`

- Restart Grafana to load the new plugin.
- In the sidebar, hover the cursor over the **Configuration** (gear) icon, and click **Plugins**.
- In the search box, enter "world" to find your new plugin.
- Click the **Worldmap Panel** plugin for more details on how to use it.

Once installed, panel plugins become available as visualizations when configuring your panel. Let's try out the new panel plugin by adding a world map to a dashboard.

- Create a new dashboard by hovering the cursor over the **Create** (plus) icon in the sidebar, and clicking **Dashboard**.
- Click **Choose visualization** and select the **Worldmap Panel** from the list of visualizations.

To remove a plugin, enter the following command in your terminal:

```
grafana-cli plugins remove <plugin-id>
```

{{< /tutorials/step >}}
{{< tutorials/step title="Congratulations" >}}

Congratulations, you made it to the end of this tutorial!

### Learn more

- Explore what more you can do with the [Grafana command-line tool](https://grafana.com/docs/grafana/latest/administration/cli)
- Learn how to [build your own panel plugin](/tutorials/build-a-panel-plugin)

{{< /tutorials/step >}}
