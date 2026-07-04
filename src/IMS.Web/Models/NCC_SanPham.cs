using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace IMS.Web.Models
{
    [Table("NCC_SanPham")]
    public class NCC_SanPham
    {
        [Required]
        public int MaNCC { get; set; }

        [ForeignKey("MaNCC")]
        public NhaCungCap? NhaCungCap { get; set; }

        [Required]
        public int MaSP { get; set; }

        [ForeignKey("MaSP")]
        public SanPham? SanPham { get; set; }

        [Required(ErrorMessage = "GiÃ¡ nháº­p khÃ´ng Ä‘Æ°á»£c Ä‘á»ƒ trá»‘ng")]
        [Range(0, double.MaxValue, ErrorMessage = "GiÃ¡ nháº­p pháº£i lá»›n hÆ¡n hoáº·c báº±ng 0")]
        public decimal GiaNhap { get; set; } = 0;

        public DateTime NgayCapNhat { get; set; } = DateTime.Now;
    }
}
