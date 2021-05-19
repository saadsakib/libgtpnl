#!/bin/bash

## Configuration

# Address given to GTP devices instead of creating lo
# PC 1

NS1=100

NS1_NAME="ns-gtp-$NS1"

TEID_OUT="100"
TEID_IN="200"

GTP_DEV1="gtp-$NS1"

NS1_GTP_IP="192.168.40.$TEID_OUT"
NS1_GTP_CIDR="$NS1_GTP_IP/32"
NS2_GTP_IP="192.168.40.$TEID_IN"
NS2_GTP_CIDR="$NS2_GTP_IP/32"

NS2_VETH_IP="192.168.1.103"

## Logger
function log {
  echo -e "[INFO] $1"
  sleep 1
}

function print_test_msg {
  echo ""
  echo "You can do for e.g.:"
  echo "In PC1, ping $NS2_GTP_IP"
  echo "In PC2, ping $NS1_GTP_IP"
  echo ""
  echo "Using tshark you will see ICMP pckets encapsulated in GTP"
  echo ""
}

## Create gtp ifaces
function start {
  log "create gtp devices (run in bg mode)"
  ./gtp-link add $GTP_DEV1 &

  log "configure address of gtp devices"
  ip addr add $NS1_GTP_CIDR dev $GTP_DEV1

  log "configure mtu of gtp devices"
  ifconfig $GTP_DEV1 mtu 1500 up
  
  log "create gtp tunnels"
  ./gtp-tunnel add $GTP_DEV1 v1 $TEID_IN $TEID_OUT $NS2_GTP_IP $NS2_VETH_IP
  log "$(./gtp-tunnel list)"

  log "configure routes using gtp devices"
  ip route add $NS2_GTP_CIDR dev $GTP_DEV1

  print_test_msg
}

## Destroy everything
function stop {
  log "remove gtp devices"
  ./gtp-link del $GTP_DEV1
}

if [ "$1" = "start" ]; then
  start
elif [ "$1" = "stop" ]; then
  stop
else
  echo "This is an example to create gtp tunnel and send some traffic"
  echo ""
  echo "  Usage: $0 <start|stop>"
  echo ""
fi

