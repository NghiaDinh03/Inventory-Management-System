using IMS.Web.Data;
using Microsoft.EntityFrameworkCore;
using System.Data;

namespace IMS.Web.Services
{
    public class SqlExecuteService : ISqlExecuteService
    {
        private readonly AppDbContext _context;

        public SqlExecuteService(AppDbContext context)
        {
            _context = context;
        }

        public async Task<DataTable> ExecuteQueryAsync(string sql)
        {
            var connection = _context.Database.GetDbConnection();
            bool wasClosed = connection.State == ConnectionState.Closed;
            
            if (wasClosed)
            {
                await connection.OpenAsync();
            }

            try
            {
                using (var command = connection.CreateCommand())
                {
                    command.CommandText = sql;
                    command.CommandType = CommandType.Text;
                    
                    using (var reader = await command.ExecuteReaderAsync())
                    {
                        var dataTable = new DataTable();
                        dataTable.Load(reader);
                        return dataTable;
                    }
                }
            }
            finally
            {
                if (wasClosed)
                {
                    await connection.CloseAsync();
                }
            }
        }

        public async Task<int> ExecuteNonQueryAsync(string sql)
        {
            return await _context.Database.ExecuteSqlRawAsync(sql);
        }
    }
}
