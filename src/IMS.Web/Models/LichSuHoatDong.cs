using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace IMS.Web.Models
{
    [Table("LichSuHoatDong")]
    public class LichSuHoatDong
    {
        [Key]
        public long MaLog { get; set; }

        [Required]
        [StringLength(50)]
        public string BangLienQuan { get; set; } = null!;

        [Required]
        public int MaBanGhi { get; set; }

        [Required]
        [StringLength(10)]
        public string HanhDong { get; set; } = null!; // INSERT, UPDATE, DELETE

        public string? NoiDungCu { get; set; } // Dạng JSON string chứa dữ liệu cũ

        public string? NoiDungMoi { get; set; } // Dạng JSON string chứa dữ liệu mới

        public int? MaNV { get; set; } // Người thực hiện hành động (null nếu hệ thống tự chạy)

        public DateTime ThoiGian { get; set; } = DateTime.Now;
    }
}
