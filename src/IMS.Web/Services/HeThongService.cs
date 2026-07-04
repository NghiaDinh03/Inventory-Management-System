using IMS.Web.Data;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;

namespace IMS.Web.Services
{
    public class HeThongService : IHeThongService
    {
        private readonly AppDbContext _context;

        public HeThongService(AppDbContext context)
        {
            _context = context;
        }

        public async Task<bool> BackupDatabaseAsync(string path)
        {
            try
            {
                
                var folderParam = new SqlParameter("@BackupFolder", path);
                
                await _context.Database.ExecuteSqlRawAsync(
                    "EXEC sp_BackupDatabase @BackupFolder", 
                    folderParam);
                
                return true;
            }
            catch (Exception ex)
            {
                
                Console.WriteLine("Backup Error: " + ex.Message);
                return false;
            }
        }

        public async Task<bool> RestoreDatabaseAsync(string path)
        {
            try
            {
                var pathParam = new SqlParameter("@BackupFilePath", path);
                
                
                await _context.Database.ExecuteSqlRawAsync(
                    "EXEC master.dbo.sp_RestoreDatabase @BackupFilePath", 
                    pathParam);
                
                return true;
            }
            catch (Exception ex)
            {
                Console.WriteLine("Restore Error: " + ex.Message);
                return false;
            }
        }
    }
}
