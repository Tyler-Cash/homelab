## Jellyfin configuration
I should probably investigate just putting this in an init container, but that would require modifying the internal DB state as plugins don't really have much of an interface outside of the API. For the meantime.... I'll just refer to this.

Run Terraform onboarding to initialize Authentik as needed.
Once that's onboarded, go to the UI -> Admin interface -> Applications -> Outposts and save the LDAP outpost (Why is this needed???)
Generate a very long pass and update the Jellyfin user with that pass

#### Configure LDAP server
LDAP server: ak-outpost-jellyfin-outpost.security.svc.cluster.local
LDAP Port: 636

Secure LDAP: tick
StartTLS:
Skip SSL/TLS Verification: tick

Allow Password Change: 
Password Reset Url:
LDAP Bind User: cn=jellyfin,dc=ldap,dc=tylercash,dc=dev

LDAP Base DN: dc=ldap,dc=tylercash,dc=dev
LDAP User Filter: (|(memberOf=cn=jellyfin,ou=groups,dc=ldap,dc=tylercash,dc=dev)(memberOf=cn=jellyfin_admin,ou=groups,dc=ldap,dc=tylercash,dc=dev)(memberOf=cn=admin,ou=groups,dc=ldap,dc=tylercash,dc=dev))
LDAP Admin Base DN:
LDAP Admin Filter: (|(memberOf=cn=jellyfin_admin,ou=groups,dc=ldap,dc=tylercash,dc=dev)(memberOf=cn=admin,ou=groups,dc=ldap,dc=tylercash,dc=dev))

Enable Case Insensitive Username: tick

LDAP Name Attribute: mail