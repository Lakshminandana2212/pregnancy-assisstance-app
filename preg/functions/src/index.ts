/**
 * Import function triggers from their respective submodules:
 *
 * import {onCall} from "firebase-functions/v2/https";
 * import {onDocumentWritten} from "firebase-functions/v2/firestore";
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

import {onRequest} from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import * as sgMail from '@sendgrid/mail';

admin.initializeApp();
sgMail.setApiKey(functions.config().sendgrid.key);

// Cloud Function for emergency alerts
export const sendEmergencyAlert = functions.firestore
  .document('emergency_alerts/{alertId}')
  .onCreate(async (snapshot, context) => {
    const alertData = snapshot.data();
    
    // 1. Get user info
    const userDoc = await admin.firestore()
      .collection('users')
      .doc(alertData.fromUserId)
      .get();
    const userData = userDoc.data();

    // 2. Prepare notification
    const msg = {
      to: alertData.toUserEmail,
      from: 'emergency@pregnacare.com',
      subject: '🚨 EMERGENCY ALERT',
      html: `
        <h2>${userData?.name} needs help!</h2>
        <p><strong>Location:</strong> 
          <a href="https://maps.google.com/?q=${alertData.location.latitude},${alertData.location.longitude}">
            View on Map
          </a>
        </p>
        <p><strong>Time:</strong> ${new Date().toLocaleString()}</p>
      `,
    };

    // 3. Send via SendGrid (or Twilio for SMS)
    await sgMail.send(msg);
    
    // 4. Update alert status
    return snapshot.ref.update({ status: 'sent' });
  });

  import { GoogleGenerativeAI } from "@google/generative-ai";

const genAI = new GoogleGenerativeAI(functions.config().gemini.key);

export const geminiChatbot = functions.https.onCall(async (data, context) => {
  // 1. Authenticate request
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated', 
      'Authentication required'
    );
  }

  // 2. Initialize model
  const model = genAI.getGenerativeModel({ 
    model: "gemini-pro",
    safetySettings: [
      {
        category: "HARM_CATEGORY_MEDICAL",
        threshold: "BLOCK_MEDIUM_AND_ABOVE"
      }
    ]
  });

  // 3. Generate response
  try {
    const result = await model.generateContent({
      contents: [{
        role: "user",
        parts: [{ text: `As a pregnancy assistant, respond to: "${data.message}"` }]
      }]
    });
    
    return { response: result.response.text() };
  } catch (error) {
    throw new functions.https.HttpsError(
      'internal', 
      'AI request failed', 
      error
    );
  }
});
// Start writing functions
// https://firebase.google.com/docs/functions/typescript

// export const helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
