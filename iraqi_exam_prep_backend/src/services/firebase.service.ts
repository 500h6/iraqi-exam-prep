import * as admin from 'firebase-admin';
import * as path from 'path';

class FirebaseService {
    private static instance: FirebaseService;

    private constructor() {
        try {
            let serviceAccount;

            if (process.env.FIREBASE_PRIVATE_KEY && process.env.FIREBASE_CLIENT_EMAIL) {
                // Use Environment Variables (Production / Secure)
                console.log('Using Firebase credentials from Environment Variables');
                serviceAccount = {
                    projectId: process.env.FIREBASE_PROJECT_ID,
                    clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
                    // Handle newlines in private key which are often escaped in env vars
                    privateKey: process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n'),
                };
            } else {
                // Fallback to file (Local Development)
                console.log('Using Firebase credentials from local file');
                // Use path.resolve to get the absolute path relative to CWD
                const serviceAccountPath = path.resolve(process.cwd(), 'src/config/serviceAccountKey.json');
                // Load the service account key
                serviceAccount = require(serviceAccountPath);
            }

            admin.initializeApp({
                credential: admin.credential.cert(serviceAccount),
            });

            console.log('✅ Firebase Admin Initialized successfully');
        } catch (error) {
            console.error('❌ Error initializing Firebase Admin:', error);
        }
    }

    public static getInstance(): FirebaseService {
        if (!FirebaseService.instance) {
            FirebaseService.instance = new FirebaseService();
        }
        return FirebaseService.instance;
    }

    public get messaging() {
        return admin.messaging();
    }
}

export const firebaseService = FirebaseService.getInstance();
