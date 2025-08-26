namespace NghiQuyetMVC.Models
{
    public class TaskOverview
    {
        public Guid Id { get; set; }
        public string Code { get; set; }
        public string Title { get; set; }
        public int? LeadMinistryId { get; set; }
        public string LeadMinistryName { get; set; }
        public DateTime? Deadline { get; set; }
        public string Status { get; set; }
        public int Progress { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }
    }
}
