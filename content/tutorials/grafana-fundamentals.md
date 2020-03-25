
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

### You'll learn how to:

- Explore metrics and logs
- Build dashboards
- Annotate dashboards
- Set up alerts

### You'll need:

- [Docker](https://docs.docker.com/install/)
- [Docker Compose](https://docs.docker.com/compose/)
- [Git](https://git-scm.com/)

{{% /tutorials/step %}}
{{% tutorials/step title="Set up the sample application" %}}

This tutorial uses a sample application to demonstrate some of the features in Grafana. To complete the exercises in this tutorial, you need to download the files to your local machine.

In this step, you'll set up the sample application, as well as supporting services, such as [Prometheus](https://prometheus.io/) and [Loki](https://grafana.com/oss/loki/).

- Clone the [Tutorial environment repository](https://github.com/grafana/tutorial-environment). 

If using Git Desktop, then click the link above, click **Clone or download**, and then click [Open in Desktop](https://git-scm.com/).

Or in the command line, enter:

```
git clone https://github.com/grafana/tutorial-environment.git
```

- Change to the directory where you cloned this repository:

```
# Linux or Mac
cd tutorial-environment

# Windows

cd "<path to where you cloned the repository>"
```

- Make sure Docker is running:

```
docker ps
```

No errors means it is running. If you get an error, than start Docker and then run the command again.

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

All services should report their status as `Up`.

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

- Browse to [localhost:3000](http://localhost:3000).
- In **email or username**, type **admin**.
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
- In the URL box, type **http://prometheus:9090**.
- Click **Save & Test**.

Prometheus is now available as a data source in Grafana.

{{% /tutorials/step %}}
{{% tutorials/step title="Explore your metrics" %}}

Grafana Explore is a workflow for troubleshooting and data exploration. In this step, you'll be using Explore to understand the metrics exposed by the sample application.

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

As you can see in the graph legend, the query returns a time series for every method, route, and status code. ((Wait, what? No it doesn't. This is confusing. You need to tell them what the legend is on the screen (different colored lines) and explain this more simply. At first, I was confused because job and instance were all listed, but after inspecting them for a few seconds, I realized that those were all the same.)) 

- PromQL lets you group time series by labels. Add the `sum` function to your query to group time series by route:

```
sum(rate(tns_request_duration_seconds_count[5m])) by(route)
```

- Go back to the sample application and generate some traffic by adding new links, voting, or just refresh the browser. ((This would be a great place to have them change the time picker at the top. I added some stuff, but I thought nothing changed because it was just very small lines at the far right. If they change the time picker to 5 minutes or 15 minutes, then the changes will be far more obvious.))

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

Grafana Explore not only lets you make ad-hoc queries for metrics, but lets you explore your logs as well. ((MARCUS - Remember, I am a noob. I don't know what an ad hoc query is, so you should explain it.))

- In the side bar, click the **Explore** (compass) icon.
- In the data source list at the top, select the **Loki** data source.
- In the **Query editor**, enter:

```
{filename="/var/log/tns-app.log"}
```

- Grafana displays all logs within the log file of the sample application. ((As a noob, I have no idea what I am looking at. You might want to explain what the graph means and what those lines of text at the bottom mean.))

Not only does Loki let you filter logs based on labels, but on specific occurrences.

- Enter the following query to filter log lines based on a substring:

```
{filename="/var/log/tns-app.log"} |= "error"
```
((I got no results from this query until I clicked **Scan for older logs**.))
Grafana only shows logs within the current time interval. This lets you narrow down your logs to a certain time.

- Click and drag over a log occurrence in the graph to filter logs based on time. ((Not clear what a log occurrence is. Perhaps you mean graph data?))

{{% /tutorials/step %}}
{{% tutorials/step title="Build a dashboard" %}}

A _dashboard_*_ gives you an at-a-glance view of your data and lets you track metrics through different visualizations.

Dashboards consist of _panels_, each representing a part of the story you want your dashboard to tell.
((MARCUS - Feels like we should have had this definition earlier, when we were exploring the first panel.))

Every panel consists by a _query_ and a _visualization_. The query defines _what_ data you want to display, whereas the visualization defines _how_ the data is displayed. ((Feels like we should have had this definition earlier, when we were exploring the first panel.))

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
- In **Tags**, enter **migration**.
- Click **Save**.
  Grafana adds your annotation to the graph. Hover your mouse over the base of the annotation to read the text.

((Marcus - Since we are having them tag the annotations, you might want to demonstrate how to use them, or at least explain what they do.))
Grafana also lets you annotate a time interval, with _region annotations_.

Add a region annotation.

- Press Ctrl (or Cmd on macOS), then click and drag across the graph to select an area.
- In **Description**, enter **Performed load tests**.
- In **Tags**, enter **testing**.
((In case you wondered, I'm changing "type" to "enter" because there are multiple ways to input the value. If we specify type, then they might think they cannot copy and paste. In reality, we don't care how they get the value there, so we say "enter."))

Manually annotating your dashboard is fine for those single events. For regularly occurring events, such as deploying a new release, Grafana supports querying annotations from one of your data sources. Let's create an annotation using the Loki data source we added earlier.
((One hallmark of tutorials is friendly language like this. We hold their hand and walk them through what we are doing and why.))

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

The log lines returned by your query are now displayed as annotations in the graph. ((Am I supposed to be seeing new annotations? I do not see any in my Traffic graph.))

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

- In the side bar, hover your cursor over the **Alerting** (bell) icon and then click **Notification channels**. ((When I did this, Grafana asked if I wanted to Save my time range. I clicked Discard, hope that was the right choice. ))
- Click **Add channel**.
- In **Name**, type **RequestBin**.
- In **Type**, select **webhook**.
- In **Url**, paste the endpoint to your request bin.
- Click **Send Test** to send a test alert to your request bin.
- Click **Save**. Grafana displays a list of your existing notification channels.
  ((Okay...now what? What should I see?))

### Configure an alert rule

Now that Grafana knows how to notify you, it's time to set up an alert rule:

- Go to the dashboard you just created. ((Need instructions for how to navigate there from the Notification channels list.))
- Click the Traffic panel title and then type **e**. This keyboard shortcut opens the panel in edit mode.
- Click the bell icon to the left of the panel editor to access the settings for alerting.
- Click **Create Alert**.
- In **Name**, enter **My alert**.
- In **Evaluate every**, type **5s**. For the purpose of this tutorial, the evaluation interval is intentionally shorter than what's recommended to make it easier to test. ((This begs the question, what is recommended? Where would I find that?))
- In **For**, enter **0m**. ((What does 0m do? Make it last forever?))
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

Read more about [alert rules](https://grafana.com/docs/grafana/latest/alerting/rules/) and [notification channels](https://grafana.com/docs/grafana/latest/alerting/notifications/).
((This ending is very short and abrupt. Maybe link to the next suggested tutorial in the series? Now that I completed this, what should I do next?))

{{% /tutorials/step %}}
