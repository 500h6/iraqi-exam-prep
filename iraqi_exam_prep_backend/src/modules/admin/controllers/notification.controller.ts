import { Request, Response } from 'express';
import { firebaseService } from '../../../services/firebase.service';

export const sendNotificationHandler = async (req: Request, res: Response) => {
    try {
        const { title, body } = req.body;

        if (!title || !body) {
            return res.status(400).json({
                success: false,
                message: 'Title and body are required',
            });
        }

        // Send to 'all_users' topic
        const message = {
            notification: {
                title: title,
                body: body,
            },
            topic: 'all_users',
        };

        const response = await firebaseService.messaging.send(message);

        return res.status(200).json({
            success: true,
            message: 'Notification sent successfully',
            messageId: response,
        });
    } catch (error) {
        console.error('Error sending notification:', error);
        return res.status(500).json({
            success: false,
            message: 'Failed to send notification',
        });
    }
};
