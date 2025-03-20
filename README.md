# pfsense-wg-rotate
A simple shell script to rotate the [WireGuard](https://docs.netgate.com/pfsense/en/latest/vpn/wireguard/index.html) tunnel listen ports on a [pfSense](https://pfsense.org) firewall.

# Summary
I was constantly running in to issues with my ISP in which they would block wireguard traffic after an intermittant period, and the only workaround I was able to find was to update the listen port on the primary tunnel. There is no clean programmatic way to do this within the pfSense UI, so here we are.

When called, the script simply generates a random port number, updates the `config.xml` file, and uses PHP Shell to restart the WireGuard service.

# Setup
- This script assumes the  following:
  1. You already have a working WireGuard tunnel configured on your pfSense firewall.
  2. The firewall rule you are using to allow ingress of WireGuard traffic on WAN port uses a [Port Alias](https://docs.netgate.com/pfsense/en/latest/firewall/aliases.html#port-aliases) rather than mapping the WireGuard tunnel's listen ports directly.
- Download the script and open in your text editor of choice.
- Configure the following variables:
  - `config_file` - The full path to the config.xml file.
  - `port_start` - The beginning of the random port range.
  - `port_end` - The end of the random port range.
  - `port_alias` - The name of the port alias you are using to map the WireGuard listen port to the WAN interface ingress rules.
  - `tunnel_id` - The interface name for your wireguard tunnel. (most likely something like `tun_wg0`)
- Save the file and ensure it has the correct permissions with `sudo chmod +x ./wireguard_rotate.sh`
- Move the file to a save place on your pfSense system. I recommend `/usr/local/bin/`
- Configure your WAN interface such that the ports specified in the port range are open. This is **required** for WireGuard to function (I recommend creating a port alias for convenience).
- Schedule the script to run at your preferred interval using `cron`. This can be done from the cli via ssh, however you may also install the cron package from within the pfSense package manager instead.

# Important
- This script has only been tested on pfSense CE v 2.7.2, however it should function similarly on the commercial builds.
- Presently, the script assumes you are only using one wireguard tunnel.
- The script **does** create a full backup of the previous `config.xml` file and places it in the same directory as a precaution.
- Regarding the port range - I strongly recommend keeping this as small as you feel is practical because these ports must be open on your WAN interface in order for WireGuard to function. I have no plans to extend functionality to automatically open/close ports following the listen port reassignment. Mostly because PHP Shell is a headache - but it is definitely possible for anyone adequately ambitious.

# Disclaimer
Configuration of WireGuard via the CLI is explicitly **not** supported or recommended by Netgate. This script directly modifies the `config.xml` file which can be dangerous. As such, these project files are provided "as-is" without any warranty of any kind, either express or implied. Use of this script is at your own risk.

Neither Netgate, nor the author of this project, nor any contributors shall be held liable for any direct, indirect, incidental, special, consequential, or punitive damages arising from its use. This script is not officially supported by Netgate, and no support services are provided by the author. If you experience any issues or adverse effects as a result of using this script, you do so entirely at your own risk with no recourse against the author or associated parties.

**TL;DR** Make backups, thoroughly test & be careful.

# TODO:
- Add support for port rotation with more than one WireGuard tunnels.
  - This is a super low priority tbh. Don't hold your breath.
