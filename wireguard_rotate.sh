#!/bin/sh
#
# Rotate the listen port on a WireGuard tunnel
# https://github.com/sudonem/pfsense-wg-rotate
# Date: 2025-03-20
# TODO: Support performing rotation on multiple tunnels (tbd)

# Fail fast & loud
set -eu

# Full path to the config file to modify
# This is /conf/config.xml by default.
# config_file=/conf/config.xml
config_file="[CONFIG FILE PATH]"

# Specify the name of the firewall port alias that will be
# assigned to the WireGuard tunnel so that that the allowed
# WAN ports may also be updated dynamically
port_alias="[WIREGUARD PORT ALIAS]"

# Specify the name of the WireGuard tunnel interface
# that is to be rotated. This is most likely "tun_wg0"
tunnel_id="[TUNNEL INTERFACE NAME]"

# Define range of random listen ports
range_start="51820"
range_end="51830"

# Backup config.xml file
cp "$config_file" "$config_file.bak"

# Identify current port and the matching config file line number
current_port="$(grep $tunnel_id -A5 $config_file | grep '<listenport>' | sed 's/[[:space:]]//g' | sed -E 's#</?listenport>##g')"

port_line="$(grep -n $tunnel_id -A5 $config_file | grep '<listenport>' | sed 's/-//' | awk '{print $1}')"

alias_line="$(grep -n '<alias>' -A5 $config_file | grep "$port_alias" -A3 | grep '<address>' | sed 's/-//' | awk '{print $1}')"

# Generate random port number & confirm its different than current port
# Yes there are better ways to do this, but the pfSense cli offers
# very limited options - so here we are.
generate=1
while [ "$generate" -eq 1 ]; do
  new_port="$(jot -r 1 $range_start $range_end)"
  if [ "$new_port" -ne "$current_port" ]; then
    generate=0
  fi
done

# Replace wireguard tunnel listen port with new port number
sed -i '' "${port_line}s/<listenport>.*<\/listenport>/<listenport>${new_port}<\/listenport>/" "$config_file"
sed -i '' "${alias_line}s/<address>.*<\/address>/<address>${new_port}<\/address>/" "$config_file"
logger -s -t wireguard "Listen port for $tunnel_id updated from $current_port to $new_port."

# Apply changes made to config.xml
/usr/local/sbin/pfSsh.php playback upgradeconfig

# Restart wireguard service via php shell
/usr/local/sbin/pfSsh.php playback svc restart WireGuard
logger -s -t wireguard "Restarting wireguard tunnels."
