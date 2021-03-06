function ConvertTo-ShortenedPath {
    <#
        .SYNOPSIS
            Path Shortener
        .DESCRIPTION
            Function to convert paths to a shortend form.
            Usefull in prompts to keep the total path length down.
        .EXAMPLE
            ConvertTo-ShortenedPath
            Will shorten the current path, using default parameter values.
        .EXAMPLE
            $path | ConvertTo-ShortenedPath -ReplaceHome:$false
            Will shorten the path in the $path variable. The home path will not be replaced.
        .EXAMPLE
            ConvertTo-ShortenedPath -Path $pwd -MaxSegmentLength 1
            Will shorten the current path, while truncating all but the first and last
            path segments to just one character.
        .EXAMPLE
            ConvertTo-ShortenedPath -Path $pwd -MaxSegmentLength 1 -TruncateFirstSegment
            Will shorten the current path, while truncating all but the last
            path segment to just one character.
        .INPUTS
            System.String
        .OUTPUTS
            SYstem.String
        .LINK
            https://communary.net/
        .NOTES
            Rewrite of my old function 'Invoke-PathShortener'

            Author: Øyvind Kallstad
            Date: 13.05.2017
            Version: 1.0
    #>
    [CmdletBinding()]
    param (
        # The path to shorten. Defaults to the current location.
        [Parameter(Position = 0, ValueFromPipeline = $true)]
        [string] $Path = (Get-Location),

        # Number of segments to keep before truncating. Default value is 2.
        [Parameter()]
        [Alias('Before')]
        [ValidateRange(0, [int32]::MaxValue)]
        [int] $KeepBefore = 2,

        # Number of segments to keep after truncating. Default value is 1.
        [Parameter()]
        [Alias('After')]
        [ValidateRange(1, [int32]::MaxValue)]
        [int] $KeepAfter = 1,

        # Maximum length of each segment. If set, will truncate each path segment to the desired length.
        # Default value is null, which means no truncating of the segments will take place.
        [Parameter()]
        [Alias('SegmentLength')]
        [nullable[int]] $MaxSegmentLength = $null,

        # Choose whether to truncate the first path segment or not. Default value is false.
        [Parameter()]
        [Alias('First')]
        [switch] $TruncateFirstSegment = $false,

        # Choose whether to truncate the last path segment or not. Default value is false.
        [Parameter()]
        [Alias('Last')]
        [switch] $TruncateLastSegment = $false,

        # Character(s) to use in place of the truncated path segments.
        # Default value is '[char]8230' (horizontal ellipsis).
        [Parameter()]
        [string] $TruncateCharacter = [char]8230,

        # Choose whether to replace the home path. If set will replace the home path
        # with the value of the HomeReplacementCharacter parameter.
        # Default value is true.
        [Parameter()]
        [switch] $ReplaceHome = $true,

        # Character(s) to use as replacement for the home path. Default value is '~'.
        [Parameter()]
        [string] $HomeCharacter = '~',

        # Path separator character.
        # Defaults to DirectorySeparatorChar from the System.IO.Path class.
        [Parameter()]
        [string] $Separator = [System.IO.Path]::DirectorySeparatorChar,

        # Custom separator in the shortened path.
        # If set, the path separator character will be replaced with this in the output string.
        [Parameter()]
        [nullable[char]] $OutputSeparator = $null
    )

    # Support environment variables that override default parameter values
    if (-not($PSBoundParameters.Keys -icontains 'KeepBefore')) {
        if (Test-Path -Path 'env:PathShortenerKeepBefore') {
            $KeepBefore = $env:PathShortenerKeepBefore
        }
    }
    if (-not($PSBoundParameters.Keys -icontains 'KeepAfter')) {
        if (Test-Path -Path 'env:PathShortenerKeepAfter') {
            $KeepAfter = $env:PathShortenerKeepAfter
        }
    }
    if (-not($PSBoundParameters.Keys -icontains 'MaxSegmentLength')) {
        if (Test-Path -Path 'env:PathShortenerMaxSegmentLength') {
            $MaxSegmentLength = $env:PathShortenerMaxSegmentLength
        }
    }
    if (-not($PSBoundParameters.Keys -icontains 'TruncateFirstSegment')) {
        if (Test-Path -Path 'env:PathShortenerTruncateFirstSegment') {
            $TruncateFirstSegment = $env:PathShortenerTruncateFirstSegment
        }
    }
    if (-not($PSBoundParameters.Keys -icontains 'TruncateLastSegment')) {
        if (Test-Path -Path 'env:PathShortenerTruncateLastSegment') {
            $TruncateLastSegment = $env:PathShortenerTruncateLastSegment
        }
    }
    if (-not($PSBoundParameters.Keys -icontains 'TruncateCharacter')) {
        if (Test-Path -Path 'env:PathShortenerTruncateCharacter') {
            $TruncateCharacter = $env:PathShortenerTruncateCharacter
        }
    }
    if (-not($PSBoundParameters.Keys -icontains 'ReplaceHome')) {
        if (Test-Path -Path 'env:PathShortenerReplaceHome') {
            $ReplaceHome = $env:PathShortenerReplaceHome
        }
    }
    if (-not($PSBoundParameters.Keys -icontains 'HomeCharacter')) {
        if (Test-Path -Path 'env:PathShortenerHomeCharacter') {
            $HomeCharacter = $env:PathShortenerHomeCharacter
        }
    }
    if (-not($PSBoundParameters.Keys -icontains 'Separator')) {
        if (Test-Path -Path 'env:PathShortenerSeparator') {
            $Separator = $env:PathShortenerSeparator
        }
    }
    if (-not($PSBoundParameters.Keys -icontains 'OutputSeparator')) {
        if (Test-Path -Path 'env:PathShortenerOutputSeparator') {
            $OutputSeparator = $env:PathShortenerOutputSeparator
        }
    }

    $outPath = New-Object -TypeName System.Text.StringBuilder

    # Remove 'Microsoft.PowerShell.Core\FileSystem::' from UNC paths
    $Path = $Path -replace('^.*::','')

    # Replace home path
    if ($ReplaceHome) {
        if ($Path.ToLower().StartsWith($HOME.ToLower())) {
            $Path = $Path -ireplace(([regex]::Escape($HOME)),$HomeCharacter)
            $KeepBefore++
        }
    }

    # Split path into segments
    $pathSegments = $Path.Split($Separator.ToString(),[System.StringSplitOptions]::RemoveEmptyEntries)

    # Replace separator character
    if ($OutputSeparator) {
        $Separator = $OutputSeparator
    }

    # Truncate segments
    if ($MaxSegmentLength) {
        if ($MaxSegmentLength -ge 1) {
            $tmpArray = New-Object -TypeName System.Collections.ArrayList
            for ($i = 0; $i -lt $pathSegments.Count; $i++) {

                # Make sure that the MaxSegmentLength is not greater than the actual segment length
                if ($pathSegments[$i].Length -lt $MaxSegmentLength) {
                    $_maxSegmentLength = $pathSegments[$i].Length
                }
                else {
                    $_maxSegmentLength = $MaxSegmentLength
                }

                # first segment
                if ($i -eq 0) {
                    if ($TruncateFirstSegment) {
                        [void]$tmpArray.Add(($pathSegments[$i].SubString(0,$_maxSegmentLength)))
                    }
                    else {
                        [void]$tmpArray.Add(($pathSegments[$i]))
                    }
                }
                # last segment
                elseif ($i -eq ($pathSegments.Count - 1)) {
                    if ($TruncateLastSegment) {
                        [void]$tmpArray.Add(($pathSegments[$i].SubString(0,$_maxSegmentLength)))
                    }
                    else {
                        [void]$tmpArray.Add(($pathSegments[$i]))
                    }
                }
                # the rest of the segments
                else {
                    [void]$tmpArray.Add(($pathSegments[$i].SubString(0,$_maxSegmentLength)))
                }
            }
            $pathSegments = $tmpArray
        }
    }

    # Check if path needs shortening
    if ($pathSegments.Count -gt ($KeepBefore + $KeepAfter)) {
        # Add segments before truncate character(s) to the output string
        for ($i = 0; $i -lt $KeepBefore; $i++) {
            [void]$outPath.Append($pathSegments[$i] + $Separator)
        }

        # Add the truncate character(s) to the output string
        [void]$outPath.Append("$($TruncateCharacter)$($Separator)")

        # Add segments after truncate character(s) to the output string
        for ($i = ($pathSegments.Count - $KeepAfter); $i -lt $pathSegments.Count; $i++) {
            # Don't add the separator for the last segment
            if ($i -eq ($pathSegments.Count - 1)) {
                [void]$outPath.Append($pathSegments[$i])
            }
            else {
                [void]$outPath.Append($pathSegments[$i] + $Separator)
            }
        }
    }
    # Not enought segments to shorten the path
    else {
        [void]$outPath.Append(($pathSegments -join $Separator))
    }

    # \\ is lost for UNC paths, so re-insert this
    if ($Path.StartsWith('\\')) {
        [void]$outPath.Insert(0,'\\')
    }

    Write-Output $outPath.ToString()
}

Export-ModuleMember -Function ConvertTo-ShortenedPath