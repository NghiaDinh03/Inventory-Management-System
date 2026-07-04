using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace IMS.Web.Models
{
    [Table("TaiKhoan")]
    public class TaiKhoan
    {
        [Key]
        public int MaTK { get; set; }

        [Required(ErrorMessage = "TÃªn Ä‘Äƒng nháº­p khÃ´ng Ä‘Æ°á»£c Ä‘á»ƒ trá»‘ng")]
        [StringLength(50, ErrorMessage = "TÃªn Ä‘Äƒng nháº­p khÃ´ng quÃ¡ 50 kÃ½ tá»±")]
        public string TenDangNhap { get; set; } = null!;

        [Required(ErrorMessage = "Máº­t kháº©u khÃ´ng Ä‘Æ°á»£c Ä‘á»ƒ trá»‘ng")]
        [StringLength(256, ErrorMessage = "Máº­t kháº©u khÃ´ng quÃ¡ 256 kÃ½ tá»±")]
        public string MatKhau { get; set; } = null!;

        [Required(ErrorMessage = "Vui lÃ²ng chá»n nhÃ¢n viÃªn sá»Ÿ há»¯u tÃ i khoáº£n")]
        public int MaNV { get; set; }

        [ForeignKey("MaNV")]
        public NhanVien? NhanVien { get; set; }

        [Required(ErrorMessage = "Vui lÃ²ng chá»n vai trÃ²")]
        public int MaVT { get; set; }

        [ForeignKey("MaVT")]
        public VaiTro? VaiTro { get; set; }

        public bool TrangThai { get; set; } = true;
    }
}
