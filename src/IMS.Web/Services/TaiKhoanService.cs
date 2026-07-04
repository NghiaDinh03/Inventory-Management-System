using IMS.Web.Data;
using IMS.Web.Models;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using System.Security.Cryptography;
using System.Text;

namespace IMS.Web.Services
{
    public class TaiKhoanService : ITaiKhoanService
    {
        private readonly AppDbContext _context;

        public TaiKhoanService(AppDbContext context)
        {
            _context = context;
        }

        public async Task<TaiKhoan?> LoginAsync(string username, string password)
        {
            string passwordHash = HashPassword(password);
            
            return await _context.TaiKhoans
                .Include(t => t.NhanVien)
                .Include(t => t.VaiTro)
                .FirstOrDefaultAsync(t => t.TenDangNhap == username 
                                       && t.MatKhau == passwordHash 
                                       && t.TrangThai == true);
        }

        public async Task<bool> DoiMatKhauAsync(int maTK, string matKhauCu, string matKhauMoi)
        {
            try
            {
                string hashCu = HashPassword(matKhauCu);
                string hashMoi = HashPassword(matKhauMoi);


                var maTKParam = new SqlParameter("@MaTK", maTK);
                var matKhauCuParam = new SqlParameter("@MatKhauCu", hashCu);
                var matKhauMoiParam = new SqlParameter("@MatKhauMoi", hashMoi);

                await _context.Database.ExecuteSqlRawAsync(
                    "EXEC sp_DoiMatKhau @MaTK, @MatKhauCu, @MatKhauMoi",
                    maTKParam, matKhauCuParam, matKhauMoiParam);

                return true;
            }
            catch (Exception)
            {
                return false;
            }
        }

        private string HashPassword(string password)
        {
            using (var sha256 = SHA256.Create())
            {
                byte[] bytes = Encoding.UTF8.GetBytes(password);
                byte[] hash = sha256.ComputeHash(bytes);
                return Convert.ToHexString(hash);
            }
        }
    }
}
