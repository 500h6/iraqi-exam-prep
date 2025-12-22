import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../presentation/bloc/admin_question_bloc.dart';
import '../../presentation/bloc/admin_question_event.dart';
import '../../presentation/bloc/admin_question_state.dart';

class AdminQuestionPage extends StatefulWidget {
  const AdminQuestionPage({super.key});

  @override
  State<AdminQuestionPage> createState() => _AdminQuestionPageState();
}

class _AdminQuestionPageState extends State<AdminQuestionPage> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final _explanationController = TextEditingController();
  final List<TextEditingController> _optionControllers =
      List.generate(4, (_) => TextEditingController());
  final List<Map<String, String>> _subjects = const [
    {'value': 'ARABIC', 'label': 'اللغة العربية'},
    {'value': 'ENGLISH', 'label': 'اللغة الإنجليزية'},
    {'value': 'COMPUTER', 'label': 'مهارات الحاسوب'},
  ];

  String _selectedSubject = 'ARABIC';
  int _correctAnswerIndex = 0;

  @override
  void dispose() {
    _questionController.dispose();
    _explanationController.dispose();
    for (final controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addOptionField() {
    setState(() {
      _optionControllers.add(TextEditingController());
    });
  }

  void _removeOptionField(int index) {
    if (_optionControllers.length <= 2) return;
    setState(() {
      final controller = _optionControllers.removeAt(index);
      controller.dispose();
      if (_correctAnswerIndex >= _optionControllers.length) {
        _correctAnswerIndex = _optionControllers.length - 1;
      }
    });
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _questionController.clear();
    _explanationController.clear();
    for (final controller in _optionControllers) {
      controller.clear();
    }
    _selectedSubject = 'ARABIC';
    _correctAnswerIndex = 0;
    setState(() {});
  }

  void _submit(BuildContext context) {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    final options = _optionControllers
        .map((controller) => controller.text.trim())
        .where((option) => option.isNotEmpty)
        .toList();

    if (options.length < 2) {
      Fluttertoast.showToast(
        msg: 'يرجى إضافة خيارين على الأقل',
        backgroundColor: AppColors.error,
        textColor: Colors.white,
      );
      return;
    }

    context.read<AdminQuestionBloc>().add(
          SubmitQuestionEvent(
            subject: _selectedSubject,
            questionText: _questionController.text.trim(),
            options: options,
            correctAnswer: _correctAnswerIndex,
            explanation: _explanationController.text.trim().isEmpty
                ? null
                : _explanationController.text.trim(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final isAdmin = authState is AuthAuthenticated &&
        authState.user.role.toUpperCase() == 'ADMIN';

    if (!isAdmin) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('إدارة الأسئلة'),
        ),
        body: const Center(
          child: Text('هذه الصفحة متاحة للمشرفين فقط.'),
        ),
      );
    }

    return BlocProvider(
      create: (_) => getIt<AdminQuestionBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إضافة أسئلة الامتحانات'),
        ),
        body: BlocConsumer<AdminQuestionBloc, AdminQuestionState>(
          listener: (context, state) {
            if (state is AdminQuestionSuccess) {
              Fluttertoast.showToast(
                msg: 'تم حفظ السؤال بنجاح',
                backgroundColor: AppColors.success,
                textColor: Colors.white,
              );
              _resetForm();
              context
                  .read<AdminQuestionBloc>()
                  .add(ResetAdminQuestionEvent());
            } else if (state is AdminQuestionFailure) {
              Fluttertoast.showToast(
                msg: state.message,
                backgroundColor: AppColors.error,
                textColor: Colors.white,
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is AdminQuestionLoading;
            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'إضافة سؤال جديد',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedSubject,
                        decoration: const InputDecoration(
                          labelText: 'المادة',
                        ),
                        items: _subjects
                            .map(
                              (subject) => DropdownMenuItem<String>(
                                value: subject['value'],
                                child: Text(subject['label']!),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            _selectedSubject = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _questionController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'نص السؤال',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().length < 10) {
                          return 'يجب ألا يقل السؤال عن 10 أحرف';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'الخيارات',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      ..._optionControllers.asMap().entries.map(
                        (entry) {
                          final index = entry.key;
                          final controller = entry.value;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: controller,
                                    decoration: InputDecoration(
                                      labelText: 'الخيار ${index + 1}',
                                    ),
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'لا يمكن ترك الخيار فارغاً';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: Icon(
                                    _correctAnswerIndex == index
                                        ? Icons.check_circle
                                        : Icons.radio_button_unchecked,
                                    color: _correctAnswerIndex == index
                                        ? AppColors.success
                                        : AppColors.textSecondary,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _correctAnswerIndex = index;
                                    });
                                  },
                                ),
                                if (_optionControllers.length > 2)
                                  IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () => _removeOptionField(index),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: _addOptionField,
                          icon: const Icon(Icons.add),
                          label: const Text('إضافة خيار'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _explanationController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'شرح السؤال (اختياري)',
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () => _submit(context),
                          child: isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('حفظ السؤال'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
