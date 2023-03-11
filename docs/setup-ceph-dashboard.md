## Ceph dashboard configuration
The current config should setup the Ceph dashboard completely automatically.

### WARNING
If a login loop occurs with SSO (Ie, bouncing over and over between Ceph and Authentik), this is caused by the user not being created in the dashboard. Refer to the below from the Ceph docs
> The Ceph Dashboard supports external authentication of users via the SAML 2.0 protocol. You need to first create user accounts and associate them with desired roles, as authorization is performed by the Dashboard. However, the authentication process can be performed by an existing Identity Provider (IdP).
