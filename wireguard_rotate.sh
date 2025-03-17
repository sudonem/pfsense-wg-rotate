#!/bin/sh
#
# Rotate the listenprot on a WireGuard tunnel
# https://github.com/sudonem/pfsense-wg-rotate
# Date: 2025-03-17

# Fail fast & loud
set -eu

# Full path to the config file to modify
# This is /conf/config.xml by default, but you should
# test this script on your own system using a different file.
# config_file=/conf/config.xml
config_file=[config file]

# Define port range to cycle through
# IMPORTANT: Because these ports must be open on your WAN interface
# I strongly advise keeping this range as small as possible
port_start="51820"
port_end="51830"

# Generate new port number
new_port="$(jot -r 1 $port_start $port_end)"

# Find previous listen port
current_port="$(grep '<listenport>' $config_file | sed 's/[[:space:]]//g' | sed -E 's#</?listenport>##g')"

# Replace wireguard tunnel listen port with new port number
sed -E -i .bak "s/<listenport>[0-9]{5}/<listenport>$new_port/g" "$config_file"
logger -s -t wireguard "Tunnel listen port updated from $current_port to $new_port."

# Restart wireguard service via php shell
pfSsh.php playback svc restart WireGuard
logger -s -t wireguard "Restarting wireguard tunnels."
