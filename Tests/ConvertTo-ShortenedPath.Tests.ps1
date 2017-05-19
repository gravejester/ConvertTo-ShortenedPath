Import-Module '.\ConvertTo-ShortenedPath.psd1' -Force

$TruncateCharacter = [char]8230

$path1 = 'C:\'
$path2 = 'C:\windows\system32\microsoft\Crypto\RSA\MachineKeys'
$path3 = '\\computer1\share\subfolder1\subfolder2\subfolder3'
$path4 = Join-Path -Path $HOME -ChildPath 'documents\work\confidential'
$path5 = 'HKLM:\SOFTWARE\Microsoft\Windows\ClickNote\UserCustomization\'
$path6 = 'Microsoft.PowerShell.Core\FileSystem::\\localhost\c$\temp\sub1\sub2\another\different\deep\folder\test\dev\temp\'

Describe 'default settings' {
    It $path1 {
        ConvertTo-ShortenedPath -Path $path1 | Should Be 'C:'
    }
    It $path2 {
        ConvertTo-ShortenedPath -Path $path2 | Should Be "C:\windows\$TruncateCharacter\MachineKeys"
    }
    It $path3 {
        ConvertTo-ShortenedPath -Path $path3 | Should Be "\\computer1\share\$TruncateCharacter\subfolder3"
    }
    It $path4 {
        ConvertTo-ShortenedPath -Path $path4 | Should Be '~\documents\work\confidential'
    }
    It $path5 {
        ConvertTo-ShortenedPath -Path $path5 | Should Be "HKLM:\SOFTWARE\$TruncateCharacter\UserCustomization"
    }
    It $path6 {
        ConvertTo-ShortenedPath -Path $path6 | Should Be "\\localhost\c$\$TruncateCharacter\temp"
    }
}

Describe 'custom settings' {
    Context 'MaxSegmentLength = 1' {
        It $path1 {
            ConvertTo-ShortenedPath -Path $path1 -MaxSegmentLength 1 | Should Be 'C:'
        }
        It $path2 {
            ConvertTo-ShortenedPath -Path $path2 -MaxSegmentLength 1 | Should Be "C:\w\$TruncateCharacter\MachineKeys"
        }
        It $path3 {
            ConvertTo-ShortenedPath -Path $path3 -MaxSegmentLength 1 | Should Be "\\computer1\s\$TruncateCharacter\subfolder3"
        }
        It $path4 {
            ConvertTo-ShortenedPath -Path $path4 -MaxSegmentLength 1 | Should Be '~\d\w\confidential'
        }
        It $path5 {
            ConvertTo-ShortenedPath -Path $path5 -MaxSegmentLength 1 | Should Be "HKLM:\S\$TruncateCharacter\UserCustomization"
        }
        It $path6 {
            ConvertTo-ShortenedPath -Path $path6 -MaxSegmentLength 1 | Should Be "\\localhost\c\$TruncateCharacter\temp"
        }
    }
    Context 'MaxSegmentLength = 1 & TruncateFirstSegment' {
        It $path1 {
            ConvertTo-ShortenedPath -Path $path1 -MaxSegmentLength 1 -TruncateFirstSegment | Should Be 'C'
        }
        It $path2 {
            ConvertTo-ShortenedPath -Path $path2 -MaxSegmentLength 1 -TruncateFirstSegment | Should Be "C\w\$TruncateCharacter\MachineKeys"
        }
        It $path3 {
            ConvertTo-ShortenedPath -Path $path3 -MaxSegmentLength 1 -TruncateFirstSegment | Should Be "\\c\s\$TruncateCharacter\subfolder3"
        }
        It $path4 {
            ConvertTo-ShortenedPath -Path $path4 -MaxSegmentLength 1 -TruncateFirstSegment | Should Be '~\d\w\confidential'
        }
        It $path5 {
            ConvertTo-ShortenedPath -Path $path5 -MaxSegmentLength 1 -TruncateFirstSegment | Should Be "H\S\$TruncateCharacter\UserCustomization"
        }
        It $path6 {
            ConvertTo-ShortenedPath -Path $path6 -MaxSegmentLength 1 -TruncateFirstSegment | Should Be "\\l\c\$TruncateCharacter\temp"
        }
    }
    Context '-Before 99 -After 99 -MaxSegmentLength 2 -First' {
        It $path1 {
            ConvertTo-ShortenedPath -Path $path1 -Before 99 -After 99 -MaxSegmentLength 2 -First | Should Be 'C:'
        }
        It $path2 {
            ConvertTo-ShortenedPath -Path $path2 -Before 99 -After 99 -MaxSegmentLength 2 -First | Should Be 'C:\wi\sy\mi\Cr\RS\MachineKeys'
        }
        It $path3 {
            ConvertTo-ShortenedPath -Path $path3 -Before 99 -After 99 -MaxSegmentLength 2 -First | Should Be '\\co\sh\su\su\subfolder3'
        }
        It $path4 {
            ConvertTo-ShortenedPath -Path $path4 -Before 99 -After 99 -MaxSegmentLength 2 -First | Should Be '~\do\wo\confidential'
        }
        It $path5 {
            ConvertTo-ShortenedPath -Path $path5 -Before 99 -After 99 -MaxSegmentLength 2 -First | Should Be 'HK\SO\Mi\Wi\Cl\UserCustomization'
        }
        It $path6 {
            ConvertTo-ShortenedPath -Path $path6 -Before 99 -After 99 -MaxSegmentLength 2 -First | Should Be '\\lo\c$\te\su\su\an\di\de\fo\te\de\temp'
        }
    }
    Context '-OutputSeparator "|"' {
        It $path1 {
            ConvertTo-ShortenedPath -Path $path1 -OutputSeparator "|" | Should Be 'C:'
        }
        It $path2 {
            ConvertTo-ShortenedPath -Path $path2 -OutputSeparator "|" | Should Be "C:|windows|$TruncateCharacter|MachineKeys"
        }
        It $path3 {
            ConvertTo-ShortenedPath -Path $path3 -OutputSeparator "|" | Should Be "\\computer1|share|$TruncateCharacter|subfolder3"
        }
        It $path4 {
            ConvertTo-ShortenedPath -Path $path4 -OutputSeparator "|" | Should Be '~|documents|work|confidential'
        }
        It $path5 {
            ConvertTo-ShortenedPath -Path $path5 -OutputSeparator "|" | Should Be "HKLM:|SOFTWARE|$TruncateCharacter|UserCustomization"
        }
        It $path6 {
            ConvertTo-ShortenedPath -Path $path6 -OutputSeparator "|" | Should Be "\\localhost|c$|$TruncateCharacter|temp"
        }
    }
}