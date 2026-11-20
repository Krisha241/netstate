#!/usr/bin/env bash
pkill -f "http.server" || true
for ns in client app mgmt router; do ip netns del $ns 2>/dev/null || true; done
echo "Lab is down."
