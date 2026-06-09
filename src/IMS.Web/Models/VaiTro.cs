using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace IMS.Web.Models
{
    [Table("VaiTro")]
    public class VaiTro
    {
        [Key]
        public int MaVT { get; set; }

        [Required(ErrorMessage = "Tên vai trò không được để trống")]
        [StringLength(50, ErrorMessage = "Tên vai trò không quá 50 ký tự")]
        public string TenVaiTro { get; set; } = null!;

        [StringLength(200, ErrorMessage = "Mô tả không quá 200 ký tự")]
        public string? MoTa { get; set; }

        public bool TrangThai { get; set; } = true;

        public ICollection<TaiKhoan>? TaiKhoans { get; set; }
    }
}
