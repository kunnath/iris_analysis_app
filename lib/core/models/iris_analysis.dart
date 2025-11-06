class IrisAnalysis {
  final String id;
  final String userId;
  final String imageUrl;
  final Map<String, dynamic> analysisResults;
  final DateTime createdAt;
  final double confidence;
  final int processingTimeMs;

  const IrisAnalysis({
    required this.id,
    required this.userId,
    required this.imageUrl,
    required this.analysisResults,
    required this.createdAt,
    required this.confidence,
    required this.processingTimeMs,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'imageUrl': imageUrl,
      'analysisResults': analysisResults,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'confidence': confidence,
      'processingTimeMs': processingTimeMs,
    };
  }

  factory IrisAnalysis.fromMap(Map<String, dynamic> map) {
    return IrisAnalysis(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      analysisResults: Map<String, dynamic>.from(map['analysisResults'] ?? {}),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      confidence: (map['confidence'] ?? 0.0).toDouble(),
      processingTimeMs: map['processingTimeMs'] ?? 0,
    );
  }

  IrisAnalysis copyWith({
    String? id,
    String? userId,
    String? imageUrl,
    Map<String, dynamic>? analysisResults,
    DateTime? createdAt,
    double? confidence,
    int? processingTimeMs,
  }) {
    return IrisAnalysis(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      imageUrl: imageUrl ?? this.imageUrl,
      analysisResults: analysisResults ?? this.analysisResults,
      createdAt: createdAt ?? this.createdAt,
      confidence: confidence ?? this.confidence,
      processingTimeMs: processingTimeMs ?? this.processingTimeMs,
    );
  }
}