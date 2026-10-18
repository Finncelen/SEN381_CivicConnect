using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;
using CivicConnectMvc.Interfaces;

namespace CivicConnectMvc.Infrastructure.Notifications;

public class TwilioWhatsAppNotificationClient
    : IWhatsAppNotificationClient
{
    private readonly HttpClient _httpClient;
    private readonly IConfiguration _configuration;

    public TwilioWhatsAppNotificationClient(
        HttpClient httpClient,
        IConfiguration configuration)
    {
        _httpClient = httpClient;
        _configuration = configuration;
    }

    public string SendMessage(
        string recipientPhone,
        string title,
        string body)
    {
        var accountSid = _configuration["Twilio:AccountSid"];
        var authToken = _configuration["Twilio:AuthToken"];
        var from = _configuration["Twilio:WhatsAppFrom"];
        var contentSid = _configuration["Twilio:ContentSid"];

        if (string.IsNullOrWhiteSpace(accountSid) ||
            string.IsNullOrWhiteSpace(authToken) ||
            string.IsNullOrWhiteSpace(from) ||
            string.IsNullOrWhiteSpace(contentSid))
        {
            throw new InvalidOperationException(
                "Twilio configuration is incomplete.");
        }

        if (string.IsNullOrWhiteSpace(recipientPhone))
        {
            throw new ArgumentException(
                "The resident's phone number is required.");
        }

        var to = recipientPhone.StartsWith(
            "whatsapp:", StringComparison.OrdinalIgnoreCase)
            ? recipientPhone
            : $"whatsapp:{recipientPhone}";

        var url =
            $"https://api.twilio.com/2010-04-01/Accounts/{accountSid}/Messages.json";

        using var request = new HttpRequestMessage(HttpMethod.Post, url);

        var credentials = Convert.ToBase64String(
            Encoding.UTF8.GetBytes($"{accountSid}:{authToken}"));

        request.Headers.Authorization =
            new AuthenticationHeaderValue("Basic", credentials);

        request.Content = new FormUrlEncodedContent(
            new Dictionary<string, string>
            {
                ["To"] = to,
                ["From"] = from,
                ["ContentSid"] = contentSid
            });

        using var response = _httpClient
            .SendAsync(request)
            .GetAwaiter()
            .GetResult();

        var responseJson = response.Content
            .ReadAsStringAsync()
            .GetAwaiter()
            .GetResult();

        if (!response.IsSuccessStatusCode)
        {
            throw new HttpRequestException(
                $"Twilio returned HTTP {(int)response.StatusCode}: " +
                responseJson);
        }

        using var document = JsonDocument.Parse(responseJson);

        var messageSid = document.RootElement
            .GetProperty("sid")
            .GetString();

        if (string.IsNullOrWhiteSpace(messageSid))
        {
            throw new InvalidOperationException(
                "Twilio returned no message SID.");
        }

        return messageSid;
    }
}