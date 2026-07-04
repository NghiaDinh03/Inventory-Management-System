namespace IMS.Web.Models.Views
{
    public class SanPhamDuoiTonToiThieuView
    {
        public int MaSP { get; set; }
        public string TenSP { get; set; } = null!;
        public string DonVi { get; set; } = null!;
        public string TenDanhMuc { get; set; } = null!;
        public string TenKho { get; set; } = null!;
        public int SoLuong { get; set; }
        public int TonToiThieu { get; set; }
        public int CanNhapThem { get; set; }
    }
}
