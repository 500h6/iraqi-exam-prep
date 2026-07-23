class QuestionInput {
  final String subject;
  final String questionText;
  final List<String> options;
  final int correctAnswer;
  final String? explanation;
  final String? imageUrl;
  final String? category;

  const QuestionInput({
    required this.subject,
    required this.questionText,
    required this.options,
    required this.correctAnswer,
    this.explanation,
    this.imageUrl,
    this.category,
  });

  Map<String, dynamic> toJson() => {
        'subject': subject,
        'questionText': questionText,
        'options': options,
        'correctAnswer': correctAnswer,
        if (explanation != null && explanation!.isNotEmpty)
          'explanation': explanation,
        if (imageUrl != null && imageUrl!.isNotEmpty)
          'imageUrl': imageUrl,
        if (category != null && category!.isNotEmpty)
          'category': category,
      };
}
