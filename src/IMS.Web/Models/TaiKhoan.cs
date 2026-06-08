using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace IMS.Web.Models
{
    [Table("TaiKhoan")]
    public class TaiKhoan
    {
        [Key]
        public int MaTK { get; set; }

        [Required(ErrorMessage = "Tên đăng nhập không được để trống")]
        [StringLength(50, ErrorMessage = "Tên đăng nhập không quá 50 ký tự")]
        public string TenDangNhap { get; set; } = null!;

        [Required(ErrorMessage = "Mật khẩu không được để trống")]
        [StringLength(256, ErrorMessage = "Mật khẩu không quá 256 ký tự")]
        public string MatKhau { get; set; } = null!;

        [Required(ErrorMessage = "Vui lòng chọn nhân viên sở hữu tài khoản")]
        public int MaNV { get; set; }

        [ForeignKey("MaNV")]
        public NhanVien? NhanVien { get; set; }

        [Required(ErrorMessage = "Vui lòng chọn vai trò")]
        [StringLength(20)]
        public string VaiTro { get; set; } = "NVKho";

        public bool TrangThai { get; set; } = true;
    }
}
