import 'package:awesome_notifications/awesome_notifications.dart';

class NotificationController{
  static String BASIC_CHANNEL_KEY = "basic_channel";
  static String SUBJECT_REQUEST_CHANNEL_KEY = "subject_request_channel";
  static int TODAY_SCHEDULES_NOTI = 1;
  static int NEW_SCHEDULES_NOTI = 2;
  static int DENIED_SCHEDULES_NOTI = 3;
  static int ACCEPT_SCHEDULES_NOTI = 4;
  static int NEW_CLASS_NOTI = 5;
  static int SIGN_UP_SUCCESSFULLY = 6;
  static int CLASS_REMOVE_NOTI = 7;

  /// Use this method to detect when a new notification or a schedule is created
  @pragma("vm:entry-point")
  static Future <void> onNotificationCreatedMethod(ReceivedNotification receivedNotification) async {
    // Your code goes here
  }

  /// Use this method to detect if the user dismissed a notification
  @pragma("vm:entry-point")
  static Future <void> onDismissActionReceivedMethod(ReceivedAction receivedAction) async {
    // Your code goes here

  }

  /// Use this method to detect when the user taps on a notification or action button
  @pragma("vm:entry-point")
  static Future <void> onActionReceivedMethod(ReceivedAction receivedAction) async {
    // Your code goes here

    // Navigate into pages, avoiding to open the notification details page over another details page already opened

  }

  /// Use this method to detect every time that a new notification is displayed
  @pragma("vm:entry-point")
  static Future <void> onNotificationDisplayedMethod(ReceivedNotification receivedNotification) async {
    // Your code goes here
  }

}