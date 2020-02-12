summary: Learn how to use D3.js in your panel plugins.
id: build-a-panel-plugin-with-d3
categories: Plugins
tags: beginner
status: Published
authors: Grafana Labs
Feedback Link: https://github.com/grafana/tutorials/issues/new

# Build a panel plugin with D3.js

## Introduction

Duration: 1

Panels are the building blocks of Grafana, and allow you to visualize data in different ways. This tutorial gives you a hands-on walkthrough of creating your own panel using [D3.js](https://d3js.org/).

For more information about panels, refer to the documentation on [Panels](https://grafana.com/docs/grafana/latest/guides/basic_concepts/#panel).

### What you'll build

In this tutorial, you'll build a simple, but complete bar graph panel.

### What you'll learn

- How to use D3.js to build a panel using data-driven transformations.

### What you'll need

- Grafana version 7.0+
- NodeJS
- yarn

## Set up your environment

Duration: 1

[[**import** [set-up-environment](shared/set-up-environment.md)]]

## Create a new plugin

Duration: 1

[[**import** [create-plugin](shared/create-plugin.md)]]

## Data-driven transformations

[D3.js](https://d3js.org/) is a JavaScript library for manipulating documents based on data. It lets you transform arbitrary data into HTML, and is commonly used for creating visualizations.

In fact, D3.js is already bundled with Grafana, and you can access it by importing the `d3` package.

**SimplePanel.tsx**

```tsx
import { select } from 'd3';
```

- Create a function called `draw`, where we'll construct our chart, and call it in `componentDidMount`, and `componentDidUpdate`. By doing this, the `render` function returns a prebuilt chart to avoid rebuilding the chart on every call to `render`.

```tsx
class SimplePanel extends PureComponent<Props> {
  containerElement: any;

  componentDidMount() {
    this.draw();
  }

  componentDidUpdate() {
    this.draw();
  }

  draw() {
    const { width, height } = this.props;

    const chart = select(this.containerElement)
      .html('')
      .attr('width', width)
      .attr('height', height)
      .text('Hello, world!');
  }

  render() {
    return <div ref={element => (this.containerElement = element)}></div>;
  }
}
```

Notice that, in the `render` function, the `ref` attribute is used to replace the `div` with `containerElement`.

- Run `yarn dev`, and reload Grafana to reflect the changes you've made.

When you add the panel to your dashboard, it will have the text 'Hello, world!' written in it.

### Build a chart from data

You've seen how to use D3.js to create a container element with some hard-coded text in it. Next, you'll build the graph from actual data.

- Update the `draw` function with the following code:

```tsx
draw() {
  const { width, height } = this.props;

  const data = [4, 8, 15, 16, 23, 42];

  const maxValue = Math.max.apply(Math, data.map(o => o));

  const chart = select(this.containerElement)
    .html('')
    .attr('width', width)
    .attr('height', height);

  chart
    .selectAll('div')
    .data(data)
    .enter()
    .append('div')
    .style('height', height / data.length + 'px')
    .style('width', d => (d * width) / maxValue + 'px')
    .style('background-color', 'blue');
}
```

- Run `yarn dev`, and reload Grafana to see a bar chart that dynamically resizes to fit the panel.

Congratulations, you've created a dynamic bar chart! Still, you've only touched the surface of what's possible with D3. To learn more, check out the [D3 Gallery](https://github.com/d3/d3/wiki/Gallery).

## Theme your panel

To provide your users with a consistent look-and-feel, you'll want to use the same colors as the built-in panels.

In this step, you'll learn how to use the colors from the current theme.

- In `SimplePanel.tsx`, add a `GrafanaTheme` property to the `PanelProps`.

```tsx
interface Props extends PanelProps<SimpleOptions> {
  theme: GrafanaTheme;
}
```

`GrafanaTheme` is available from the `grafana/data` package:

```tsx
import { PanelProps, GrafanaTheme } from '@grafana/data';
```

The `theme` property is not set by default, so you need to use the `withTheme` to provide the current theme to the panel.

- Rename `SimplePanel` to `PartialSimplePanel`.

```tsx
class PartialSimplePanel extends PureComponent<Props>
```

- Import `withTheme` from `grafana/ui`.

```tsx
import { withTheme } from '@grafana/ui';
```

- Export the `SimplePanel`, now complete with a theme. `withTheme` assigns the current theme to the `theme` property.

```tsx
export const SimplePanel = withTheme(PartialSimplePanel);
```

The theme property is now available from within the component.

```tsx
const { width, height, theme } = this.props;
```

- Replace the current background color with a color from the theme.

```tsx
style('background-color', theme.colors.red)
```

## Complete example

```tsx
import React, { PureComponent } from 'react';
import { withTheme } from '@grafana/ui';
import { PanelProps, GrafanaTheme } from '@grafana/data';

import { SimpleOptions } from 'types';
import { select } from 'd3';

interface Props extends PanelProps<SimpleOptions> {
  theme: GrafanaTheme;
}

class PartialSimplePanel extends PureComponent<Props> {
  containerElement: any;

  componentDidMount() {
    this.draw();
  }

  componentDidUpdate() {
    this.draw();
  }

  draw() {
    const { width, height, theme } = this.props;

    const data = [4, 8, 15, 16, 23, 42];

    const maxValue = Math.max.apply(
      Math,
      data.map(o => o)
    );

    const chart = select(this.containerElement)
      .html('')
      .attr('width', width)
      .attr('height', height);

    chart
      .selectAll('div')
      .data(data)
      .enter()
      .append('div')
      .style('height', height / data.length + 'px')
      .style('width', d => (d * width) / maxValue + 'px')
      .style('background-color', theme.colors.red);
  }

  render() {
    return <div ref={element => (this.containerElement = element)}></div>;
  }
}

export const SimplePanel = withTheme(PartialSimplePanel);
```

## Congratulations

Congratulations, you made it to the end of this tutorial!
