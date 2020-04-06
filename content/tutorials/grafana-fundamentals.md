
---
title: Grafana fundamentals
summary: Get familiar with Grafana
id: grafana-fundamentals
categories: ["fundamentals"]
tags: beginner
status: Published
authors: Grafana Labs
Feedback Link: https://github.com/grafana/tutorials/issues/new
---

{{% tutorials/step duration="1" title="Introduction" %}}

In this tutorial, you'll learn how to use Grafana to set up a monitoring solution for your application.

### What you'll learn:

- How to explore metrics and logs
- How to build dashboards
- How to annotate dashboards
- How to set up alerts

### What you'll need:

- [Docker](https://docs.docker.com/install/)
- [Docker Compose](https://docs.docker.com/compose/) (included in Docker for Desktop for macOS and Windows)
- [Git](https://git-scm.com/)

{{% /tutorials/step %}}
{{% tutorials/step title="Set up the sample application" %}}

This tutorial uses a sample application to demonstrate some of the features in Grafana. To complete the exercises in this tutorial, you need to download the files to your local machine.

In this step, you'll set up the sample application, as well as supporting services, such as [Prometheus](https://prometheus.io/) and [Loki](https://grafana.com/oss/loki/).

- Clone the [github.com/grafana/tutorial-environment](https://github.com/grafana/tutorial-environment) repository.

```
git clone https://github.com/grafana/tutorial-environment.git
```

- Change to the directory where you cloned this repository:

```
cd tutorial-environment
```

- Make sure Docker is running:

```
docker ps
```

No errors means it is running. If you get an error, then start Docker and then run the command again.

- Start the sample application:

```
docker-compose up -d
```

The first time you run `docker-compose up -d`, Docker downloads all the necessary resources for the tutorial. This might take a few minutes, depending on your internet connection.

> **Note:** If you already have Grafana, Loki, or Prometheus running on your system, then you might see errors because the Docker image is trying to use ports that your local installations are already using. Stop the services, then run the command again.

- Ensure all services are up-and-running:

```
docker-compose ps
```

In the **State** column, it should say `Up` for all services.

- Browse to the sample application on [localhost:8081](http://localhost:8081).

### Grafana News

The sample application, Grafana News, lets you post links and vote for the ones you like.

To add a link:

- In **Title**, enter **Example**.
- In **URL**, enter **https://example.com**.
- Click **Submit** to add the link.

The link appears in the list under the Grafana News heading.

To vote for a link, click the triangle icon next to the name of the link.

{{% /tutorials/step %}}
{{% tutorials/step title="Log in to Grafana" %}}

Grafana is an open-source platform for monitoring and observability that lets you visualize and explore the state of your systems.

- Open a new tab.
- Browse to [localhost:3000](http://localhost:3000).
- In **email or username**, enter **admin**.
- In **password**, enter **admin**.
- Click **Log In**.

The first time you log in, you're asked to change your password:

- In **New password**, enter your new password.
- In **Confirm new password**, enter the same password.
- Click **Save**.

The first thing you see is the Home dashboard, which helps you get started.

To the far left you can see the _sidebar_, a set of quick access icons for navigating Grafana.

{{% /tutorials/step %}}
{{% tutorials/step title="Add a metrics data source" %}}

The sample application exposes metrics which are stored in [Prometheus](https://prometheus.io/), a popular time series database (TSDB).

To be able to visualize the metrics from Prometheus, you first need to add it as a data source in Grafana.

- In the side bar, hover your cursor over the  **Configuration** (gear) icon, and then click **Data Sources**.
- Click **Add data source**.
- In the list of data sources, click **Prometheus**.
- In the URL box, enter **http://prometheus:9090**.
- Click **Save & Test**.

Prometheus is now available as a data source in Grafana.

{{% /tutorials/step %}}
{{% tutorials/step title="Explore your metrics" %}}

Grafana Explore is a workflow for troubleshooting and data exploration. In this step, you'll be using Explore to create ad-hoc queries to understand the metrics exposed by the sample application.

> Ad-hoc queries are queries that are made interactively, with the purpose of exploring data. An ad-hoc query is commonly followed by another, more specific query.

- In the side bar, click the **Explore** (compass rose) icon.
- In the **Query editor**, where it says *Enter a PromQL query*, enter `tns_request_duration_seconds_count` and then press Enter.
  A graph appears.
- In the top right corner, click the dropdown arrow on the **Run Query** button, and then select **5s**. Grafana runs your query and updates the graph every 5 seconds.

You just made your first _PromQL_ query! [PromQL](https://prometheus.io/docs/prometheus/latest/querying/basics/) is a powerful query language that lets you select and aggregate time series data stored in Prometheus.

`tns_request_duration_seconds_count` is a _counter_, a type of metric whose value only ever increases. Rather than visualizing the actual value, you can use counters to calculate the _rate of change_, i.e. how fast the value increases.

- Add the `rate` function to your query to visualize the rate of requests per second. Enter the following in the **Query editor** and then press Enter.

```
rate(tns_request_duration_seconds_count[5m])
```

Immediately below the graph there's an area where each time series is listed with a colored icon next to it. This area is called the _legend_.

PromQL lets you group the time series by their labels, using the `sum` function.

- Add the `sum` function to your query to group time series by route:

```
sum(rate(tns_request_duration_seconds_count[5m])) by(route)
```

- Go back to the sample application and generate some traffic by adding new links, voting, or just refresh the browser.

- In the upper right corner, click the _time picker_, and select **Last 5 minutes**. By zooming in on the last few minutes, it's easier to see when you receive new data.

Depending on your use case, you might want to group on other labels. Try grouping by other labels, such as `status_code`, by changing the `by(route)` part of the query.

{{% /tutorials/step %}}
{{% tutorials/step title="Add a logging data source" %}}

Grafana supports log data sources, like [Loki](https://grafana.com/oss/loki/). Just like for metrics, you first need to add your data source to Grafana.

- In the side bar, hover your cursor over the  **Configuration** (gear) icon, and then click **Data Sources**.
- Click **Add data source**.
- In the list of data sources, click **Loki**.
- In the URL box, enter [http://loki:3100](http://loki:3100).
- Click **Save & Test** to save your changes.

Loki is now available as a data source in Grafana.

{{% /tutorials/step %}}
{{% tutorials/step title="Explore your logs" %}}

Grafana Explore not only lets you make ad-hoc queries for metrics, but lets you explore your logs as well.

- In the side bar, click the **Explore** (compass) icon.
- In the data source list at the top, select the **Loki** data source.
- In the **Query editor**, enter:

```
{filename="/var/log/tns-app.log"}
```

- Grafana displays all logs within the log file of the sample application. The height of each bar encodes the number of logs that were generated at that time.

Not only does Loki let you filter logs based on labels, but on specific occurrences.

- Enter the following query to filter log lines based on a substring:

```
{filename="/var/log/tns-app.log"} |= "error"
```

Grafana only shows logs within the current time interval. This lets you narrow down your logs to a certain time.

- Click and drag across the bars in the graph to filter logs based on time.

{{% /tutorials/step %}}
{{% tutorials/step title="Build a dashboard" %}}

A _dashboard_ gives you an at-a-glance view of your data and lets you track metrics through different visualizations.

Dashboards consist of _panels_, each representing a part of the story you want your dashboard to tell.

Every panel consists by a _query_ and a _visualization_. The query defines _what_ data you want to display, whereas the visualization defines _how_ the data is displayed.

- In the side bar, hover your cursor over the **Create** (plus sign) icon and then click **Dashboard**.
- Click **Add query**.
- In the **Query editor**, enter the query from earlier and then press Enter:

```
sum(rate(tns_request_duration_seconds_count[5m])) by(route)
```

- In the **Legend** field, enter **{{route}}** to rename the time series in the legend. The graph legend updates when you click outside the field.
  Four icons on the left allow you to navigate between the **Queries**, **Visualization**, **General**, and **Alert** tabs. Hover your mouse over the icons to see the name of each tab.
- In the **General** tab, change the panel title to "Traffic".
- Click the **Go Back** arrow in the top-left corner to go back to the dashboard view.
- Click the **Save dashboard** (disk) icon at the top of the dashboard to save your dashboard.
- Enter a name in the **New name** field and then click **Save**.

{{% /tutorials/step %}}
{{% tutorials/step title="Annotate events" %}}

We monitor systems for many reasons, but a common use case is to monitor systems that might go down.

Adding annotations to your dashboards is a great way to communicate important events to the rest of your team.

When things go bad, it often helps if you understand the context in which the system failed. Time of last deploy, system changes, or database migration can offer insight into what might have caused an outage. Annotations allow you to add custom events to your graphs.

In the next part of the tutorial, we will simulate some common use cases that someone would add annotations for.

- To manually add an annotation, click anywhere in your graph, then click **Add annotation**.
- In **Description**, enter **Migrated user database**.
- Click **Save**.
  Grafana adds your annotation to the graph. Hover your mouse over the base of the annotation to read the text.

Grafana also lets you annotate a time interval, with _region annotations_.

Add a region annotation:

- Press Ctrl (or Cmd on macOS), then click and drag across the graph to select an area.
- In **Description**, enter **Performed load tests**.
- In **Tags**, enter **testing**.

Manually annotating your dashboard is fine for those single events. For regularly occurring events, such as deploying a new release, Grafana supports querying annotations from one of your data sources. Let's create an annotation using the Loki data source we added earlier.

- At the top of the dashboard, click the **Dashboard settings** (gear) icon.
- In Annotations, click **Add Annotation Query**.
- In **Name**, enter **Errors**.
- In **Data source**, select **Loki**.
- In **Query**, enter the following query:

```
{filename="/var/log/tns-app.log"} |= "error"
```

- Click **Add**. Grafana displays the Annotations list, with your new annotation.
- Click the **Go back** arrow to return to your dashboard.

The log lines returned by your query are now displayed as annotations in the graph.

Being able to combine data from multiple data sources in one graph allows you to correlate information from both Prometheus and Loki.

{{% /tutorials/step %}}
{{% tutorials/step title="Set up an alert" %}}

Alerts allow you to identify problems in your system moments after they occur. By quickly identifying unintended changes in your system, you can minimize disruptions to your services.

Alerts consists of two parts:

* _Notification channel_ - How the alert is delivered. When the conditions of an _alert rule_ are met, the Grafana notifies the channels configured for that alert.
* _Alert rules_ - When the alert is triggered. Alert rules are defined by one or more _conditions_ that are regularly evaluated by Grafana.

### Configure a notification channel

In this step, you'll send alerts using _web hooks_. To test your alerts, you first need to have a place to send them.

- Browse to [requestbin.com](https://requestbin.com)
- Clear the **Private (requires log in)** check box, then click **Create Request Bin**.
  You request bin is now waiting for the first request.
- Copy the endpoint URL.

Next, configure a notification channel for web hooks to send notifications to your Request Bin.

- In the side bar, hover your cursor over the **Alerting** (bell) icon and then click **Notification channels**.
- Click **Add channel**.
- In **Name**, enter **RequestBin**.
- In **Type**, select **webhook**.
- In **Url**, paste the endpoint to your request bin.
- Click **Send Test** to send a test alert to your request bin.
- Navigate back to the request bin you created earlier. On the left side, there's now a `POST /` entry. Click it to see what information is sent by Grafana.
- Click **Save**.

### Configure an alert rule

Now that Grafana knows how to notify you, it's time to set up an alert rule:

- In the sidebar, click **Dashboards** -> **Manage**.
- Click the dashboard you created earlier.
- Click the Traffic panel title and then type **e**. This keyboard shortcut opens the panel in edit mode.
- Click the bell icon to the left of the panel editor to access the settings for alerting.
- Click **Create Alert**.
- In **Name**, enter **My alert**.
- In **Evaluate every**, enter **5s**. For the purpose of this tutorial, the evaluation interval is intentionally short to make it easier to test.
- In **For**, enter **0m**. This setting makes Grafana wait until an alert has fired for a given time, before Grafana sends the notification.
- In the Conditions section, you can change the white text by clicking it and then choosing a new option or typing text in the blank field.
  Change the alert condition to:

```
WHEN last() OF query(A, 1m, now) IS ABOVE 0.2
```

This condition evaluates whether the last value of any of the time series from one minute back is more than 0.2 requests per second.

- In the Notifications section, click the plus sign (+) next to **Send to** and then click **RequestBin**.
- Click the **Go back** arrow and then click the **Save dashboard** icon.
- Enter a note to describe your changes. Something like, **Added My alert**. Notes like this are optional, but can be useful when trying to understand changes made to dashboards over time.

You now have an alert set up to send a notification using a web hook. See if you can trigger it by generating some traffic on the sample application.

- Browse to [localhost:8081](http://localhost:8081).
- Refresh the page repeatedly to generate traffic.
  When Grafana triggers the alert, it sends a request to the web hook you set up earlier. ((I did this, it did not generate an alert.))
- Browse to the Request Bin you created earlier, to inspect the alert notification.

### Pause an alert

Once you've acknowledged an alert, consider pausing it. This can be useful to avoid sending subsequent alerts, while you work on a fix.

- In the Grafana side bar, hover your cursor over the **Alerting** icon and then click **Alert Rules**. All the alert rules configured so far are listed, along with their current state.
- Find your alert in the list, and click the **Pause** icon on the right. The **Pause** icon turns into a **Play** icon.
- Click the **Play** icon to resume evaluation of your alert.

{{% /tutorials/step %}}
{{% tutorials/step title="Congratulations" %}}

Congratulations, you made it to the end of this tutorial!

### Learn more

- [Alert rules](https://grafana.com/docs/grafana/latest/alerting/rules/)
- [Notification channels](https://grafana.com/docs/grafana/latest/alerting/notifications/).

{{% /tutorials/step %}}
