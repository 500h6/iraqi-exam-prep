import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/datasources/admin_remote_datasource.dart';

class AdminUsersPage extends StatefulWidget {
  final AdminRemoteDataSource dataSource;

  const AdminUsersPage({super.key, required this.dataSource});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  final _phoneController = TextEditingController();
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = false;
  bool _isPromoting = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _searchUsers() async {
    setState(() => _isLoading = true);
    try {
      final users = await widget.dataSource.searchUsers(
        phone: _phoneController.text.trim(),
      );
      setState(() => _users = users);
    } catch (e) {
      Fluttertoast.showToast(
        msg: e.toString().replaceFirst('Exception: ', ''),
        backgroundColor: AppColors.error,
        textColor: Colors.white,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _promoteUser(String userId, String userName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الترقية'),
        content: Text('هل تريد ترقية "$userName" إلى أدمن؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('ترقية'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isPromoting = true);
    try {
      await widget.dataSource.promoteToAdmin(userId);
      Fluttertoast.showToast(
        msg: 'تمت ترقية "$userName" بنجاح! 🎉',
        backgroundColor: AppColors.success,
        textColor: Colors.white,
      );
      _searchUsers(); // Refresh list
    } catch (e) {
      Fluttertoast.showToast(
        msg: e.toString().replaceFirst('Exception: ', ''),
        backgroundColor: AppColors.error,
        textColor: Colors.white,
      );
    } finally {
      setState(() => _isPromoting = false);
    }
  }

  Future<void> _demoteUser(String userId, String userName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد التنزيل'),
        content: Text('هل تريد تنزيل "$userName" من رتبة أدمن؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('تنزيل'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isPromoting = true);
    try {
      await widget.dataSource.demoteFromAdmin(userId);
      Fluttertoast.showToast(
        msg: 'تم تنزيل "$userName" إلى مستخدم عادي. ✅',
        backgroundColor: AppColors.success,
        textColor: Colors.white,
      );
      _searchUsers(); // Refresh list
    } catch (e) {
      Fluttertoast.showToast(
        msg: e.toString().replaceFirst('Exception: ', ''),
        backgroundColor: AppColors.error,
        textColor: Colors.white,
      );
    } finally {
      setState(() => _isPromoting = false);
    }
  }

  Future<void> _activateUser(String userId, String userName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد التفعيل'),
        content: Text('هل تريد تفعيل كل الامتحانات لـ "$userName"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            child: const Text('تفعيل الآن'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isPromoting = true);
    try {
      await widget.dataSource.activateUser(userId);
      Fluttertoast.showToast(
        msg: 'تم تفعيل حساب "$userName" بنجاح! 👑',
        backgroundColor: AppColors.success,
        textColor: Colors.white,
      );
      _searchUsers(); // Refresh list
    } catch (e) {
      Fluttertoast.showToast(
        msg: e.toString().replaceFirst('Exception: ', ''),
        backgroundColor: AppColors.error,
        textColor: Colors.white,
      );
    } finally {
      setState(() => _isPromoting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إدارة المستخدمين'),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.people, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'إدارة صلاحيات المستخدمين',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'ترقية لأدمن أو تفعيل الاشتراك يدوياً',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Search Field
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      textDirection: TextDirection.ltr,
                      decoration: const InputDecoration(
                        hintText: '07XXXXXXXX',
                        prefixIcon: Icon(Icons.phone),
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _searchUsers(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _searchUsers,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.search),
                      label: const Text('بحث'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Users List
              Expanded(
                child: _users.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person_search, size: 64, color: AppColors.textTertiary),
                            const SizedBox(height: 16),
                            Text(
                              'ابحث عن مستخدم برقم هاتفه',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _users.length,
                        itemBuilder: (context, index) {
                          final user = _users[index];
                          final isAdmin = user['role'] == 'ADMIN';
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: isAdmin
                                    ? AppColors.warning.withValues(alpha: 0.2)
                                    : AppColors.primary.withValues(alpha: 0.2),
                                child: Icon(
                                  isAdmin ? Icons.admin_panel_settings : Icons.person,
                                  color: isAdmin ? AppColors.warning : AppColors.primary,
                                ),
                              ),
                              title: Text(
                                user['name'] ?? 'بدون اسم',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                user['phone'] ?? '',
                                textDirection: TextDirection.ltr,
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Premium Status
                                  if (user['isPremium'] == true)
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Tooltip(
                                          message: 'حساب مفعل (Premium)',
                                          child: Icon(Icons.stars, color: Colors.amber, size: 28),
                                        ),
                                        const SizedBox(width: 8),
                                        ElevatedButton(
                                          onPressed: _isPromoting
                                              ? null
                                              : () => _deactivateUser(
                                                    user['id'] as String,
                                                    user['name'] as String? ?? 'مستخدم',
                                                  ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.error.withValues(alpha: 0.1),
                                            foregroundColor: AppColors.error,
                                            elevation: 0,
                                            padding: const EdgeInsets.symmetric(horizontal: 12),
                                            side: const BorderSide(color: AppColors.error),
                                          ),
                                          child: const Text('إلغاء'),
                                        ),
                                      ],
                                    )
                                  else
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: ElevatedButton(
                                        onPressed: _isPromoting
                                            ? null
                                            : () => _activateUser(
                                                  user['id'] as String,
                                                  user['name'] as String? ?? 'مستخدم',
                                                ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          padding: const EdgeInsets.symmetric(horizontal: 12),
                                        ),
                                        child: const Text('تفعيل'),
                                      ),
                                    ),

                                  // Role Status & Action
                                  if (isAdmin)
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Chip(
                                          label: const Text('أدمن'),
                                          backgroundColor: AppColors.warning.withValues(alpha: 0.2),
                                          labelStyle: const TextStyle(color: AppColors.warning),
                                        ),
                                        const SizedBox(width: 8),
                                        ElevatedButton(
                                          onPressed: _isPromoting
                                              ? null
                                              : () => _demoteUser(
                                                    user['id'] as String,
                                                    user['name'] as String? ?? 'مستخدم',
                                                  ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.error,
                                            padding: const EdgeInsets.symmetric(horizontal: 12),
                                          ),
                                          child: const Text('تنزيل'),
                                        ),
                                      ],
                                    )
                                  else
                                    ElevatedButton(
                                      onPressed: _isPromoting
                                          ? null
                                          : () => _promoteUser(
                                                user['id'] as String,
                                                user['name'] as String? ?? 'مستخدم',
                                              ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.success,
                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                      ),
                                      child: const Text('ترقية'),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
