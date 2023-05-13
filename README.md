<div align="center">

<img src="https://camo.githubusercontent.com/5b298bf6b0596795602bd771c5bddbb963e83e0f/68747470733a2f2f692e696d6775722e636f6d2f7031527a586a512e706e67" align="center" width="144px" height="144px"/>

### My home infrastructure repository :octocat:

</div>

<div align="center">

[![Kubernetes](https://img.shields.io/badge/v1.25-blue?style=for-the-badge&logo=kubernetes&logoColor=white)](https://k3s.io/)

</div>

## ⚠️ Disclaimer

Please don't judge the commit history and some janky components too harshly, I'm just doing this for fun in my spare time with the majority of these services not exposed to the Internet.

## ⛵ Overview

This is a repository for my Kubernetes cluster. ([Shamelessly stolen README](https://github.com/onedr0p/home-ops)) I have all of my ArgoCD applications here to deploy the infrastructure and services I use at home.

### Installation

My K8S cluster is deployed with the [Ansible](https://www.ansible.com/) script in the Ansible folder. This sets up a [K3S](https://k3s.io/) flavoured K8S cluster.

Once the k8s cluster is up, the Ansible script will bootstrap ArgoCD and then my app of apps, which will deploy all applications to the cluster.

After that the terraform process needs to be run to onboard necessary secrets and create the needed cloud infrastructure.

### Core Components

- [argo-cd](https://argo-cd.readthedocs.io/en/stable/): Continous deployment tool used to deploy manifests/charts from git to my homelab
- [authentik](https://goauthentik.io/): SSO for the services that support LDAP/SAML/OIDC.
- [cert-manager](https://cert-manager.io/docs/): Creates SSL certificates for services in my Kubernetes cluster.
- [cloudnative-pg](https://cloudnative-pg.io/): Operator for Postgresql DB management.
- [external-dns](https://github.com/kubernetes-sigs/external-dns): Automatically manages DNS records from my cluster in a cloud DNS provider.
- [external-secrets](https://external-secrets.io/main/): Used to store my secrets in a reversible way so DR is trivial.
- [ingress-nginx](https://github.com/kubernetes/ingress-nginx/): Ingress controller to expose HTTP traffic to pods over DNS.
- [kyverno](https://kyverno.io/): Policy management for cluster (ie. Setup all pods with timezone Australia/Sydney)
- [loki](https://grafana.com/oss/loki/): Centralized log storage
- [metallb](https://metallb.universe.tf/): Load balancer provisioning service for bare metal LBs
- [prometheus](https://prometheus.io/)/[alert manager](https://prometheus.io/docs/alerting/latest/alertmanager/)/ [grafana](https://grafana.com/): Observability and alerting
- [rook](https://github.com/rook/rook): Distributed block storage for peristent storage.
- [volsync](https://github.com/backube/volsync) and [snapscheduler](https://github.com/backube/snapscheduler): Backup and recovery of persistent volume claims.

### Directories

This Git repository contains the following directories.

```sh
📁 .taskfiles           # Script files for common operations I perform
📁 ansible              # Ansible playbook to deploy K3S binaries onto nodes
📁 kubernetes           # Contains all k8s manifests deployed using Argo CD
└─📁 helm
  └─📁 ${namespace}     # Folder name used by Argo to determine application's namespace
    └─📁 ${application} # folder name used to name the Helm Application created by Argo
      └─📁 manifests    # optional : manifests related to application (i.e. Secrets, ClusterPolicy, etc)
📁 terraform            # Create cloud infrastructure and k8s manifests in a repeatable way
```

## ☁️ Cloud Dependencies

While most of my infrastructure and workloads are selfhosted I do rely upon the cloud for certain key parts of my setup. This saves me from having to worry about two things. (1) Dealing with chicken/egg scenarios and (2) services I critically need whether my cluster is online or not.

| Service                                                         | Use                                                            | Cost             |
|-----------------------------------------------------------------|----------------------------------------------------------------|------------------|
| [G Suite](https://workspace.google.com/intl/en_au/)             | Email                                                          | ~$15/mo          |
| [Backblaze B2](https://www.backblaze.com/b2/cloud-storage.html) | Backups                                                        | ~$5/mo           |
| [GCP](https://cloud.google.com/)                                | Secrets management                                             | ~$2/mo           |
| [Cloudflare](https://www.cloudflare.com/)                       | Domain, DNS and proxy management                               | ~$30/yr          |
| [GitHub](https://github.com/)                                   | Hosting this repository and continuous integration/deployments | Free             |
| [Zen Duty](https://www.zenduty.com/)                            | Push notifications alerting when health issue occurs           | Free             |
|                                                                 |                                                                | Total: ~$24.5/mo |

---

### Ingress Controller

Over WAN, I have port forwarded ports `80` and `443` to the load balancer IP of my [ingress-nginx](https://github.com/kubernetes/ingress-nginx) controller that's running in my Kubernetes cluster.

### Internal DNS

[CoreDNS](https://github.com/coredns/coredns) is deployed in my k8s cluster. All DNS queries for _**k8s.tylercash.dev**_ domains are forwarded to [k8s_gateway](https://github.com/ori-edge/k8s_gateway) that is running in my cluster. With this setup `k8s_gateway` has direct access to my clusters ingresses and services and serves DNS for them in my internal network.

### Ad Blocking

The [CoreDNS](https://github.com/coredns/coredns) deployment has a volume with a hosts file present on it. This hostfile is updated frequently by a [CronJob run in cluster](manifests/networking/adblock-updater/cron.yaml). CoreDNS is configured to drop any entries that are matched in this file, which results in ads failing to load.

### External DNS

[external-dns](https://github.com/kubernetes-sigs/external-dns) is deployed in my cluster and configure to sync DNS records to [Cloudflare](https://www.cloudflare.com/). The only ingresses `external-dns` looks at to gather DNS records to put in `Cloudflare` are ones that have an annotation of `external-dns.alpha.kubernetes.io/target`

### Dynamic DNS

My home IP can change at any given time and in order to keep my WAN IP address up to date on Cloudflare. [pfSense](https://www.pfsense.org/) has a native Dynamic DNS tool which I use to update my IP in cloudflare

---

## 🔧 Hardware

| Device                      | Count | OS Disk Size | Data Disk Size         | Ram  | Operating System | Purpose  |
|-----------------------------|-------|--------------|------------------------|------|------------------|----------|
| DIY machine (i5 11400)      | 2     | 256GB SSD    | 1x 1TB SSD, 1x 4TB HDD | 32GB | Ubuntu 22.04     | K8S Node |
| HP ProDesk 600 G2 (i5 6500) | 1     | 256GB SSD    | 1x 1TB SSD, 4x 1TB HDD | 32GB | Ubuntu 22.04     | K8S Node |
| Soft Router (Celeron N5105) | 1     | 256GB SSD    | N/A                    | 8GB  | pfSense          | Router   |


---

## 🤝 Gratitude and Thanks

Thanks to all the people who donate their time to the [Kubernetes @Home](https://discord.gg/k8s-at-home) Discord community. A lot of inspiration for my cluster comes from the people that have shared their clusters using the [k8s-at-home](https://github.com/topics/k8s-at-home) GitHub topic. Be sure to check out the [Kubernetes @Home search](https://nanne.dev/k8s-at-home-search/) for ideas on how to deploy applications or get ideas on what you can deploy.
