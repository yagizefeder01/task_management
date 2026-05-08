class BookModel {
  const BookModel({
    this.key,
    required this.title,
    required this.author,
    required this.imagePath,
    required this.totalPages,
    required this.currentPages,
    required this.status,
    required this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  final dynamic key;
  final String title;
  final String author;
  final String imagePath;
  final int totalPages;
  final int currentPages;
  final String status;
  final String note;
  final String createdAt;
  final String updatedAt;

  double get progress {
    if (totalPages <= 0) {
      return 0;
    }

    return (currentPages / totalPages).clamp(0.0, 1.0);
  }

  int get remainingPages {
    final remaining = totalPages - currentPages;
    return remaining < 0 ? 0 : remaining;
  }

  BookModel copyWith({
    dynamic key,
    String? title,
    String? author,
    String? imagePath,
    int? totalPages,
    int? currentPages,
    String? status,
    String? note,
    String? createdAt,
    String? updatedAt,
  }) {
    return BookModel(
      key: key ?? this.key,
      title: title ?? this.title,
      author: author ?? this.author,
      imagePath: imagePath ?? this.imagePath,
      totalPages: totalPages ?? this.totalPages,
      currentPages: currentPages ?? this.currentPages,
      status: status ?? this.status,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'author': author,
      'imagePath': imagePath,
      'totalPages': totalPages,
      'currentPages': currentPages,
      'status': status,
      'note': note,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory BookModel.fromMap(Map<dynamic, dynamic> map, {dynamic key}) {
    return BookModel(
      key: key,
      title: (map['title'] ?? '').toString(),
      author: (map['author'] ?? '').toString(),
      imagePath: (map['imagePath'] ?? '').toString(),
      totalPages: (map['totalPages'] as num? ?? 0).toInt(),
      currentPages: (map['currentPages'] as num? ?? 0).toInt(),
      status: (map['status'] ?? '').toString(),
      note: (map['note'] ?? '').toString(),
      createdAt: (map['createdAt'] ?? '').toString(),
      updatedAt: (map['updatedAt'] ?? map['createdAt'] ?? '').toString(),
    );
  }
}
