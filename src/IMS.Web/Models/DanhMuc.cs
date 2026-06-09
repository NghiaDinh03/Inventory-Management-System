using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace IMS.Web.Models
{
    [Table("DanhMucSanPham")]
    public class DanhMuc
    {
        [Key]
        [Column("MaDanhMucSP")]
        public int MaDanhMuc { get; set; }

        [Required(ErrorMessage = "Tên danh mục không được để trống")]
        [StringLength(100, ErrorMessage = "Tên danh mục không quá 100 ký tự")]
        [Column("TenDanhMucSP")]
        public string TenDanhMuc { get; set; } = null!;

        [StringLength(300, ErrorMessage = "Mô tả không quá 300 ký tự")]
        public string? MoTa { get; set; }

        public ICollection<SanPham>? SanPhams { get; set; }
    }
}
