using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace IMS.Web.Models
{
    [Table("CT_PhieuXuat")]
    public class ChiTietPhieuXuat
    {
        [Key]
        public int MaCTPX { get; set; }

        [Required]
        public int MaPX { get; set; }

        [ForeignKey("MaPX")]
        public PhieuXuat? PhieuXuat { get; set; }

        [Required(ErrorMessage = "Vui lÃ²ng chá»n sáº£n pháº©m")]
        public int MaSP { get; set; }

        [ForeignKey("MaSP")]
        public SanPham? SanPham { get; set; }

        [Required(ErrorMessage = "Sá»‘ lÆ°á»£ng khÃ´ng Ä‘Æ°á»£c Ä‘á»ƒ trá»‘ng")]
        [Range(1, int.MaxValue, ErrorMessage = "Sá»‘ lÆ°á»£ng pháº£i lá»›n hÆ¡n 0")]
        public int SoLuong { get; set; }

        [Required(ErrorMessage = "ÄÆ¡n giÃ¡ khÃ´ng Ä‘Æ°á»£c Ä‘á»ƒ trá»‘ng")]
        [Range(0, double.MaxValue, ErrorMessage = "ÄÆ¡n giÃ¡ pháº£i lá»›n hÆ¡n hoáº·c báº±ng 0")]
        public decimal DonGia { get; set; }

        public decimal? TrongLuong { get; set; }

        [DatabaseGenerated(DatabaseGeneratedOption.Computed)]
        public decimal ThanhTien { get; private set; }
    }
}
