dotnet user-secrets init
dotnet user-secrets set ConnectionStrings:DefaultConnection "Server=tcp:adv001dbserver.database.windows.net,1433;Initial Catalog=AdventureWorksLT;Persist Security Info=False;User ID=app-user;Password=SuperSecret!@#;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
dotnet ef dbcontext scaffold Name=ConnectionStrings:DefaultConnection Microsoft.EntityFrameworkCore.SqlServer