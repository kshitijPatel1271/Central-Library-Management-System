class Borrow {
  final String transactionId;
  final String userId;
  final String bookId;
  final String bookName;
  final String libraryId;
  final DateTime issueDate;
  final DateTime deadline;      // Expected return date
  final DateTime? returnDate;   // Actual return date
  final double penalty;
  final int latency;            // in days

  Borrow({
    required this.transactionId,
    required this.userId,
    required this.bookId,
    required this.bookName,
    required this.libraryId,
    required this.issueDate,
    required this.deadline,
    required this.returnDate,
    required this.penalty,
    required this.latency,
  });

  factory Borrow.fromJson(Map<String, dynamic> json) {
    return Borrow(
      transactionId: json['tid'].toString(),
      userId: json['uid'].toString(),
      bookId: json['bid'].toString(),
      bookName: json['name'] ?? '',
      libraryId: json['lid'].toString(),
      issueDate: DateTime.parse(json['issue_date']),
      deadline: DateTime.parse(json['deadline']),
      returnDate: json['return_date'] != null ? DateTime.parse(json['return_date']) : null,
      penalty: (json['penalty'] as num).toDouble(),
      latency: json['latency'] ?? 0,
    );
  }
}
