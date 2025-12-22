class QuestionInput {
  final String subject;
  final String questionText;
  final List<String> options;
  final int correctAnswer;
  final String? explanation;

  const QuestionInput({
    required this.subject,
    required this.questionText,
    required this.options,
    required this.correctAnswer,
    this.explanation,
  });

  Map<String, dynamic> toJson() => {
        'subject': subject,
        'questionText': questionText,
        'options': options,
        'correctAnswer': correctAnswer,
        if (explanation != null && explanation!.isNotEmpty)
          'explanation': explanation,
      };
}
