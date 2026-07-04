using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace IMS.Web.Models
{
    [Table("Gia")]
    public class Gia
    {
        [Key]
        public int MaGia { get; set; }

        [Required]
        public int MaSP { get; set; }

        [ForeignKey("MaSP")]
        public SanPham? SanPham { get; set; }

        public DateTime NgayLap { get; set; } = DateTime.Now;

        [Required(ErrorMessage = "ÄÆ¡n giÃ¡ nháº­p khÃ´ng Ä‘Æ°á»£c Ä‘á»ƒ trá»‘ng")]
        [Range(0, double.MaxValue, ErrorMessage = "ÄÆ¡n giÃ¡ nháº­p pháº£i lá»›n hÆ¡n hoáº·c báº±ng 0")]
        public decimal DonGiaNhap { get; set; } = 0;
    }
}
