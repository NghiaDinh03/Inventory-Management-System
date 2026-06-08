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

        [Required(ErrorMessage = "Vui lòng chọn nhà cung cấp")]
        public int MaNCC { get; set; }

        [ForeignKey("MaNCC")]
        public NhaCungCap? NhaCungCap { get; set; }

        [Required(ErrorMessage = "Vui lòng chọn kho nhập")]
        public int MaKho { get; set; }

        [ForeignKey("MaKho")]
        public Kho? Kho { get; set; }

        [Required(ErrorMessage = "Vui lòng chỉ định nhân viên lập phiếu")]
        public int MaNV { get; set; }

        [ForeignKey("MaNV")]
        public NhanVien? NhanVien { get; set; }

        [Required]
        [StringLength(20)]
        public string TrangThai { get; set; } = "Nháp"; // 'Nháp', 'ĐãDuyệt', 'ĐãHủy'

        public decimal TongTien { get; set; } = 0;

        [StringLength(500, ErrorMessage = "Ghi chú không quá 500 ký tự")]
        public string? GhiChu { get; set; }

        public ICollection<ChiTietPhieuNhap>? ChiTietPhieuNhaps { get; set; }
    }
}
