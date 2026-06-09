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

        [Required(ErrorMessage = "Số lượng tồn kho không được để trống")]
        [Range(0, int.MaxValue, ErrorMessage = "Số lượng tồn kho phải lớn hơn hoặc bằng 0")]
        [Column("SoLuongTon")]
        public int SoLuong { get; set; } = 0;

        [Required(ErrorMessage = "Trọng lượng tồn kho không được để trống")]
        [Range(0, double.MaxValue, ErrorMessage = "Trọng lượng tồn kho phải lớn hơn hoặc bằng 0")]
        public decimal TrongLuongTon { get; set; } = 0;
    }
}
