function acr-login
    az acr login --name acrcsocasgard --expose-token --output tsv --query accessToken \
        | docker login acrcsocasgard.azurecr.io \
            --username 00000000-0000-0000-0000-000000000000 \
            --password-stdin
end
