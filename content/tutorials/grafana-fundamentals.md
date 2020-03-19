
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

### What you'll learn how to:

- Explore metrics and logs
- Build dashboards
- Annotate dashboards
- Set up alerts

### What you'll need

- [Docker](https://docs.docker.com/install/)
- [Docker Compose](https://docs.docker.com/compose/)
- [Git](https://git-scm.com/)

{{% /tutorials/step %}}
{{% tutorials/step title="Set up the sample application" %}}

This tutorial uses a sample application to demonstrate some of the features in Grafana. To complete the exercises in this tutorial, you need to download the files to your local machine.

In this step, you'll set up the sample application, as well as supporting services, such as [Prometheus](https://prometheus.io/) and [Loki](https://grafana.com/oss/loki/).

- Clone the [Tutorial environment Git repository](https://github.com/grafana/tutorial-environment). 

If using Git Desktop, then click the link above, click **Clone or download**, and then click [Open in Desktop](https://git-scm.com/).

Or in the command line (`cmd` for Windows), enter:

```
git clone https://github.com/grafana/tutorial-environment.git
```

- Change to the directory where you cloned this repository:

```
# Linux or Mac
cd tutorial-environment

# Windows example, replace the path with the one on your system

cd "C:\GitFiles\tutorial-environment"
```

- Make sure Docker is running:

```
docker ps
```
MARCUS - How do I know if it is running? I got a list of column names but no text. However, the Docker icon in my hidden icons says Docker is running.

- Start the sample application:

```
docker-compose up -d
```

The first time you run `docker-compose up -d`, Docker downloads all the necessary resources for the tutorial. This might take a few minutes, depending on your internet connection.

> **Note:** If you already have Grafana, Loki, or Prometheus running on your system, then you might see errors because the Docker image is trying to use ports that your local installations are already using. Stop the services, then run 

- Ensure all services are up-and-running:

```
docker-compose ps
```

All services should report their status as "Up <time>".

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

- Browse to [localhost:3001](http://localhost:3001).
- In the **email or username** box, type **admin**.
- In the **password** box, type **admin**.
- Click **Log In**.

The first time you log in, you're asked to change your password:

- In the **New password** box, type your new password.
- In the **Confirm new password** box, type the same password.
- Click **Save**.

The first thing you see is the Home dashboard, which helps you get started.

To the far left you can see the _sidebar_, a set of quick access icons for navigating Grafana.

{{% /tutorials/step %}}
{{% tutorials/step title="Add a metrics data source" %}}

The sample application exposes metrics which are stored in [Prometheus](https://prometheus.io/), a popular time series database (TSDB).

To be able to visualize the metrics from Prometheus, you first need to add it as a data source in Grafana.

- In the side bar, click the **Configuration** (gear) icon, and then click **Data Sources**.
- Click **Add data source**. 
- In the list of data sources, click **Prometheus**.
- In the URL box, type **http://prometheus:9090**.
- Click **Save & Test**.

Prometheus is now available as a data source in Grafana.

{{% /tutorials/step %}}
{{% tutorials/step title="Explore your metrics" %}}

Grafana Explore is a workflow for troubleshooting and data exploration. In this step, you'll be using Explore to understand the metrics exposed by the sample application.

- In the side bar, click the **Explore** (compass rose) icon.
- In the **Query editor**, where it says *Enter a PromQL query*, enter `the following text` and then press Enter.
  A graph appears.
- In the top right corner, click the dropdown arrow on the **Run Query** button, and then select **5s**. Grafana runs your query and updates the graph every 5 seconds.

You just made your first _PromQL_ query! [PromQL](https://prometheus.io/docs/prometheus/latest/querying/basics/) is a powerful query language that lets you select and aggregate time series data stored in Prometheus.

`tns_request_duration_seconds_count` is a _counter_, a type of metric whose value only ever increases. Rather than visualizing the actual value, you can use counters to calculate the _rate of change_, i.e. how fast the value increases.

- Add the `rate` function to your query to visualize the rate of requests per second. Enter the following in the **Query editor** and then press Enter.

```
rate(tns_request_duration_seconds_count[5m])
```

As you can see in the graph legend, the query returns a time series for every method, route, and status code. ((Wait, what? No it doesn't. This is confusing. You need to tell them what the legend is on the screen (different colored lines) and explain this more simply. At first, I was confused because job and instance were all listed, but after inspecting them for a few seconds, I realized that those were all the same.)) 

- PromQL lets you group time series by labels. Add the `sum` function to your query to group time series by route:

```
sum(rate(tns_request_duration_seconds_count[5m])) by(route)
```

- Go back to the sample application and generate some traffic by adding new links, voting, or just refresh the browser. ((This would be a great place to have them change the time picker at the top. I added some stuff, but I thought nothing changed because it was just very small lines at the far right. If they change the time picker to 5 minutes or 15 minutes, then the changes will be far more obvious.))

> Depending on your use case, you might want to group on other labels. Try grouping by other labels, such as `status_code`, by changing the `by(route)` part of the query.

{{% /tutorials/step %}}
{{% tutorials/step title="Add a logging data source" %}}

Grafana supports log data sources, like [Loki](https://grafana.com/oss/loki/). Just like for metrics, you first need to add your data source to Grafana.

- In the side bar, click the **Configuration** (gear) icon, and then click **Data Sources**.
- Click **Add data source**. 
- In the list of data sources, click **Loki**.
- In the URL box, enter [http://loki:3100](http://loki:3100).
- Click **Save & Test** to save your changes.

Loki is now available as a data source in Grafana.

{{% /tutorials/step %}}
{{% tutorials/step title="Explore your logs" %}}

Grafana Explore not only lets you make ad-hoc queries for metrics, but lets you explore your logs as well.

- In the side bar, click **Explore**.
- In the dropdown at the top, select the "Loki" data source.
- In the **Query** box, type:

```
{filename="/var/log/tns-app.log"}
```

- Press Enter to display all logs within the log file of the sample application.

Not only does Loki let you filter logs based on labels, but on specific occurrences:

- Filter log lines based on a substring:

```
{filename="/var/log/tns-app.log"} |= "error"
```

Grafana only shows logs within the current time interval. This lets you narrow down your logs to a certain time.

- Click and drag over a log occurrence in the graph to filter logs based on time.

{{% /tutorials/step %}}
{{% tutorials/step title="Build a dashboard" %}}

A dashboard gives you an at-a-glance view of your data and lets you track metrics through different visualizations.

Dashboards are made up of _panels_, each representing a part of the story you want your dashboard to tell.

Every panel consists by a _query_ and a _visualization_. The query defines _what_ data you want to display, whereas the visualization defines _how_ the data is displayed.

- In the side bar, click **Create** to create a new dashboard.
- Click **Add query**, and enter the query from earlier:

```
sum(rate(tns_request_duration_seconds_count[5m])) by(route)
```

- In the **Legend** box, enter "{{route}}" to rename the time series in the legend.
- Click the **General** panel tab, and change the title to "Traffic".
- Click the arrow in the top-left corner to go back to the dashboard view.
- Click the **Save dashboard** icon at the top of the dashboard, to save your dashboard.

{{% /tutorials/step %}}
{{% tutorials/step title="Annotate events" %}}

Whenever things go bad, it can be invaluable to understand the context in which the system failed. Time of last deploy, or database migration can offer insight into what might have caused an outage. Annotations lets you add custom events to your graphs.

- To manually add an annotation, left-click anywhere in your graph, and click **Add annotation**.
- In the **Description** box, type "Migrated user database".
- In the **Tags** box, type "migration".

Grafana also lets you annotate a time interval, through _region annotations_.

- While pressing Ctrl (or Cmd on macOS), click and drag across the graph using your left mouse button.
- In the **Description** box, type "Performed load tests".
- In the **Tags** box, type "testing".

Adding annotations to your dashboards is a great way to communicate important events to the rest of your team.

Manually annotating your dashboard is fine for those one-off events. For regularly occurring events, such as deploying a new release, Grafana supports querying annotations from one of your data sources:

- Select **Dashboard settings** from the top of the dashboard view.
- Click **Annotations**, then **New Annotation Query**.
- In the **Name** box, type "Errors".
- Select "Loki" from the **Data source** drop down.
- In the **Query** box, type a LogQL query:

```
{filename="/var/log/tns-app.log"} |= "error"
```

- Click **Add** and go back to your dashboard.

The log lines returned by your query are now displayed as annotations in the graph.

{{% /tutorials/step %}}
{{% tutorials/step title="Set up an alert" %}}

Alerts allows you to identify problems in your system moments after they occur. By quickly identifying unintended changes in your system, you can minimize disruptions to your services.

Configuring alerting consists of two parts: _Alert rules_ and _notification channels_.

Alert rules are defined by one or more _conditions_ that are regularly evaluated by Grafana. Whenever the conditions of an alert rule are met, the Grafana notifies the channels configured for that alert.

### Configure a notification channel

In this step, you'll be sending alerts using _web hooks_. To be able to test your alerts, you first need to have a place to send them:

- Browse to [requestbin.com](https://requestbin.com)
- Unselect **Private (requires log in)**, and click **Create Request Bin**.
- You request bin is now waiting for the first request.
- Copy the endpoint URL.

Next, you'll configure a notification channel for web hooks, to send notifications to your Request Bin:

- In the side bar, click **Alerting** -> **Notification channels**.
- Click **Add channel**.
- In the **Name** box, type RequestBin.
- In the **Type** box, select "webhook".
- In the **Url** box, paste the endpoint to your request bin.
- Click **Send Test** to send a test alert to your request bin.

### Configure an alert rule

Now that Grafana knows how to notify you, it's time to set up an alert rule:

- Go to the dashboard you just created, and **Edit** the Traffic panel.
- Click the bell icon to the left of the panel editor to access the settings for alerting.
- In the **Name** box, type "My alert".
- In the **Evaluate every** box, type "5s". For the purpose of this tutorial, the evaluation interval is intentionally shorter than what's recommended, to make it easier to test.
- In the **For** box, type "0m".
- Change the alert condition to:

```
WHEN last() OF query(A, 1m, now) IS ABOVE 0.2
```

This condition will evaluate whether the last value of any of the time series from one minute back is more than 0.2 requests per second.

- Under **Notification**, click the plus sign (+) next to **Send to**.
- Select the notification channel you configured earlier.
- Go back to the dashboard, and save the changes you've made.

You now have an alert set up to send a notification using a web hook. See if you can trigger it by generating some traffic on the sample application.

- Browse to [localhost:8081](http://localhost:8081).
- Refresh the page repeatedly to generate traffic.

When Grafana triggers the alert, it sends a request to the web hook you set up earlier.

- Browse to the Request Bin you created earlier, to inspect the alert notification.

### Pause an alert

Once you've acknowledged an alert, consider pausing it. This can be useful to avoid sending subsequent alerts, while you work on a fix.

- In the side bar, click **Alerting** -> **Alert Rules**. All the alert rules configured so far are listed, along with their current state.
- Find your alert in the list, and click the **Pause** icon on the right. The **Pause** icon turns into a **Play** icon.
- Click the **Play** icon to resume evaluation of your alert.

Read more about [alert rules](https://grafana.com/docs/grafana/latest/alerting/rules/) and [notification channels](https://grafana.com/docs/grafana/latest/alerting/notifications/).

{{% /tutorials/step %}}
{{% tutorials/step title="Congratulations" %}}

Congratulations, you made it to the end of this tutorial!

{{% /tutorials/step %}}
