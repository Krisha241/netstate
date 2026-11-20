#!/usr/bin/env bash
probe() { # name url
  if ip netns exec client curl -s -m 2 "$2" >/dev/null; then echo "$1: REACHABLE"; else echo "$1: blocked"; fi
}
probe "client -> app:8080 " http://10.0.2.10:8080
probe "client -> mgmt:9000" http://10.0.3.10:9000
