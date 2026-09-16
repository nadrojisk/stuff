function az-login
    _op_load; or return 1
    az login --service-principal \
        -u "$OP_AZ_USER" \
        --password "$OP_AZ_CRED" \
        --tenant "$OP_AZ_TENANT"
end
