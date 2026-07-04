namespace IMS.Web.Models.Views
{
    public class PhieuGanDayView
    {
        public int MaPhieu { get; set; }
        public string? SoPhieu { get; set; }
        public string LoaiPhieu { get; set; } = null!;
        public DateTime NgayLap { get; set; }
        public string TrangThai { get; set; } = null!;
        public decimal TongTien { get; set; }
        public string? NguoiLap { get; set; }
    }
}
