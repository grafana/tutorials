---
title: Grafana Cloud fundamentals
summary: Get familiar with Grafana Cloud
id: grafana-fundamentals-cloud
categories: ["fundamentals"]
tags: ["beginner"]
status: Published
authors: ["grafana_labs"]
Feedback Link: https://github.com/grafana/tutorials/issues/new
weight: 10
---

{{< tutorials/step title="Introduction" >}}

In this tutorial, you'll learn how to use Grafana Cloud to set up a monitoring solution for your application.

You will also learn how to:

- Explore metrics and logs
- Build dashboards
- Annotate dashboards
- Set up alerts

{{% class "prerequisite-section" %}}
> Prerequisites

- [A Grafana Cloud account](https://grafana.com/products/cloud/)

{{% /class %}}
{{< /tutorials/step >}}
{{< tutorials/step title="Using `https://grafana.news`" >}}

This tutorial uses a sample application called [Grafana News](https://grafana.news) to demonstrate some of the features in Grafana Cloud. Grafana News lets you post links and vote for the ones you like. You can view it here:

- [https://grafana.news](https://grafana.news)


> **Adding links to Grafana news**

Go to Grafana News and try adding a link:

1. In **Title**, enter **Example**.
1. In **URL**, enter **https://example.com**.
1. Click **Submit** to add the link.

   The link appears in the list under the Grafana News heading.

To vote for a link, click the triangle icon next to the name of the link.

{{< /tutorials/step >}}
{{< tutorials/step title="Log in to Grafana" >}}

Log in to your Grafana Cloud account. If you do not have an account, [you can create a free forever account here](https://grafana.com/products/cloud/).

{{< /tutorials/step >}}
{{< tutorials/step title="Add a metrics data source" >}}

Our sample application, Grafana News, exposes metrics that are stored in [Prometheus](https://prometheus.io/), a popular time series database (TSDB).

To visualize these metrics from Prometheus, you first need to add and configure the Prometheus Data Source Plugin in Grafana.

1. In the sidebar, hover your cursor over the  **Configuration** (gear) icon, and then click **Data Sources**.
1. Click **Add data source**.
1. In the list of data sources, click **Prometheus**.
1. In the URL box, enter `https://prometheus.grafana.news`.
1. Click **Save & Test**.

   Prometheus is now available as a data source in Grafana.

{{< /tutorials/step >}}
{{< tutorials/step title="Explore your metrics" >}}

Grafana Explore is a workflow for troubleshooting and data exploration. In this step, you'll be using Explore to create ad-hoc queries to understand the metrics exposed by the sample application.

> Ad-hoc queries are created interactively to explore data. An ad-hoc query is commonly followed by another, more specific query.

1. In the sidebar, click the **Explore** (compass rose) icon.
1. In the **Query editor**, where it says *Enter a PromQL query…*, enter `tns_request_duration_seconds_count` and then press Shift + Enter.
  A graph appears.
1. In the top right corner, click the dropdown arrow on the **Run Query** button, and then select **5s**. Grafana runs your query and updates the graph every 5 seconds.

   You just made your first _PromQL_ query! [PromQL](https://prometheus.io/docs/prometheus/latest/querying/basics/) is a powerful query language that lets you select and aggregate time series data stored in Prometheus.

   `tns_request_duration_seconds_count` is a _counter_, a type of metric whose value only ever increases. Rather than visualizing the actual value, you can use counters to calculate the _rate of change_, i.e. how fast the value increases.

1. Add the `rate` function to your query to visualize the rate of requests per second. Enter the following in the **Query editor** and then press Shift + Enter.

   ```
   rate(tns_request_duration_seconds_count[5m])
   ```

   Immediately below the graph, there's an area where each time series is listed with a colored icon next to it. This area is called the _legend_.

   PromQL lets you group the time series by their labels, using the `sum` function.

1. Add the `sum` function to your query to group time series by route:

   ```
   sum(rate(tns_request_duration_seconds_count[5m])) by(route)
   ```

1. Go back to the [sample application](https://grafana.news) and generate some traffic by adding new links, voting, or by refreshing the browser.

1. In the upper right corner, click the _time picker_, and select **Last 5 minutes**. By zooming in on the last few minutes, it's easier to see when you receive new data.

Depending on your use case, you might want to group on other labels. Try grouping by other labels, such as `status_code`, by changing the `by(route)` part of the query.

{{< /tutorials/step >}}
{{< tutorials/step title="Add a logging data source" >}}

Grafana supports log data sources, like [Loki](https://grafana.com/oss/loki/). Just like for metrics, you first need to add your data source to Grafana.

1. In the left navigation pane or sidebar, hover your cursor over the  **Configuration** (gear) icon and then click **Data Sources**.
1. Click **Add data source**.
1. From the list of data sources, click **Loki**.
1. In the URL box, enter `https://loki.grafana.news`.
1. Click **Save & Test** to save your changes.

Loki is now available as a data source in Grafana.

{{< /tutorials/step >}}
{{< tutorials/step title="Explore your logs" >}}

Grafana Explore not only lets you make ad-hoc queries for metrics but lets you explore your logs as well.

1. In the left navigation pane or sidebar, click the **Explore** (compass) icon.
1. From the data source list at the top, select the **Loki** data source.
1. In the **Query editor**, enter:

   ```
   {filename="/var/log/tns-app.log"}
   ```

Grafana displays all logs within the log file of the sample application. The height of each bar encodes the number of logs that were generated at that time.

Now click and drag across the bars in the graph to filter logs based on time.

Loki lets you filter logs based on labels and also on specific occurrences.

Let's generate an error, and analyze it with Explore.

1. In the [sample application](https://grafana.news), post a new link without a URL to generate an error in your browser that says `empty url`.
1. Go back to Grafana and enter the following query to filter log lines based on a substring:

   ```
   {filename="/var/log/tns-app.log"} |= "error"
   ```

1. Click on the log line that says `level=error msg="empty url"` to see more information about the error.

Logs help you identify and understand what went wrong. Later in this tutorial, you'll see how you can correlate logs with metrics from Prometheus to better understand the context of the error.

{{< /tutorials/step >}}
{{< tutorials/step title="Build a dashboard" >}}

A _dashboard_ gives you an at-a-glance view of your data and lets you track metrics through different visualizations.

Dashboards consist of _panels_, each representing a part of the story you want your dashboard to tell.

Every panel consists of a _query_ and a _visualization_. The query defines _what_ data you want to display, whereas the visualization defines _how_ the data is displayed.

1. In the sidebar, hover your cursor over the **Create** (plus sign) icon and then click **Dashboard**.
1. Click **Add new panel**.
1. In the **Query editor** below the graph, enter the query from earlier and then press Shift + Enter:

   ```
   sum(rate(tns_request_duration_seconds_count[5m])) by(route)
   ```

1. In the **Legend** field, enter **{{route}}** to rename the time series in the legend. The graph legend updates when you click outside the field.
1. In the Panel editor on the right, under **Settings**, change the panel title to "Traffic".
1. Click **Apply** in the top-right corner to save the panel and go back to the dashboard view.
1. Click the **Save dashboard** (disk) icon at the top of the dashboard to save your dashboard.
1. Enter a name in the **New name** field and then click **Save**.

{{< /tutorials/step >}}
{{< tutorials/step title="Annotate events" >}}

When things go bad, it often helps if you understand the context in which the failure occurred. Time of last deployment, system changes, or database migration can offer insight into what might have caused an outage. Annotations allow you to represent such events directly on your graphs.

In the next part of the tutorial, we will simulate some common use cases where you can add annotations.

1. To manually add an annotation, click anywhere in your graph, then click **Add annotation**.
1. In **Description**, enter **Migrated user database**.
1. Click **Save**.

   Grafana adds your annotation to the graph. Hover your mouse over the base of the annotation to read the text.

Grafana also lets you annotate a time interval, with _region annotations_.

Add a region annotation:

1. Press Ctrl (or Cmd on macOS), then click and drag across the graph to select an area.
1. In **Description**, enter **Performed load tests**.
1. In **Tags**, enter **testing**.

Manually annotating your dashboard is fine for those single events. For regularly occurring events, such as deploying a new release, Grafana supports querying annotations from one of your data sources. Let's create an annotation using the Loki data source we added earlier.

1. At the top of the dashboard, click the **Dashboard settings** (gear) icon.
1. Go to **Annotations** and click **Add Annotation Query**.
1. In **Name**, enter **Errors**.
1. In **Data source**, select **Loki**.
1. In **Query**, enter the following query:

   ```
   {filename="/var/log/tns-app.log"} |= "error"
   ```

1. Click **Add**. Grafana displays the Annotations list, with your new annotation.
1. Click the **Go back** arrow to return to your dashboard.

The log lines returned by your query are now displayed as annotations in the graph.

Being able to combine data from multiple data sources in one graph allows you to correlate information from both Prometheus and Loki.

Annotations also work very well alongside alerts. In the next and final section, we will set up an alert for our app `grafana.news` and then trigger it. This will provide a quick introduction to our new Alerting platform.

{{< /tutorials/step >}}
{{< tutorials/step title="Set Up an Alert" >}}

Alerts allow you to identify problems in your system moments after they occur. By quickly identifying unintended changes in your system, you can minimize disruptions to your services.

Grafana's new alerting platform debuted with Grafana 8. A year later, with Grafana 9, it became the default alerting method. In this step, we will create a Grafana Managed Alert. Then we will trigger our new alert, which will send us an email notification.

>**The most basic alert consists of two parts**:
>
>1. A _Contact Point_ - A Contact point defines how Grafana delivers an alert. When the conditions of an _alert rule_ are met, Grafana notifies the contact points, or channels, configured for that alert. Some popular channels include email, webhooks, Slack notifications, and PagerDuty notifications. 
>1. An _Alert rule_ - An Alert rule defines one or more _conditions_ that Grafana regularly evaluates. When these evaluations meet the rule's criteria, the alert is triggered.

To begin, let's create a contact point that will send us an email. Then we'll write an alert rule that will monitor grafana.news for any spikes in traffic. We will then simulate a spike and watch as our Grafana Managed Alert triggers and sends us an email notification.

> Create a Contact Point for Grafana Managed Alerts

In this step, we'll set up a new Contact Point. This contact point will use the _email_ channel. Luckily, every Grafana Cloud instance comes with a default email contact point already added. Therefore, all we need to do is add a personal email to the configuration:

1. In Grafana's sidebar, hover your cursor over the **Alerting** (bell) icon and then click **Contact points**.
1. You should see an entry below the **Contact points** heading called `grafana-default-email`. Click the pencil icon on the right-hand side to edit this Contact point.
1. Under addresses, add an email address that you can access. This is how we will test our alert. 
1. Click the **Test** button and then the **Send test notification** button in the popup. Now check your email. You should see an email from Grafana with a subject like `[FIRING:1] (TestAlert Grafana)`
1. Return to Grafana and click **Save contact point**.

We have configured an email-based contact point to use a personal email. Now we can create an alert rule and link it to this new channel.

> Add an Alert Rule to Grafana

Now that Grafana knows how to notify us, it's time to set up an alert rule:

1. In Grafana's sidebar, hover the cursor over the **Alerting** (bell) icon and then click **Alert rules**.
1. Click **+ New Alert Rule**.
1. A new page will appear with four distinct sections. Let's review them one at a time. For **Section 1**, leave **Grafana Managed Alert** as the chosen alert type. Name the rule `fundamentals-test` and for **group** write `fundamentals`.
1. For **Section 2**, find the **query A** box. Choose your Prometheus datasource and enter the same query that we used in our earlier panel: `sum(rate(tns_request_duration_seconds_count[5m])) by(route)`. Press **Run query**. You should see some data in the graph.
1. Now scroll down to the **query B** box. For **Operation** choose `Classic condition`. [You can read more about classic and multi-dimensional conditions here](https://grafana.com/docs/grafana/latest/alerting/unified-alerting/alerting-rules/create-grafana-managed-rule/#single-and-multi-dimensional-rule). For conditions enter the following: `WHEN last() OF A IS ABOVE 0.2`
1. In **Section 3**, enter `30s` for the **Evaluate every** field. For the purposes of this tutorial, the evaluation interval is intentionally short. This makes it easier to test. In the **For** field, enter `0m`. This setting makes Grafana wait until an alert has fired for a given time before Grafana sends the notification.
1. In **Section 4**, you can add some sample text to your summary message. [Read more about message templating here](https://grafana.com/docs/grafana/latest/alerting/unified-alerting/message-templating/).
1. Click **Save and Exit** at the top of the page.
1. Because we only have one contact point (our email channel), our alerts will default to use it. As a system grows, admins can use the **Notification Policies** setting to organize and match alert rules to specific contact points.

> Trigger a Grafana Managed Alert

We have configured an alert rule and a contact point. Now lets see if we can trigger a Grafana Managed Alert by generating some traffic on our sample application.

1. Browse to [Grafana News](https://grafana.news).
1. Repeatedly click the vote button or refresh the page numerous times to generate a traffic spike.

Once the Prometheus query `sum(rate(tns_request_duration_seconds_count[5m])) by(route)` returns a value greater than `0.2` Grafana will trigger our alert. Go to your email inbox. A new Grafana alert notification with details and metadata should appear.

{{< /tutorials/step >}}
{{< tutorials/step title="Summary" >}}

In this tutorial, you learned about the fundamental features of Grafana. But this is just the beginning. Check out the links below to continue your learning journey with Grafana's LGTM stack.

> Learn more

- [Prometheus](https://grafana.com/docs/grafana/latest/features/datasources/prometheus/)
- [Loki](https://grafana.com/docs/grafana/latest/features/datasources/loki/)
- [Explore](https://grafana.com/docs/grafana/latest/features/explore/)
- [Alerting Overview](https://grafana.com/docs/grafana/latest/alerting/)
- [Alert rules](https://grafana.com/docs/grafana/latest/alerting/create-alerts/)
- [Contact Points](https://grafana.com/docs/grafana/latest/alerting/notifications/)

{{< /tutorials/step >}}
