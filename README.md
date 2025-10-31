# Notifshare
## Background Notification Forwarder (Flutter)

A lightweight Flutter app that captures Android notifications and forwards selected ones to a configurable API endpoint, such as a Telegram bot. This repo provides everything needed to run the app and configure your own notification forwarding service.

---

## Features

- Real-time Android notification capture
- Rule-based filtering on app package, title, or message
- Deduplication to avoid sending repeated notifications
- Persistent background service with foreground notification
- Forward notifications to any REST API (Telegram, Slack, etc.)
- Dynamic rule management via UI

---

## Getting Started

### 1. Install Dependencies

Make sure you have Flutter installed and configured. Then, in the project root:

```bash
flutter pub get
```

---

### 2. Configure Permissions

The app requires the following permissions on Android:

- Notification access
- Internet access
- Foreground service

Add them in your `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.BIND_NOTIFICATION_LISTENER_SERVICE" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
<uses-permission android:name="android.permission.INTERNET"/>
```

---

### 3. Configure the API Endpoint

By default, the app forwards notifications via HTTP POST to a configurable API endpoint. You can use a simple PHP script to receive and relay notifications to Telegram:

```php
<?php
// send_notification.php
$botToken = 'YOUR_TELEGRAM_BOT_TOKEN';
$chatId = 'YOUR_TELEGRAM_CHAT_ID';

// Get JSON POST payload
$data = json_decode(file_get_contents('php://input'), true);

if (!$data) {
    http_response_code(400);
    echo 'Invalid request';
    exit;
}

$message = "New Notification:\n";
$message .= "App: " . $data['packageName'] . "\n";
$message .= "Title: " . $data['title'] . "\n";
$message .= "Message: " . $data['message'] . "\n";
$message .= "Time: " . $data['timestamp'];

// Send message via Telegram API
file_get_contents("https://api.telegram.org/bot$botToken/sendMessage?chat_id=$chatId&text=" . urlencode($message));

echo 'Notification sent';
?>
```

Update the app configuration in the UI or `SharedPreferences` to point to your API endpoint, e.g.:

```
https://yourdomain.com/send_notification.php
```

---

### 4. Rule Management

1. Open the app.
2. Go to the Rules screen.
3. Add rules specifying:
   - Package filter (e.g., `com.fiverr.app`)
   - Title keywords (optional)
   - Message keywords (optional)
4. Rules are saved locally and applied in real-time.

> If no rules exist, the app will prompt you to create one.

---

### 5. Running the App

```bash
flutter run
```

The app will:

1. Start a persistent background service.
2. Capture notifications in real-time.
3. Apply your defined rules.
4. Forward matching notifications to your API endpoint.
5. Show status in a persistent foreground notification.

---

## Example JSON Payload

When a notification is forwarded, the app sends a POST request like this:

```json
{
  "packageName": "com.fiverr.app",
  "title": "New Message",
  "message": "You have a new request",
  "timestamp": "2025-10-30T10:15:00Z"
}
```

---

## Tech Stack

| Component                  | Library                       |
|----------------------------|-------------------------------|
| Background Execution       | flutter_background_service    |
| Notification Access        | notifications                 |
| Foreground Notification    | flutter_local_notifications   |
| Local Storage              | shared_preferences            |
| HTTP Requests              | http                          |
| Permission Handling        | permission_handler            |

---

## Notes

- Works on Android devices supporting notification listener services.
- App is designed for personal automation, but the structure can be adapted for other APIs.
- PHP script can be replaced with any backend that accepts JSON POST requests.

---
