import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../data/datasources/admin_remote_datasource.dart';
import '../../domain/entities/activation_code.dart';
import '../bloc/admin_code_bloc.dart';
import '../bloc/admin_code_event.dart';
import '../bloc/admin_code_state.dart';

class AdminCodePage extends StatefulWidget {
  final AdminRemoteDataSource dataSource;

  const AdminCodePage({super.key, required this.dataSource});

  @override
  State<AdminCodePage> createState() => _AdminCodePageState();
}

class _AdminCodePageState extends State<AdminCodePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Generator Form State
  final Set<String> _selectedSubjects = {};
  bool _unlockAll = true;
  int _codeCount = 1;
  int _maxUses = 1;
  int? _expiresInDays;

  final List<Map<String, dynamic>> _subjects = const [
    {'value': 'ARABIC', 'label': 'اللغة العربية', 'color': AppColors.arabicColor},
    {'value': 'ENGLISH', 'label': 'اللغة الإنجليزية', 'color': AppColors.englishColor},
    {'value': 'COMPUTER', 'label': 'مهارات الحاسوب', 'color': AppColors.computerColor},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    Fluttertoast.showToast(
      msg: 'تم نسخ الكود',
      backgroundColor: AppColors.success,
      textColor: Colors.white,
    );
  }

  void _copyAllCodes(List<ActivationCode> codes) {
    final allCodes = codes.map((c) => c.code).join('\n');
    Clipboard.setData(ClipboardData(text: allCodes));
    Fluttertoast.showToast(
      msg: 'تم نسخ جميع الأكواد',
      backgroundColor: AppColors.success,
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final isAdmin = authState is AuthAuthenticated &&
        authState.user.role.toUpperCase() == 'ADMIN';

    if (!isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('إدارة الأكواد')),
        body: const Center(
          child: Text('هذه الصفحة متاحة للمشرفين فقط.'),
        ),
      );
    }

    return BlocProvider(
      create: (_) => AdminCodeBloc(dataSource: widget.dataSource),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إدارة أكواد التفعيل'),
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.people_outline),
              tooltip: 'إدارة المستخدمين',
              onPressed: () => context.push('/admin/users'),
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Icons.add_circle_outline), text: 'توليد أكواد'),
              Tab(icon: Icon(Icons.list_alt), text: 'قائمة الأكواد'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildGeneratorTab(),
            _buildListTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneratorTab() {
    return BlocConsumer<AdminCodeBloc, AdminCodeState>(
      listener: (context, state) {
        if (state is AdminCodeFailure) {
          Fluttertoast.showToast(
            msg: state.message,
            backgroundColor: AppColors.error,
            textColor: Colors.white,
          );
        }
      },
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                        color: Colors.white.withValues(alpha:0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.key, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'مولد الأكواد',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'إنشاء أكواد تفعيل للمستخدمين',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Unlock All Switch
              Card(
                child: SwitchListTile(
                  title: const Text('فتح جميع المواد'),
                  subtitle: const Text('الكود يفتح كل المواد الثلاث'),
                  value: _unlockAll,
                  activeThumbColor: AppColors.primary,
                  activeTrackColor: AppColors.primary.withValues(alpha:0.5),
                  onChanged: (value) {
                    setState(() {
                      _unlockAll = value;
                      if (value) _selectedSubjects.clear();
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Subject Selection (if not unlock all)
              if (!_unlockAll) ...[
                Text(
                  'اختر المواد',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _subjects.map((subject) {
                    final isSelected = _selectedSubjects.contains(subject['value']);
                    return FilterChip(
                      label: Text(subject['label'] as String),
                      selected: isSelected,
                      selectedColor: (subject['color'] as Color).withValues(alpha:0.2),
                      checkmarkColor: subject['color'] as Color,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedSubjects.add(subject['value'] as String);
                          } else {
                            _selectedSubjects.remove(subject['value']);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],

              // Code Count
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('عدد الأكواد'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          IconButton(
                            onPressed: _codeCount > 1
                                ? () => setState(() => _codeCount--)
                                : null,
                            icon: const Icon(Icons.remove_circle_outline),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$_codeCount',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: _codeCount < 50
                                ? () => setState(() => _codeCount++)
                                : null,
                            icon: const Icon(Icons.add_circle_outline),
                          ),
                          const Spacer(),
                          // Quick buttons
                          TextButton(
                            onPressed: () => setState(() => _codeCount = 5),
                            child: const Text('5'),
                          ),
                          TextButton(
                            onPressed: () => setState(() => _codeCount = 10),
                            child: const Text('10'),
                          ),
                          TextButton(
                            onPressed: () => setState(() => _codeCount = 25),
                            child: const Text('25'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Max Uses
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('عدد مرات الاستخدام'),
                            Text(
                              'كم مرة يمكن استخدام كل كود',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      DropdownButton<int>(
                        value: _maxUses,
                        items: [1, 2, 3, 5, 10].map((v) {
                          return DropdownMenuItem(
                            value: v,
                            child: Text('$v'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) setState(() => _maxUses = value);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Generate Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: state is AdminCodeGenerating
                      ? null
                      : () {
                          context.read<AdminCodeBloc>().add(
                                GenerateCodesEvent(
                                  subjects: _selectedSubjects.toList(),
                                  unlockAll: _unlockAll,
                                  maxUses: _maxUses,
                                  expiresInDays: _expiresInDays,
                                  count: _codeCount,
                                ),
                              );
                        },
                  icon: state is AdminCodeGenerating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.vpn_key),
                  label: Text(
                    state is AdminCodeGenerating ? 'جاري التوليد...' : 'توليد الأكواد',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Generated Codes Display
              if (state is AdminCodeGenerated) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'الأكواد المولدة (${state.codes.length})',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    TextButton.icon(
                      onPressed: () => _copyAllCodes(state.codes),
                      icon: const Icon(Icons.copy_all),
                      label: const Text('نسخ الكل'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.codes.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, color: AppColors.border),
                    itemBuilder: (context, index) {
                      final code = state.codes[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary.withValues(alpha:0.1),
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          code.code,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.copy, color: AppColors.primary),
                          onPressed: () => _copyToClipboard(code.code),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildListTab() {
    return BlocBuilder<AdminCodeBloc, AdminCodeState>(
      builder: (context, state) {
        // Auto-load on first visit
        if (state is AdminCodeInitial) {
          context.read<AdminCodeBloc>().add(const LoadCodesEvent(limit: 50));
        }

        if (state is AdminCodeLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is AdminCodesLoaded) {
          if (state.codes.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 64, color: AppColors.textTertiary),
                  SizedBox(height: 16),
                  Text('لا توجد أكواد بعد'),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<AdminCodeBloc>().add(const LoadCodesEvent(limit: 50));
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.codes.length,
              itemBuilder: (context, index) {
                final code = state.codes[index];
                return _buildCodeCard(code);
              },
            ),
          );
        }

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.refresh, size: 64, color: AppColors.textTertiary),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  context.read<AdminCodeBloc>().add(const LoadCodesEvent(limit: 50));
                },
                child: const Text('تحميل الأكواد'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCodeCard(ActivationCode code) {
    Color statusColor;
    String statusLabel;
    IconData statusIcon;

    switch (code.status) {
      case 'active':
        statusColor = AppColors.success;
        statusLabel = 'نشط';
        statusIcon = Icons.check_circle;
        break;
      case 'used':
        statusColor = AppColors.warning;
        statusLabel = 'مستخدم';
        statusIcon = Icons.done_all;
        break;
      case 'revoked':
        statusColor = AppColors.error;
        statusLabel = 'ملغي';
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = AppColors.textSecondary;
        statusLabel = code.status;
        statusIcon = Icons.help;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    code.code,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 16, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        statusLabel,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildInfoChip(
                  Icons.repeat,
                  '${code.uses}/${code.maxUses}',
                ),
                const SizedBox(width: 8),
                if (code.unlockAll)
                  _buildInfoChip(Icons.all_inclusive, 'جميع المواد')
                else
                  _buildInfoChip(
                    Icons.subject,
                    code.subjects.join(', '),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'تاريخ الإنشاء: ${_formatDate(code.createdAt)}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, size: 20),
                  onPressed: () => _copyToClipboard(code.code),
                  tooltip: 'نسخ',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month}/${date.day}';
  }
}
