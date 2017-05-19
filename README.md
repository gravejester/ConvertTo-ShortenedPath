# ConvertTo-ShortenedPath

PowerShell function to shorten paths.

This functions takes a path as input and lets you shorten it with multiple customization options. It was primarily made as a helper funtion for custom PowerShell prompts, but works just as well stand-alone if needed.

## Examples

Given the following string as input:

    Microsoft.PowerShell.Core\FileSystem::\\localhost\c$\temp\sub1\sub2\another\different\deep\folder\test\dev\temp\


You can shorten it to be any of the following (and more):

    \\localhost\c$\…\temp
    \\l\c\…\temp
    \\l\c\t\s\s\a\d\d\f\t\d\temp
    \\localhost|c$|...|temp
    \\localhost\c\t\…\t\d\temp

The function will also replace the home path Unix-style, if you so choose. Take a look at the built-in help for more examples and a complete overview of the different parameters.

## Installation

If you have PowerShellGet, you can install it with:

    Install-Module ConvertTo-ShortenedPath

Else, you would have to download the zip from this repository and manually unpack it to one of the module paths on your system.