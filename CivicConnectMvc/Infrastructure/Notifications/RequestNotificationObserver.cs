using CivicConnectMvc.Interfaces;
using CivicConnectMvc.Models;

namespace CivicConnectMvc.Infrastructure.Notifications;

// Observer reacts to service-request changes without putting
// notification code in the domain model.
public class RequestNotificationObserver : IRequestObserver
{
    private readonly INotificationAdapter _notificationAdapter;
    private readonly IWhatsAppNotificationClient _whatsAppClient;

    public RequestNotificationObserver(
        INotificationAdapter notificationAdapter,
        IWhatsAppNotificationClient whatsAppClient)
    {
        _notificationAdapter = notificationAdapter;
        _whatsAppClient = whatsAppClient;
    }

    public void OnRequestChanged(ServiceRequest request, string action)
    {
        // 1. Send the email notification.
        var emailRecipient = request.Requester?.Email;

        if (!string.IsNullOrWhiteSpace(emailRecipient))
        {
            var emailNotification = new NotificationMessage(
                emailRecipient,
                $"CivicConnect request #{request.RequestId} updated",
                $"{action}. Current status: {request.CurrentStatus}.");

            _notificationAdapter.Send(emailNotification);
        }


        // 2. Send the WhatsApp notification if a phone number is available.
        var phoneNumber = request.Requester?.PhoneNumber;

        if (!string.IsNullOrWhiteSpace(phoneNumber))
        {
            var messageSid = _whatsAppClient.SendMessage(
                phoneNumber,
                $"CivicConnect request #{request.RequestId}",
                $"{action}. Current status: {request.CurrentStatus}.");

            // The SID identifies the message accepted by Twilio.
            // Avoid logging credentials or other sensitive information.
            Console.WriteLine(
                $"WhatsApp notification submitted to Twilio. Message SID: {messageSid}");
        }
    }
}