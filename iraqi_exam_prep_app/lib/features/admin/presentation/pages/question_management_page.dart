import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../exams/domain/entities/question_entity.dart';
import '../bloc/admin_question_bloc.dart';
import '../bloc/admin_question_event.dart';
import '../bloc/admin_question_state.dart';
import 'admin_question_page.dart';

class QuestionManagementPage extends StatefulWidget {
  const QuestionManagementPage({super.key});

  @override
  State<QuestionManagementPage> createState() => _QuestionManagementPageState();
}

class _QuestionManagementPageState extends State<QuestionManagementPage> {
  final _searchController = TextEditingController();
  String? _selectedSubject;
  final List<String> _subjects = [
    'ARABIC',
    'ENGLISH',
    'MATH',
    'SCIENCE',
    'SOCIAL_STUDIES',
    'ISLAMIC',
    'COMPUTER',
  ];

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  void _fetchQuestions() {
    context.read<AdminQuestionBloc>().add(
          SearchAdminQuestionsEvent(
            subject: _selectedSubject,
            query: _searchController.text.isEmpty ? null : _searchController.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الأسئلة', style: TextStyle(fontFamily: 'Cairo')),
        centerTitle: true,
      ),
      body: BlocListener<AdminQuestionBloc, AdminQuestionState>(
        listener: (context, state) {
          if (state is AdminQuestionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message ?? 'تمت العملية بنجاح')),
            );
            _fetchQuestions();
          } else if (state is AdminQuestionFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'بحث في الأسئلة...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (value) => _fetchQuestions(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: _selectedSubject,
                    hint: const Text('المادة'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('الكل')),
                      ..._subjects.map((s) => DropdownMenuItem(value: s, child: Text(s))),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedSubject = value;
                      });
                      _fetchQuestions();
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<AdminQuestionBloc, AdminQuestionState>(
                builder: (context, state) {
                  if (state is AdminQuestionLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  // We show questions even if state is success (list success)
                  if (state is AdminQuestionListSuccess) {
                    final questions = state.questions;
                    if (questions.isEmpty) {
                      return const Center(child: Text('لا توجد أسئلة'));
                    }
                    return ListView.builder(
                      itemCount: questions.length,
                      itemBuilder: (context, index) {
                        final question = questions[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          child: ListTile(
                            title: Text(
                              question.questionText,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(question.subject),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => AdminQuestionPage(question: question),
                                      ),
                                    ).then((_) => _fetchQuestions());
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _showDeleteDialog(question),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                  return const Center(child: Text('ابدأ البحث'));
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AdminQuestionPage()),
          ).then((_) => _fetchQuestions());
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDeleteDialog(QuestionEntity question) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف السؤال'),
        content: const Text('هل أنت متأكد من حذف هذا السؤال؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AdminQuestionBloc>().add(DeleteAdminQuestionEvent(question.id));
              // We need to handle the success of deletion to refresh the list.
              // For simplicity, we'll just wait a bit or use a listener in the main build.
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
