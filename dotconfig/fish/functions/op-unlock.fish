set -g _OP_SECRETS_FILE /tmp/op_secrets_(id -u)
set -g _OP_CACHE_TTL 86400

function op-unlock
    echo "Unlocking 1Password secrets..." >&2

    set -l incubator  (op.exe read "op://PNNL/AI Incubator - Personal/credential" 2>/dev/null)
    set -l jira       (op.exe read "op://PNNL/Jira PAT/credential" 2>/dev/null)
    set -l confluence (op.exe read "op://PNNL/Confluence PAT/credential" 2>/dev/null)
    set -l az_user    (op.exe read "op://PNNL/Asgard Azure Service Principal/username" 2>/dev/null)
    set -l az_cred    (op.exe read "op://PNNL/Asgard Azure Service Principal/credential" 2>/dev/null)
    set -l az_tenant  (op.exe read "op://PNNL/Asgard Azure Service Principal/tenant_id" 2>/dev/null)
    set -l thehive    (op.exe read "op://PNNL/TheHive/credential" 2>/dev/null)
    set -l thehivedev    (op.exe read "op://PNNL/TheHiveDev/credential" 2>/dev/null)

    if test -z "$incubator"
        echo "error: failed to retrieve secrets from 1Password" >&2
        return 1
    end

    printf '%s\n' \
        "OP_INCUBATOR=$incubator" \
        "OP_JIRA=$jira" \
        "OP_CONFLUENCE=$confluence" \
        "OP_AZ_USER=$az_user" \
        "OP_AZ_CRED=$az_cred" \
        "OP_AZ_TENANT=$az_tenant" \
        "OP_THEHIVE=$thehive" \
        "OP_THEHIVEDEV=$thehivedev" \
        > $_OP_SECRETS_FILE
    chmod 600 $_OP_SECRETS_FILE

    echo "1Password secrets cached." >&2
end
