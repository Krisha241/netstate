#!/usr/bin/env bash
set -euo pipefail

for ns in client app mgmt router; do ip netns add $ns; done

# link <ns_a> <if_a> <ip_a> <ns_b> <if_b> <ip_b>
link() {
  ip link add "$2" netns "$1" type veth peer name "$5" netns "$4"
  ip -n "$1" addr add "$3" dev "$2"; ip -n "$1" link set "$2" up
  ip -n "$4" addr add "$6" dev "$5"; ip -n "$4" link set "$5" up
}
link router r-client 10.0.1.1/24 client c0 10.0.1.10/24
link router r-app    10.0.2.1/24 app    a0 10.0.2.10/24
link router r-mgmt   10.0.3.1/24 mgmt   m0 10.0.3.10/24

for ns in client app mgmt; do ip -n $ns link set lo up; done
ip -n client route add default via 10.0.1.1
ip -n app    route add default via 10.0.2.1
ip -n mgmt   route add default via 10.0.3.1
ip netns exec router sysctl -qw net.ipv4.ip_forward=1

# Intended policy: client -> app:8080 only
ip netns exec router nft -f - <<'NFT'
table inet filter {
  chain forward {
    type filter hook forward priority 0; policy drop;
    ct state established,related accept
    iifname "r-client" oifname "r-app" tcp dport 8080 accept
  }
}
NFT

ip netns exec app  python3 -m http.server 8080 --bind 10.0.2.10 >/dev/null 2>&1 &
ip netns exec mgmt python3 -m http.server 9000 --bind 10.0.3.10 >/dev/null 2>&1 &
echo "Lab is up."
