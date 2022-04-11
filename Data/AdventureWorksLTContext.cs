using System;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata;
using AdventureWorksDemo.Models;

namespace AdventureWorksDemo.Data
{
    public partial class AdventureWorksLTContext : DbContext
    {
        public AdventureWorksLTContext()
        {
        }

        public AdventureWorksLTContext(DbContextOptions<AdventureWorksLTContext> options)
            : base(options)
        {
        }

        public virtual DbSet<SalesOrderDetail> SalesOrderDetails { get; set; } = null!;
        public virtual DbSet<SalesOrderHeader> SalesOrderHeaders { get; set; } = null!;

        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {
            if (!optionsBuilder.IsConfigured)
            {
                optionsBuilder.UseSqlServer("Name=ConnectionStrings:DefaultConnection");
            }
        }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<SalesOrderDetail>(entity =>
            {
                entity.HasKey(e => new { e.SalesOrderId, e.SalesOrderDetailId })
                    .HasName("PK_SalesOrderDetail_SalesOrderID_SalesOrderDetailID");

                entity.ToTable("SalesOrderDetail", "SalesLT");

                entity.HasIndex(e => e.Rowguid, "AK_SalesOrderDetail_rowguid")
                    .IsUnique();

                entity.HasIndex(e => e.ProductId, "IX_SalesOrderDetail_ProductID");

                entity.Property(e => e.SalesOrderId).HasColumnName("SalesOrderID");

                entity.Property(e => e.SalesOrderDetailId)
                    .ValueGeneratedOnAdd()
                    .HasColumnName("SalesOrderDetailID");

                entity.Property(e => e.LineTotal).HasColumnType("numeric(38, 6)");

                entity.Property(e => e.ModifiedDate).HasColumnType("datetime");

                entity.Property(e => e.ProductId).HasColumnName("ProductID");

                entity.Property(e => e.Rowguid).HasColumnName("rowguid");

                entity.Property(e => e.UnitPrice).HasColumnType("money");

                entity.Property(e => e.UnitPriceDiscount).HasColumnType("money");

                entity.HasOne(d => d.SalesOrder)
                    .WithMany(p => p.SalesOrderDetails)
                    .HasForeignKey(d => d.SalesOrderId);
            });

            modelBuilder.Entity<SalesOrderHeader>(entity =>
            {
                entity.HasKey(e => e.SalesOrderId)
                    .HasName("PK_SalesOrderHeader_SalesOrderID");

                entity.ToTable("SalesOrderHeader", "SalesLT");

                entity.HasIndex(e => e.SalesOrderNumber, "AK_SalesOrderHeader_SalesOrderNumber")
                    .IsUnique();

                entity.HasIndex(e => e.Rowguid, "AK_SalesOrderHeader_rowguid")
                    .IsUnique();

                entity.HasIndex(e => e.CustomerId, "IX_SalesOrderHeader_CustomerID");

                entity.Property(e => e.SalesOrderId)
                    .ValueGeneratedNever()
                    .HasColumnName("SalesOrderID");

                entity.Property(e => e.BillToAddressId).HasColumnName("BillToAddressID");

                entity.Property(e => e.CreditCardApprovalCode)
                    .HasMaxLength(15)
                    .IsUnicode(false);

                entity.Property(e => e.CustomerId).HasColumnName("CustomerID");

                entity.Property(e => e.DueDate).HasColumnType("datetime");

                entity.Property(e => e.Freight).HasColumnType("money");

                entity.Property(e => e.ModifiedDate).HasColumnType("datetime");

                entity.Property(e => e.OrderDate).HasColumnType("datetime");

                entity.Property(e => e.Rowguid).HasColumnName("rowguid");

                entity.Property(e => e.SalesOrderNumber).HasMaxLength(25);

                entity.Property(e => e.ShipDate).HasColumnType("datetime");

                entity.Property(e => e.ShipMethod).HasMaxLength(50);

                entity.Property(e => e.ShipToAddressId).HasColumnName("ShipToAddressID");

                entity.Property(e => e.SubTotal).HasColumnType("money");

                entity.Property(e => e.TaxAmt).HasColumnType("money");

                entity.Property(e => e.TotalDue).HasColumnType("money");
            });

            modelBuilder.HasSequence<int>("SalesOrderNumber", "SalesLT");

            OnModelCreatingPartial(modelBuilder);
        }

        partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
    }
}
