using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace NghiQuyetMVC.Models
{
    [Table("resolutions")]
    public class Resolution
    {
        [Key]
        public Guid id { get; set; }
        public string number { get; set; }
        public string title { get; set; }
        public string summary { get; set; }
        public DateTime? issued_date { get; set; }
        public DateTime? effective_date { get; set; }

        public virtual ICollection<Task> Tasks { get; set; }
    }

    [Table("ministries")]
    public class Ministry
    {
        [Key]
        public int id { get; set; }
        public string code { get; set; }
        public string name { get; set; }
    }

    [Table("tasks")]
    public class Task
    {
        [Key]
        public Guid id { get; set; }
        public string code { get; set; }
        public string title { get; set; }
        public string description { get; set; }

        [ForeignKey("Resolution")]
        public Guid resolution_id { get; set; }
        public Resolution Resolution { get; set; }

        [ForeignKey("Ministry")]
        public int? lead_ministry_id { get; set; }
        public Ministry Ministry { get; set; }

        public DateTime? deadline { get; set; }
        public string status { get; set; }
        public short progress { get; set; }
    }
}
