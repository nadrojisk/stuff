function claude
    _op_load; or return 1
    ANTHROPIC_FOUNDRY_API_KEY="$OP_INCUBATOR" command claude $argv
end
