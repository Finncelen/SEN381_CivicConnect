using CivicConnectMvc.Interfaces;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using CivicConnectMvc.Interfaces;

namespace CivicConnectMvc.Infrastructure.Notifications;

public class DemoNotificationClient : IExternalNotificationClient
{
    private readonly HttpClient _httpClient;
    private readonly IConfiguration _configuration;

    public DemoNotificationClient(
        HttpClient httpClient,
        IConfiguration configuration)
    {
        _httpClient = httpClient;
        _configuration = configuration;
    }

    public void SendMessage(string recipient, string title, string body)
    {
        var apiKey = _configuration["Email:ApiKey"];
        var fromEmail = _configuration["Email:From"];

        if (string.IsNullOrWhiteSpace(apiKey) ||
            string.IsNullOrWhiteSpace(fromEmail))
        {
            throw new InvalidOperationException(
                "Email API key or sender email is not configured.");
        }

        _httpClient.DefaultRequestHeaders.Authorization =
            new AuthenticationHeaderValue("Bearer", apiKey);

        var email = new
        {
            from = fromEmail,
            to = new[] { recipient },
            subject = title,
            html = $"""
                <h2>CivicConnect Confirmation</h2>
                <p>{System.Net.WebUtility.HtmlEncode(body)}</p>
                <p>Thank you for submitting your service request.</p>
                <p>Regards,<br/>The CivicConnect Team</p>
                """
        };

        // Send the email through the Resend API.
        var response = _httpClient
            .PostAsJsonAsync("https://api.resend.com/emails", email)
            .GetAwaiter()
            .GetResult();

        if (!response.IsSuccessStatusCode)
        {
            var error = response.Content.ReadAsStringAsync()
                .GetAwaiter()
                .GetResult();

            throw new InvalidOperationException(
                $"Email API failed ({(int)response.StatusCode}): {error}");
        }
    }
}
