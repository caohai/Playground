#!/usr/bin/env bash
set -u

mkdir -p /logs/verifier
echo 0 > /logs/verifier/reward.txt

find_sqlcmd() {
    for candidate in \
        /opt/mssql-tools18/bin/sqlcmd \
        /opt/mssql-tools/bin/sqlcmd
    do
        if [[ -x "$candidate" ]]; then
            printf '%s\n' "$candidate"
            return 0
        fi
    done

    return 1
}

if ! SQLCMD="$(find_sqlcmd)"; then
    echo "sqlcmd was not found in the task image." >&2
    exit 0
fi

marker="$(
    "$SQLCMD" -S localhost -U sa -P "$MSSQL_SA_PASSWORD" -C \
        -l 5 -h -1 -W -d MsbenchPoc \
        -Q "SET NOCOUNT ON; SELECT Marker FROM dbo.ValidationMarker WHERE Id = 1;" \
        2>/tmp/sqlcmd-verifier-error.log
)"

if [[ "$marker" == "msbench-ces-sqlserver-poc" ]]; then
    echo 1 > /logs/verifier/reward.txt
else
    cat /tmp/sqlcmd-verifier-error.log >&2 || true
    printf 'Unexpected marker: <%s>\n' "$marker" >&2
fi
