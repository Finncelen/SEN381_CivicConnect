namespace CivicConnectMvc.Interfaces;

public interface IWhatsAppNotificationClient
{
    string SendMessage(
        string recipientPhone,
        string title,
        string body);
}