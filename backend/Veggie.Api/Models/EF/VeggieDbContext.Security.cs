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

        modelBuilder.Entity<Promotion>(entity =>
        {
            entity.ToTable("Promotions");
            entity.HasKey(p => p.Id);
            entity.HasIndex(p => p.Code).IsUnique();
            entity.Property(p => p.Code).HasMaxLength(40).IsRequired();
            entity.Property(p => p.Description).HasMaxLength(240).IsRequired();
            entity.Property(p => p.DiscountType).HasMaxLength(12).IsRequired();
            entity.Property(p => p.DiscountValue).HasColumnType("decimal(18, 2)");
            entity.Property(p => p.MinimumSubtotal).HasColumnType("decimal(18, 2)");
            entity.Property(p => p.MaximumDiscount).HasColumnType("decimal(18, 2)");
            entity.Property(p => p.CreatedAt).HasDefaultValueSql("(sysutcdatetime())");
            entity.HasOne<User>().WithMany().HasForeignKey(p => p.AssignedUserId).OnDelete(DeleteBehavior.NoAction);
        });

        modelBuilder.Entity<PromotionUsage>(entity =>
        {
            entity.ToTable("PromotionUsages");
            entity.HasKey(p => p.Id);
            entity.HasIndex(p => p.OrderId).IsUnique();
            entity.HasIndex(p => new { p.PromotionId, p.UserId });
            entity.Property(p => p.DiscountAmount).HasColumnType("decimal(18, 2)");
            entity.Property(p => p.UsedAt).HasDefaultValueSql("(sysutcdatetime())");
            entity.HasOne<Promotion>().WithMany().HasForeignKey(p => p.PromotionId).OnDelete(DeleteBehavior.NoAction);
            entity.HasOne<User>().WithMany().HasForeignKey(p => p.UserId).OnDelete(DeleteBehavior.NoAction);
            entity.HasOne<Order>().WithMany().HasForeignKey(p => p.OrderId).OnDelete(DeleteBehavior.NoAction);
        });

        modelBuilder.Entity<Reward>(entity =>
        {
            entity.ToTable("Rewards");
            entity.HasKey(r => r.Id);
            entity.Property(r => r.Name).HasMaxLength(120).IsRequired();
            entity.Property(r => r.Description).HasMaxLength(500).IsRequired();
            entity.Property(r => r.RewardType).HasMaxLength(12).IsRequired();
            entity.Property(r => r.DiscountAmount).HasColumnType("decimal(18, 2)");
            entity.Property(r => r.MinimumOrderAmount).HasColumnType("decimal(18, 2)");
            entity.Property(r => r.CreatedAt).HasDefaultValueSql("(sysutcdatetime())");
        });

        modelBuilder.Entity<RewardRedemption>(entity =>
        {
            entity.ToTable("RewardRedemptions");
            entity.HasKey(r => r.Id);
            entity.HasIndex(r => r.PromotionId).IsUnique().HasFilter("[PromotionId] IS NOT NULL");
            entity.Property(r => r.Status).HasMaxLength(20).IsRequired();
            entity.Property(r => r.RedeemedAt).HasDefaultValueSql("(sysutcdatetime())");
            entity.HasOne(r => r.User).WithMany().HasForeignKey(r => r.UserId).OnDelete(DeleteBehavior.NoAction);
            entity.HasOne(r => r.Reward).WithMany().HasForeignKey(r => r.RewardId).OnDelete(DeleteBehavior.NoAction);
            entity.HasOne(r => r.Promotion).WithMany().HasForeignKey(r => r.PromotionId).OnDelete(DeleteBehavior.NoAction);
        });

        modelBuilder.Entity<LoyaltyPointTransaction>(entity =>
        {
            entity.ToTable("LoyaltyPointTransactions");
            entity.HasKey(p => p.Id);
            entity.HasIndex(p => p.OrderId).IsUnique().HasFilter("[OrderId] IS NOT NULL");
            entity.HasIndex(p => p.RedemptionId).IsUnique().HasFilter("[RedemptionId] IS NOT NULL");
            entity.Property(p => p.Type).HasMaxLength(12).IsRequired();
            entity.Property(p => p.Note).HasMaxLength(240).IsRequired();
            entity.Property(p => p.CreatedAt).HasDefaultValueSql("(sysutcdatetime())");
            entity.HasOne<User>().WithMany().HasForeignKey(p => p.UserId).OnDelete(DeleteBehavior.NoAction);
            entity.HasOne<Order>().WithMany().HasForeignKey(p => p.OrderId).OnDelete(DeleteBehavior.NoAction);
            entity.HasOne<RewardRedemption>().WithMany().HasForeignKey(p => p.RedemptionId).OnDelete(DeleteBehavior.NoAction);
        });

        modelBuilder.Entity<LoyaltySettings>(entity =>
        {
            entity.ToTable("LoyaltySettings");
            entity.HasKey(s => s.Id);
            entity.Property(s => s.UpdatedAt).HasDefaultValueSql("(sysutcdatetime())");
        });
    }
}

