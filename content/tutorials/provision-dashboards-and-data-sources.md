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

### What you'll learn

- How to provision dashboard
- How to provision data sources

### What you'll need

- Grafana 7.0

{{% /tutorials/step %}}
{{% tutorials/step title="Configuration as code" %}}

As the number of dashboards and data sources grows within your organization, manually managing changes and permissions can become tedious and error-prone.

Configuration as code is the practice of storing the the configuration of your system as version controlled, human-readable configuration files, rather than in a database.

Encouraging reuse becomes important in order to avoid multiple teams redesigning the same dashboards. These configuration files can be reused across environments to avoid duplicated resources.

Grafana supports configuration as code through _provisioning_. The resources that currently supports provisioning are:

- [Dashboards](https://grafana.com/docs/grafana/latest/administration/provisioning/#dashboards)
- [Data sources](https://grafana.com/docs/grafana/latest/administration/provisioning/#datasources)
- [Notification channels](https://grafana.com/docs/grafana/latest/administration/provisioning/#alert-notification-channels)

{{% /tutorials/step %}}
{{% tutorials/step title="Set the provisioning directory" %}}

Grafana regularly looks in a specified directory for configuration files containing provisioning manifests.

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

Data source definitions are defined in a manifest.

Each configuration file contains a manifest that specifies the desired state of a set of data sources.

Grafana provisions data sources on start-up.

#### Create a data source manifest:

Let's configure a Prometheus data source by provisioning it.

- In the `provisioning/datasources/` directory, create a file called `datasources.yaml` with the following content:

```yaml
apiVersion: 1

datasources:
  - name: TestData DB
    type: testdata

  - name: Prometheus
    type: prometheus
    url: http://localhost:9090
```

- Restart Grafana.

The new Prometheus data sources has been added to the list of data sources, with a time interval of 15s.

The configuration options can vary between different types of data sources. For more information on how to configure a specific data source type, refer to [Data sources](https://grafana.com/docs/grafana/latest/administration/provisioning/#datasources).

{{% /tutorials/step %}}
{{% tutorials/step title="Provision a dashboard" %}}

Each configuration file contains a manifest that specifies the desired state of a set of _dashboard providers_.

A dashboard provider tells Grafana where to find the dashboard definitions, and where to create them.

Grafana regularly checks for changes to the dashboard definitions (by default every **10 seconds**).

#### Create a dashboard provider manifest:

- Create a file called `dashboards.yaml` with the following content:

```yaml
apiVersion: 1

providers:
  - name: Default      # A uniquely identifiable name for the provider
    folder: Services # The folder where to place the dashboards
    type: file         # ???
    options:
      path: /var/lib/grafana/dashboards # The path to the dashboard definitions
```

For more information on how to configure data sources, refer to [Dashboards](https://grafana.com/docs/grafana/latest/administration/provisioning/#dashboards).

{{% /tutorials/step %}}
{{% tutorials/step title="Provision a dashboard with Grafonnet" %}}

Dashboard definitions define every aspect of a Grafana dashboard. As a result, they can get big and unwieldly.

There are a number of tools that aim to make it easier to define dashboards:

- [grafana-dash-gen](https://github.com/uber/grafana-dash-gen) (Javascript)
- [grafanalib](https://github.com/weaveworks/grafanalib) (Python)
- [grafonnet-lib](https://github.com/grafana/grafonnet-lib) (Jsonnet)
- [grafyaml](https://docs.openstack.org/infra/grafyaml/) (YAML)

In this tutorial, you'll use Grafonnet, a [Jsonnet](https://jsonnet.org/) library for generating Grafana dashboards.

Jsonnet is a data templating language developed by Google, that extends the JSON format with features like variables and functions.

#### Install Grafonnet

- Install [Jsonnet](https://jsonnet.org/). Instructions on how to install Jsonnet is available on the [GitHub page](https://github.com/google/jsonnet).
- Clone the [grafonnet-lib](https://github.com/grafana/grafonnet-lib) repository in your preferred work space:

```
git clone https://github.com/grafana/grafonnet-lib.git
```

#### Generate a dashboard

- Create a file called `cluster.jsonnet` with the following content:

```jsonnet
local grafana = import 'grafonnet/grafana.libsonnet';
local dashboard = grafana.dashboard;
local graphPanel = grafana.graphPanel;

dashboard.new(
  'Cluster',
  schemaVersion=16,
  tags=['kubernetes'],
).addPanel(
  graphPanel.new(
    title='CPU Usage',
    datasource='TestData DB',
  ),
  gridPos={
    x: 0,
    y: 0,
    w: 24,
    h: 8,
  }
)
```

- Open a terminal and change the directory to where `cluster.jsonnet` is located:

```
jsonnet -J <path> cluster.jsonnet > cluster.json
```

Where `<path>` is the path to where you cloned grafonnet-lib.

For more information on about how you can use Grafonnet, refer to the [project page](https://github.com/grafana/grafonnet-lib).


{{% /tutorials/step %}}
{{% tutorials/step title="Congratulations" %}}

### Learn more

- [Provisioning Grafana](https://grafana.com/docs/grafana/latest/administration/provisioning/)

{{% /tutorials/step %}}
