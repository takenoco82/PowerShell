<#
.SYNOPSIS
ここに概要を書きます

.DESCRIPTION
ここに説明を書きます

.EXAMPLE
.\Template.ps1 -Param abc

例の解説を書きます

.EXAMPLE
.\Template.ps1 -Param1 123 -Param2 bar -Param3 fuga -Param4 a,i,u,e,o

例の解説を書きます

.LINK
http://example.com/
#>

# ==========================================================
# 引数
# ==========================================================
param (
    # パラメーターの説明を書きます。
    [Parameter(Mandatory=$true)]
    [string]$Param1,

    # パラメーターの説明を書きます。
    [Parameter()]
    [string]$Param2="foo",

    # パラメーターの説明を書きます。
    [Parameter()]
    [ValidateSet("hoge", "fuga")]
    [string]$Param3="hoge",

    # パラメーターの説明を書きます。
    [Parameter()]
    [string[]]$Param4=@("aha","ihi","ufu")
)


# ==========================================================
# スクリプトの挙動制御
# ==========================================================

# 未初期化変数の参照を禁止する
Set-StrictMode -Version Latest

# ユーザー定義変数
$ErrorActionPreference = "Stop"
$WarningPreference = "Continue"
$VerbosePreference = "Continue"
$DebugPreference = "Continue"


# ==========================================================
# 定数
# ==========================================================
$SCRPT_FILE = $MyInvocation.MyCommand.Path
$SCRPT_FILENAME = $MyInvocation.MyCommand.Name
$SCRPT_DIR = Split-Path -Path $SCRPT_FILE


# ==========================================================
# 関数
# ==========================================================

function ValidateParameter ([string]$Param1, 
                            [string]$Param2,
                            [string]$Param3,
                            [string[]]$Param4) {
    Write-Debug "Param1=$Param1"
    Write-Debug "Param2=$Param2"
    Write-Debug "Param3=$Param3"
    Write-Debug "Param4=$($Param4 -join ",")"
    
    # do something
    if ($false) {
        throw [System.ArgumentException] "メッセージ"
    }
}

function LoadConfig () {
    Write-Debug "設定を読み込みます。"

    # ホントはテキストファイルから読み込む
    $properties = @'
key1=value1
key2=value2
key3=value3
'@
    ConvertFrom-StringData -StringData $properties
}

function WriteUsage () {
    Write-Host @"
Usage:
  PS> Get-Help $SCRPT_FILE -Detailed

"@
}

function CloseResource () {
    Write-Debug "リソースをクローズします。"

    # do something
}

# ==========================================================
# メイン
# ==========================================================

#
# 前処理
#
Write-Verbose "${SCRPT_FILENAME} Start"

try {
    $param = @{
        Param1 = $Param1
        Param2 = $Param2
        Param3 = $Param3
        Param4 = $Param4
    }
    ValidateParameter @param

    $config = LoadConfig
    Write-Debug "config:$(($config.Keys | ForEach-Object { $_ + "=" + $config[$_] }) -join ",")"
} catch [System.ArgumentException] {
    CloseResource
    Write-Warning $_
    WriteUsage
    exit
} catch {
    CloseResource
    throw $_
}

#
# 主処理
#
try {
    # do something
} catch {
    throw $_
} finally {
    CloseResource
}

#
# 後処理
#
Write-Verbose "${SCRPT_FILENAME} Finished"
