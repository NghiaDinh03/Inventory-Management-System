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
                ModelState.AddModelError("", "TÃªn Ä‘Äƒng nháº­p vÃ  máº­t kháº©u khÃ´ng Ä‘Æ°á»£c trá»‘ng.");
                return View();
            }

            var taiKhoan = await _taiKhoanService.LoginAsync(username, password);
            if (taiKhoan == null)
            {
                ModelState.AddModelError("", "TÃ i khoáº£n hoáº·c máº­t kháº©u khÃ´ng Ä‘Ãºng.");
                return View();
            }

            
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
            ViewData["Title"] = "Äá»•i máº­t kháº©u";
            return View();
        }

        [HttpPost]
        [Authorize]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> DoiMatKhau(string matKhauCu, string matKhauMoi, string xacNhanMatKhau)
        {
            ViewData["Title"] = "Äá»•i máº­t kháº©u";

            if (string.IsNullOrEmpty(matKhauCu) || string.IsNullOrEmpty(matKhauMoi))
            {
                TempData["Error"] = "Vui lÃ²ng Ä‘iá»n Ä‘áº§y Ä‘á»§ thÃ´ng tin.";
                return View();
            }

            if (matKhauMoi != xacNhanMatKhau)
            {
                TempData["Error"] = "Máº­t kháº©u má»›i vÃ  máº­t kháº©u xÃ¡c nháº­n khÃ´ng khá»›p.";
                return View();
            }

            
            var maTKClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (string.IsNullOrEmpty(maTKClaim) || !int.TryParse(maTKClaim, out int maTK))
            {
                return RedirectToAction("Logout");
            }

            bool result = await _taiKhoanService.DoiMatKhauAsync(maTK, matKhauCu, matKhauMoi);
            if (result)
            {
                TempData["Success"] = "Äá»•i máº­t kháº©u thÃ nh cÃ´ng!";
                return View();
            }
            else
            {
                TempData["Error"] = "Äá»•i máº­t kháº©u tháº¥t báº¡i. Vui lÃ²ng kiá»ƒm tra láº¡i máº­t kháº©u cÅ©.";
                return View();
            }
        }

        [HttpGet]
        [AllowAnonymous]
        public IActionResult AccessDenied()
        {
            ViewData["Title"] = "Tá»« chá»‘i truy cáº­p";
            return View();
        }
    }
}
