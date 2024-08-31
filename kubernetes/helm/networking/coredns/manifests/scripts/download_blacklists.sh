#!/bin/bash
set -e
set -v
# Taken from https://news.ycombinator.com/item?id=21238213
HOSTS_FILE="/tmp/hosts.blacklist"
HOSTS_FILES="$HOSTS_FILE.d"
destination="/blacklist"
mkdir -p "${HOSTS_FILES}"
download() {
echo "download($1)"
curl \
    --location --max-redirs 3 \
    --max-time 600 --retry 3 --retry-delay 0 --retry-max-time 1000 \
    "$1" > "$(mktemp "${HOSTS_FILES}"/XXXXXX)"
}


download "https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/hosts/pro.txt"


cat "${HOSTS_FILES}"/* > "${HOSTS_FILE}"

cat "${HOSTS_FILE}"

mv "${HOSTS_FILE}" "${destination}"

curl --location --max-redirs 3 \
    --max-time 600 --retry 3 --retry-delay 0 --retry-max-time 1000 \
    "https://github.com/Tyler-Cash/homelab/raw/master/kubernetes/helm/networking/coredns/manifests/scripts/lancache.txt" >> "/blacklist/hosts.blacklist"

