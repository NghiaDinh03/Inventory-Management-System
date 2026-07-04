using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace IMS.Web.Models
{
    [Table("NhanVien")]
    public class NhanVien
    {
        [Key]
        public int MaNV { get; set; }

        [Required(ErrorMessage = "Há» tÃªn nhÃ¢n viÃªn khÃ´ng Ä‘Æ°á»£c Ä‘á»ƒ trá»‘ng")]
        [StringLength(100, ErrorMessage = "Há» tÃªn khÃ´ng quÃ¡ 100 kÃ½ tá»±")]
        public string HoTen { get; set; } = null!;

        [StringLength(50, ErrorMessage = "Chá»©c vá»¥ khÃ´ng quÃ¡ 50 kÃ½ tá»±")]
        public string? ChucVu { get; set; }

        [StringLength(20, ErrorMessage = "Sá»‘ Ä‘iá»‡n thoáº¡i khÃ´ng quÃ¡ 20 kÃ½ tá»±")]
        [Phone(ErrorMessage = "Sá»‘ Ä‘iá»‡n thoáº¡i khÃ´ng há»£p lá»‡")]
        public string? SoDienThoai { get; set; }

        [StringLength(100, ErrorMessage = "Email khÃ´ng quÃ¡ 100 kÃ½ tá»±")]
        [EmailAddress(ErrorMessage = "Email khÃ´ng há»£p lá»‡")]
        public string? Email { get; set; }

        [DataType(DataType.Date)]
        public DateTime? NgaySinh { get; set; }

        [StringLength(12, ErrorMessage = "CCCD pháº£i Ä‘Ãºng 12 kÃ½ tá»±")]
        public string? CCCD { get; set; }

        [DataType(DataType.Date)]
        public DateTime? NgayCap { get; set; }

        [StringLength(100, ErrorMessage = "NÆ¡i cáº¥p khÃ´ng quÃ¡ 100 kÃ½ tá»±")]
        public string? NoiCap { get; set; }

        public bool? GioiTinh { get; set; }

        public bool TrangThai { get; set; } = true;

        public TaiKhoan? TaiKhoan { get; set; }

        public ICollection<PhieuNhap>? PhieuNhaps { get; set; }
        public ICollection<PhieuXuat>? PhieuXuats { get; set; }
        public ICollection<LichSuHoatDong>? LichSuHoatDongs { get; set; }
    }
}
