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

        [Required(ErrorMessage = "Giá nhập không được để trống")]
        [Range(0, double.MaxValue, ErrorMessage = "Giá nhập phải lớn hơn hoặc bằng 0")]
        public decimal GiaNhap { get; set; } = 0;

        public DateTime NgayCapNhat { get; set; } = DateTime.Now;
    }
}
