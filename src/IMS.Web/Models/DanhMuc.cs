using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace IMS.Web.Models
{
    [Table("DanhMucSanPham")]
    public class DanhMuc
    {
        [Key]
        [Column("MaDanhMucSP")]
        public int MaDanhMuc { get; set; }

        [Required(ErrorMessage = "TÃªn danh má»¥c khÃ´ng Ä‘Æ°á»£c Ä‘á»ƒ trá»‘ng")]
        [StringLength(100, ErrorMessage = "TÃªn danh má»¥c khÃ´ng quÃ¡ 100 kÃ½ tá»±")]
        [Column("TenDanhMucSP")]
        public string TenDanhMuc { get; set; } = null!;

        [StringLength(300, ErrorMessage = "MÃ´ táº£ khÃ´ng quÃ¡ 300 kÃ½ tá»±")]
        public string? MoTa { get; set; }

        public ICollection<SanPham>? SanPhams { get; set; }
    }
}
