namespace IMS.Web.Models.Views
{
    public class TopSanPhamXuatNhieuView
    {
        public int MaSP { get; set; }
        public string TenSP { get; set; } = null!;
        public string DonVi { get; set; } = null!;
        public string TenDanhMuc { get; set; } = null!;
        public int TongSoLuongXuat { get; set; }
        public decimal TongGiaTriXuat { get; set; }
    }
}
