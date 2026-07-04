using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace IMS.Web.Models
{
    [Table("VaiTro")]
    public class VaiTro
    {
        [Key]
        public int MaVT { get; set; }

        [Required(ErrorMessage = "TÃªn vai trÃ² khÃ´ng Ä‘Æ°á»£c Ä‘á»ƒ trá»‘ng")]
        [StringLength(50, ErrorMessage = "TÃªn vai trÃ² khÃ´ng quÃ¡ 50 kÃ½ tá»±")]
        public string TenVaiTro { get; set; } = null!;

        [StringLength(200, ErrorMessage = "MÃ´ táº£ khÃ´ng quÃ¡ 200 kÃ½ tá»±")]
        public string? MoTa { get; set; }

        public bool TrangThai { get; set; } = true;

        public ICollection<TaiKhoan>? TaiKhoans { get; set; }
    }
}
