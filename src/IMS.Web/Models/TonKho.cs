using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace IMS.Web.Models
{
    [Table("TonKho")]
    public class TonKho
    {
        [Key]
        public int MaTonKho { get; set; }

        [Required]
        public int MaSP { get; set; }

        [ForeignKey("MaSP")]
        public SanPham? SanPham { get; set; }

        [Required]
        public int MaKho { get; set; }

        [ForeignKey("MaKho")]
        public Kho? Kho { get; set; }

        [Required(ErrorMessage = "Sá»‘ lÆ°á»£ng tá»“n kho khÃ´ng Ä‘Æ°á»£c Ä‘á»ƒ trá»‘ng")]
        [Range(0, int.MaxValue, ErrorMessage = "Sá»‘ lÆ°á»£ng tá»“n kho pháº£i lá»›n hÆ¡n hoáº·c báº±ng 0")]
        [Column("SoLuongTon")]
        public int SoLuong { get; set; } = 0;

        [Required(ErrorMessage = "Trá»ng lÆ°á»£ng tá»“n kho khÃ´ng Ä‘Æ°á»£c Ä‘á»ƒ trá»‘ng")]
        [Range(0, double.MaxValue, ErrorMessage = "Trá»ng lÆ°á»£ng tá»“n kho pháº£i lá»›n hÆ¡n hoáº·c báº±ng 0")]
        public decimal TrongLuongTon { get; set; } = 0;
    }
}
