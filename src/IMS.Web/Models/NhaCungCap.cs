using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace IMS.Web.Models
{
    [Table("NhaCungCap")]
    public class NhaCungCap
    {
        [Key]
        public int MaNCC { get; set; }

        [Required(ErrorMessage = "Tên nhà cung cấp không được để trống")]
        [StringLength(200, ErrorMessage = "Tên nhà cung cấp không quá 200 ký tự")]
        public string TenNCC { get; set; } = null!;

        [StringLength(300, ErrorMessage = "Địa chỉ không quá 300 ký tự")]
        public string? DiaChi { get; set; }

        [StringLength(20, ErrorMessage = "Số điện thoại không quá 20 ký tự")]
        [Phone(ErrorMessage = "Số điện thoại không hợp lệ")]
        public string? SoDienThoai { get; set; }

        [StringLength(100, ErrorMessage = "Email không quá 100 ký tự")]
        [EmailAddress(ErrorMessage = "Email không hợp lệ")]
        public string? Email { get; set; }

        [StringLength(100, ErrorMessage = "Người liên hệ không quá 100 ký tự")]
        public string? NguoiLienHe { get; set; }

        public bool TrangThai { get; set; } = true;

        public ICollection<PhieuNhap>? PhieuNhaps { get; set; }
    }
}
