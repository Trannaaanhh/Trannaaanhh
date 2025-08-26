using Microsoft.EntityFrameworkCore;
using NghiQuyetMVC.Models;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllersWithViews();

// ??ng ký DbContext v?i connection string trong appsettings.json
builder.Services.AddDbContext<NghiQuyetContext>(options =>
    options.UseNpgsql(builder.Configuration.GetConnectionString("NghiQuyetContext")));

var app = builder.Build();

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Home/Error");
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseStaticFiles();

app.UseRouting();

app.UseAuthorization();

app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Resolutions}/{action=Index}/{id?}");

app.Run();
