using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;
using Microsoft.Extensions.Configuration;

namespace CivicConnectMvc.Data;

public class CivicConnectDbContextFactory
    : IDesignTimeDbContextFactory<CivicConnectDbContext>
{
    public CivicConnectDbContext CreateDbContext(string[] args)
    {
        var configuration = new ConfigurationBuilder()
            .SetBasePath(Directory.GetCurrentDirectory())
            .AddJsonFile("appsettings.json", optional: false)
            .AddUserSecrets<Program>(optional: true)
            .AddEnvironmentVariables()
            .Build();

        var connectionString =
            configuration.GetConnectionString("CivicConnectDb");

        if (string.IsNullOrWhiteSpace(connectionString))
        {
            throw new InvalidOperationException(
                "Connection string 'CivicConnectDb' is not configured.");
        }

        var options = new DbContextOptionsBuilder<CivicConnectDbContext>()
            .UseNpgsql(connectionString)
            .Options;

        return new CivicConnectDbContext(options);
    }
}