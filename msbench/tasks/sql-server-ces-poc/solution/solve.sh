#!/usr/bin/env bash
set -euo pipefail

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

SQLCMD="$(find_sqlcmd)"
SQLSERVER_LOG=/tmp/sqlserver.log

if ! "$SQLCMD" -S localhost -U sa -P "$MSSQL_SA_PASSWORD" -C \
    -l 1 -Q "SELECT 1" >/dev/null 2>&1
then
    nohup /opt/mssql/bin/sqlservr >"$SQLSERVER_LOG" 2>&1 &
fi

for _ in $(seq 1 60); do
    if "$SQLCMD" -S localhost -U sa -P "$MSSQL_SA_PASSWORD" -C \
        -l 1 -Q "SELECT 1" >/dev/null 2>&1
    then
        break
    fi
    sleep 2
done

if ! "$SQLCMD" -S localhost -U sa -P "$MSSQL_SA_PASSWORD" -C \
    -l 1 -Q "SELECT 1" >/dev/null 2>&1
then
    cat "$SQLSERVER_LOG" >&2 || true
    echo "SQL Server did not become ready." >&2
    exit 1
fi

"$SQLCMD" -S localhost -U sa -P "$MSSQL_SA_PASSWORD" -C -b -Q "
IF DB_ID(N'MsbenchPoc') IS NULL
BEGIN
    CREATE DATABASE [MsbenchPoc];
END;
"

"$SQLCMD" -S localhost -U sa -P "$MSSQL_SA_PASSWORD" -C -b \
    -d MsbenchPoc -Q "
IF OBJECT_ID(N'dbo.ValidationMarker', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.ValidationMarker
    (
        Id int NOT NULL CONSTRAINT PK_ValidationMarker PRIMARY KEY,
        Marker nvarchar(100) NOT NULL
    );
END;

MERGE dbo.ValidationMarker AS target
USING
(
    SELECT
        CAST(1 AS int) AS Id,
        CAST(N'msbench-ces-sqlserver-poc' AS nvarchar(100)) AS Marker
) AS source
ON source.Id = target.Id
WHEN MATCHED THEN
    UPDATE SET Marker = source.Marker
WHEN NOT MATCHED THEN
    INSERT (Id, Marker) VALUES (source.Id, source.Marker);
"
