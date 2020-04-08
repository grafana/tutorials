---
title: Provision dashboards and data sources
summary: Treat your configuration as code.
id: provision-dashboards-and-data-sources
categories: ["administration"]
tags: intermediate
status: Published
authors: Grafana Labs
Feedback Link: https://github.com/grafana/tutorials/issues/new
draft: true
---

{{% tutorials/step duration="1" title="Introduction" %}}

In this tutorial, you'll:

- Provision dashboards
- Provision data sources

### Prerequisites

- Grafana 7.0

{{% /tutorials/step %}}
{{% tutorials/step title="Configuration as code" %}}

As the number of dashboards and data sources grows within your organization, manually managing changes and permissions can become tedious and error-prone.

Configuration as code is the practice of storing the the configuration of your system as a set of version controlled, human-readable configuration files, rather than in a database.

Encouraging reuse becomes important in order to avoid multiple teams redesigning the same dashboards. These configuration files can be reused across environments to avoid duplicated resources.

Grafana supports configuration as code through _provisioning_. The resources that currently supports provisioning are:

- [Dashboards](https://grafana.com/docs/grafana/latest/administration/provisioning/#dashboards)
- [Data sources](https://grafana.com/docs/grafana/latest/administration/provisioning/#datasources)
- [Notification channels](https://grafana.com/docs/grafana/latest/administration/provisioning/#alert-notification-channels)

In this tutorial, you'll learn how to provision dashboards and data sources.

{{% /tutorials/step %}}
{{% tutorials/step title="Set the provisioning directory" %}}

To tell Grafana where to find these config files, configure the `provisioning` property in the main config file for Grafana:

```ini
[paths]
provisioning = <path to config files>
```

By default, Grafana looks for a provisioning directory in the configuration directory.

The provisioning directory assumes the following structure:

```
provisioning/
  datasources/
    <yaml files>
  dashboards/
    <yaml files>
  notifiers/
    <yaml files>
```

{{% /tutorials/step %}}
{{% tutorials/step title="Provision a data source" %}}

Each data source config file contains a manifest that specifies the desired state of a set of data sources.

At start-up, Grafana loads the configuration files and provisions the data sources listed in the manifests.

Let's configure a [TestData DB](https://grafana.com/docs/grafana/latest/features/datasources/testdata/) data source that we can use for our dashboards.

#### Create a data source manifest:

- In the `provisioning/datasources/` directory, create a file called `default.yaml` with the following content:

```yaml
apiVersion: 1

datasources:
  - name: TestData DB
    type: testdata
```

- Restart Grafana to see the new changes. The TestData DB appears in the list of data sources.

> The configuration options can vary between different types of data sources. For more information on how to configure a specific data source type, refer to [Data sources](https://grafana.com/docs/grafana/latest/administration/provisioning/#datasources).

{{% /tutorials/step %}}
{{% tutorials/step title="Provision a dashboard" %}}

Each dashboard config file contains a manifest that specifies the desired state of a set of _dashboard providers_.

A dashboard provider tells Grafana where to find the dashboard definitions and where to put them.

Grafana regularly checks for changes to the dashboard definitions (by default every **10 seconds**).

First, let's define a dashboard provider so that Grafana knows where to find the dashboards.

#### Define a dashboard provider:

- In the `provisioning/dashboards/` directory, create a file called `default.yaml` with the following content:

```yaml
apiVersion: 1

providers:
  - name: Default    # A uniquely identifiable name for the provider
    folder: Services # The folder where to place the dashboards
    type: file
    options:
      path: /var/lib/grafana/dashboards # The path to the dashboard definitions
```

For more information on how to configure dashboard providers, refer to [Dashboards](https://grafana.com/docs/grafana/latest/administration/provisioning/#dashboards).

#### Create a dashboard definition

- In the dashboard definitions directory you specified in the dashboard provider, i.e. `options.path`, create a file called `cluster.json` with the following content:

```json
{
   "__inputs": [ ],
   "__requires": [ ],
   "annotations": {
      "list": [ ]
   },
   "editable": false,
   "gnetId": null,
   "graphTooltip": 0,
   "hideControls": false,
   "id": null,
   "links": [ ],
   "panels": [
      {
         "aliasColors": { },
         "bars": false,
         "dashLength": 10,
         "dashes": false,
         "datasource": "TestData DB",
         "fill": 1,
         "gridPos": {
            "h": 8,
            "w": 24,
            "x": 0,
            "y": 0
         },
         "id": 2,
         "legend": {
            "alignAsTable": false,
            "avg": false,
            "current": false,
            "max": false,
            "min": false,
            "rightSide": false,
            "show": true,
            "total": false,
            "values": false
         },
         "lines": true,
         "linewidth": 1,
         "links": [ ],
         "nullPointMode": "null",
         "percentage": false,
         "pointradius": 5,
         "points": false,
         "renderer": "flot",
         "repeat": null,
         "seriesOverrides": [ ],
         "spaceLength": 10,
         "stack": false,
         "steppedLine": false,
         "targets": [ ],
         "thresholds": [ ],
         "timeFrom": null,
         "timeShift": null,
         "title": "CPU Usage",
         "tooltip": {
            "shared": true,
            "sort": 0,
            "value_type": "individual"
         },
         "type": "graph",
         "xaxis": {
            "buckets": null,
            "mode": "time",
            "name": null,
            "show": true,
            "values": [ ]
         },
         "yaxes": [
            {
               "format": "short",
               "label": null,
               "logBase": 1,
               "max": null,
               "min": null,
               "show": true
            },
            {
               "format": "short",
               "label": null,
               "logBase": 1,
               "max": null,
               "min": null,
               "show": true
            }
         ]
      }
   ],
   "refresh": "",
   "rows": [ ],
   "schemaVersion": 16,
   "style": "dark",
   "tags": [
      "kubernetes"
   ],
   "templating": {
      "list": [ ]
   },
   "time": {
      "from": "now-6h",
      "to": "now"
   },
   "timepicker": {
      "refresh_intervals": [
         "5s",
         "10s",
         "30s",
         "1m",
         "5m",
         "15m",
         "30m",
         "1h",
         "2h",
         "1d"
      ],
      "time_options": [
         "5m",
         "15m",
         "1h",
         "6h",
         "12h",
         "24h",
         "2d",
         "7d",
         "30d"
      ]
   },
   "timezone": "browser",
   "title": "Cluster",
   "version": 0
}
```

- Restart Grafana to provision the new dashboard (or wait 10 seconds for Grafana to automatically create the dashboard).

{{% /tutorials/step %}}
{{% tutorials/step title="Congratulations" %}}

Congratulations, you made it to the end of this tutorial!

### Learn more

- [Provisioning Grafana](https://grafana.com/docs/grafana/latest/administration/provisioning/)

{{% /tutorials/step %}}
