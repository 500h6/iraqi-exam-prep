import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../config/routes/app_router.dart';
import '../../data/datasources/admin_remote_datasource.dart';
import '../../../../core/di/injection_container.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';

class SendNotificationPage extends StatefulWidget {
  const SendNotificationPage({super.key});

  @override
  State<SendNotificationPage> createState() => _SendNotificationPageState();
}

class _SendNotificationPageState extends State<SendNotificationPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  bool _isLoading = false;

  Future<void> _sendNotification() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final dataSource = getIt<AdminRemoteDataSource>();
      await dataSource.sendNotification(
        title: _titleController.text,
        body: _bodyController.text,
      );

      if (mounted) {
        Fluttertoast.showToast(msg: "تم إرسال الإشعار بنجاح");
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        Fluttertoast.showToast(msg: "فشل إرسال الإشعار: $e");
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('إرسال إشعار عام'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'سيتم إرسال هذا الإشعار لجميع المستخدمين المشتركين في التطبيق.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'عنوان الإشعار',
                  hintText: 'مثلاً: تحديث جديد، امتحان متاح...',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) => 
                  value == null || value.isEmpty ? 'يرجى إدخال العنوان' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bodyController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'نص الرسالة',
                  hintText: 'اكتب رسالتك هنا...',
                  prefixIcon: Icon(Icons.message),
                  alignLabelWithHint: true,
                ),
                validator: (value) => 
                  value == null || value.isEmpty ? 'يرجى إدخال نص الرسالة' : null,
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _sendNotification,
                  icon: _isLoading 
                    ? const SizedBox(
                        width: 20, 
                        height: 20, 
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                      )
                    : const Icon(Icons.send_rounded),
                  label: Text(_isLoading ? 'جاري الإرسال...' : 'إرسال الإشعار'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
