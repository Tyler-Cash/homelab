## Unifi configuration
Run below command to get the IP of the service
```sh
homelab|git:(master*)⇒ k get svc -n networking unifi 
NAME    TYPE           CLUSTER-IP    EXTERNAL-IP   PORT(S)                                                                                      AGE
unifi   LoadBalancer   10.43.70.17   10.0.90.124   8080:31833/TCP,10001:30487/UDP,8443:31675/TCP,${many_ports}   16m
```

Take the External IP and log into the [controller](unifi.k8s.tylercash.dev).

Navigate to Settings -> System -> Override Inform Host and input the value (assuming above). Note: This IP is different to the IP the UI is served on. (For the most part)
```sh
10.0.90.124
```

Now that the controller is setup, time to onboard the APs. Access the APs like so
```sh
homelab|git:(master*)⇒ ssh ubnt@${AP_IP_ADDRESS}
ubnt@${AP_IP_ADDRESS}'s password: ubnt

U6-Pro-BZ.6.0.15# set-inform http://10.0.90.124:8080/inform
```

Now that the APs are configured, go to the [controller](unifi.k8s.tylercash.dev) and adopt them, everything should spin up and be auto configured per backup.