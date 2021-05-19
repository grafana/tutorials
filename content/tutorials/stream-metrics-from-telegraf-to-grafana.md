---
title: Stream data from Telegraf to Grafana
summary: Setup a Telegraf which will stream data to Grafana.
id: stream-data-from-telegraf-to-grafana
categories: ["administration"]
tags: ["beginner"]
status: Published
authors: ["grafana_labs"]
Feedback Link: https://github.com/grafana/tutorials/issues/new
weight: 75
---

{{< tutorials/step title="Introduction" >}}

Grafana v8 introduced streaming capabilities - i.e. a way to push data to UI panels. In this tutorial we show how Grafana streaming capabilities can be used together with Telegraf to display data in near real-time.

In this tutorial, you'll:

- Setup Telegraf and output measurements directly to Grafana

{{% class "prerequisite-section" %}}
#### Prerequisites

- Grafana 8.0+
- Telegraf
{{% /class %}}
{{< /tutorials/step >}}
{{< tutorials/step title="Set up your environment" >}}

First, you need to install Grafana and Telegraf. For Grafana [follow the instructions from documentation](https://grafana.com/docs/grafana/latest/installation/). And the same for [installing Telegraf](https://docs.influxdata.com/telegraf/v1.18/introduction/installation/).

{{< /tutorials/step >}}
{{< tutorials/step title="Run Grafana and create admin token" >}}

1. Run Grafana
1. Log in and go to Configuration -> API Keys
1. Press "Add API key" button and create a new API token with Admin role

{{< /tutorials/step >}}
{{< tutorials/step title="Configure and run Telegraf" >}}

In this tutorial we will be using Telegraf configuration like this:

```
[agent]
  interval = "1s"
  flush_interval = "1s"

[[inputs.cpu]]
  percpu = false
  totalcpu = true

[[outputs.http]]
  url = "http://localhost:3000/api/live/push/telegraf"
  data_format = "influx"
  [outputs.http.headers]
    Authorization = "Bearer <Your API Key>"
```

Make sure replacing `<Your API Key>` placeholder with your actual API key. Save this config into file and run Telegraf pointing to it. After running Telegraf will periodically (once in a second) report the state of total CPU usage on a host to Grafana. The only thing left here is create a dashboard with streaming data.

{{< /tutorials/step >}}
{{< tutorials/step title="Create dashboard with streaming data" >}}

1. Create new dashboard
1. Press Add empty panel
1. Select `-- Grafana --` datasource
1. Select `Live measurements` query type
1. Find and select `stream/telegraf/cpu` measurement for Channel field
1. Save dashboard changes

After making these steps you should see a CPU data updated in near real-time on a panel.

{{< /tutorials/step >}}
{{< tutorials/step title="Stream using WebSocket endpoint" >}}

If you aim for high-frequency update sending then you may want to use WebSocket output plugin of Telegraf instead of HTTP output plugin we used here. There is [an ongoing pull request to Telegraf](https://github.com/influxdata/telegraf/pull/9188) we contributed that adds WebSocket output support. Once it's merged and released you can stream data to Grafana using configuration like this:

```
[agent]
  interval = "200ms"
  flush_interval = "200ms"

[[inputs.cpu]]
  percpu = false
  totalcpu = true

[[outputs.websocket]]
  url = "ws://localhost:3000/api/live/push/telegraf"
  data_format = "influx"
  [outputs.websocket.headers]
    Authorization = "Bearer <Your API Key>"
```

WebSocket avoids running all Grafana HTTP middleware on each request from Telegraf thus reducing Grafana backend CPU usage significantly.

{{< /tutorials/step >}}
{{< tutorials/step title="Congratulations" >}}

Congratulations, you made it to the end of this tutorial!

{{< /tutorials/step >}}
