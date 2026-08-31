import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp();

// Twilio configuration (set via Firebase CLI)
// firebase functions:config:set twilio.account_sid="YOUR_SID"
// firebase functions:config:set twilio.auth_token="YOUR_TOKEN"
// firebase functions:config:set twilio.phone_number="+1234567890"

interface TwilioConfig {
  account_sid: string;
  auth_token: string;
  phone_number: string;
}

/**
 * Send leave time notification via SMS
 */
export const sendLeaveTimeNotification = functions.https.onCall(
  async (data, context) => {
    // Verify authentication
    if (!context.auth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        'User must be authenticated to send notifications'
      );
    }

    const { phoneNumber, childName, leaveTime, dismissalTime } = data;

    // Validate inputs
    if (!phoneNumber || !childName || !leaveTime || !dismissalTime) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        'Missing required parameters'
      );
    }

    const message = 
      `🚗 BellGo: Time to leave!\n\n` +
      `${childName}'s school ends at ${dismissalTime}.\n` +
      `Leave by ${leaveTime} to arrive on time.`;

    try {
      await sendSmsViaTwilio(phoneNumber, message);
      
      // Log notification
      await admin.firestore()
        .collection('notifications')
        .add({
          userId: context.auth.uid,
          type: 'leave_time',
          phoneNumber: phoneNumber,
          childName: childName,
          sentAt: admin.firestore.FieldValue.serverTimestamp(),
          status: 'sent',
        });

      return { success: true, message: 'Notification sent' };
    } catch (error) {
      console.error('Error sending SMS:', error);
      throw new functions.https.HttpsError(
        'internal',
        'Failed to send SMS notification'
      );
    }
  }
);

/**
 * Send schedule change notification via SMS
 */
export const sendScheduleChangeNotification = functions.https.onCall(
  async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        'User must be authenticated'
      );
    }

    const { phoneNumber, childName, date, scheduleType, dismissalTime } = data;

    if (!phoneNumber || !childName || !date || !scheduleType || !dismissalTime) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        'Missing required parameters'
      );
    }

    const message = 
      `⚠️ BellGo: Schedule Change\n\n` +
      `${childName} has a ${scheduleType} on ${date}.\n` +
      `School ends at ${dismissalTime}.`;

    try {
      await sendSmsViaTwilio(phoneNumber, message);
      
      await admin.firestore()
        .collection('notifications')
        .add({
          userId: context.auth.uid,
          type: 'schedule_change',
          phoneNumber: phoneNumber,
          childName: childName,
          sentAt: admin.firestore.FieldValue.serverTimestamp(),
          status: 'sent',
        });

      return { success: true, message: 'Notification sent' };
    } catch (error) {
      console.error('Error sending SMS:', error);
      throw new functions.https.HttpsError(
        'internal',
        'Failed to send SMS notification'
      );
    }
  }
);

/**
 * Send test SMS to verify phone number
 */
export const sendTestSms = functions.https.onCall(
  async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        'User must be authenticated'
      );
    }

    const { phoneNumber } = data;

    if (!phoneNumber) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        'Phone number is required'
      );
    }

    const message = 
      `✅ BellGo Test\n\n` +
      `Your phone is verified! You'll receive pickup reminders at this number.`;

    try {
      await sendSmsViaTwilio(phoneNumber, message);
      
      await admin.firestore()
        .collection('notifications')
        .add({
          userId: context.auth.uid,
          type: 'test',
          phoneNumber: phoneNumber,
          sentAt: admin.firestore.FieldValue.serverTimestamp(),
          status: 'sent',
        });

      return { success: true, message: 'Test SMS sent' };
    } catch (error) {
      console.error('Error sending test SMS:', error);
      throw new functions.https.HttpsError(
        'internal',
        'Failed to send test SMS'
      );
    }
  }
);

/**
 * Send SMS via Twilio
 */
async function sendSmsViaTwilio(
  phoneNumber: string,
  message: string
): Promise<void> {
  const twilioConfig = functions.config().twilio as TwilioConfig;
  
  if (!twilioConfig || !twilioConfig.account_sid || !twilioConfig.auth_token) {
    throw new Error('Twilio configuration not found');
  }

  const twilio = require('twilio');
  const client = twilio(
    twilioConfig.account_sid,
    twilioConfig.auth_token
  );

  await client.messages.create({
    body: message,
    from: twilioConfig.phone_number,
    to: phoneNumber,
  });
}

/**
 * Scheduled function to send daily pickup reminders
 * Runs every day at 2:00 PM (adjustable)
 */
export const sendDailyPickupReminders = functions.pubsub
  .schedule('0 14 * * *')
  .timeZone('America/Los_Angeles')
  .onRun(async (context) => {
    const now = new Date();
    
    // Query users who have verified phone numbers and active children
    const usersSnapshot = await admin.firestore()
      .collection('users')
      .where('phoneVerifiedAt', '!=', null)
      .get();

    const promises: Promise<any>[] = [];

    for (const userDoc of usersSnapshot.docs) {
      const userData = userDoc.data();
      const phoneNumber = userData.phoneNumber;

      if (!phoneNumber) continue;

      // Get user's children and today's schedule
      // This is a simplified version - adjust based on your data model
      const childrenSnapshot = await admin.firestore()
        .collection('users')
        .doc(userDoc.id)
        .collection('children')
        .get();

      for (const childDoc of childrenSnapshot.docs) {
        const childData = childDoc.data();
        
        // Check if it's time to send reminder
        // Add your logic here based on dismissal time, location, etc.
        
        const message = 
          `🚗 BellGo Reminder\n\n` +
          `${childData.name}'s school ends soon. Check the app for pickup details.`;

        promises.push(sendSmsViaTwilio(phoneNumber, message));
      }
    }

    await Promise.all(promises);
    console.log(`Sent ${promises.length} daily reminders`);
  });
