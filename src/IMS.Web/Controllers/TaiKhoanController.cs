using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using IMS.Web.Services;
using System.Security.Claims;

namespace IMS.Web.Controllers
{
    public class TaiKhoanController : Controller
    {
        private readonly ITaiKhoanService _taiKhoanService;

        public TaiKhoanController(ITaiKhoanService taiKhoanService)
        {
            _taiKhoanService = taiKhoanService;
        }

        [HttpGet]
        [AllowAnonymous]
        public IActionResult Login()
        {
            if (User.Identity != null && User.Identity.IsAuthenticated)
            {
                return RedirectToAction("Index", "Home");
            }
            return View();
        }

        [HttpPost]
        [AllowAnonymous]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Login(string username, string password)
        {
            if (string.IsNullOrEmpty(username) || string.IsNullOrEmpty(password))
            {
                ModelState.AddModelError("", "Tên đăng nhập và mật khẩu không được trống.");
                return View();
            }

            var taiKhoan = await _taiKhoanService.LoginAsync(username, password);
            if (taiKhoan == null)
            {
                ModelState.AddModelError("", "Tài khoản hoặc mật khẩu không đúng.");
                return View();
            }

            // Set up authentication claims
            var claims = new List<Claim>
            {
                new Claim(ClaimTypes.Name, taiKhoan.TenDangNhap),
                new Claim(ClaimTypes.Role, taiKhoan.VaiTro?.TenVaiTro ?? "NVKho"),
                new Claim(ClaimTypes.GivenName, taiKhoan.NhanVien?.HoTen ?? taiKhoan.TenDangNhap),
                new Claim(ClaimTypes.NameIdentifier, taiKhoan.MaTK.ToString()),
                new Claim("MaNV", taiKhoan.MaNV.ToString())
            };

            var claimsIdentity = new ClaimsIdentity(claims, CookieAuthenticationDefaults.AuthenticationScheme);

            var authProperties = new AuthenticationProperties
            {
                IsPersistent = true,
                ExpiresUtc = DateTimeOffset.UtcNow.AddHours(4)
            };

            await HttpContext.SignInAsync(
                CookieAuthenticationDefaults.AuthenticationScheme,
                new ClaimsPrincipal(claimsIdentity),
                authProperties);

            // Store user info in Session
            HttpContext.Session.SetString("TenNV", taiKhoan.NhanVien?.HoTen ?? taiKhoan.TenDangNhap);
            HttpContext.Session.SetString("VaiTro", taiKhoan.VaiTro?.TenVaiTro ?? "NVKho");
            HttpContext.Session.SetInt32("MaNV", taiKhoan.MaNV);

            return RedirectToAction("Index", "Home");
        }

        [HttpGet]
        public async Task<IActionResult> Logout()
        {
            await HttpContext.SignOutAsync(CookieAuthenticationDefaults.AuthenticationScheme);
            HttpContext.Session.Clear();
            return RedirectToAction("Login");
        }

        [HttpGet]
        [Authorize]
        public IActionResult DoiMatKhau()
        {
            ViewData["Title"] = "Đổi mật khẩu";
            return View();
        }

        [HttpPost]
        [Authorize]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> DoiMatKhau(string matKhauCu, string matKhauMoi, string xacNhanMatKhau)
        {
            ViewData["Title"] = "Đổi mật khẩu";

            if (string.IsNullOrEmpty(matKhauCu) || string.IsNullOrEmpty(matKhauMoi))
            {
                TempData["Error"] = "Vui lòng điền đầy đủ thông tin.";
                return View();
            }

            if (matKhauMoi != xacNhanMatKhau)
            {
                TempData["Error"] = "Mật khẩu mới và mật khẩu xác nhận không khớp.";
                return View();
            }

            // Get account ID of the logged in user
            var maTKClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (string.IsNullOrEmpty(maTKClaim) || !int.TryParse(maTKClaim, out int maTK))
            {
                return RedirectToAction("Logout");
            }

            bool result = await _taiKhoanService.DoiMatKhauAsync(maTK, matKhauCu, matKhauMoi);
            if (result)
            {
                TempData["Success"] = "Đổi mật khẩu thành công!";
                return View();
            }
            else
            {
                TempData["Error"] = "Đổi mật khẩu thất bại. Vui lòng kiểm tra lại mật khẩu cũ.";
                return View();
            }
        }

        [HttpGet]
        [AllowAnonymous]
        public IActionResult AccessDenied()
        {
            ViewData["Title"] = "Từ chối truy cập";
            return View();
        }
    }
}
