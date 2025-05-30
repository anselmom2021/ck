oc create secret generic openid-okta-secret --from-literal=clientSecret="$OKTASECRET" -n openshift-config
