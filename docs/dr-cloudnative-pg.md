## Cloudnative configuration
Something has gone terribly wrong and Cloudnative PG needs to be restored from backup!

#### Steps for restoring from s3
1. Remove spec.backup.barmanObjectStore field
2. Apply manifest
3. Reconfigure spec.backup.barmanObjectStore
4. Validate backups are working again
