function az-login
    _op_load; or return 1
    AZURE_CLIENT_SECRET="$OP_AZ_CRED" az login --service-principal \
        -u "$OP_AZ_USER" \
        --tenant "$OP_AZ_TENANT"
end
