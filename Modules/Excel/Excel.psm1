function Import-ExcelTable {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $True)]
        [string]$Path,
        [string[]]$TableName,
        [string[]]$Header
    )

    Write-Verbose "`$Path=$Path"
    if ($TableName -ne $null) { Write-Verbose "`$TableName=$($TableName -join ', ')" }
    if ($Header -ne $null) { Write-Verbose "`$Header=$($Header -join ', ')" }

    try {
        $AbsolutePath = Get-AbsolutePath $Path

        $xlApp = New-Object -ComObject "Excel.Application"
        #$xlApp.Visible = $true

        $xlBook = $xlApp.Workbooks.Open($AbsolutePath, 0, $true)
        $xlTables = Get-Table $xlBook $TableName

        $IsFirst = $true
        foreach ($xlTable in $xlTables) {
            # ヘッダーの項目数チェック
            if ($IsFirst) {
                Verify-Header $xlTable $Header
                $IsFirst = $false
            }

            Get-TableRow $xlTable $Header
        }

    } catch [System.ArgumentException] {
        Write-Error $_
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

function Get-AbsolutePath {
    param(
        [string]$Path
    )

    if (Test-Path -Path $Path) {
        return (Resolve-Path $Path).Path
    }

    $message = [String]::Format("ファイル '{0}' が見つかりません。", $Path)
    throw New-Object "System.ArgumentException" $message
}

function Get-Table {
    param(
        [Object]$xlBook,
        [string[]]$TableName
    )

    begin {
        function Get-AllTable {
            param(
                [Object]$xlBook
            )

            $existTable = $false
            foreach ($xlSheet in $xlBook.Worksheets) {
                $xlTables = $xlSheet.ListObjects
                foreach ($xlTable in $xlTables) {
                    $xlTable
                    $existTable = $true
                }
                $xlSheet = $null
            }

            if (-not $existTable) {
                $message = "テーブルが見つかりません。"
                throw New-Object "System.ArgumentException" $message
            }
        }

        function Get-SpecificTable {
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
    }

    end {
        if ($null -eq $TableName) {
            Get-AllTable $xlBook
        } else {
            Get-SpecificTable $xlBook $TableName
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

function Verify-Header {
    param(
        [Object]$xlTable,
        [string[]]$Header
    )

    if ($null -eq $Header) {
        return
    }

    if ($Header.Length -ge $xlTable.ListColumns.Count) {
        return
    }

    $message = [String]::Format(
        "パラメーター '{0}' の数が足りません。テーブル '{1}' の項目数 '{2}' に合わせてパラメーターを指定してください。", 
        "Header", 
        $xlTable.Name, 
        $xlTable.ListColumns.Count)
    throw New-Object "System.ArgumentException" $message
}

Export-ModuleMember -Function Import-ExcelTable
