# artisan-pscomplete

PowerShell tab-completion for Laravel artisan.

> [!WARNING]
> This project is a proof-of-concept, and not supported in any way.

> [!NOTE]
> Completion of some strings starting `-` does not work on PowerShell v5.1 due to a [bug](https://github.com/PowerShell/PowerShell/issues/2912). It does work on v7.x.

## Usage

Append the script contents to your PowerShell profile. As-is, it allows artisan to be run with the alias `art`; to allow other aliases, or even `php artisan` if you love typing, register the completer using a different `-CommandName`.
