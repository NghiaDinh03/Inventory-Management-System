#!/bin/bash
# Chờ SQL Server khởi động hoàn toàn
echo "Waiting for SQL Server to be ready..."
for i in {1..30}; do
    /opt/mssql-tools18/bin/sqlcmd -S sqlserver -U sa -P "$MSSQL_SA_PASSWORD" -C -Q "SELECT 1" &>/dev/null
    if [ $? -eq 0 ]; then
        echo "SQL Server is ready! Starting script execution..."
        break
    fi
    echo "SQL Server not ready yet. Retrying in 2 seconds..."
    sleep 2
done

# Chạy các script SQL theo đúng thứ tự
echo "Executing 01_create-tables.sql..."
/opt/mssql-tools18/bin/sqlcmd -S sqlserver -U sa -P "$MSSQL_SA_PASSWORD" -C -i /database/01_create-tables.sql

echo "Executing 02_create-views.sql..."
/opt/mssql-tools18/bin/sqlcmd -S sqlserver -U sa -P "$MSSQL_SA_PASSWORD" -C -i /database/02_create-views.sql

echo "Executing 03_create-functions.sql..."
/opt/mssql-tools18/bin/sqlcmd -S sqlserver -U sa -P "$MSSQL_SA_PASSWORD" -C -i /database/03_create-functions.sql

echo "Executing 04_create-stored-procedures.sql..."
/opt/mssql-tools18/bin/sqlcmd -S sqlserver -U sa -P "$MSSQL_SA_PASSWORD" -C -i /database/04_create-stored-procedures.sql

echo "Executing 05_create-triggers.sql..."
/opt/mssql-tools18/bin/sqlcmd -S sqlserver -U sa -P "$MSSQL_SA_PASSWORD" -C -i /database/05_create-triggers.sql

echo "Executing 06_create-cursors.sql..."
/opt/mssql-tools18/bin/sqlcmd -S sqlserver -U sa -P "$MSSQL_SA_PASSWORD" -C -i /database/06_create-cursors.sql

echo "Executing 07_seed-data.sql..."
/opt/mssql-tools18/bin/sqlcmd -S sqlserver -U sa -P "$MSSQL_SA_PASSWORD" -C -i /database/07_seed-data.sql

echo "Executing 08_create-users-roles.sql..."
/opt/mssql-tools18/bin/sqlcmd -S sqlserver -U sa -P "$MSSQL_SA_PASSWORD" -C -i /database/08_create-users-roles.sql

echo "Executing 09_backup-restore.sql..."
/opt/mssql-tools18/bin/sqlcmd -S sqlserver -U sa -P "$MSSQL_SA_PASSWORD" -C -i /database/09_backup-restore.sql

echo "Database initialization completed successfully!"
