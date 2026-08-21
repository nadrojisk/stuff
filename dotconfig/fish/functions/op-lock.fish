function op-lock
    if test -f $_OP_SECRETS_FILE
        rm -f $_OP_SECRETS_FILE
        echo "1Password secrets cleared." >&2
    end
end
