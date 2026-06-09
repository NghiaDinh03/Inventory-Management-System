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

        [Required(ErrorMessage = "Vui lòng chọn sản phẩm")]
        public int MaSP { get; set; }

        [ForeignKey("MaSP")]
        public SanPham? SanPham { get; set; }

        [Required(ErrorMessage = "Số lượng không được để trống")]
        [Range(1, int.MaxValue, ErrorMessage = "Số lượng phải lớn hơn 0")]
        public int SoLuong { get; set; }

        [Required(ErrorMessage = "Đơn giá không được để trống")]
        [Range(0, double.MaxValue, ErrorMessage = "Đơn giá phải lớn hơn hoặc bằng 0")]
        public decimal DonGia { get; set; }

        public decimal? TrongLuong { get; set; }

        [DatabaseGenerated(DatabaseGeneratedOption.Computed)]
        public decimal ThanhTien { get; private set; }
    }
}
