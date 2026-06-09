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

        [Required(ErrorMessage = "Đơn giá nhập không được để trống")]
        [Range(0, double.MaxValue, ErrorMessage = "Đơn giá nhập phải lớn hơn hoặc bằng 0")]
        public decimal DonGiaNhap { get; set; } = 0;
    }
}
