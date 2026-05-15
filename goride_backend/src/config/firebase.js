const admin = require('firebase-admin');
const path = require('path');
require('dotenv').config();

let firebaseApp;

try {
  const serviceAccountPath = path.join(__dirname, '../../firebase-service-account.json');
  
  firebaseApp = admin.initializeApp({
    credential: admin.credential.cert(serviceAccountPath)
  });
  
  console.log('Firebase working properly');
} catch (error) {
  console.warn('Firebase not working properly');
  console.warn(error.message);
}

module.exports = admin;
