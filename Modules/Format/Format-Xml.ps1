<#
.SYNOPSIS
XMLをインデントします。

.DESCRIPTION
指定されたXML文字列を半角スペースやタブでインデントして返却します。

.EXAMPLE
Format-Xml $xmlStr

XML文字列 $xmlStr を半角スペース2つでインデントします。

.EXAMPLE
Get-Content .\test.xml -Encoding UTF8 | Format-Xml -IndentChar "`t" -Indentation 1

test.xml を読み込み、タブでインデントします。

#>
function Format-Xml
{
    [CmdletBinding()]
    [OutputType([string])]
    Param
    (
        # フォーマットするXML文字列を指定します。
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   Position=0)]
        [string]$Xml,

        # インデントする際の文字を指定します。指定しない場合 ' '(半角スペース) になります。
        [Parameter()]
        [string]$IndentChar=" ",

        # IndentChar でインデントする際の数を指定します。指定しない場合 2 になります。
        [Parameter()]
        [int]$Indentation=2
    )

    Begin {
        Write-Debug "IndentChar=${IndentChar}"
        Write-Debug "Indentation=${Indentation}"

        function Close-Resource {
            $xmlWriter.Close()
            $stringWriter.Close()
        }
    }

    Process {
        Write-Debug "Xml=${Xml}"

        $stringWriter = New-Object System.IO.StringWriter
        $xmlWriter = New-Object System.XMl.XmlTextWriter $stringWriter
        $xmlWriter.Formatting = [System.XML.Formatting]::Indented
        $xmlWriter.IndentChar = $IndentChar
        $xmlWriter.Indentation = $Indentation

        try {
            $xmldoc = [xml]$Xml
            $xmldoc.WriteContentTo($xmlWriter)
            $xmlWriter.Flush()
            $stringWriter.Flush()
            Write-Output $stringWriter.ToString()

        } catch [System.Management.Automation.PSInvalidCastException] {
            $msg = [string]::Format("パラメーター '{0}' に指定された値は無効なXMLです。{0}={1}", "Xml", $Xml)
            Write-Warning $msg
            Close-Resource
            throw
        } catch [System.Exception] {
            Write-Warning "予期せぬエラーが発生しました。"
            Close-Resource
            throw
        }
    }

    End {
        Close-Resource
    }
}
