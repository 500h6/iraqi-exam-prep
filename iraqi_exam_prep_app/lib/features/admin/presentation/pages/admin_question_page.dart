import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../exams/domain/entities/question_entity.dart';
import '../../presentation/bloc/admin_question_bloc.dart';
import '../../presentation/bloc/admin_question_event.dart';
import '../../presentation/bloc/admin_question_state.dart';

class AdminQuestionPage extends StatefulWidget {
  final QuestionEntity? question;
  const AdminQuestionPage({super.key, this.question});

  @override
  State<AdminQuestionPage> createState() => _AdminQuestionPageState();
}

class _AdminQuestionPageState extends State<AdminQuestionPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _questionController;
  late final TextEditingController _explanationController;
  late final TextEditingController _imageUrlController;
  late final List<TextEditingController> _optionControllers;
  
  final List<Map<String, String>> _subjects = const [
    {'value': 'ARABIC', 'label': 'اللغة العربية'},
    {'value': 'ENGLISH', 'label': 'اللغة الإنجليزية'},
    {'value': 'COMPUTER', 'label': 'مهارات الحاسوب'},
    {'value': 'MATH', 'label': 'الرياضيات'},
    {'value': 'SCIENCE', 'label': 'العلوم'},
    {'value': 'SOCIAL_STUDIES', 'label': 'الاجتماعيات'},
    {'value': 'ISLAMIC', 'label': 'التربية الإسلامية'},
  ];

  late String _selectedSubject;
  late int _correctAnswerIndex;
  bool _isUploadingImage = false;

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    setState(() {
      _isUploadingImage = true;
    });

    try {
      final storageRef = FirebaseStorage.instance.ref();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${image.name}';
      final imageRef = storageRef.child('questions/$fileName');

      final metadata = SettableMetadata(contentType: image.mimeType);
      final uploadTask = imageRef.putData(await image.readAsBytes(), metadata);

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      setState(() {
        _imageUrlController.text = downloadUrl;
        _isUploadingImage = false;
      });
      
      Fluttertoast.showToast(
        msg: 'تم رفع الصورة بنجاح',
        backgroundColor: AppColors.success,
        textColor: Colors.white,
      );
    } catch (e) {
      setState(() {
        _isUploadingImage = false;
      });
      Fluttertoast.showToast(
        msg: 'فشل رفع الصورة: $e',
        backgroundColor: AppColors.error,
        textColor: Colors.white,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController(text: widget.question?.questionText);
    _explanationController = TextEditingController(text: widget.question?.explanation);
    _imageUrlController = TextEditingController(text: widget.question?.imageUrl);
    
    if (widget.question != null) {
      _optionControllers = widget.question!.options
          .map((o) => TextEditingController(text: o))
          .toList();
      _selectedSubject = widget.question!.subject;
      _correctAnswerIndex = widget.question!.correctAnswer;
    } else {
      _optionControllers = List.generate(4, (_) => TextEditingController());
      _selectedSubject = 'ARABIC';
      _correctAnswerIndex = 0;
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    _explanationController.dispose();
    _imageUrlController.dispose();
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
    if (widget.question != null) {
      Navigator.pop(context);
      return;
    }
    _formKey.currentState?.reset();
    _questionController.clear();
    _explanationController.clear();
    _imageUrlController.clear();
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

    if (widget.question != null) {
      context.read<AdminQuestionBloc>().add(
            UpdateAdminQuestionEvent(
              id: widget.question!.id,
              subject: _selectedSubject,
              questionText: _questionController.text.trim(),
              options: options,
              correctAnswer: _correctAnswerIndex,
              explanation: _explanationController.text.trim().isEmpty
                  ? null
                  : _explanationController.text.trim(),
              imageUrl: _imageUrlController.text.trim().isEmpty
                  ? null
                  : _imageUrlController.text.trim(),
            ),
          );
    } else {
      context.read<AdminQuestionBloc>().add(
            SubmitQuestionEvent(
              subject: _selectedSubject,
              questionText: _questionController.text.trim(),
              options: options,
              correctAnswer: _correctAnswerIndex,
              explanation: _explanationController.text.trim().isEmpty
                  ? null
                  : _explanationController.text.trim(),
              imageUrl: _imageUrlController.text.trim().isEmpty
                  ? null
                  : _imageUrlController.text.trim(),
            ),
          );
    }
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
          title: Text(widget.question == null ? 'إضافة سؤال جديد' : 'تعديل السؤال'),
        ),
        body: BlocConsumer<AdminQuestionBloc, AdminQuestionState>(
          listener: (context, state) {
            if (state is AdminQuestionSuccess) {
              Fluttertoast.showToast(
                msg: state.message ?? 'تم حفظ السؤال بنجاح',
                backgroundColor: AppColors.success,
                textColor: Colors.white,
              );
              if (widget.question != null) {
                Navigator.pop(context);
              } else {
                _resetForm();
                context.read<AdminQuestionBloc>().add(ResetAdminQuestionEvent());
              }
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
                        widget.question == null ? 'إضافة سؤال جديد' : 'تعديل السؤال',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedSubject,
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
                          if (value == null || value.trim().length < 5) {
                            return 'يجب ألا يقل السؤال عن 5 أحرف';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _imageUrlController,
                                decoration: const InputDecoration(
                                  labelText: 'رابط الصورة (اختياري)',
                                  hintText: 'https://example.com/image.jpg',
                                ),
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _isUploadingImage
                                ? const SizedBox(
                                    width: 48,
                                    height: 48,
                                    child: Center(
                                      child: SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      ),
                                    ),
                                  )
                                : IconButton(
                                    onPressed: _pickAndUploadImage,
                                    icon: const Icon(Icons.cloud_upload_outlined),
                                    tooltip: 'رفع صورة',
                                  ),
                          ],
                        ),
                      if (_imageUrlController.text.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            _imageUrlController.text,
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                const Center(child: Text('خطأ في تحميل الصورة')),
                          ),
                        ),
                      ],
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
                                      if (value == null || value.trim().isEmpty) {
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
                          onPressed: isLoading ? null : () => _submit(context),
                          child: isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(widget.question == null ? 'إضافة السؤال' : 'تحديث السؤال'),
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
