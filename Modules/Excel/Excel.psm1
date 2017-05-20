﻿function Import-ExcelTable {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $True)]
        [string]$Path,
        [Parameter(Mandatory = $True)]
        [string[]]$TableName,
        [string[]]$Header
    )

    Write-Verbose "`$Path=$Path"
    if ($TableName -ne $null) { Write-Verbose "`$TableName=$($TableName -join ', ')" }
    if ($Header -ne $null) { Write-Verbose "`$Header=$($Header -join ', ')" }

    try {
        # ファイル存在チェック
        if (!(Test-Path -Path $Path)) {
            Write-Error "ファイルが存在しません。Path=$Path"
            return
        }

        $xlApp = New-Object -ComObject "Excel.Application"
        #$xlApp.Visible = $true

        $xlBook = $xlApp.Workbooks.Open($Path, 0, $true)
        $xlTables = Get-Table $xlBook $TableName

        $IsFirst = $true
        foreach ($xlTable in $xlTables) {
            # ヘッダーの項目数チェック
            if ($IsFirst) {
                if ($Header -ne $null -and $Header.Length -lt $xlTable.ListColumns.Count) {
                    $ColumnCount = $xlTable.ListColumns.Count
                    $HeaderStr = $Header -join ", "
                    Write-Error "ヘッダーの項目数が足りません。テーブルの項目数=$ColumnCount, Header=$HeaderStr"
                    return
                }
                $IsFirst = $false
            }

            Get-TableRow $xlTable $Header
        }

    } catch [System.ArgumentException] {
        Write-Error $Error[0]
    } catch [System.Exception] {
        Write-Error $Error[0]
    } finally {
        if ($xlBook -ne $null) {
            $xlBook.Close()
            $xlBook = $null
        }

        if ($xlApp -ne $null) {
            $xlApp.Quit()
            $xlApp = $null
        }

        # http://eriverjp.azurewebsites.net/2016/02/08/powershell-excel-exe%E3%81%8C%E3%82%B9%E3%82%AF%E3%83%AA%E3%83%97%E3%83%88%E7%B5%82%E4%BA%86%E3%81%97%E3%81%A6%E3%82%82%E6%B6%88%E3%81%88%E3%81%AA%E3%81%84/
        [System.GC]::Collect()
    }
}

function Get-Table {
    param(
        [Object]$xlBook,
        [string[]]$TableName
    )

    $map = [ordered]@{}
    foreach ($xlSheet in $xlBook.Worksheets) {
        $xlTables = $xlSheet.ListObjects
        foreach ($xlTable in $xlTables) {
            $map.Add($xlTable.Name, $xlTable)
        }
        $xlSheet = $null
    }

    foreach ($key in $TableName) {
        if ($map.Contains($key)) {
            $map.Item($key)
        } else {
            $message = [String]::Format("テーブル '{0}' が見つかりません。", $key)
            throw New-Object "System.ArgumentException" $message
        }
    }
}

function Get-TableRow {
    param(
        [Object]$xlTable,
        [string[]]$Header
    )

    begin { }

    process {
        foreach ($row in $xlTable.ListRows) {
            # 並び順を追加した順番とおりにする
            # http://tech.guitarrapc.com/entry/2013/03/20/200351
            $map = [ordered]@{}

            $isBlankRow = $true
            foreach ($col in $xlTable.ListColumns) {
                $ColumnName = $col.Name
                if ($Header -ne $null) {
                    # 気持ち悪いけど Index が 1 から始まる
                    $ColumnName = $Header[$col.Index - 1]
                }
                $ColumnValue = $row.Range.Item($col.Index).Value()
                $map.Add($ColumnName, $ColumnValue)
                if ($isBlankRow -and ($null -ne $ColumnValue)) {
                    $isBlankRow = $false
                }
            }

            if (!$isBlankRow) {
                [PSCustomObject]$map
            }
        }
    }
}

Export-ModuleMember -Function Import-ExcelTable
