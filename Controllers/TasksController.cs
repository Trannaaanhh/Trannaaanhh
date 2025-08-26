using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using NghiQuyetMVC.Models;

namespace NghiQuyetMVC.Controllers
{
    public class TasksController : Controller
    {
        private readonly NghiQuyetContext _context;

        public TasksController(NghiQuyetContext context)
        {
            _context = context;
        }

        public async Task<IActionResult> Index()
        {
            var tasks = await _context.TaskOverviews.ToListAsync();
            return View(tasks);
        }
    }
}
