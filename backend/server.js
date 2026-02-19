const express = require('express');
const admin = require('firebase-admin');
const cors = require('cors');
const bodyParser = require('body-parser');
const axios = require('axios');
const path = require('path');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(bodyParser.json());

// Initialize Firebase Admin
// EXPECTS serviceAccountKey.json in the same directory
const serviceAccountPath = path.join(__dirname, 'serviceAccountKey.json');
let firebaseInitialized = false;

try {
    const serviceAccount = require(serviceAccountPath);
    admin.initializeApp({
        credential: admin.credential.cert(serviceAccount)
    });
    firebaseInitialized = true;
    console.log("Firebase Admin Initialized successfully.");
} catch (error) {
    console.error("WARNING: Could not initialize Firebase Admin. Missing 'serviceAccountKey.json'?");
    console.error(error.message);
}

const db = firebaseInitialized ? admin.firestore() : null;

// Helper: Sign in with Email/Password using REST API
async function verifyPassword(email, password) {
    if (!process.env.FIREBASE_WEB_API_KEY) {
        throw new Error("Missing FIREBASE_WEB_API_KEY in .env");
    }
    const url = `https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${process.env.FIREBASE_WEB_API_KEY}`;

    try {
        const response = await axios.post(url, {
            email: email,
            password: password,
            returnSecureToken: true
        });
        return response.data; // contains idToken, localId, etc.
    } catch (error) {
        throw new Error(error.response?.data?.error?.message || "Authentication failed");
    }
}

// --- Routes ---

// Health Check
app.get('/', (req, res) => {
    res.send('Smart Travel Backend is Running!');
});

// Signup Route
app.post('/api/auth/signup', async (req, res) => {
    if (!firebaseInitialized) {
        return res.status(500).json({ error: "Backend not configured (Firebase missing)." });
    }

    const { name, email, password } = req.body;

    if (!email || !password || !name) {
        return res.status(400).json({ error: "Missing required fields." });
    }

    try {
        // 1. Create User in Firebase Auth
        const userRecord = await admin.auth().createUser({
            email: email,
            password: password,
            displayName: name,
        });

        // 2. Store additional user data in Firestore
        await db.collection('users').doc(userRecord.uid).set({
            uid: userRecord.uid,
            name: name,
            email: email,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        res.status(201).json({ message: "User registered successfully", uid: userRecord.uid });
    } catch (error) {
        console.error("Signup Error:", error);
        res.status(400).json({ error: error.message });
    }
});

// Login Route
app.post('/api/auth/login', async (req, res) => {
    const { email, password } = req.body;

    if (!email || !password) {
        return res.status(400).json({ error: "Missing email or password." });
    }

    try {
        // Verify via REST API
        const authData = await verifyPassword(email, password);

        // Fetch user name from Firestore if needed
        let userName = "User";
        if (firebaseInitialized) {
            const userDoc = await db.collection('users').doc(authData.localId).get();
            if (userDoc.exists) {
                userName = userDoc.data().name;
            }
        }

        res.json({
            message: "Login successful",
            idToken: authData.idToken,
            userId: authData.localId,
            name: userName,
            email: email
        });

    } catch (error) {
        console.error("Login Error:", error.message);
        res.status(401).json({ error: "Invalid credentials or login failed." });
    }
});

// Google Sign-In Route
app.post('/api/auth/google', async (req, res) => {
    const { idToken } = req.body;

    if (!idToken) {
        return res.status(400).json({ error: "Missing ID Token." });
    }

    try {
        // 1. Verify ID Token
        const decodedToken = await admin.auth().verifyIdToken(idToken);
        const { uid, name, email, picture } = decodedToken;

        // 2. Check/Create User in Firestore
        const userRef = db.collection('users').doc(uid);
        const userDoc = await userRef.get();

        if (!userDoc.exists) {
            await userRef.set({
                uid: uid,
                name: name || 'Google User',
                email: email,
                photoUrl: picture,
                provider: 'google',
                createdAt: admin.firestore.FieldValue.serverTimestamp(),
                lastLogin: admin.firestore.FieldValue.serverTimestamp(),
            });
        } else {
            await userRef.update({
                lastLogin: admin.firestore.FieldValue.serverTimestamp(),
                photoUrl: picture // Update picture if changed
            });
        }

        res.json({
            message: "Google Login successful",
            uid: uid,
            name: name || 'Google User',
            email: email,
            photoUrl: picture
        });

    } catch (error) {
        console.error("Google Login Error:", error);
        res.status(401).json({ error: "Invalid Google Token or Login Failed." });
    }
});

app.listen(PORT, () => {
    console.log(`Server running on http://localhost:${PORT}`);
});
