---
title: Build a panel plugin
summary: Learn at how to create a custom visualization for your dashboards.
id: build-a-panel-plugin
categories: ["plugins"]
tags: beginner
status: Published
authors: Grafana Labs
Feedback Link: https://github.com/grafana/tutorials/issues/new
weight: 50
---

{{< tutorials/step title="Introduction" >}}

> **IMPORTANT**: This tutorial is currently in **beta** and requires Grafana 7.0, which is scheduled for release in May. Some of the features mentioned may not work for earlier versions.

Panels are the building blocks of Grafana. They allow you to visualize data in different ways. While Grafana has several types of panels already built-in, you can also build your own panel, to add support other visualizations.

For more information about panels, refer to the documentation on [Panels](https://grafana.com/docs/grafana/latest/features/panels/panels/).

### Prerequisites

- Grafana version 7.0+
- NodeJS
- yarn

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
{{< tutorials/step title="Panel plugins" >}}

Since Grafana 6.x, panels are [ReactJS components](https://reactjs.org/docs/components-and-props.html). The simplest panel consists of a single function, the `render` function, which returns the content of the panel.

Prior to Grafana 6.0, plugins were written in [AngularJS](https://angular.io/). Even though we still support plugins written in AngularJS, we highly recommend that you write new plugins using ReactJS.

### The `render` function

The `render` function in `SimplePanel.tsx` determines how Grafana displays the panel in a dashboard.

### Panel properties

The [PanelProps](https://github.com/grafana/grafana/blob/747b546c260f9a448e2cb56319f796d0301f4bb9/packages/grafana-data/src/types/panel.ts#L27-L40) interface exposes runtime information about the panel, such as panel dimensions, and the current time range.

You can access the panel properties through `this.props`, as seen in your plugin.

**src/SimplePanel.tsx**

```js
const { options, data, width, height } = this.props;
```

### Development workflow

Next, you'll learn the basic workflow of making a change to your panel, building it, and reloading Grafana to reflect the change you made.

First, you need to add your panel to a dashboard:

1. Open Grafana in your browser.
1. Create a new dashboard, and select **Choose Visualization** in the **New Panel** view.
1. Select your panel from the list of visualizations.
1. Save the dashboard.

Now that you can view your panel, make a change to the panel plugin:

1. In the panel `render` function, change the fill color of the circle.
1. Run `yarn dev` to build the plugin.
1. In the browser, reload Grafana with the new changes.

{{< /tutorials/step >}}
{{< tutorials/step title="Add panel options" >}}

Sometimes you want to offer the users of your panel to configure the behavior of your plugin. By configuring  _panel options_ for your plugin, your panel will be able to accept user input.

In the previous step, you changed the fill color of the circle in the code. Let's change the code so that the plugin user can configure the color from the panel editor.

#### Add an option

Panel options are defined in a _panel options object_. `SimpleOptions` is an interface that describes the options object.

1. In `types.ts`, add a `CircleColor` type to hold the colors the users can choose from:

   ```
   type CircleColor = 'red' | 'green' | 'blue';
   ```

1. In the `SimpleOptions` interface, add a new option called `color`:

   ```
   color: CircleColor;
   ```

Here's the updated options definition:

**src/types.ts**

```ts
type SeriesSize = 'sm' | 'md' | 'lg';
type CircleColor = 'red' | 'green' | 'blue';

// interface defining panel options type
export interface SimpleOptions {
  text: string;
  showSeriesCount: boolean;
  seriesCountSize: SeriesSize;
  color: CircleColor;
}
```

#### Add an option control

To change the option from the panel editor, you need to bind the `color` option to an _option control_.

Grafana supports a range of option controls, such as text inputs, switches, and radio groups.

Let's create a radio control and bind it to the `color` option.

1. In `src/module.ts`, add the control at the end of the builder:

   ```ts
   .addRadio({
     path: 'color',
     name: 'Circle color',
     defaultValue: 'red',
     settings: {
       options: [
         {
           value: 'red',
           label: 'Red',
         },
         {
           value: 'green',
           label: 'Green',
         },
         {
           value: 'blue',
           label: 'Blue',
         },
       ],
     }
   });
   ```

   The `path` is used to bind the control to an option. You can bind a control to nested option by specifying the full path within a options object, for example `colors.background`.

Grafana builds an options editor for you and displays it in the panel editor sidebar in the **Display** section.

#### Use the new option

You're almost done. You've added a new option and a corresponding control to change the value. But the plugin isn't using the option yet. Let's change that.

1. To convert option value to the colors used by the current theme, add a `switch` statement right before the `return` statement in `SimplePanel.tsx`.

   **src/SimplePanel.tsx**

   ```ts
   let color;
   switch (options.color) {
     case 'red':
       color = theme.palette.redBase;
       break;
     case 'green':
       color = theme.palette.greenBase;
       break;
     case 'blue':
       color = theme.palette.blue95;
       break;
   }
   ```

1. Configure the circle to use the color.

   ```
   <g>
     <circle style={{ fill: color }} r={100} />
   </g>
   ```

Now, when you change the color in the panel editor, the fill color of the circle changes as well.

{{< /tutorials/step >}}
{{< tutorials/step title="Access time series data" >}}

Most panels visualize dynamic data from a Grafana data source. You've already seen that the `this.props` object provides useful data to your panel. It also contains the results from a data source query, which you can access through the `data` property:

```js
const { data } = this.props;
```

### Data frames

Data sources in Grafana return the results of a query in a format called _data frames_. A data frame is a _columnar data structure_, which means values are organized by fields, rather than by records.

Columnar data is a common occurrence in analytics, as it can greatly reduce the amount data read.

Here's an example of what a query result that contains a data frame can look like:

```json
{
  series: [
    {
      name: "My data frame",
      fields: [
        {
          name: "Time",
          type: "time",
          values: [1576578517623, 1576578518236, 1576578519714]
        },
        {
          name: "Value",
          type: "number",
          values: [0.0, 1.0, 2.0]
        }
      ],
      length: 3,
    }
  ]
}
```

The current panel implementation only displays the number of series returned. Try changing it to display the current value, i.e. the last value in a series.
{{% /tutorials/step %}}
{{< tutorials/step title="Publish your plugin" >}}

{{< tutorials/shared "publish-your-plugin" >}}

{{< /tutorials/step >}}
{{< tutorials/step title="Congratulations" >}}

Congratulations, you made it to the end of this tutorial!

{{< /tutorials/step >}}
