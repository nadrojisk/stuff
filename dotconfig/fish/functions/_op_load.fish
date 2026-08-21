function _op_load
    set -l needs_unlock 0

    if not test -f $_OP_SECRETS_FILE
        set needs_unlock 1
    else
        set -l age (math (date +%s) - (stat -c %Y $_OP_SECRETS_FILE))
        if test $age -gt $_OP_CACHE_TTL
            set needs_unlock 1
        end
    end

    if test $needs_unlock -eq 1
        op-unlock; or return 1
    end

    touch $_OP_SECRETS_FILE

    while read -l line
        set -l key (string split -m1 "=" $line)[1]
        set -l val (string split -m1 "=" $line)[2]
        set -g $key $val
    end < $_OP_SECRETS_FILE
end
