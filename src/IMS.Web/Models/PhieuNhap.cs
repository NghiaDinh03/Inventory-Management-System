using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace IMS.Web.Models
{
    [Table("PhieuNhap")]
    public class PhieuNhap
    {
        [Key]
        public int MaPN { get; set; }

        [StringLength(20)]
        public string? SoPhieu { get; set; }

        public DateTime NgayLap { get; set; } = DateTime.Now;

        public DateTime? NgayDuyet { get; set; }

        [Required(ErrorMessage = "Vui lÃ²ng chá»n nhÃ  cung cáº¥p")]
        public int MaNCC { get; set; }

        [ForeignKey("MaNCC")]
        public NhaCungCap? NhaCungCap { get; set; }

        [Required(ErrorMessage = "Vui lÃ²ng chá»n kho nháº­p")]
        public int MaKho { get; set; }

        [ForeignKey("MaKho")]
        public Kho? Kho { get; set; }

        [Required(ErrorMessage = "Vui lÃ²ng chá»‰ Ä‘á»‹nh nhÃ¢n viÃªn láº­p phiáº¿u")]
        public int MaNV { get; set; }

        [ForeignKey("MaNV")]
        public NhanVien? NhanVien { get; set; }

        public int? MaNV_Duyet { get; set; }

        [ForeignKey("MaNV_Duyet")]
        public NhanVien? NhanVienDuyet { get; set; }

        [Required]
        [StringLength(20)]
        public string TrangThai { get; set; } = "NhÃ¡p";

        public decimal TongTien { get; set; } = 0;

        [StringLength(500, ErrorMessage = "Ghi chÃº khÃ´ng quÃ¡ 500 kÃ½ tá»±")]
        public string? GhiChu { get; set; }

        public ICollection<ChiTietPhieuNhap>? ChiTietPhieuNhaps { get; set; }
    }
}
