using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace IMS.Web.Models
{
    [Table("Kho")]
    public class Kho
    {
        [Key]
        public int MaKho { get; set; }

        [Required(ErrorMessage = "TÃªn kho khÃ´ng Ä‘Æ°á»£c Ä‘á»ƒ trá»‘ng")]
        [StringLength(100, ErrorMessage = "TÃªn kho khÃ´ng quÃ¡ 100 kÃ½ tá»±")]
        public string TenKho { get; set; } = null!;

        [StringLength(300, ErrorMessage = "Äá»‹a chá»‰ khÃ´ng quÃ¡ 300 kÃ½ tá»±")]
        public string? DiaChi { get; set; }

        public bool TrangThai { get; set; } = true;

        public ICollection<PhieuNhap>? PhieuNhaps { get; set; }
        public ICollection<PhieuXuat>? PhieuXuats { get; set; }
        public ICollection<TonKho>? TonKhos { get; set; }
    }
}
