using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace IMS.Web.Models
{
    [Table("SanPham")]
    public class SanPham
    {
        [Key]
        public int MaSP { get; set; }

        [Required(ErrorMessage = "Tên sản phẩm không được để trống")]
        [StringLength(200, ErrorMessage = "Tên sản phẩm không quá 200 ký tự")]
        public string TenSP { get; set; } = null!;

        [Required(ErrorMessage = "Vui lòng chọn danh mục")]
        [Column("MaDanhMucSP")]
        public int MaDanhMuc { get; set; }
        
        [ForeignKey("MaDanhMuc")]
        public DanhMuc? DanhMuc { get; set; }

        [Required(ErrorMessage = "Đơn vị tính không được để trống")]
        [StringLength(50, ErrorMessage = "Đơn vị tính không quá 50 ký tự")]
        public string DonVi { get; set; } = null!;

        [StringLength(50, ErrorMessage = "Mã vạch không quá 50 ký tự")]
        public string? MaVach { get; set; }

        [Required(ErrorMessage = "Trọng lượng không được để trống")]
        [Range(0, double.MaxValue, ErrorMessage = "Trọng lượng phải lớn hơn hoặc bằng 0")]
        public decimal TrongLuong { get; set; } = 0;

        [Required(ErrorMessage = "Giá nhập không được để trống")]
        [Range(0, double.MaxValue, ErrorMessage = "Giá nhập phải lớn hơn hoặc bằng 0")]
        public decimal GiaNhap { get; set; } = 0;

        [Required(ErrorMessage = "Giá bán không được để trống")]
        [Range(0, double.MaxValue, ErrorMessage = "Giá bán phải lớn hơn hoặc bằng 0")]
        public decimal GiaBan { get; set; } = 0;

        public int TonToiThieu { get; set; } = 10;

        [StringLength(500, ErrorMessage = "Đường dẫn hình ảnh không quá 500 ký tự")]
        public string? HinhAnh { get; set; }

        [StringLength(500, ErrorMessage = "Mô tả không quá 500 ký tự")]
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
