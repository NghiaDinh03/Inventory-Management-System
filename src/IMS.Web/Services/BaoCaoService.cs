using IMS.Web.Data;
using IMS.Web.Models.Views;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using System.Data;
using System.Data.Common;

namespace IMS.Web.Services
{
    public class BaoCaoService : IBaoCaoService
    {
        private readonly AppDbContext _context;

        public BaoCaoService(AppDbContext context)
        {
            _context = context;
        }

        public async Task<DataTable> GetBaoCaoTonKhoAsync(int? maKho, DateTime tuNgay, DateTime denNgay)
        {
            return await ExecuteStoredProcedureAsync("sp_BaoCaoTonKho", new[]
            {
                new SqlParameter("@MaKho", (object?)maKho ?? DBNull.Value),
                new SqlParameter("@TuNgay", tuNgay.Date),
                new SqlParameter("@DenNgay", denNgay.Date)
            });
        }

        public async Task<DataTable> GetBaoCaoNhapTheoNCCAsync(int? maNCC, DateTime tuNgay, DateTime denNgay)
        {
            return await ExecuteStoredProcedureAsync("sp_BaoCaoNhapTheoNCC", new[]
            {
                new SqlParameter("@MaNCC", (object?)maNCC ?? DBNull.Value),
                new SqlParameter("@TuNgay", tuNgay.Date),
                new SqlParameter("@DenNgay", denNgay.Date)
            });
        }

        public async Task<DataTable> GetBaoCaoXuatTheoSPAsync(int? maSP, DateTime tuNgay, DateTime denNgay)
        {
            return await ExecuteStoredProcedureAsync("sp_BaoCaoXuatTheoSP", new[]
            {
                new SqlParameter("@MaSP", (object?)maSP ?? DBNull.Value),
                new SqlParameter("@TuNgay", tuNgay.Date),
                new SqlParameter("@DenNgay", denNgay.Date)
            });
        }

        public async Task<List<TopSanPhamXuatNhieuView>> GetTopSanPhamXuatNhieuAsync()
        {
            return await _context.TopSanPhamXuatNhieuViews.AsNoTracking().ToListAsync();
        }

        public async Task<List<DoanhThuTheoThangView>> GetDoanhThuTheoThangAsync()
        {
            return await _context.DoanhThuTheoThangViews.AsNoTracking().ToListAsync();
        }

        public async Task<DataTable> ExecuteCursorCanhBaoTonAsync()
        {
            return await ExecuteStoredProcedureAsync("sp_CursorCanhBaoTon", Array.Empty<SqlParameter>());
        }

        public async Task<DataTable> ExecuteCursorTonCuoiKyAsync(int? maKho, DateTime tuNgay, DateTime denNgay)
        {
            return await ExecuteStoredProcedureAsync("sp_CursorTonCuoiKy", new[]
            {
                new SqlParameter("@MaKho", (object?)maKho ?? DBNull.Value),
                new SqlParameter("@TuNgay", tuNgay.Date),
                new SqlParameter("@DenNgay", denNgay.Date)
            });
        }

        
        private async Task<DataTable> ExecuteStoredProcedureAsync(string spName, SqlParameter[] parameters)
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
                    command.CommandText = spName;
                    command.CommandType = CommandType.StoredProcedure;
                    command.CommandTimeout = 120; 

                    if (parameters != null)
                    {
                        command.Parameters.AddRange(parameters);
                    }

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
    }
}
