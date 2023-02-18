# Startup guide for starting the cluster

Follow onedr0p's guide on installing k3s. Just putting it here as this project will be mostly branching off. So reorgs may not be relevant here.

Note, although the steps are listed in sequence, on the ansible:install, it's possible to also run terraform:apply.

### ⚡ Preparing Fedora or Ubuntu Server with Ansible

📍 Here we will be running a Ansible Playbook to prepare Fedora or Ubuntu Server for running a Kubernetes cluster.

📍 Nodes are not security hardened by default, you can do this with [dev-sec/ansible-collection-hardening](https://github.com/dev-sec/ansible-collection-hardening) or similar if supported. This is an advanced configuration and generally not recommended unless you want to [DevSecOps](https://www.ibm.com/topics/devsecops) your cluster and nodes.

1. Install the Ansible deps

    ```sh
    task ansible:init
    ```

2. Verify Ansible can view your config

    ```sh
    task ansible:list
    ```
3. Setup nodes to be accessed with only the configured SSH keys
    ```sh
    task ansible:sudoers
    ```
4. Verify Ansible can ping your nodes (Also validates root access)

    ```sh
    task ansible:ping
    ```

5. Run the Fedora/Ubuntu Server Ansible prepare playbook

    ```sh
    task ansible:prepare
    ```

6. Reboot the nodes (if not done in step 5)

    ```sh
    task ansible:force-reboot
    ```

### ⛵ Installing k3s with Ansible

📍 Here we will be running a Ansible Playbook to install [k3s](https://k3s.io/) with [this](https://galaxy.ansible.com/xanmanning/k3s) wonderful k3s Ansible galaxy role. After completion, Ansible will drop a `kubeconfig` in `./kubeconfig` for use with interacting with your cluster with `kubectl`.

☢️ If you run into problems, you can run `task ansible:nuke` to destroy the k3s cluster and start over.

1. Verify Ansible can view your config

    ```sh
    task ansible:list
    ```

2. Verify Ansible can ping your nodes

    ```sh
    task ansible:ping
    ```

3. Install k3s with Ansible

    ```sh
    task ansible:install
    ```
4. Move the kubeconfig
    ```sh
    ```
5. Verify the nodes are online

    ```sh
    kubectl get nodes
    # NAME           STATUS   ROLES                       AGE     VERSION
    # k8s-0          Ready    control-plane,master      4d20h   v1.21.5+k3s1
    # k8s-1          Ready    worker                    4d20h   v1.21.5+k3s1
    ```

### Setup cloud components

📍 The cluster requires some cloud based components to be created. For secret encryption GCP is used so we can put secrets in and decrypt them based on a single cred that's regeneratable. Cloudflare is also used for DNS components, we'll also setup this information here. Necessary configs need to be put into the Ansible configs to allow this to be auto configured.

1. Login to gcloud
    ```sh
    gcloud auth application-default login
    ```

2. Plan terraform changes
    ```sh
    task terraform:plan
    ```

3. Onboard all cloud infrastructure
    ```sh
    task terraform:apply -- -auto-approve -target=module.dns
    ```

### Start syncing Argo components

📍 Once the cluster is up, Argo will start syncing through everything gradually. To speed things up, we can sync up the 'core' services, which will allow everything to sync through successfully. These were the ones I manually synced to speed things along.

    ```sh
    argocd app sync argocd
    argocd app sync metallb
    argocd app sync metallb-manifests
    argocd app sync rook-operator
    argocd app sync rook-ceph
    argocd app sync cert-manager
    argocd app sync kubed
    task terraform:apply -- -auto-approve -target=module.secrets_storage
    ```

Wait for Storage to come up, Authentik (Aka all UIs) depend on the Rook cluster coming up
  ```shell
  kubectl get -n storage pod -w
  ```
