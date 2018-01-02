function Get-UrlEncodedString {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   Position=0)]
        [string]$Target
    )
    
    begin {
    }
    
    process {
        [System.Uri]::EscapeDataString($Target)
    }
    
    end {}
}

function Get-UrlDecodedString {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   Position=0)]
        [string]$Target
    )
    
    begin {}
    
    process {
        [System.Uri]::UnescapeDataString($Target)
    }
    
    end {}
}

function Test-Get-UrlEncodedString {
    Write-Host (Get-UrlEncodedString " ")
    Write-Host (Get-UrlEncodedString "!")
    Write-Host (Get-UrlEncodedString '"')
    Write-Host (Get-UrlEncodedString "#")
    Write-Host (Get-UrlEncodedString "$")
    Write-Host (Get-UrlEncodedString "%")
    Write-Host (Get-UrlEncodedString "&")
    Write-Host (Get-UrlEncodedString "'")
    Write-Host (Get-UrlEncodedString "(")
    Write-Host (Get-UrlEncodedString ")")
    Write-Host (Get-UrlEncodedString "*")
    Write-Host (Get-UrlEncodedString "+")
    Write-Host (Get-UrlEncodedString ",")
    Write-Host (Get-UrlEncodedString "-") # そのまま
    Write-Host (Get-UrlEncodedString ".") # そのまま
    Write-Host (Get-UrlEncodedString "/")

    Write-Host (Get-UrlEncodedString "0") # そのまま
    Write-Host (Get-UrlEncodedString "9") # そのまま
    Write-Host (Get-UrlEncodedString ":")
    Write-Host (Get-UrlEncodedString ";")
    Write-Host (Get-UrlEncodedString "<")
    Write-Host (Get-UrlEncodedString "=")
    Write-Host (Get-UrlEncodedString ">")
    Write-Host (Get-UrlEncodedString "?")

    Write-Host (Get-UrlEncodedString "@")
    Write-Host (Get-UrlEncodedString "A") # そのまま
    Write-Host (Get-UrlEncodedString "Z") # そのまま
    Write-Host (Get-UrlEncodedString "[")
    Write-Host (Get-UrlEncodedString "\")
    Write-Host (Get-UrlEncodedString "]")
    Write-Host (Get-UrlEncodedString "^")
    Write-Host (Get-UrlEncodedString "_") # そのまま
    
    Write-Host (Get-UrlEncodedString "``")
    Write-Host (Get-UrlEncodedString "a") # そのまま
    Write-Host (Get-UrlEncodedString "z") # そのまま
    Write-Host (Get-UrlEncodedString "{")
    Write-Host (Get-UrlEncodedString "|")
    Write-Host (Get-UrlEncodedString "}")
    Write-Host (Get-UrlEncodedString "~") # そのまま
}

function Test-Get-UrlDecodedString {
    Write-Host (Get-UrlDecodedString (Get-UrlEncodedString " "))
    Write-Host (Get-UrlDecodedString (Get-UrlEncodedString "!"))
    Write-Host (Get-UrlDecodedString (Get-UrlEncodedString '"'))
    Write-Host (Get-UrlDecodedString (Get-UrlEncodedString "#"))
    Write-Host (Get-UrlDecodedString (Get-UrlEncodedString "$"))
    Write-Host (Get-UrlDecodedString (Get-UrlEncodedString "%"))
    Write-Host (Get-UrlDecodedString (Get-UrlEncodedString "&"))
    Write-Host (Get-UrlDecodedString (Get-UrlEncodedString "'"))
    Write-Host (Get-UrlDecodedString (Get-UrlEncodedString "("))
    Write-Host (Get-UrlDecodedString (Get-UrlEncodedString ")"))
    Write-Host (Get-UrlDecodedString (Get-UrlEncodedString "*"))
    Write-Host (Get-UrlDecodedString (Get-UrlEncodedString "+"))
    Write-Host (Get-UrlDecodedString (Get-UrlEncodedString ","))
    Write-Host (Get-UrlDecodedString (Get-UrlEncodedString "-")) # そのまま
    Write-Host (Get-UrlDecodedString (Get-UrlEncodedString ".")) # そのまま
    Write-Host (Get-UrlDecodedString (Get-UrlEncodedString "/"))

    Write-Host (Get-UrlDecodedString (Get-UrlEncodedString "0")) # そのまま
    Write-Host (Get-UrlDecodedString (Get-UrlEncodedString "9")) # そのまま
    Write-Host (Get-UrlDecodedString (Get-UrlEncodedString ":"))
    Write-Host (Get-UrlDecodedString (Get-UrlEncodedString ";"))
    Write-Host (Get-UrlDecodedString (Get-UrlEncodedString "<"))
    Write-Host (Get-UrlDecodedString (Get-UrlEncodedString "="))
    Write-Host (Get-UrlDecodedString (Get-UrlEncodedString ">"))
    Write-Host (Get-UrlDecodedString (Get-UrlEncodedString "?"))

    Write-Host (Get-UrlDecodedString (Get-UrlEncodedString "@"))
    Write-Host (Get-UrlDecodedString (Get-UrlEncodedString "A")) # そのまま
    Write-Host (Get-UrlDecodedString (Get-UrlEncodedString "Z")) # そのまま
    Write-Host (Get-UrlDecodedString (Get-UrlEncodedString "["))
    Write-Host (Get-UrlDecodedString (Get-UrlEncodedString "\"))
    Write-Host (Get-UrlDecodedString (Get-UrlEncodedString "]"))
    Write-Host (Get-UrlDecodedString (Get-UrlEncodedString "^"))
    Write-Host (Get-UrlDecodedString (Get-UrlEncodedString "_")) # そのまま
    
    Write-Host (Get-UrlDecodedString (Get-UrlEncodedString "``"))
    Write-Host (Get-UrlDecodedString (Get-UrlEncodedString "a")) # そのまま
    Write-Host (Get-UrlDecodedString (Get-UrlEncodedString "z")) # そのまま
    Write-Host (Get-UrlDecodedString (Get-UrlEncodedString "{"))
    Write-Host (Get-UrlDecodedString (Get-UrlEncodedString "|"))
    Write-Host (Get-UrlDecodedString (Get-UrlEncodedString "}"))
    Write-Host (Get-UrlDecodedString (Get-UrlEncodedString "~")) # そのまま
}
