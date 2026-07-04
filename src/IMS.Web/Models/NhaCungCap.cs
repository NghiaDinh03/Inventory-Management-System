using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace IMS.Web.Models
{
    [Table("NhaCungCap")]
    public class NhaCungCap
    {
        [Key]
        public int MaNCC { get; set; }

        [Required(ErrorMessage = "TÃªn nhÃ  cung cáº¥p khÃ´ng Ä‘Æ°á»£c Ä‘á»ƒ trá»‘ng")]
        [StringLength(200, ErrorMessage = "TÃªn nhÃ  cung cáº¥p khÃ´ng quÃ¡ 200 kÃ½ tá»±")]
        public string TenNCC { get; set; } = null!;

        [StringLength(300, ErrorMessage = "Äá»‹a chá»‰ khÃ´ng quÃ¡ 300 kÃ½ tá»±")]
        public string? DiaChi { get; set; }

        [StringLength(20, ErrorMessage = "Sá»‘ Ä‘iá»‡n thoáº¡i khÃ´ng quÃ¡ 20 kÃ½ tá»±")]
        [Phone(ErrorMessage = "Sá»‘ Ä‘iá»‡n thoáº¡i khÃ´ng há»£p lá»‡")]
        public string? SoDienThoai { get; set; }

        [StringLength(100, ErrorMessage = "Email khÃ´ng quÃ¡ 100 kÃ½ tá»±")]
        [EmailAddress(ErrorMessage = "Email khÃ´ng há»£p lá»‡")]
        public string? Email { get; set; }

        [StringLength(100, ErrorMessage = "NgÆ°á»i liÃªn há»‡ khÃ´ng quÃ¡ 100 kÃ½ tá»±")]
        public string? NguoiLienHe { get; set; }

        public bool TrangThai { get; set; } = true;

        public ICollection<PhieuNhap>? PhieuNhaps { get; set; }
        public ICollection<NCC_SanPham>? NCC_SanPhams { get; set; }
    }
}
