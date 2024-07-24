function php_artisan {
    php artisan ${Args} 
}
Set-Alias -Name art -Value php_artisan


@('art', 'php') | ForEach-Object {
    Register-ArgumentCompleter -CommandName $_ -Native -ScriptBlock {
        param($wordToComplete, $commandAst, $cursorPosition)

        # First determine whether we're completing the artisan command (e.g. list or db:seed), 
        # or a command parameter (e.g. -vv). For this, collect the command elements that occur 
        # after the "artisan" element is found, and before the current word.
        $commandPreElements = @()
        $artFound = $false
        foreach ($commandElement in $commandAst.CommandElements) {
        
            if ($commandElement.Extent.EndOffset -ge $cursorPosition) {
                # This is the current word
                break
            }

            if (-not $artFound -and (Split-Path $commandElement -Leaf) -like 'art*') {
                # This is the "artisan" element
                $artFound = $true
            }
            elseif ($artFound) {
                $commandPreElements += $commandElement.ToString()
            }
        }

        if (-not $artFound) {
            # We're not running artisan
            return
        }

        if ($commandPreElements.Count -eq 0) {
            # We're completing the artisan comment (e.g. list or db:seed)
            php artisan list --format=json | 
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
                # We're completing a command parameter (e.g. -vv)
                $artisanCommand, [string[]]$options = $commandPreElements
                php artisan list --format=json | 
                    ConvertFrom-Json | 
                    Select-Object -ExpandProperty 'commands' | 
                    Where-Object { $_.name -eq $artisanCommand } | 
                    Select-Object -ExpandProperty 'definition' | 
                    Select-Object -ExpandProperty 'options' | 
                    ForEach-Object { $_.psobject.properties.Value } | 
                    ForEach-Object { 
                        $spec = $_
                        @{
                            name = $_.name; 
                            spec = $spec 
                        };

                        $_.shortcut -split '\|' | 
                            Where-Object { $_ -ne '' } | 
                            ForEach-Object { 
                                @{
                                    name = $_; 
                                    spec = $spec 
                                } 
                            } 
                        } | 
                        Where-Object { $_.name -like "$wordToComplete*" -and ($_.spec.is_multiple -or $_.name -notin $options) } |
                        ForEach-Object { 
                            [System.Management.Automation.CompletionResult]::new(
                                $(
                                    $suffix = ''
                                    if ($_.spec.is_value_required) {
                                        $suffix = '='
                                    }
                                    $_.name + $suffix
                                ),
                                $(
                                    $suffix = ''
                                    if ($_.spec.accept_value) {
                                        $suffix = '=' + ($_.spec.name -replace '^-+', '').ToUpper()
                                        if (-not $_.spec.is_value_required) {
                                            $suffix = "[$suffix]"
                                        }
                                    }
                                    $_.name + $suffix
                                ),
                                'ParameterName',
                                $_.spec.description)
                        }
            
                        return
                    }
                }
            }

(TabExpansion2 -inputScript 'php ../laravelbootcamp/chirper/artisan migrate:rollback ' -cursorColumn 56).CompletionMatches