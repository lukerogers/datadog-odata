using Microsoft.AspNetCore.Diagnostics.HealthChecks;
using Microsoft.Extensions.Diagnostics.HealthChecks;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllers();

builder.Services.AddHealthChecks()
    .AddCheck("healthz", () => HealthCheckResult.Healthy())
    .AddCheck("readyz", () => HealthCheckResult.Healthy(), new[] { "readiness" });

var app = builder.Build();

// Configure the HTTP request pipeline.

app.UseHealthChecks("/healthz", new HealthCheckOptions
{
    Predicate = r => r.Name.Contains("healthz")
});

app.UseHealthChecks("/readyz", new HealthCheckOptions
{
    Predicate = r => r.Tags.Contains("readiness")
});

app.UseAuthorization();

app.MapControllers();

app.Run();
