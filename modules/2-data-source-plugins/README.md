# Build data source plugins

Grafana has support for a wide range of data sources, like Prometheus, MySQL, or even Datadog. This means that it’s very likely that you can already visualize metrics from the systems you've already set up. In some cases though, you might already have an in-house metrics solution that you’d like to add to your Grafana dashboards. Luckily, Grafana supports data source plugins, which lets you build a custom integration for your specific source of data.

In this codelab, you'll learn how to build a plugin to integrate with a custom data source.

## What you'll need

- Grafana version 6.4+
- NodeJS
- yarn

## Units

1. [Create a new data source plugin](1-create-data-source-plugin.md)
1. [Add a config editor](2-add-config-editor.md)
1. [Add a query editor](3-add-query-editor.md)
1. [Handle errors](4-error-handling.md)
