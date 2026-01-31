import * as admin from 'firebase-admin';
import * as path from 'path';

class FirebaseService {
    private static instance: FirebaseService;

    private constructor() {
        try {
            // Use path.resolve to get the absolute path relative to CWD
            const serviceAccountPath = path.resolve(process.cwd(), 'src/config/serviceAccountKey.json');

            // Load the service account key
            const serviceAccount = require(serviceAccountPath);

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
