# pfsense-wg-rotate
A simple shell script to randomly rotate the [WireGuard](https://docs.netgate.com/pfsense/en/latest/vpn/wireguard/index.html) tunnel listen ports on a [pfSense](https://pfsense.org) firewall.

# Summary
I was constantly running in to issues with my ISP in which they would block wireguard traffic after an intermittant period, and the only workaround I was able to find was to update the listen port on the primary tunnel. There is no clean programmatic way to do this within the pfSense web UI, so here we are.

When called, the script generates a random port number, updates the `config.xml` file, and uses PHP Shell to apply the changes and restart the WireGuard service.

# Prerequisites
  - You already have a working WireGuard tunnel configured on your pfSense firewall.
  - You must enable [SSH](https://docs.netgate.com/pfsense/en/latest/recipes/ssh-access.html) access on your pfSense device for at least one user.
  - That user will need sudo permissions - which requires the  [Sudo Package](https://docs.netgate.com/pfsense/en/latest/packages/sudo.html).

# Setup
- Log in to your pfSense device via [SSH](https://docs.netgate.com/pfsense/en/latest/recipes/ssh-access.html)
- Download the script using curl (wget is not avialable on pfSense):
```sh
curl -O https://raw.githubusercontent.com/sudonem/pfsense-wg-rotate/refs/heads/main/wireguard_rotate.sh
```
  - Open the script for editing using [vi](https://www.thegeekdiary.com/basic-vi-commands-cheat-sheet/).
    - Note: `vi` is the only text editor installed on the pfSense device by default.
- Configure/populate the following values:
  - `config_file` - The full path to the config.xml file.
    - This is `/conf/config.xml` by default and probably what you need.
  - `port_start` - The beginning of the random port range.
  - `port_end` - The end of the random port range.
  - `tunnel_id` - The interface name for your wireguard tunnel. (most likely something like `tun_wg0`)
- Save the file and ensure it has the correct permissions with:
```sh
sudo chmod +x ./wireguard_rotate.sh
```
- Move the file to a safe place on your pfSense system. I recommend `/usr/local/bin/`
- Configure your WAN interface such that the ports specified in the port range are open. This is **required** for WireGuard to function (I recommend creating a port alias for convenience).
- Schedule the script to run at your preferred interval using `cron`.
  - This can be done from the cli via ssh, however you may also install the cron package from within the pfSense package manager instead.

# Notes
- This script has only been tested on pfSense CE v 2.7.2, however it should function similarly on the commercial builds.
- Presently, the script only allows for port rotation with a single WireGuard tunnel.
- Each time it is run, the script **does** create a full backup of the current `config.xml` file and places it in the same directory as a precaution, but you should probably make your own backup for safe keeping.
- When run, the script adds log entries which are visible from the pfSense UI via **Status > System Logs > System > General** under the **wireguard** process.

# Disclaimer
Configuration of WireGuard via the CLI is explicitly **not** supported or recommended by Netgate. This script directly modifies the `config.xml` file which can be dangerous. As such, these project files are provided "as-is" without any warranty of any kind, either express or implied. Use of this script is at your own risk.

Neither Netgate, nor the author of this project, nor any contributors shall be held liable for any direct, indirect, incidental, special, consequential, or punitive damages arising from its use. This script is not officially supported by Netgate, and no support services are provided by the author. If you experience any issues or adverse effects as a result of using this script, you do so entirely at your own risk with no recourse against the author or associated parties.

**TL;DR** Make backups, thoroughly test & be careful.

# TODO:
- Add support for port rotation with more than one WireGuard tunnels.
  - This is a super low priority tbh. Don't hold your breath.
