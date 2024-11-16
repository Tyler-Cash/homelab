## Ceph disaster recovery
Something has gone terribly wrong and Ceph needs to be restored from backup!

#### Steps for restoring from s3
1. Update [.taskfiles/Volsync/ReplicationDestination.tmpl.yaml](.taskfiles/Volsync/ReplicationDestination.tmpl.yaml) with correct `restoreOf` time
2. Run below command and wait for all volumes to restore from backup
```shell
k get replicationsources --all-namespaces --no-headers | awk '{print $2, $1}' | xargs --max-procs=20 -l bash -c 'task volsync:restore rsrc=$0 namespace=$1'
```
3. Within 10m-30m likely most services will recover

