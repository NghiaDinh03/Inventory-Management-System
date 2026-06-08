using Microsoft.EntityFrameworkCore;
using IMS.Web.Models;
using IMS.Web.Models.Views;

namespace IMS.Web.Data
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options)
        {
        }

        // 12 Core Database Tables
        public DbSet<DanhMuc> DanhMucs { get; set; } = null!;
        public DbSet<NhaCungCap> NhaCungCaps { get; set; } = null!;
        public DbSet<Kho> Khos { get; set; } = null!;
        public DbSet<SanPham> SanPhams { get; set; } = null!;
        public DbSet<NhanVien> NhanViens { get; set; } = null!;
        public DbSet<TaiKhoan> TaiKhoans { get; set; } = null!;
        public DbSet<PhieuNhap> PhieuNhaps { get; set; } = null!;
        public DbSet<ChiTietPhieuNhap> ChiTietPhieuNhaps { get; set; } = null!;
        public DbSet<PhieuXuat> PhieuXuats { get; set; } = null!;
        public DbSet<ChiTietPhieuXuat> ChiTietPhieuXuats { get; set; } = null!;
        public DbSet<TonKho> TonKhos { get; set; } = null!;
        public DbSet<LichSuHoatDong> LichSuHoatDongs { get; set; } = null!;

        // 7 Views (No key, read-only query mapping)
        public DbSet<TonKhoHienTaiView> TonKhoHienTaiViews { get; set; } = null!;
        public DbSet<SanPhamDuoiTonToiThieuView> SanPhamDuoiTonToiThieuViews { get; set; } = null!;
        public DbSet<NhapXuatTheoNgayView> NhapXuatTheoNgayViews { get; set; } = null!;
        public DbSet<PhieuGanDayView> PhieuGanDayViews { get; set; } = null!;
        public DbSet<ThongKeTongQuatView> ThongKeTongQuatViews { get; set; } = null!;
        public DbSet<TopSanPhamXuatNhieuView> TopSanPhamXuatNhieuViews { get; set; } = null!;
        public DbSet<DoanhThuTheoThangView> DoanhThuTheoThangViews { get; set; } = null!;

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // Configuration for core tables
            modelBuilder.Entity<DanhMuc>(entity =>
            {
                entity.HasIndex(e => e.TenDanhMuc).IsUnique();
            });

            modelBuilder.Entity<SanPham>(entity =>
            {
                entity.HasIndex(e => e.TenSP);
                entity.HasIndex(e => e.MaVach).IsUnique().HasFilter("[MaVach] IS NOT NULL");
                entity.Property(e => e.GiaNhap).HasColumnType("decimal(18,2)");
                entity.Property(e => e.GiaBan).HasColumnType("decimal(18,2)");

                entity.HasOne(d => d.DanhMuc)
                    .WithMany(p => p.SanPhams)
                    .HasForeignKey(d => d.MaDanhMuc)
                    .OnDelete(DeleteBehavior.Restrict);
            });

            modelBuilder.Entity<TaiKhoan>(entity =>
            {
                entity.HasIndex(e => e.TenDangNhap).IsUnique();
                entity.HasIndex(e => e.MaNV).IsUnique();

                entity.HasOne(d => d.NhanVien)
                    .WithOne(p => p.TaiKhoan)
                    .HasForeignKey<TaiKhoan>(d => d.MaNV)
                    .OnDelete(DeleteBehavior.Restrict);
            });

            modelBuilder.Entity<PhieuNhap>(entity =>
            {
                entity.HasIndex(e => e.SoPhieu).IsUnique();
                entity.Property(e => e.TongTien).HasColumnType("decimal(18,2)");

                entity.HasOne(d => d.NhaCungCap)
                    .WithMany(p => p.PhieuNhaps)
                    .HasForeignKey(d => d.MaNCC)
                    .OnDelete(DeleteBehavior.Restrict);

                entity.HasOne(d => d.Kho)
                    .WithMany(p => p.PhieuNhaps)
                    .HasForeignKey(d => d.MaKho)
                    .OnDelete(DeleteBehavior.Restrict);

                entity.HasOne(d => d.NhanVien)
                    .WithMany(p => p.PhieuNhaps)
                    .HasForeignKey(d => d.MaNV)
                    .OnDelete(DeleteBehavior.Restrict);
            });

            modelBuilder.Entity<ChiTietPhieuNhap>(entity =>
            {
                entity.Property(e => e.DonGia).HasColumnType("decimal(18,2)");
                entity.Property(e => e.ThanhTien).HasColumnType("decimal(18,2)");

                entity.HasOne(d => d.PhieuNhap)
                    .WithMany(p => p.ChiTietPhieuNhaps)
                    .HasForeignKey(d => d.MaPN)
                    .OnDelete(DeleteBehavior.Cascade); // Cascade delete on purchase order deletion

                entity.HasOne(d => d.SanPham)
                    .WithMany(p => p.ChiTietPhieuNhaps)
                    .HasForeignKey(d => d.MaSP)
                    .OnDelete(DeleteBehavior.Restrict);
            });

            modelBuilder.Entity<PhieuXuat>(entity =>
            {
                entity.HasIndex(e => e.SoPhieu).IsUnique();
                entity.Property(e => e.TongTien).HasColumnType("decimal(18,2)");

                entity.HasOne(d => d.Kho)
                    .WithMany(p => p.PhieuXuats)
                    .HasForeignKey(d => d.MaKho)
                    .OnDelete(DeleteBehavior.Restrict);

                entity.HasOne(d => d.NhanVien)
                    .WithMany(p => p.PhieuXuats)
                    .HasForeignKey(d => d.MaNV)
                    .OnDelete(DeleteBehavior.Restrict);
            });

            modelBuilder.Entity<ChiTietPhieuXuat>(entity =>
            {
                entity.Property(e => e.DonGia).HasColumnType("decimal(18,2)");
                entity.Property(e => e.ThanhTien).HasColumnType("decimal(18,2)");

                entity.HasOne(d => d.PhieuXuat)
                    .WithMany(p => p.ChiTietPhieuXuats)
                    .HasForeignKey(d => d.MaPX)
                    .OnDelete(DeleteBehavior.Cascade); // Cascade delete on goods issue deletion

                entity.HasOne(d => d.SanPham)
                    .WithMany(p => p.ChiTietPhieuXuats)
                    .HasForeignKey(d => d.MaSP)
                    .OnDelete(DeleteBehavior.Restrict);
            });

            modelBuilder.Entity<TonKho>(entity =>
            {
                entity.HasIndex(e => new { e.MaSP, e.MaKho }).IsUnique();

                entity.HasOne(d => d.SanPham)
                    .WithMany(p => p.TonKhos)
                    .HasForeignKey(d => d.MaSP)
                    .OnDelete(DeleteBehavior.Restrict);

                entity.HasOne(d => d.Kho)
                    .WithMany(p => p.TonKhos)
                    .HasForeignKey(d => d.MaKho)
                    .OnDelete(DeleteBehavior.Restrict);
            });

            // Configuration for views (Keyless entities)
            modelBuilder.Entity<TonKhoHienTaiView>(entity =>
            {
                entity.HasNoKey();
                entity.ToView("v_TonKhoHienTai");
                entity.Property(e => e.GiaNhap).HasColumnType("decimal(18,2)");
                entity.Property(e => e.GiaTri).HasColumnType("decimal(18,2)");
            });

            modelBuilder.Entity<SanPhamDuoiTonToiThieuView>(entity =>
            {
                entity.HasNoKey();
                entity.ToView("v_SanPhamDuoiTonToiThieu");
            });

            modelBuilder.Entity<NhapXuatTheoNgayView>(entity =>
            {
                entity.HasNoKey();
                entity.ToView("v_NhapXuatTheoNgay");
            });

            modelBuilder.Entity<PhieuGanDayView>(entity =>
            {
                entity.HasNoKey();
                entity.ToView("v_PhieuGanDay");
                entity.Property(e => e.TongTien).HasColumnType("decimal(18,2)");
            });

            modelBuilder.Entity<ThongKeTongQuatView>(entity =>
            {
                entity.HasNoKey();
                entity.ToView("v_ThongKeTongQuat");
                entity.Property(e => e.TongGiaTriTon).HasColumnType("decimal(18,2)");
            });

            modelBuilder.Entity<TopSanPhamXuatNhieuView>(entity =>
            {
                entity.HasNoKey();
                entity.ToView("v_TopSanPhamXuatNhieu");
                entity.Property(e => e.TongGiaTriXuat).HasColumnType("decimal(18,2)");
            });

            modelBuilder.Entity<DoanhThuTheoThangView>(entity =>
            {
                entity.HasNoKey();
                entity.ToView("v_DoanhThuTheoThang");
                entity.Property(e => e.TongDoanhThu).HasColumnType("decimal(18,2)");
            });
        }
    }
}
