using Microsoft.AspNetCore.Mvc;
using NghiQuyetMVC.Models;
using Microsoft.EntityFrameworkCore;
using System;
using System.Linq;

namespace NghiQuyetMVC.Controllers
{
    public class ResolutionsController : Controller
    {
        private readonly NghiQuyetContext _context;

        public ResolutionsController(NghiQuyetContext context)
        {
            _context = context;
        }

        // GET: /Resolutions
        public IActionResult Index()
        {
            var resolutions = _context.Resolutions.ToList();
            return View(resolutions);
        }

        // GET: /Resolutions/Details/{id}
        public IActionResult Details(Guid id)
        {
            var resolution = _context.Resolutions
                                     .Include(r => r.Tasks)
                                     .FirstOrDefault(r => r.id == id);

            if (resolution == null) return NotFound();

            return View(resolution);
        }
    }
}
