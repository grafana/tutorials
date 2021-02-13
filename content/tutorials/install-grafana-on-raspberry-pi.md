---
title: Install Grafana on Raspberry Pi
summary: Get Grafana set up on your Raspberry Pi.
id: install-grafana-on-raspberry-pi
categories: ["administration"]
tags: beginner
authors: Grafana Labs
Feedback Link: https://github.com/grafana/tutorials/issues/new
---

{{< tutorials/step title="Introduction" >}}

The Raspberry Pi is a tiny, affordable, yet capable computer that can run a range of different applications. Even Grafana!

Many people are running Grafana on Raspberry Pi as a way to monitor their home, for things like indoor temperature, humidity, or energy usage.

In this tutorial, you'll:

- Set up a headless Raspberry Pi using Raspberry Pi OS (formerly Raspian).
- Install Grafana on your Raspberry Pi.

### Prerequisites

- Raspberry Pi
- SD card

{{< /tutorials/step >}}
{{< tutorials/step title="Set up your Raspberry Pi" >}}

Before we can install Grafana, you first need to be configure your Raspberry Pi.

For this tutorial, you'll configure your Raspberry Pi to be _headless_. This means you don't need to connect a monitor, keyboard, or mouse to your Raspberry Pi. All configuration is done from your regular computer.

Before we get started, you need to download the Raspberry Pi Imager. It's available for Linux, macOS, and Windows.

- [Raspberry Pi Imager](https://www.raspberrypi.org/software/)

#### Copy image to the SD card

Once you've installed the Raspberry Pi Imager, you can use it to write  image to your SD card.

1. Insert an empty SD card into your computer.
2. Install Raspberry Pi Imager.
3. Start Raspberry Pi Imager.
4. For "Operating System" choose the category "Raspberry Pi OS (other)" and select "Raspberry Pi OS Lite (32-Bit)".
5. Click "Write" and wait for the operation to finish.
3. Eject the SD card from your computer, and insert it again.

While you _could_ fire up the Raspberry Pi now, we don't yet have any way of accessing it.

1. Create an empty file called `ssh` in the boot directory. This enables SSH so that you can log in remotely.

   The next step is only required if you want the Raspberry Pi to connect to your wireless network. Otherwise, connect the it to your network by using a network cable.

1. **(Optional)** Create a file called `wpa_supplicant.conf` in the boot directory:

   ```
   ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
   update_config=1
   country=<Insert 2 letter ISO 3166-1 country code here>

   network={
    ssid="<Name of your wireless LAN>"
    psk="<Password for your wireless LAN>"
   }
   ```

All the necessary files are now on the SD card. Let's start up the Raspberry Pi.

1. Eject the SD card and insert it into the SD card slot on the Raspberry Pi.
1. Connect the power cable and make sure the LED lights are on.
1. Find the IP address of the Raspberry Pi. Usually you can find the address in the control panel for your WiFi router.

#### Connect remotely via SSH

1. Open up your terminal and enter the following command:
   ```
   ssh pi@<ip address>
   ```
1. SSH warns you that the authenticity of the host can't be established. Type "yes" to continue connecting.
1. When asked for a password, enter the default password: `raspberry`.
1. Once you're logged in, change the default password:
   ```
   passwd
   ```

Congratulations! You've now got a tiny Linux machine running that you can hide in a closet and access from your normal workstation.

{{< /tutorials/step >}}
{{< tutorials/step title="Install Grafana" >}}

Now that you've got the Raspberry Pi up and running, the next step is to install Grafana.

1. Add the APT key used to authenticate packages:
   ```
   wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
   ```

1. Add the Grafana APT repository:
   ```
   echo "deb https://packages.grafana.com/oss/deb stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list
   ```

1. Install Grafana:
   ```
   sudo apt-get update
   sudo apt-get install -y grafana
   ```

Grafana is now installed, but not yet running. To make sure Grafana starts up even if the Raspberry Pi is restarted, we need to enable and start the Grafana Systemctl service.

1. Enable the Grafana server:
   ```
   sudo /bin/systemctl enable grafana-server
   ```

1. Start the Grafana server:
   ```
   sudo /bin/systemctl start grafana-server
   ```
   Grafana is now running on the machine and is accessible from any device on the local network.

1. Open a browser and go to `http://<ip address>:3000`, where the IP address is the address that you used to connect to the Raspberry Pi earlier. You're greeted with the Grafana login page.
1. Log in to Grafana with the default username `admin`, and the default password `admin`.
1. Change the password for the admin user when asked.

Congratulations! Grafana is now running on your Raspberry Pi. If the Raspberry Pi is ever restarted or turned off, Grafana will start up whenever the machine regains power.

{{< /tutorials/step >}}
{{< tutorials/step title="Congratulations" >}}

Congratulations, you've made it to the end of this tutorial!

### Learn more

- [Raspberry Pi Documentation](https://www.raspberrypi.org/documentation/)


{{< /tutorials/step >}}
