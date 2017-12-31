function Out-Log {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   Position=0)]
        [string]$Message,

        [Parameter(Mandatory=$true)]
        [ValidateSet("Error", "Warn", "Info", "Debug")]
        [string]$Level,

        [Parameter(Mandatory=$true)]
        [string]$FilePath,

        [Parameter()]
        [ValidateSet("Default", "UTF8")]
        [string]$Encoding="Default"
    )
    
    begin {}
    
    process {
        $now = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss")
        $msg = [string]::Format("{0} {1, -5} {2}", $now, $Level, $Message)
        $msg | Out-File -FilePath $FilePath -Encoding $Encoding -Append
    }
    
    end {}
}

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

    return $logger
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
