using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;

namespace IMS.Web.Models
{
    [Table("SanPham")]
    public class SanPham
    {
        [Key]
        public int MaSP { get; set; }

        [Required(ErrorMessage = "TÃªn sáº£n pháº©m khÃ´ng Ä‘Æ°á»£c Ä‘á»ƒ trá»‘ng")]
        [StringLength(200, ErrorMessage = "TÃªn sáº£n pháº©m khÃ´ng quÃ¡ 200 kÃ½ tá»±")]
        public string TenSP { get; set; } = null!;

        [Required(ErrorMessage = "Vui lÃ²ng chá»n danh má»¥c")]
        [Column("MaDanhMucSP")]
        public int MaDanhMuc { get; set; }
        
        [ForeignKey("MaDanhMuc")]
        public DanhMuc? DanhMuc { get; set; }

        [Required(ErrorMessage = "ÄÆ¡n vá»‹ tÃ­nh khÃ´ng Ä‘Æ°á»£c Ä‘á»ƒ trá»‘ng")]
        [StringLength(50, ErrorMessage = "ÄÆ¡n vá»‹ tÃ­nh khÃ´ng quÃ¡ 50 kÃ½ tá»±")]
        public string DonVi { get; set; } = null!;

        [StringLength(50, ErrorMessage = "MÃ£ váº¡ch khÃ´ng quÃ¡ 50 kÃ½ tá»±")]
        public string? MaVach { get; set; }

        [Required(ErrorMessage = "Trá»ng lÆ°á»£ng khÃ´ng Ä‘Æ°á»£c Ä‘á»ƒ trá»‘ng")]
        [Range(0, double.MaxValue, ErrorMessage = "Trá»ng lÆ°á»£ng pháº£i lá»›n hÆ¡n hoáº·c báº±ng 0")]
        public decimal TrongLuong { get; set; } = 0;

        [NotMapped]
        public decimal GiaNhap
        {
            get
            {
                if (GiaNhaps != null && GiaNhaps.Any())
                {
                    return GiaNhaps.OrderByDescending(g => g.NgayLap).FirstOrDefault()?.DonGiaNhap ?? 0;
                }
                return 0;
            }
            set
            {
            }
        }

        [Required(ErrorMessage = "GiÃ¡ bÃ¡n khÃ´ng Ä‘Æ°á»£c Ä‘á»ƒ trá»‘ng")]
        [Range(0, double.MaxValue, ErrorMessage = "GiÃ¡ bÃ¡n pháº£i lá»›n hÆ¡n hoáº·c báº±ng 0")]
        public decimal GiaBan { get; set; } = 0;

        public int TonToiThieu { get; set; } = 10;

        [StringLength(500, ErrorMessage = "ÄÆ°á»ng dáº«n hÃ¬nh áº£nh khÃ´ng quÃ¡ 500 kÃ½ tá»±")]
        public string? HinhAnh { get; set; }

        [StringLength(500, ErrorMessage = "MÃ´ táº£ khÃ´ng quÃ¡ 500 kÃ½ tá»±")]
        public string? MoTa { get; set; }

        public bool TrangThai { get; set; } = true;

        public DateTime NgayTao { get; set; } = DateTime.Now;
        public DateTime NgayCapNhat { get; set; } = DateTime.Now;

        public ICollection<ChiTietPhieuNhap>? ChiTietPhieuNhaps { get; set; }
        public ICollection<ChiTietPhieuXuat>? ChiTietPhieuXuats { get; set; }
        public ICollection<TonKho>? TonKhos { get; set; }
        public ICollection<Gia>? GiaNhaps { get; set; }
        public ICollection<NCC_SanPham>? NCC_SanPhams { get; set; }
    }
}
