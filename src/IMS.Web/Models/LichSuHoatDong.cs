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
        public string HanhDong { get; set; } = null!;

        [StringLength(20)]
        public string? MaPhieu { get; set; }

        public string? NoiDungCu { get; set; }

        public string? NoiDungMoi { get; set; }

        public int? MaNV { get; set; }

        [ForeignKey("MaNV")]
        public NhanVien? NhanVien { get; set; }

        public DateTime ThoiGian { get; set; } = DateTime.Now;
    }
}
