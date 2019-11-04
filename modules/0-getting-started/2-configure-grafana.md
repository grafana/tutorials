# Configure Grafana for plugin development

There are three ways Grafana can find your plugin:

1. If you've already set up Grafana for development, you can place your plugin in `data/plugins` in the root directory of the project.
1. If you've installed Grafana, the plugin path is defined in the Grafana config file.
1. Define the plugin path in the Grafana config file.

> **Note:** If you're on a Linux system, consider creating a symlink from your preferred project directory to the plugin directory.
