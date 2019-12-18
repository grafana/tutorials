summary: Learn how to use D3.js in your panel plugins.
id: build-a-panel-plugin-with-d3
categories: Plugins
tags: beginner
status: Published
authors: Grafana Labs
Feedback Link: https://github.com/grafana/grafana

# Build a panel plugin with D3.js

## Introduction

Duration: 1

Panels are the building blocks of Grafana, and allow you to visualize data in different ways. This tutorial gives you a hands-on walkthrough of creating your own panel using [D3.js](https://d3js.org/).

For more information about panels, refer to the documentation on [Panels](https://grafana.com/docs/grafana/latest/guides/basic_concepts/#panel).

### What you'll build

In this tutorial, you'll build a simple, but complete bar graph panel.

### What you'll learn

- How to scaffold a panel plugin

### What you'll need

- Grafana version 6.4+
- NodeJS
- yarn

## Create a new plugin

Duration: 1

[[**import** [create-plugin](shared/create-plugin.md)]]

## Data-driven transformations using D3.js

D3.js is already bundled with Grafana, and you can access it by importing the `d3` package.

**SimplePanel.tsx**

```tsx
import { select } from 'd3';
```

- Update `SimplePanel`.

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
      .style('background-color', 'blue');
  }

  render() {
    return <div ref={element => (this.containerElement = element)}></div>;
  }
}
```

## Theme your panel

- Add a `GrafanaTheme` field to the `PanelProps`.

```tsx
import { PanelProps, GrafanaTheme } from '@grafana/data';
```

```tsx
interface Props extends PanelProps<SimpleOptions> {
  theme: GrafanaTheme;
}
```

- Rename `SimplePanel` to `PartialSimplePanel`.

```tsx
class PartialSimplePanel extends PureComponent<Props>
```

- Import `withTheme`.

```tsx
import { withTheme } from '@grafana/ui';
```

```tsx
export const SimplePanel = withTheme(PartialSimplePanel);
```

`withTheme` assigns the current theme to the `theme` property.

```tsx
const { width, height, theme } = this.props;
```

- Replace the current background color with a color from the theme.

```tsx
style('background-color', theme.colors.red)
```
