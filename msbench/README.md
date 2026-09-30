# MSBench experiments

## SQL Server CES smoke task

`tasks/sql-server-ces-poc` is a Harbor-native task that derives its environment
from Microsoft's public SQL Server 2022 container image. The oracle solution
starts SQL Server, creates a database and marker table, and the verifier checks
the marker through `sqlcmd`.

The dataset pins the task to an immutable Git commit:

```bash
msbench-cli run \
  --config fix_validation \
  --dataset msbench/datasets/sql-server-ces-poc.jsonl
```

The task uses a fixed, non-secret SQL administrator password for the isolated
proof-of-concept container. Do not reuse that credential for a network-accessible
or persistent SQL Server.
