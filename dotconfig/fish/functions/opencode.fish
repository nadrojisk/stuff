function opencode
    _op_load; or return 1
    PNNL_INCUBATOR_API_KEY="$OP_INCUBATOR" \
        JIRA_PERSONAL_TOKEN="$OP_JIRA" \
        CONFLUENCE_PERSONAL_TOKEN="$OP_CONFLUENCE" \
        THEHIVEDEV_BEARER_TOKEN="$OP_THEHIVE" \
        command opencode $argv
end
