# Shared connection resolution for the SQL Server tests.
#
# The tests run against the server named by $env:GENXDEV_SQL_TEST_CONNECTIONSTRING.
# They work in tempdb, so the configured string is pointed at tempdb first.
# Without the variable, the local default instance is used with integrated
# security, which is also what the -Server parameter builds.

function Get-SqlServerTestConfiguration {

    [CmdletBinding()]
    param()

    $configured = $env:GENXDEV_SQL_TEST_CONNECTIONSTRING

    if ([string]::IsNullOrWhiteSpace($configured)) {

        return [pscustomobject]@{
            Server                = '.'
            ConnectionString      = 'Server=.;Database=tempdb;Integrated Security=true;TrustServerCertificate=true'
            CanUseServerParameter = $true
        }
    }

    $server = '.'
    $usesSqlAuthentication = $false
    $pairs = [System.Collections.Generic.List[string]]::new()

    foreach ($part in $configured.Split(';')) {

        if ([string]::IsNullOrWhiteSpace($part)) { continue }

        $separator = $part.IndexOf('=')
        if ($separator -lt 1) { continue }

        $key = $part.Substring(0, $separator).Trim().ToLowerInvariant()
        $value = $part.Substring($separator + 1).Trim()

        # the tests work in tempdb, whatever database the string names
        if ($key -in @('database', 'initial catalog')) { continue }

        if ($key -in @('server', 'data source', 'addr', 'address', 'network address')) {

            $server = $value.Trim('"').Trim("'")
        }
        elseif ($key -in @('uid', 'user id', 'user')) {

            $usesSqlAuthentication = $true
        }

        $pairs.Add($part.Trim())
    }

    $pairs.Add('Database=tempdb')

    [pscustomobject]@{
        Server                = $server
        ConnectionString      = ($pairs -join ';')
        CanUseServerParameter = -not $usesSqlAuthentication
    }
}
