dotnet tool install -g dotnet-aspnet-codegenerator
dotnet aspnet-codegenerator controller -name OrderController -async -api -m Models/SalesOrderHeader -dc Data/AdventureWorksLTContext -outDir Controllers