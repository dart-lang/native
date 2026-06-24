function Convert-Arg($arg) {
    if ($arg -match '^[A-Za-z]:\\') {
        return (& wsl wslpath ($arg -replace '\\', '/')).Trim()
    }
    if ($arg -match '^(-[LIo])([A-Za-z]:\\.*)$') {
        $wslPath = (& wsl wslpath ($matches[2] -replace '\\', '/')).Trim()
        return "$($matches[1])$wslPath"
    }
    return $arg
}

$rawArgs = $args
$result = [System.Collections.Generic.List[string]]::new()
$i = 0
while ($i -lt $rawArgs.Count) {
    $arg = $rawArgs[$i]
    $nextArg = if (($i + 1) -lt $rawArgs.Count) { $rawArgs[$i + 1] } else { "" }

    # Matches -LC (drive letter eaten into flag) + \Users\... on next arg
    $isSplitPrefix = $arg -match '^(-[LIo])([A-Za-z])$'
    $nextIsPath = $nextArg.StartsWith('\')

    if ($isSplitPrefix -and $nextIsPath) {
        $prefix = $matches[1]
        $driveLetter = $matches[2]
        $fullPath = "${driveLetter}:$nextArg" -replace '\\', '/'
        $wslPath = (& wsl wslpath $fullPath).Trim()
        $result.Add("$prefix$wslPath")
        $i += 2
    } else {
        $result.Add((Convert-Arg $arg))
        $i++
    }
}

& wsl x86_64-linux-gnu-gcc @result
