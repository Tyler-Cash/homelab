#!/bin/bash
# Taken from https://news.ycombinator.com/item?id=21238213
HOSTS_FILE="/tmp/hosts.blacklist"
destination="/blacklist"
HOSTS_FILES="$HOSTS_FILE.d"

mkdir -p "${HOSTS_FILES}"
download() {
echo "download($1)"
curl \
    --location --max-redirs 3 \
    --max-time 20 --retry 3 --retry-delay 0 --retry-max-time 60 \
    "$1" > "$(mktemp "${HOSTS_FILES}"/XXXXXX)"
}

download "https://hosts.oisd.nl/"

cat "${HOSTS_FILES}"/* | \
sed \
-e 's/0.0.0.0//g' \
-e 's/127.0.0.1//g' \
-e '/255.255.255.255/d' \
-e '/::/d' \
-e '/#/d' \
-e 's/ //g' \
-e 's/  //g' \
-e '/^$/d' \
-e 's/^/0.0.0.0 /g' | \
awk '!a[$0]++' | \
sed \
-e '/tylercash.dev/d' > "${HOSTS_FILE}"

rm -rf "${HOSTS_FILES}"

mv "${HOSTS_FILE}" "${destination}"