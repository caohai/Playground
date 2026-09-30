Create a SQL Server database named `MsbenchPoc` on the local SQL Server
instance. In that database, create a table named `dbo.ValidationMarker` with an
integer primary key column named `Id` and an `nvarchar(100)` column named
`Marker`.

Insert or update the row with `Id = 1` so that `Marker` is exactly:

```text
msbench-ces-sqlserver-poc
```

The SQL Server administrator password is available in the
`MSSQL_SA_PASSWORD` environment variable.
