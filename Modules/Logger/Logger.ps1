<#
.SYNOPSIS
ログを出力します。

.DESCRIPTION
ログを出力します。ログには、出力日時・ログレベル・メッセージを指定できます。
ログの出力イメージを以下に示します。

  2017-12-29 03:13:17 DEBUG メッセージ

ログファイルの文字コードは UTF8(BOM有り), Shift-JIS のどちらかを指定できます。
文字コードを指定しない場合 Shift-JIS になります。

.EXAMPLE
Out-Log -Message "テスト" -Level DEBUG -FilePath ~\Desktop\test.log -Encoding UTF8

メッセージ「テスト」をDEBUGレベルで出力します。
文字コードは UTF8(BOM有り) になります。

.EXAMPLE
"テスト1","テスト2" | Out-Log -Level ERROR -FilePath .\test.log

メッセージ「テスト1」,「テスト2」をそれぞれERRORレベルで出力します。
文字コードは Shift-JIS になります。
#>
function Out-Log {
    [CmdletBinding()]
    param (
        # ログに出力するメッセージを指定します。
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   Position=0)]
        [string]$Message,

        # ログレベルを指定します。
        # Error, Warn, Info, Debug の4種類から指定できます。
        [Parameter(Mandatory=$true)]
        [ValidateSet("Error", "Warn", "Info", "Debug")]
        [string]$Level,

        # ログファイルのパスを指定します。
        # 相対パスでの指定も可能です。
        [Parameter(Mandatory=$true)]
        [string]$FilePath,

        # ログファイルの文字コードを指定します。
        # 以下の2種類から指定できます。指定しない場合 Shift-JIS になります。
        #
        #   UTF8   : UTF8(BOM有り)
        #   Default: Shift-JIS
        [Parameter()]
        [ValidateSet("Default", "UTF8")]
        [string]$Encoding="Default"
    )
    
    begin {
        Write-Debug "Level=${Level}"
        Write-Debug "FilePath=${FilePath}"
        Write-Debug "Encoding=${Encoding}"
        Write-Debug "Delimiter=${Delimiter}"

        $logDir = Split-Path $FilePath -Parent
        try {
            if (-not (Test-Path $logDir -PathType Container)) {
                New-Item -Path $logDir -ItemType Directory -ErrorAction Stop > $null
            }
        } catch [System.Management.Automation.ParameterBindingException] {
            $msg = "パラメーター '{0}' に指定された値 '{1}' は無効です。" -f "FilePath", $FilePath
            Write-Warning $msg
            throw $_
        } catch [System.IO.IOException] {
            Write-Warning "ディレクトリの作成に失敗しました。${logDir}"
            throw $_
        }
    }
    
    process {
        Write-Debug "Message=${Message}"
        
        $now = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        $msg = "{0} {1, -5} {2}" -f $now, $Level, $Message
        $msg | Out-File -FilePath $FilePath -Encoding $Encoding -Append -ErrorAction Stop
    }
    
    end {}
}

<#
.SYNOPSIS
Loggerオブジェクトを返却します。

.DESCRIPTION
Loggerオブジェクトを返却します。
ログを出力する際に、ファイルパスなどを毎回指定する必要がなくなります。
使い方のイメージを以下に示します。

  $logger = Get-Logger -FilePath ~\Desktop\test.log -Encoding UTF8
  $logger.Debug("テスト")
  $logger.Info("テスト")
  $logger.Warn("テスト")
  $logger.Error("テスト")

.EXAMPLE
$logger = Get-Logger -FilePath ~\Desktop\test.log -Encoding UTF8

ログファイル test.log、文字コード UTF8(BOM有り) の Loggerオブジェクトを $logger に設定します。

.EXAMPLE
$logger.Debug("テスト")

メッセージ「テスト」をDEBUGレベルで出力します。
#>
function Get-Logger {
    [CmdletBinding()]
    [OutputType([PSObject])]
    param (
        [Parameter(Mandatory=$true)]
        [string]$FilePath,

        [Parameter()]
        [ValidateSet("Default", "UTF8")]
        [string]$Encoding="Default"
    )
    
    $logger = New-Object -TypeName PSObject -Property @{
        FilePath = $FilePath
        Encoding = $Encoding
    }

    # メソッド
    $logger | Add-Member -MemberType ScriptMethod -Name Error -Value {
        param([string]$Message)
        Out-Log $Message -Level Error -FilePath $this.FilePath -Encoding $this.Encoding
    }
    $logger | Add-Member -MemberType ScriptMethod -Name Warn -Value {
        param([string]$Message)
        Out-Log $Message -Level Warn -FilePath $this.FilePath -Encoding $this.Encoding
    }
    $logger | Add-Member -MemberType ScriptMethod -Name Info -Value {
        param([string]$Message)
        Out-Log $Message -Level Info -FilePath $this.FilePath -Encoding $this.Encoding
    }
    $logger | Add-Member -MemberType ScriptMethod -Name Debug -Value {
        param([string]$Message)
        Out-Log $Message -Level Debug -FilePath $this.FilePath -Encoding $this.Encoding
    }

    $logger
}

function Test-Out-Log {
    Out-Log "test" -Level Error -FilePath ~/tmp/Out-Log.log -Encoding UTF8
    Out-Log "test" -Level Warn -FilePath ~/tmp/Out-Log.log -Encoding UTF8
    Out-Log "test" -Level Info -FilePath ~/tmp/Out-Log.log -Encoding UTF8
    Out-Log "test" -Level Debug -FilePath ~/tmp/Out-Log.log -Encoding UTF8
}

function Test-Get-Logger {
    $logger = Get-Logger -FilePath ~/tmp/Out-Log.log -Encoding UTF8
    $logger.Error("test2")
    $logger.Warn("test2")
    $logger.Info("test2")
    $logger.Debug("test2")
}
