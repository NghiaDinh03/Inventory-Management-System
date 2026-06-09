using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace IMS.Web.Models
{
    [Table("NhanVien")]
    public class NhanVien
    {
        [Key]
        public int MaNV { get; set; }

        [Required(ErrorMessage = "Họ tên nhân viên không được để trống")]
        [StringLength(100, ErrorMessage = "Họ tên không quá 100 ký tự")]
        public string HoTen { get; set; } = null!;

        [StringLength(50, ErrorMessage = "Chức vụ không quá 50 ký tự")]
        public string? ChucVu { get; set; }

        [StringLength(20, ErrorMessage = "Số điện thoại không quá 20 ký tự")]
        [Phone(ErrorMessage = "Số điện thoại không hợp lệ")]
        public string? SoDienThoai { get; set; }

        [StringLength(100, ErrorMessage = "Email không quá 100 ký tự")]
        [EmailAddress(ErrorMessage = "Email không hợp lệ")]
        public string? Email { get; set; }

        [DataType(DataType.Date)]
        public DateTime? NgaySinh { get; set; }

        [StringLength(12, ErrorMessage = "CCCD phải đúng 12 ký tự")]
        public string? CCCD { get; set; }

        [DataType(DataType.Date)]
        public DateTime? NgayCap { get; set; }

        [StringLength(100, ErrorMessage = "Nơi cấp không quá 100 ký tự")]
        public string? NoiCap { get; set; }

        public bool? GioiTinh { get; set; }

        public bool TrangThai { get; set; } = true;

        public TaiKhoan? TaiKhoan { get; set; }

        public ICollection<PhieuNhap>? PhieuNhaps { get; set; }
        public ICollection<PhieuXuat>? PhieuXuats { get; set; }
        public ICollection<LichSuHoatDong>? LichSuHoatDongs { get; set; }
    }
}
