$result = [System.Collections.Generic.List[string]]::new()
foreach ($arg in $args) {
    # Handle /C:/... style paths
    if ($arg -match '^/([A-Za-z]):(.*)$') {
        $fullPath = "$($matches[1]):$($matches[2])" -replace '\\', '/'
        $wslPath = (& wsl wslpath $fullPath).Trim()
        $result.Add($wslPath)
    }
    # Handle bare Windows paths
    elseif ($arg -match '^[A-Za-z]:\\') {
        $wslPath = (& wsl wslpath ($arg -replace '\\', '/')).Trim()
        $result.Add($wslPath)
    }
    else {
        $result.Add($arg)
    }
}

& wsl x86_64-linux-gnu-objdump @result
