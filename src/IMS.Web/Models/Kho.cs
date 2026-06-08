using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace IMS.Web.Models
{
    [Table("Kho")]
    public class Kho
    {
        [Key]
        public int MaKho { get; set; }

        [Required(ErrorMessage = "Tên kho không được để trống")]
        [StringLength(100, ErrorMessage = "Tên kho không quá 100 ký tự")]
        public string TenKho { get; set; } = null!;

        [StringLength(300, ErrorMessage = "Địa chỉ không quá 300 ký tự")]
        public string? DiaChi { get; set; }

        public bool TrangThai { get; set; } = true;

        public ICollection<PhieuNhap>? PhieuNhaps { get; set; }
        public ICollection<PhieuXuat>? PhieuXuats { get; set; }
        public ICollection<TonKho>? TonKhos { get; set; }
    }
}
