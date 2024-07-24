function php_artisan {
    php artisan ${Args} 
}
Set-Alias -Name art -Value php_artisan


@('art', 'php') | ForEach-Object {
    Register-ArgumentCompleter -CommandName $_ -Native -ScriptBlock {
        param($wordToComplete, $commandAst, $cursorPosition)

        $commandPreElements = @()
        $artFound = $false
        foreach ($commandElement in $commandAst.CommandElements) {
        
            if ($commandElement.Extent.EndOffset -ge $cursorPosition) {
                break
            }

            if (-not $artFound -and (Split-Path $commandElement -Leaf) -like 'art*') {
                $artFound = $true
            }
            elseif ($artFound) {
                $commandPreElements += $commandElement
            }
        }

        if (-not $artFound) {
            return
        }

        if ($commandPreElements.Count -eq 0) {
            php artisan --format=json | 
                ConvertFrom-Json | 
                Select-Object -ExpandProperty 'commands' | 
                Where-Object { $_.hidden -ne $true -and $_.name -like "$wordToComplete*" } |
                ForEach-Object { 
                    [System.Management.Automation.CompletionResult]::new(
                        $_.name,
                        $_.name,
                        'Command',
                        $_.description)
                }

                return
            }
            elseif ('--' -notin $commandPreElements) {
                php artisan --format=json | 
                    ConvertFrom-Json | 
                    Select-Object -ExpandProperty 'commands' | 
                    Where-Object { $_.name -eq $commandPreElements[0] } | 
                    Select-Object -ExpandProperty 'definition' | 
                    Select-Object -ExpandProperty 'options' | 
                    ForEach-Object { $_.psobject.properties.Value } | 
                    ForEach-Object { 
                        $description = $_.description; 
                        @{
                            name        = $_.name; 
                            description = $description 
                        };
                        
                        $_.shortcut -split '\|' | 
                            Where-Object { $_ -ne '' } | 
                            ForEach-Object { 
                                @{
                                    name        = $_; 
                                    description = $description 
                                } 
                            } 
                        } | 
                        Where-Object { $_.name -like "$wordToComplete*" } |
                        ForEach-Object { 
                            [System.Management.Automation.CompletionResult]::new(
                                $_.name,
                                $_.name,
                                'ParameterName',
                                $_.description)
                        }
            
                        return
                    }
                }
            }