import "express-async-errors";
import express from "express";
import cors from "cors";
import compression from "compression";
import helmet from "helmet";
import morgan from "morgan";
import cookieParser from "cookie-parser";
import { env } from "./config/env";
import { requestLogger } from "./middlewares/requestLogger";
import { errorHandler } from "./middlewares/errorHandler";
import { globalRateLimiter } from "./middlewares/rateLimiter";
import { authRouter } from "./modules/auth/routes/auth.routes";
import { activationRouter } from "./modules/activation/routes/activation.routes";
import { examRouter } from "./modules/exams/routes/exam.routes";
import { logger } from "./config/logger";
import { adminRouter } from "./modules/admin/routes/admin.routes";

export const app = express();

app.set("trust proxy", 1); // Trust first proxy (Render load balancer)
app.use(helmet());
app.use(
  cors({
    origin: env.nodeEnv === "production" ? env.clientBaseUrl : true,
    credentials: true,
  }),
);
app.use(compression());
app.use(express.json({ limit: "1mb" }));
app.use(express.urlencoded({ extended: true }));
app.use(cookieParser());
app.use(globalRateLimiter);
app.use(requestLogger);
app.use(
  morgan("tiny", {
    stream: {
      write: (message: string) => logger.info(message.trim()),
    },
    skip: () => env.nodeEnv === "test",
  }),
);

app.get("/healthz", (_req, res) => {
  res.json({ status: "ok", timestamp: new Date().toISOString() });
});

app.get("/privacy", (_req, res) => {
  res.send(`
    <!DOCTYPE html>
    <html lang="ar" dir="rtl">
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>سياسة الخصوصية - الاستعداد للاختبار الوطني</title>
      <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; line-height: 1.6; padding: 20px; max-width: 800px; margin: auto; color: #333; }
        h1, h2 { color: #0d47a1; }
        p { margin-bottom: 15px; }
      </style>
    </head>
    <body>
      <h1>سياسة الخصوصية (Privacy Policy)</h1>
      <p>تاريخ آخر تحديث: 2026-07-23</p>
      
      <h2>1. مقدمة</h2>
      <p>نحن في تطبيق "الاستعداد للاختبار الوطني" نحترم خصوصيتك ونلتزم بحماية بياناتك الشخصية. توضح سياسة الخصوصية هذه كيفية جمعنا واستخدامنا وحمايتنا لمعلوماتك عند استخدام تطبيقنا.</p>
      
      <h2>2. المعلومات التي نجمعها</h2>
      <p>نجمع بعض المعلومات الشخصية التي تقدمها لنا طواعية، مثل: رقم الهاتف (لغرض تسجيل الدخول والمصادقة)، والاسم، وذلك لتقديم تجربة مخصصة لك وربط اشتراكاتك ونتائجك بحسابك.</p>
      
      <h2>3. كيفية استخدام المعلومات</h2>
      <p>نستخدم المعلومات التي نجمعها من أجل:<br>
      - إنشاء حسابك وإدارته.<br>
      - السماح لك بالوصول إلى الاختبارات والمواد التعليمية.<br>
      - تحسين وتطوير أداء التطبيق.</p>
      
      <h2>4. أمان البيانات</h2>
      <p>نتخذ إجراءات أمنية لحماية بياناتك من الوصول غير المصرح به. يتم تشفير كلمات المرور وتوكنات الجلسات وحفظها في خوادم سحابية آمنة.</p>
      
      <h2>5. مشاركة البيانات</h2>
      <p>نحن لا نقوم ببيع أو مشاركة معلوماتك الشخصية مع أي أطراف ثالثة لأغراض تسويقية. قد يتم مشاركة البيانات فقط مع مزودي الخدمات الموثوقين الذين يساعدوننا في تشغيل التطبيق (مثل خدمات إرسال OTP السحابية).</p>
      
      <h2>6. تواصل معنا</h2>
      <p>إذا كانت لديك أي أسئلة أو استفسارات حول سياسة الخصوصية، يرجى التواصل معنا عبر:</p>
      <p>
        <strong>واتساب:</strong> <a href="https://wa.me/9647810011034" dir="ltr" style="text-decoration: none; color: #0d47a1; font-weight: bold;">+964 781 001 1034</a>
      </p>
      
      <h2>7. حذف الحساب والبيانات (Account Deletion)</h2>
      <p>يحق للمستخدمين طلب حذف حساباتهم وكافة البيانات المرتبطة بها في أي وقت. لطلب حذف الحساب:</p>
      <ul>
        <li>يرجى إرسال رسالة عبر <strong>الواتساب</strong> إلى الرقم المذكور أعلاه (+964 781 001 1034) تتضمن طلب حذف الحساب ورقم الهاتف المسجل.</li>
        <li>أو يمكنك طلب الحذف من داخل التطبيق (إن وُجد الخيار في الإعدادات).</li>
      </ul>
      <p>عند استلامنا للطلب، سيتم <strong>حذف كافة بياناتك نهائياً</strong> (بما في ذلك اسمك، رقم هاتفك، والنتائج والاشتراكات المرتبطة) من خوادمنا خلال مدة أقصاها 14 يوماً. لا يتم الاحتفاظ بأي بيانات بعد عملية الحذف.</p>
    </body>
    </html>
  `);
});

app.use("/api/v1/auth", authRouter);
app.use("/api/v1/activation", activationRouter);
app.use("/api/v1/exams", examRouter);
app.use("/api/v1/admin", adminRouter);

app.use((req, res) => {
  res.status(404).json({
    success: false,
    error: { message: `Route ${req.path} not found`, code: "NOT_FOUND" },
  });
});

app.use(errorHandler);
