﻿#=============================================================================
# Main

function Start-InteractiveFilter {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [Object[]]$InputObject,
        [switch]$NoSelect
    )

    begin {
        # 初期化
        $CONTEXT = New-Context
        $Session = New-Session $NoSelect

        Backup-ScrBuf $Session

        Out-Log 'INFO' 'Start' '$Session.InputObject.Add()'
        $buf = New-Object "System.Collections.Generic.List[Object]"
    }
    process {
        # InputObject を格納する
        foreach ($item in $InputObject) {
            $buf.Add($item)
        }
    }
    end {
        $Session.InputObject = $buf
        Out-Log 'INFO' 'End' '$Session.InputObject.Add()'
        foreach ($item in $Session.InputObject) {
            $objectType = $CONTEXT.ObjectType.($item.GetType().FullName)
            if ($objectType -eq $null) {
                $objectType = $CONTEXT.ObjectType.($item.GetType().BaseType.FullName)
            }

            # クエリにプロパティの指定がない場合に使用するプロパティを取得
            $Session.DefaultTargetProperty = $objectType.DefaultTargetProperty
            # フィルタ結果の表示設定を取得
            $Session.Header = $objectType.ViewProperty
            break
        }

        # 画面の初期表示
        Show-InitialScreen $Session

        # 入力待ち状態になり、入力に応じてActionを実行する
        Wait-InputKey $Session

        Restore-ScrBuf $Session

        # フィルタ結果を返却する
        Out-Log 'INFO' 'Start' 'return $Session.ResultObject'
        if ($NoSelect) {
            $Session.ResultObject
        } else {
            $Session.ResultObject[$Session.SelectedIndex]
        }
        Out-Log 'INFO' 'End' 'return $Session.ResultObject'
    }
}

function Wait-InputKey ($Session) {
    while ($true) {
        $keyInfo = [System.Console]::ReadKey($true)
        $key = $keyInfo.Key
        switch ($keyInfo.Modifiers) {
            "Shift"   { $key = "S-" + $key }
            "Control" { $key = "C-" + $key }
            "Alt"     { $key = "M-" + $key }
            default   {}
        }

        $action = $CONTEXT.KeyMap.Item([string]$key)
        Invoke-Action $Session $action $keyInfo.KeyChar

        if ($action -eq "Finish" -or $Action -eq "Cancel") {
            break
        }
    }
}

#=============================================================================
# Initialize

function New-Context {
    $CONTEXT_JSON = @'
{
    "Prompt" : "QUERY> ",
    "Style" : {
        "Selected" : {
            "ForegroundColor" : "White",
            "BackgroundColor" : "Magenta"
        }
    },
    "Layout" : {
        "ResultMarginTop" : 1,
        "MarginBottom" : 2,
        "SelectedInitialPosition" : null
    },
    "KeyMap" : null,
    "FilterType" : [
        "IgnoreCase",
        "CaseSensitive",
        "RegExp",
        "Exact"
    ],
    "DefaultCondition" : {
        "FilterType" : "IgnoreCase",
        "Limit" : null,
        "KeywordSeparator" : " ",
        "PropertyPrefix" : ":",
        "NotPrefix" : "!"
    },
    "ObjectType" : {
        "System.IO.FileSystemInfo": {
            "ViewProperty"          : ["Mode", "FullName"],
            "DefaultTargetProperty" : "FullName"
        },
        "Microsoft.PowerShell.Commands.HistoryInfo": {
            "ViewProperty"          : ["Id", "CommandLine"],
            "DefaultTargetProperty" : "CommandLine"
        }
    },
    "Operator" : [
        { "Operator": "ceq",       "FilterType": "Exact",         "Not": false },
        { "Operator": "cne",       "FilterType": "Exact",         "Not": true  },
        { "Operator": "ilike",     "FilterType": "IgnoreCase",    "Not": false },
        { "Operator": "inotlike",  "FilterType": "IgnoreCase",    "Not": true  },
        { "Operator": "clike",     "FilterType": "CaseSensitive", "Not": false },
        { "Operator": "cnotlike",  "FilterType": "CaseSensitive", "Not": true  },
        { "Operator": "cmatch",    "FilterType": "RegExp",        "Not": false },
        { "Operator": "inotmatch", "FilterType": "RegExp",        "Not": true  }
    ],
    "Debug" : true
}
'@

    $Context = ConvertFrom-Json -InputObject $CONTEXT_JSON
    $Context.Layout.SelectedInitialPosition = $Context.Layout.ResultMarginTop + 3
    $Context.KeyMap = @{
        "Enter"       = "Finish"
        "Escape"      = "Cancel"
        "Spacebar"    = "AddChar"
        "Tab"         = "Completion"
        "PageUp"      = "ScrollPageUp"
        "PageDown"    = "ScrollPageDown"
        "End"         = "EndOfLine"
        "Home"        = "BeginningOfLine"
        "LeftArrow"   = "BackwardChar"
        "RightArrow"  = "ForwardChar"
        "UpArrow"     = "SelectUp"
        "DownArrow"   = "SelectDown"
        "Backspace"   = "DeleteBackwardChar"
        "Delete"      = "DeleteForwardChar"
        "A"           = "AddChar"
        "B"           = "AddChar"
        "C"           = "AddChar"
        "D"           = "AddChar"
        "E"           = "AddChar"
        "F"           = "AddChar"
        "G"           = "AddChar"
        "H"           = "AddChar"
        "I"           = "AddChar"
        "J"           = "AddChar"
        "K"           = "AddChar"
        "L"           = "AddChar"
        "M"           = "AddChar"
        "N"           = "AddChar"
        "O"           = "AddChar"
        "P"           = "AddChar"
        "Q"           = "AddChar"
        "R"           = "AddChar"
        "S"           = "AddChar"
        "T"           = "AddChar"
        "U"           = "AddChar"
        "V"           = "AddChar"
        "W"           = "AddChar"
        "X"           = "AddChar"
        "Y"           = "AddChar"
        "Z"           = "AddChar"
        "D0"          = "AddChar" # 0
        "D1"          = "AddChar" # 1
        "D2"          = "AddChar" # 2
        "D3"          = "AddChar" # 3
        "D4"          = "AddChar" # 4
        "D5"          = "AddChar" # 5
        "D6"          = "AddChar" # 6
        "D7"          = "AddChar" # 7
        "D8"          = "AddChar" # 8
        "D9"          = "AddChar" # 9
        "Oem1"        = "AddChar" # :
        "OemPlus"     = "AddChar" # ;
        "OemComma"    = "AddChar" # ,
        "OemMinus"    = "AddChar" # -
        "OemPeriod"   = "AddChar" # .
        "Oem2"        = "AddChar" # /
        "Oem3"        = "AddChar" # @
        "Oem4"        = "AddChar" # [
        "Oem5"        = "AddChar" # \
        "Oem6"        = "AddChar" # ]
        "Oem7"        = "AddChar" # ^
        "Oem102"      = "AddChar" # ^
        "S-A"         = "AddChar" # \
        "S-B"         = "AddChar"
        "S-C"         = "AddChar"
        "S-D"         = "AddChar"
        "S-E"         = "AddChar"
        "S-F"         = "AddChar"
        "S-G"         = "AddChar"
        "S-H"         = "AddChar"
        "S-I"         = "AddChar"
        "S-J"         = "AddChar"
        "S-K"         = "AddChar"
        "S-L"         = "AddChar"
        "S-M"         = "AddChar"
        "S-N"         = "AddChar"
        "S-O"         = "AddChar"
        "S-P"         = "AddChar"
        "S-Q"         = "AddChar"
        "S-R"         = "AddChar"
        "S-S"         = "AddChar"
        "S-T"         = "AddChar"
        "S-U"         = "AddChar"
        "S-V"         = "AddChar"
        "S-W"         = "AddChar"
        "S-X"         = "AddChar"
        "S-Y"         = "AddChar"
        "S-Z"         = "AddChar"
        "S-D1"        = "AddChar" # !
        "S-D2"        = "AddChar" # "
        "S-D3"        = "AddChar" # #
        "S-D4"        = "AddChar" # $
        "S-D5"        = "AddChar" # %
        "S-D6"        = "AddChar" # &
        "S-D7"        = "AddChar" # '
        "S-D8"        = "AddChar" # (
        "S-D9"        = "AddChar" # )
        "S-Oem1"      = "AddChar" # *
        "S-OemPlus"   = "AddChar" # +
        "S-OemComma"  = "AddChar" # <
        "S-OemMinus"  = "AddChar" # =
        "S-OemPeriod" = "AddChar" # >
        "S-Oem2"      = "AddChar" # ?
        "S-Oem3"      = "AddChar" # `
        "S-Oem4"      = "AddChar" # {
        "S-Oem5"      = "AddChar" # |
        "S-Oem6"      = "AddChar" # }
        "S-Oem7"      = "AddChar" # ~
        "S-Oem102"    = "AddChar" # _
        "C-H"         = "DeleteBackwardChar"
        "C-K"         = "KillEndOfLine"
        "C-N"         = "SelectDown"
        "C-P"         = "SelectUp"
        "C-R"         = "RotateFilter"
        "C-U"         = "KillBeginningOfLine"
    }
    $Context
}

function New-Session ($NoSelect) {
    @{
        Query = ""
        FilterType = $CONTEXT.DefaultCondition.FilterType
        Offset = 1
        PromptCursorPosition = @{
            X = $CONTEXT.Prompt.Length
            Y = 0
        }
        NoSelect = $NoSelect
        InputObject = $null
        ResultObject = New-Object "System.Collections.Generic.List[Object]"
        HasNextPage = $false
        Header = $null
        DefaultTargetProperty = $null
        SelectedIndex = 0
        Screen = $null
    }
}

#=============================================================================
# Action

function Invoke-Action ($Session, [string]$Action, [string]$Char) {
    switch ($Action) {
        "Finish"              { break }
        "Cancel"              { Clear-Result $Session; break }
        "AddChar"             { Add-Char $Session $Char; break }
        "DeleteBackwardChar"  { Remove-BackwardChar $Session; break }
        "DeleteForwardChar"   { Do-Something; break }
        "KillBeginningOfLine" { Remove-HeadLine $Session; break }
        "KillEndOfLine"       { Do-Something; break }
        "ScrollPageUp"        { Move-PreviousPage $Session; break }
        "ScrollPageDown"      { Move-NextPage $Session; break }
        "EndOfLine"           { Do-Something; break }
        "BeginningOfLine"     { Do-Something; break }
        "ForwardChar"         { Do-Something; break }
        "BackwardChar"        { Do-Something; break }
        "SelectUp"            { Move-SelectedUp $Session; break }
        "SelectDown"          { Move-SelectedDown $Session; break }
        "RotateFilter"        { SWitch-FilterType $Session; break }
        "Complement"          { Do-Something; break }
        default               {}
    }
}

function Do-Something ([String]$Char) {
}

# キャンセル
function Clear-Result ($Session) {
    # 前回のフィルタ結果が残っているのでクリアする
    $Session.ResultObject.Clear()
}

# 初期表示
function Show-InitialScreen ($Session) {
    Out-Log 'INFO' 'Start' 'Show-InitialScreen'
    # 検索条件の初期化
    $Session.Query = ""
    $Session.FilterType = $CONTEXT.DefaultCondition.FilterType
    $Session.Offset = 1

    # プロンプトカーソル位置の初期化
    $Session.PromptCursorPosition.X = $CONTEXT.Prompt.Length

    # 選択カーソル位置の初期化
    $Session.SelectedIndex = 0

    # 検索
    Search-Object $Session

    # 画面の表示
    Write-Screen $Session
    Out-Log 'INFO' 'End' 'Show-InitialScreen'
}

function Search-Object ($Session) {
    $limit = Get-Limit
    $param = @{
        Query = $Session.Query
        FilterType = $Session.FilterType
        InputObject = $Session.InputObject
        DefaultTargetProperty = $Session.DefaultTargetProperty
        Limit = $limit + 1
        Offset = $Session.Offset
    }

    # フィルタ結果をSessionに保存
    $Session.ResultObject.Clear()
    Filter-Object @param |
        % -Process { $Session.ResultObject.Add($_) } -End {
            # 次ページが有れば余分に取得した1件を削除する
            if ($Session.ResultObject.Count -gt $limit) {
                $Session.ResultObject.RemoveAt($Session.ResultObject.Count - 1)
                $Session.HasNextPage = $true
            } else {
                $Session.HasNextPage = $false
            }
        }
}

function Add-Char ($Session, [String]$Char) {
    Out-Log 'INFO' 'Start' 'Add-Char'
    Out-Log 'DEBUG' 'Add-Char' '$Char' $Char
    # 検索条件の更新
    $Session.Query += $Char
    $Session.Offset = 1

    # プロンプトカーソル位置の更新
    $Session.PromptCursorPosition.X++

    # 入力された文字がスペースの場合、プロンプトを更新して終了
    if ($Char -eq $CONTEXT.DefaultCondition.KeywordSeparator) {
        Write-Prompt $Session.Query $Session.PromptCursorPosition $Session.FilterType $Session.Offset
        return
    }

    # 検索
    Search-Object $Session

    # 選択カーソル位置の補正
    Update-SelectIndex $Session

    # 画面の表示
    Write-Screen $Session
    Out-Log 'INFO' 'End' 'Add-Char'
}

function Update-SelectIndex ($Session) {
    if ($Session.ResultObject.Count -eq 0) {
        # 検索結果が0件の場合は1行目に戻す
        $Session.SelectedIndex = 0
    } elseif ($Session.SelectedIndex -gt $Session.ResultObject.Count - 1) {
        # 選択カーソル位置がフィルタ結果の最終行を超えないようにする
        $Session.SelectedIndex = $Session.ResultObject.Count - 1
    }
}

function Remove-BackwardChar ($Session) {
    # クエリがない場合は何もしない
    if ($Session.Query.Length -eq 0) {
        return
    }

    $isRemovedKeywordSeparator = $Session.Query.EndsWith($CONTEXT.DefaultCondition.KeywordSeparator)

    # 検索条件の更新
    $Session.Query = $Session.Query.Substring(0, $Session.Query.Length - 1)
    $Session.Offset = 1

    # プロンプトカーソル位置の更新
    $Session.PromptCursorPosition.X--

    # 削除された文字がスペースの場合、プロンプトを更新して終了
    if ($isRemovedKeywordSeparator) {
        Write-Prompt $Session.Query $Session.PromptCursorPosition $Session.FilterType $Session.Offset
        return
    }

    # 検索
    Search-Object $Session

    # 選択カーソル位置の補正
    Update-SelectIndex $Session

    # 画面の表示
    Write-Screen $Session
}

function Remove-HeadLine ($Session) {
    $removedQueryLength = $Session.PromptCursorPosition.X - $CONTEXT.Prompt.Length

    # カーソル位置が行頭の場合は何もしない
    if ($removedQueryLength -eq 0) {
        return
    }

    # 検索条件の更新
    $Session.Query = $Session.Query.Substring($removedQueryLength,
        $Session.Query.Length - $removedQueryLength)
    $Session.Offset = 1

    # プロンプトカーソル位置の初期化
    $Session.PromptCursorPosition.X = $CONTEXT.Prompt.Length

    # 検索
    Search-Object $Session

    # 選択カーソル位置の補正
    Update-SelectIndex $Session

    # 画面の表示
    Write-Screen $Session
}

function Move-NextPage ($Session) {
    Out-Log 'INFO' 'Start' 'Move-NextPage'
    # 次ページがない場合は何もしない
    if (-not $Session.HasNextPage) {
        return
    }

    # 検索条件の更新
    $Session.Offset++

    # 検索
    Search-Object $Session

    # 選択カーソル位置の補正
    Update-SelectIndex $Session

    # 画面の表示
    Write-Screen $Session
    Out-Log 'INFO' 'End' 'Move-NextPage'
}

function Move-PreviousPage ($Session) {
    # 1ページの場合は何もしない
    if ($Session.Offset -eq 1) {
        return
    }

    # 検索条件の更新
    $Session.Offset--

    # 検索
    Search-Object $Session

    # 選択カーソル位置の補正
    Update-SelectIndex $Session

    # 画面の表示
    Write-Screen $Session
}

function Move-SelectedUp ($Session) {
    if ($Session.NoSelect) {
        return
    }

    # 最初の行が選択されている場合は何もしない
    if ($Session.SelectedIndex -eq 0) {
        return
    }

    # 選択カーソル位置の更新
    $Session.SelectedIndex--

    $resultTable = Get-ResultTable $Session

    # カーソル移動前の行の表示色を戻す
    $preSelectedIndex = $CONTEXT.Layout.SelectedInitialPosition + $Session.SelectedIndex + 1
    Write-Item $resultTable[$preSelectedIndex - 1] `
        -X 0 `
        -Y ($CONTEXT.Layout.ResultMarginTop + $preSelectedIndex - 1) `
        -NoNewline

    # 選択カーソルを表示する
    $selectedIndex = $CONTEXT.Layout.SelectedInitialPosition + $Session.SelectedIndex
    Write-Item $resultTable[$selectedIndex - 1] `
        -X 0 `
        -Y ($CONTEXT.Layout.ResultMarginTop + $selectedIndex - 1) `
        -ForegroundColor $CONTEXT.Style.Selected.ForegroundColor `
        -BackgroundColor $CONTEXT.Style.Selected.BackgroundColor `
        -NoNewline

    # カーソルをプロンプトに戻す
    Move-CursorPosition $Session.PromptCursorPosition.X $Session.PromptCursorPosition.Y
}

function Move-SelectedDown ($Session) {
    Out-Log 'INFO' 'Start' 'Move-SelectedDown'
    if ($Session.NoSelect) {
        return
    }

    # 最後の行が選択されている場合は何もしない
    if ($Session.SelectedIndex -eq ($Session.ResultObject.Count - 1)) {
        return
    }

    # 選択カーソル位置の更新
    $Session.SelectedIndex++

    $resultTable = Get-ResultTable $Session

    # カーソル移動前の行の表示色を戻す
    $preSelectedIndex = $CONTEXT.Layout.SelectedInitialPosition + $Session.SelectedIndex - 1
    Write-Item $resultTable[$preSelectedIndex - 1] `
        -X 0 `
        -Y ($CONTEXT.Layout.ResultMarginTop + $preSelectedIndex - 1) `
        -NoNewline

    # 選択カーソルを表示する
    $selectedIndex = $CONTEXT.Layout.SelectedInitialPosition + $Session.SelectedIndex
    Write-Item $resultTable[$selectedIndex - 1] `
        -X 0 `
        -Y ($CONTEXT.Layout.ResultMarginTop + $selectedIndex - 1) `
        -ForegroundColor $CONTEXT.Style.Selected.ForegroundColor `
        -BackgroundColor $CONTEXT.Style.Selected.BackgroundColor `
        -NoNewline

    # カーソルをプロンプトに戻す
    Move-CursorPosition $Session.PromptCursorPosition.X $Session.PromptCursorPosition.Y

    Out-Log 'INFO' 'End' 'Move-SelectedDown'
}

function SWitch-FilterType ($Session) {
    # 検索条件の更新
    $n = $CONTEXT.FilterType.length
    $i = $CONTEXT.FilterType.IndexOf($Session.FilterType) + 1

    $Session.FilterType = $CONTEXT.FilterType[$i % $n]
    $Session.Offset = 1

    # クエリがない場合はプロンプトを書き換えて終了
    if ($Session.Query.Length -eq 0) {
        Write-Prompt $Session.Query $Session.PromptCursorPosition $Session.FilterType $Session.Offset
        return
    }

    # 検索
    Search-Object $Session

    # 選択カーソル位置の補正
    Update-SelectIndex $Session

    # 画面の表示
    Write-Screen $Session
}

#=============================================================================
# Screen Buffer

# スクリーンバッファのバックアップ
# http://d.hatena.ne.jp/newpops/20080514/p1
function Backup-ScrBuf ($Session) {
    Out-Log 'INFO' 'Start' 'Backup-ScrBuf'
    $rect = New-Object System.Management.Automation.Host.Rectangle
    $rect.Left   = 0
    $rect.Top    = 0
    $rect.Right  = (Get-RawUI).WindowSize.Width  # コンソールWindowの横幅
    $rect.Bottom = (Get-RawUI).CursorPosition.Y  # 現在カーソル位置の行
    $Session.Screen = (Get-RawUI).GetBufferContents($rect)
    Out-Log 'INFO' 'End' 'Backup-ScrBuf'
}

# スクリーンバッファのリストア
function Restore-ScrBuf ($Session) {
    Out-Log 'INFO' 'Start' 'Restore-ScrBuf'
    Clear-Host
    $origin = New-Object System.Management.Automation.Host.Coordinates(0, 0)
    (Get-RawUI).SetBufferContents($origin, $Session.Screen)
    $pos = New-Object System.Management.Automation.Host.Coordinates(0, $Session.Screen.GetUpperBound(0))
    (Get-RawUI).CursorPosition = $pos
    Out-Log 'INFO' 'End' 'Restore-ScrBuf'
}

#=============================================================================
# Write Screen

function Write-Screen ($Session, [switch]$NoClear) {
    if (-not $NoClear) {
        Clear-Host
    }

    # プロンプトを表示
    Write-Prompt $Session.Query $Session.PromptCursorPosition $Session.FilterType $Session.Offset

    # フィルタした結果をホスト画面に表示
    #   そのままオブジェクトを標準出力すると、パイプラインで次のコマンドへ送信されてしまうので、
    #   Write-Hostでホスト画面へのみ出力する。
    if ($Session.ResultObject.Count -ne 0) {
        $resultTable = Get-ResultTable $Session
        Write-Item $resultTable -X 0 -Y $CONTEXT.Layout.ResultMarginTop

        # 選択カーソルを表示する
        $selectedIndex = $CONTEXT.Layout.SelectedInitialPosition + $Session.SelectedIndex
        Write-Item $resultTable[$selectedIndex - 1] `
            -X 0 `
            -Y ($CONTEXT.Layout.ResultMarginTop + $selectedIndex - 1) `
            -ForegroundColor $CONTEXT.Style.Selected.ForegroundColor `
            -BackgroundColor $CONTEXT.Style.Selected.BackgroundColor `
            -NoNewline
    }

    # カーソルをプロンプトに戻す
    Move-CursorPosition $Session.PromptCursorPosition.X $Session.PromptCursorPosition.Y
}

function Get-ResultTable ($Session) {
    $param = $null
    if ($Session.Header -ne $null) {
        $param = @{ Property = $Session.Header }
    }
    $Session.ResultObject | Format-Table -AutoSize @param | Out-String -Stream
}

function Write-Item {
    Param(
        [string[]]$Text,
        [int]$X,
        [int]$Y,
        $ForegroundColor,
        $BackgroundColor,
        [switch]$NoNewline 
    )

    Move-CursorPosition $X $Y

    $param = @{ NoNewline = $NoNewline }
    if ($ForegroundColor -ne $null) {
        $param += @{ ForegroundColor = $ForegroundColor }
    }
    if ($BackgroundColor -ne $null) {
        $param += @{ BackgroundColor = $BackgroundColor }
    }

    foreach ($item in $Text) {
        Write-Host $item @param
    }
}

function Write-Prompt ($Query, $PromptCursorPosition, $FilterType, $Offset) {
    # TODO rhsにページ数が入れたいなぁ
    $lhs = $CONTEXT.Prompt + $Query
    $rhs = [String]::Format("{0} [{1}]", $FilterType, $Offset) 

    # TODO 2行以上の入力に対応が必要かも...
    $WindowWidth = (Get-RawUI).WindowSize.Width
    $rhsWidth = 20
    $lhsWidth = $WindowWidth - $rhsWidth

    $promptFormat = "{0,-$lhsWidth}{1,$rhsWidth}"
    $prompt = [String]::Format($promptFormat, $lhs, $rhs)

    Move-CursorPosition 0 0
    Write-Host $prompt -NoNewLine
    Move-CursorPosition $PromptCursorPosition.X $PromptCursorPosition.Y
}

function Move-CursorPosition ([int]$X, [int]$Y) {
    $coordinate = New-Object System.Management.Automation.Host.Coordinates $X, $Y
    (Get-RawUI).CursorPosition = $coordinate
}

#=============================================================================
# Filter

function Filter-Object {
    [CmdletBinding()]

    param(
        [string]$Query,
        [string]$FilterType = "IgnoreCase",
        [Parameter(ValueFromPipeline=$true)]
        [Object[]]$InputObject,
        [string]$DefaultTargetProperty,
        [int]$Limit = 30,
        [int]$Offset = 1
    )

    begin {
        $param = @{
            Query = $Query
            FilterType = $FilterType
            InputObject = $InputObject
            DefaultTargetProperty = $DefaultTargetProperty
            KeywordSeparator = $CONTEXT.DefaultCondition.KeywordSeparator
            PropertyPrefix = $CONTEXT.DefaultCondition.PropertyPrefix
            NotPrefix = $CONTEXT.DefaultCondition.NotPrefix
        }
        $searchConditions = Parse-Query @param

        # クエリにマッチした件数
        $matchCount = 0
        # 返却したオブジェクトの件数
        $returnCount = 0
        # 返却を開始する位置(1スタート)
        $returnIndex = ($Offset - 1) * $Limit + 1
    }
    process {
        foreach ($item in $InputObject) {
            # 返却したオブジェクトの件数 ≧ 1ページあたりの表示件数 の場合、終了する
            if ($returnCount -ge $Limit) {
                break
            }

            # マッチしたオブジェクトを返却
            if (Test-Match $item $searchConditions) {
                $matchCount++
                if ($matchCount -ge $returnIndex) {
                    $item
                    $returnCount++
                }
            }
        }
    }
}

function Parse-Query {
    param(
        [string]$Query,
        [string]$FilterType = "IgnoreCase",
        [Object[]]$InputObject,
        [string]$DefaultTargetProperty,
        [string]$KeywordSeparator = " ",
        [string]$PropertyPrefix = ":",
        [string]$NotPrefix = "!"
    )

    if ($Query.Length -eq 0 ) {
        return @()
    }

    Out-Log 'DEBUG' 'Parse-Query' '$Query' $Query
    Out-Log 'DEBUG' 'Parse-Query' '$FilterType' $FilterType
    Out-Log 'DEBUG' 'Parse-Query' '$DefaultTargetProperty' $DefaultTargetProperty
    $operator = $CONTEXT.Operator.Where({ $_.FilterType -eq $FilterType }).Operator

    # クエリ文字列をスペースで分割
    $keywords = $Query -split $KeywordSeparator

    $targetProperty = $null
    $not = $false
    $result = @()
    foreach ($keyword in $keywords) {
        # プロパティの判定。1文字目が : かどうか
        if ($keyword.IndexOf($PropertyPrefix) -eq 0) {
            if ($keyword.length -eq 1) {
                continue
            }
            $propertyName = $keyword.Substring(1, $keyword.Length - 1)
            foreach ($item in $InputObject) {
                $targetProperty = Get-PropertyNames $item $propertyName
                break
            }
            continue
        }

        $pattern = $keyword
        # 否定の判定。1文字目が ! かどうか
        if ($keyword.IndexOf($NotPrefix) -eq 0) {
            if ($keyword.length -eq 1) {
                continue
            }
            $not = $true
            $pattern = $keyword.Substring(1, $keyword.Length - 1)
        }

        if ($targetProperty -ne $null) {
            $result += [PSCustomObject] @{
                TargetProperty = $targetProperty
                Pattern = $pattern
                Operator = $operator[$not] }
        } elseif ($DefaultTargetProperty -ne $null) {
            $result += [PSCustomObject] @{
                TargetProperty = $DefaultTargetProperty
                Pattern = $pattern
                Operator = $operator[$not] }
        } else {
            $result += [PSCustomObject] @{
                TargetProperty = $null
                Pattern = $pattern
                Operator = $operator[$not] }
        }

        # プロパティは引き継いだほうがいいかも...
        $targetProperty = $null
        $not = $false
    }

    Out-Log 'DEBUG' 'Parse-Query' '$result' (ConvertTo-Json $result -Compress)
    return $result
}

function Test-Match {
    param(
        [Object]$Item,
        $SearchConditions
    )

    $target = $Item.ToString()

    foreach ($searchCondition in $SearchConditions) {
        $isMatch = $false

        # プロパティが指定してあったら、プロパティに対して検索する
        $targetProperties = $searchCondition.TargetProperty
        foreach ($targetProperty in $targetProperties) {
            if ($targetProperty.Length -ne 0) {
                $target = [string]($Item.$($targetProperty))
            }

            if (Test-MatchInner $target $searchCondition.Pattern $searchCondition.Operator) {
                $isMatch = $true
                break
            }
        }

        if (-not $isMatch) {
            return $false
        }
    }

    return $true
}

function Test-MatchInner {
    param(
        [string]$Target,
        [string]$Pattern,
        [ValidateSet("ieq", "ceq", "ine", "cne", "ilike", "clike", "inotlike", "cnotlike", "imatch", "cmatch", "inotmatch", "cnotmatch")]
        [string]$Operator = "ilike"
    )

    if ($Pattern.Length -eq 0) {
        return $true
    }

    switch ($Operator) {
        "ieq"       { return $Target -ieq       $Pattern }
        "ceq"       { return $Target -ceq       $Pattern }
        "ine"       { return $Target -ine       $Pattern }
        "cne"       { return $Target -cne       $Pattern }
        "ilike"     { return $Target -ilike     ("*" + $Pattern + "*") }
        "clike"     { return $Target -clike     ("*" + $Pattern + "*") }
        "inotlike"  { return $Target -inotlike  ("*" + $Pattern + "*") }
        "cnotlike"  { return $Target -cnotlike  ("*" + $Pattern + "*") }
        "imatch"    { return $Target -imatch    $Pattern }
        "cmatch"    { return $Target -cmatch    $Pattern }
        "inotmatch" { return $Target -inotmatch $Pattern }
        "cnotmatch" { return $Target -cnotmatch $Pattern }
        default     { return $false }
    }
}

#=============================================================================
# Utils

function Get-Limit () {
    if ($CONTEXT.DefaultCondition.Limit -ne $null) {
        return $CONTEXT.DefaultCondition.Limit
    }
    return Get-DefaultLimit
}

# デフォルト表示件数
function Get-DefaultLimit () {
    $WindowHeight = (Get-RawUI).WindowSize.Height
    return $WindowHeight - $CONTEXT.Layout.SelectedInitialPosition - $CONTEXT.Layout.MarginBottom
}

function Out-Log  {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateSet("ERROR", "WARN", "INFO", "DEBUG")]
        [string]$Level,
        [Parameter(ValueFromRemainingArguments=$true)]
        [object[]]$Messages
    )

    if ($CONTEXT.Debug) {
        $message = $Messages.ForEach({ @($_) -join ", " }) -join "`t"
        [string]::Format("{0}`t{1}`t{2}",
            (Get-Date).ToString("yyyy-MM-dd HH:mm:ss.fff"),
            $Level,
            $message) |
            Out-File -FilePath "$env:TMP\peso.log" -Encoding utf8 -Append
    }
}

function Get-RawUI () {
    (Get-Host).UI.RawUI
}

function Get-PropertyNames {
    param(
        [Parameter(Mandatory=$true)]
        [Object]$Item,
        [string]$Name
    )

    $Item |
        Get-Member -Name $Name `
            -MemberType Property, CodeProperty, NoteProperty, AliasProperty, ScriptProperty |
        % { $_.Name }
}
