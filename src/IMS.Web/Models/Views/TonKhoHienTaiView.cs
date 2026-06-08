namespace IMS.Web.Models.Views
{
    public class TonKhoHienTaiView
    {
        public int MaTonKho { get; set; }
        public int MaSP { get; set; }
        public string TenSP { get; set; } = null!;
        public string DonVi { get; set; } = null!;
        public string? MaVach { get; set; }
        public string TenDanhMuc { get; set; } = null!;
        public int MaKho { get; set; }
        public string TenKho { get; set; } = null!;
        public int SoLuong { get; set; }
        public int TonToiThieu { get; set; }
        public decimal GiaNhap { get; set; }
        public decimal GiaTri { get; set; }
    }
}
