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


download "https://adaway.org/hosts.txt"
download "https://v.firebog.net/hosts/AdguardDNS.txt"
download "https://v.firebog.net/hosts/Admiral.txt"
download "https://raw.githubusercontent.com/anudeepND/blacklist/master/adservers.txt"
download "https://s3.amazonaws.com/lists.disconnect.me/simple_ad.txt"
download "https://v.firebog.net/hosts/Easylist.txt"
download "https://pgl.yoyo.org/adservers/serverlist.php?hostformat=hosts&showintro=0&mimetype=plaintext"
download "https://raw.githubusercontent.com/FadeMind/hosts.extras/master/UncheckyAds/hosts"
download "https://raw.githubusercontent.com/bigdargon/hostsVN/master/hosts"
download "https://raw.githubusercontent.com/DandelionSprout/adfilt/master/Alternate%20versions%20Anti-Malware%20List/AntiMalwareHosts.txt"
download "https://osint.digitalside.it/Threat-Intel/lists/latestdomains.txt"
download "https://s3.amazonaws.com/lists.disconnect.me/simple_malvertising.txt"
download "https://v.firebog.net/hosts/Prigent-Crypto.txt"
download "https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.Risk/hosts"
download "https://bitbucket.org/ethanr/dns-blacklists/raw/8575c9f96e5b4a1308f2f12394abd86d0927a4a0/bad_lists/Mandiant_APT1_Report_Appendix_D.txt"
download "https://phishing.army/download/phishing_army_blocklist_extended.txt"
download "https://gitlab.com/quidsup/notrack-blocklists/raw/master/notrack-malware.txt"
download "https://v.firebog.net/hosts/RPiList-Malware.txt"
download "https://v.firebog.net/hosts/RPiList-Phishing.txt"
download "https://raw.githubusercontent.com/Spam404/lists/master/main-blacklist.txt"
download "https://raw.githubusercontent.com/AssoEchap/stalkerware-indicators/master/generated/hosts"
download "https://urlhaus.abuse.ch/downloads/hostfile/"
download "https://raw.githubusercontent.com/PolishFiltersTeam/KADhosts/master/KADhosts.txt"
download "https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.Spam/hosts"
download "https://v.firebog.net/hosts/static/w3kbl.txt"
download "https://raw.githubusercontent.com/DandelionSprout/adfilt/master/Alternate%20versions%20Anti-Malware%20List/AntiMalwareHosts.txt"
download "https://osint.digitalside.it/Threat-Intel/lists/latestdomains.txt"
download "https://s3.amazonaws.com/lists.disconnect.me/simple_malvertising.txt"
download "https://v.firebog.net/hosts/Prigent-Crypto.txt"
download "https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.Risk/hosts"
download "https://bitbucket.org/ethanr/dns-blacklists/raw/8575c9f96e5b4a1308f2f12394abd86d0927a4a0/bad_lists/Mandiant_APT1_Report_Appendix_D.txt"
download "https://phishing.army/download/phishing_army_blocklist_extended.txt"
download "https://gitlab.com/quidsup/notrack-blocklists/raw/master/notrack-malware.txt"
download "https://v.firebog.net/hosts/RPiList-Malware.txt"
download "https://v.firebog.net/hosts/RPiList-Phishing.txt"
download "https://raw.githubusercontent.com/Spam404/lists/master/main-blacklist.txt"
download "https://raw.githubusercontent.com/AssoEchap/stalkerware-indicators/master/generated/hosts"
download "https://urlhaus.abuse.ch/downloads/hostfile/"

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

mv "${HOSTS_FILE}" "${destination}"

curl --location --max-redirs 3 \
    --max-time 600 --retry 3 --retry-delay 0 --retry-max-time 1000 \
    "https://github.com/Tyler-Cash/homelab/raw/master/kubernetes/helm/networking/coredns/manifests/scripts/lancache.txt" >> "/blacklist/hosts.blacklist"
