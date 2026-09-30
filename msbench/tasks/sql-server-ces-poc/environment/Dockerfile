FROM mcr.microsoft.com/mssql/server:2022-latest

USER root
RUN mkdir -p /workspace /logs/verifier \
    && chown -R mssql:root /workspace /logs

USER mssql
WORKDIR /workspace

ENV ACCEPT_EULA=Y \
    MSSQL_PID=Developer \
    MSSQL_SA_PASSWORD=MsbenchPoc_2026_StrongPassword!
