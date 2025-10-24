param ( $keyword)

function Get-CasesByTask {
    param(
        [string]$keyword
    )

    $headers = @{
        "Accept"             = "application/json, text/plain, */*"
        "Accept-Encoding"    = "gzip, deflate, br"
        "Accept-Language"    = "en-US,en;q=0.9,zh-CN;q=0.8,zh;q=0.7"
        "Origin"             = "https://thehive.pnl.gov"
        "Referer"            = "https://thehive.pnl.gov/search"
        "Sec-Fetch-Dest"     = "empty"
        "Sec-Fetch-Mode"     = "cors"
        "Sec-Fetch-Site"     = "same-origin"
        "sec-ch-ua"          = "`"Chromium`";v=`"116`", `"Not)A;Brand`";v=`"24`", `"Google Chrome`";v=`"116`""
        "sec-ch-ua-mobile"   = "?0"
        "sec-ch-ua-platform" = "`"Windows`""
        Authorization        = "Bearer Bearer <API_Key>"
    }

    Invoke-WebRequest -UseBasicParsing -Uri "https://thehive.pnl.gov/api/v1/query?name=search-listLog" `
        -Method "POST" `
        -Headers  $headers `
        -ContentType "application/json" `
        -Body "{`"query`":[{`"_name`":`"listLog`"},{`"_name`":`"filter`",`"_and`":[{},{`"_field`":`"keyword`",`"_value`":`"$keyword`"}]},{`"_name`":`"sort`",`"_fields`":[{`"_createdAt`":`"desc`"}]},{`"_name`":`"page`",`"from`":0,`"to`":10,`"extraData`":[`"task`"]}]}"
}

$search = Get-CasesByTask -keyword $keyword

foreach ($case in ($search.Content | ConvertFrom-Json))
{ Write-Host "Case #$($case.extraData.task.case.number)" }
