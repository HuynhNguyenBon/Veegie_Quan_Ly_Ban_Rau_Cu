using Microsoft.EntityFrameworkCore;
using Veggie.Api.Models.Entities;

namespace Veggie.Api.Models.EF;

public partial class VeggieDbContext
{
    public DbSet<ChatMessage> ChatMessages => Set<ChatMessage>();
    public DbSet<AccountToken> AccountTokens => Set<AccountToken>();
    public DbSet<NewsletterSubscription> NewsletterSubscriptions => Set<NewsletterSubscription>();
    public DbSet<StoreEmail> StoreEmailQueue => Set<StoreEmail>();
    partial void OnModelCreatingPartial(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Payment>().Property(p=>p.BankTransactionId).HasMaxLength(150);
        modelBuilder.Entity<ChatMessage>().Property(c=>c.GuestToken).HasMaxLength(64);
        modelBuilder.Entity<NewsletterSubscription>().Property(s => s.Email).HasMaxLength(254);
        modelBuilder.Entity<StoreEmail>().ToTable("StoreEmailQueue");
        modelBuilder.Entity<StoreEmail>().Property(s => s.ToEmail).HasMaxLength(254);
        modelBuilder.Entity<StoreEmail>().Property(s => s.ReplyTo).HasMaxLength(254);
        modelBuilder.Entity<StoreEmail>().Property(s => s.Subject).HasMaxLength(200);
        modelBuilder.Entity<User>().Property(u => u.SecurityStamp).HasMaxLength(36);
        modelBuilder.Entity<AccountToken>(entity =>
        {
            entity.HasKey(t => t.Id);
            entity.Property(t => t.TokenHash).HasMaxLength(64);
            entity.Property(t => t.Purpose).HasMaxLength(20);
            entity.HasOne<User>().WithMany().HasForeignKey(t => t.UserId).OnDelete(DeleteBehavior.NoAction);
        });
    }
}

