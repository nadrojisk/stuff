function acr_import
    set source $argv[1]
    if test -z "$source"
        echo "Usage: acr_import <registry>/<repo>:<tag>" >&2
        return 1
    end

    set host (string split -m1 "/" $source)[1]
    if string match -q "*/*" $source; and begin
            string match -q "*.*" $host; or string match -q "*:*" $host
        end
        set image (string sub -s (math (string length $host) + 2) $source)
    else
        set image $source
    end

    az acr import --name acrcsoc --source "$source" --image "$image"
end
