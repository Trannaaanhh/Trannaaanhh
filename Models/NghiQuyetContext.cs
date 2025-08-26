using Microsoft.EntityFrameworkCore;
using nghiquyet71.Models;

namespace NghiQuyetMVC.Models
{
    public class NghiQuyetContext : DbContext
    {
        public NghiQuyetContext(DbContextOptions<NghiQuyetContext> options) : base(options) { }

        public DbSet<Resolution> Resolutions { get; set; }
        public DbSet<Task> Tasks { get; set; }
        public DbSet<Ministry> Ministries { get; set; }

        // 👉 DbSet cho View
        public DbSet<TaskOverview> TaskOverviews { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // Map TaskOverview tới SQL view v_task_overview
            modelBuilder.Entity<TaskOverview>(entity =>
            {
                entity.HasNoKey();                // View không có khóa chính
                entity.ToView("v_task_overview"); // Tên view trong DB

                // Mapping các cột (chỉ cần khi khác tên property)
                entity.Property(e => e.Id).HasColumnName("id");
                entity.Property(e => e.Code).HasColumnName("code");
                entity.Property(e => e.Title).HasColumnName("title");
                entity.Property(e => e.LeadMinistryId).HasColumnName("lead_ministry_id");
                entity.Property(e => e.LeadMinistryName).HasColumnName("lead_ministry_name");
                entity.Property(e => e.Deadline).HasColumnName("deadline");
                entity.Property(e => e.Status).HasColumnName("status");
                entity.Property(e => e.Progress).HasColumnName("progress");
                entity.Property(e => e.CreatedAt).HasColumnName("created_at");
                entity.Property(e => e.UpdatedAt).HasColumnName("updated_at");
            });
        }
    }
}
