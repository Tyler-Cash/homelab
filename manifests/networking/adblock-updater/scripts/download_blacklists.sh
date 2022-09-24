#!/bin/bash
sleep 30000
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

# https://firebog.net/
## suspicious domains
download "https://hosts-file.net/grm.txt"
download "https://reddestdream.github.io/Projects/MinimalHosts/etc/MinimalHostsBlocker/minimalhosts"
download "https://raw.githubusercontent.com/StevenBlack/hosts/master/data/KADhosts/hosts"
download "https://raw.githubusercontent.com/StevenBlack/hosts/master/data/add.Spam/hosts"
download "https://v.firebog.net/hosts/static/w3kbl.txt"
## advertising domains
download "https://adaway.org/hosts.txt"
download "https://v.firebog.net/hosts/AdguardDNS.txt"
download "https://raw.githubusercontent.com/anudeepND/blacklist/master/adservers.txt"
download "https://s3.amazonaws.com/lists.disconnect.me/simple_ad.txt"
download "https://hosts-file.net/ad_servers.txt"
download "https://v.firebog.net/hosts/Easylist.txt"
download "https://pgl.yoyo.org/adservers/serverlist.php?hostformat=hosts;showintro=0"
download "https://raw.githubusercontent.com/StevenBlack/hosts/master/data/UncheckyAds/hosts"
download "https://www.squidblacklist.org/downloads/dg-ads.acl"
## tracking & telemetry domains
download "https://v.firebog.net/hosts/Easyprivacy.txt"
download "https://v.firebog.net/hosts/Prigent-Ads.txt"
download "https://gitlab.com/quidsup/notrack-blocklists/raw/master/notrack-blocklist.txt"
download "https://raw.githubusercontent.com/StevenBlack/hosts/master/data/add.2o7Net/hosts"
download "https://raw.githubusercontent.com/crazy-max/WindowsSpyBlocker/master/data/hosts/spy.txt"
## malicious domains
download "https://s3.amazonaws.com/lists.disconnect.me/simple_malvertising.txt"
download "https://mirror1.malwaredomains.com/files/justdomains"
download "https://hosts-file.net/exp.txt"
download "https://hosts-file.net/emd.txt"
download "https://hosts-file.net/psh.txt"
download "https://mirror.cedia.org.ec/malwaredomains/immortal_domains.txt"
download "https://www.malwaredomainlist.com/hostslist/hosts.txt"
download "https://bitbucket.org/ethanr/dns-blacklists/raw/8575c9f96e5b4a1308f2f12394abd86d0927a4a0/bad_lists/Mandiant_APT1_Report_Appendix_D.txt"
download "https://v.firebog.net/hosts/Prigent-Malware.txt"
download "https://v.firebog.net/hosts/Prigent-Phishing.txt"
download "https://phishing.army/download/phishing_army_blocklist_extended.txt"
download "https://gitlab.com/quidsup/notrack-blocklists/raw/master/notrack-malware.txt"
download "https://ransomwaretracker.abuse.ch/downloads/RW_DOMBL.txt"
download "https://ransomwaretracker.abuse.ch/downloads/CW_C2_DOMBL.txt"
download "https://ransomwaretracker.abuse.ch/downloads/LY_C2_DOMBL.txt"
download "https://ransomwaretracker.abuse.ch/downloads/TC_C2_DOMBL.txt"
download "https://ransomwaretracker.abuse.ch/downloads/TL_C2_DOMBL.txt"
download "https://zeustracker.abuse.ch/blocklist.php?download=domainblocklist"
download "https://v.firebog.net/hosts/Shalla-mal.txt"
download "https://raw.githubusercontent.com/StevenBlack/hosts/master/data/add.Risk/hosts"
download "https://www.squidblacklist.org/downloads/dg-malicious.acl"

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