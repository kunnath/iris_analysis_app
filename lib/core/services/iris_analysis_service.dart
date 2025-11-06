import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

enum IrisHealthIndicator {
  excellent,
  good,
  fair,
  poor,
  needsAttention,
}

extension IrisHealthIndicatorExtension on IrisHealthIndicator {
  String get displayName {
    switch (this) {
      case IrisHealthIndicator.excellent:
        return 'Excellent';
      case IrisHealthIndicator.good:
        return 'Good';
      case IrisHealthIndicator.fair:
        return 'Fair';
      case IrisHealthIndicator.poor:
        return 'Poor';
      case IrisHealthIndicator.needsAttention:
        return 'Needs Attention';
    }
  }

  String get description {
    switch (this) {
      case IrisHealthIndicator.excellent:
        return 'Iris patterns show optimal health indicators';
      case IrisHealthIndicator.good:
        return 'Iris patterns show good health with minor variations';
      case IrisHealthIndicator.fair:
        return 'Some variations in iris patterns detected';
      case IrisHealthIndicator.poor:
        return 'Multiple variations in iris patterns detected';
      case IrisHealthIndicator.needsAttention:
        return 'Significant variations detected - consider consultation';
    }
  }

  Color get color {
    switch (this) {
      case IrisHealthIndicator.excellent:
        return const Color(0xFF4CAF50); // Green
      case IrisHealthIndicator.good:
        return const Color(0xFF8BC34A); // Light Green
      case IrisHealthIndicator.fair:
        return const Color(0xFFFF9800); // Orange
      case IrisHealthIndicator.poor:
        return const Color(0xFFFF5722); // Deep Orange
      case IrisHealthIndicator.needsAttention:
        return const Color(0xFFF44336); // Red
    }
  }
}

class IrisAnalysisResult {
  final String id;
  final DateTime timestamp;
  final String imagePath;
  final double confidence;
  final IrisHealthIndicator overallHealth;
  final Map<String, dynamic> detailedAnalysis;
  final List<HealthInsight> insights;
  final Map<String, double> measurements;

  const IrisAnalysisResult({
    required this.id,
    required this.timestamp,
    required this.imagePath,
    required this.confidence,
    required this.overallHealth,
    required this.detailedAnalysis,
    required this.insights,
    required this.measurements,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'imagePath': imagePath,
      'confidence': confidence,
      'overallHealth': overallHealth.name,
      'detailedAnalysis': detailedAnalysis,
      'insights': insights.map((i) => i.toMap()).toList(),
      'measurements': measurements,
    };
  }

  static IrisAnalysisResult fromMap(Map<String, dynamic> map) {
    return IrisAnalysisResult(
      id: map['id'] ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
      imagePath: map['imagePath'] ?? '',
      confidence: (map['confidence'] ?? 0.0).toDouble(),
      overallHealth: IrisHealthIndicator.values.firstWhere(
        (e) => e.name == map['overallHealth'],
        orElse: () => IrisHealthIndicator.fair,
      ),
      detailedAnalysis: Map<String, dynamic>.from(map['detailedAnalysis'] ?? {}),
      insights: (map['insights'] as List<dynamic>?)
              ?.map((i) => HealthInsight.fromMap(Map<String, dynamic>.from(i)))
              .toList() ??
          [],
      measurements: Map<String, double>.from(
        (map['measurements'] as Map<String, dynamic>?)?.map(
              (key, value) => MapEntry(key, (value as num).toDouble()),
            ) ??
            {},
      ),
    );
  }
}

class HealthInsight {
  final String category;
  final String title;
  final String description;
  final String severity;
  final List<String> recommendations;

  const HealthInsight({
    required this.category,
    required this.title,
    required this.description,
    required this.severity,
    required this.recommendations,
  });

  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'title': title,
      'description': description,
      'severity': severity,
      'recommendations': recommendations,
    };
  }

  static HealthInsight fromMap(Map<String, dynamic> map) {
    return HealthInsight(
      category: map['category'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      severity: map['severity'] ?? 'low',
      recommendations: List<String>.from(map['recommendations'] ?? []),
    );
  }
}

class IrisAnalysisService {
  static final IrisAnalysisService _instance = IrisAnalysisService._internal();
  factory IrisAnalysisService() => _instance;
  IrisAnalysisService._internal();

  final Random _random = Random();

  // Main analysis method
  Future<IrisAnalysisResult> analyzeIrisImage(String imagePath) async {
    // Simulate processing time
    await Future.delayed(const Duration(seconds: 2));

    // Load and preprocess image
    final imageData = await _preprocessImage(imagePath);
    
    // Perform analysis (simulated for now)
    final analysisData = await _performAnalysis(imageData);
    
    // Generate insights
    final insights = _generateHealthInsights(analysisData);
    
    // Calculate overall health
    final overallHealth = _calculateOverallHealth(analysisData);
    
    return IrisAnalysisResult(
      id: _generateId(),
      timestamp: DateTime.now(),
      imagePath: imagePath,
      confidence: analysisData['confidence'],
      overallHealth: overallHealth,
      detailedAnalysis: analysisData,
      insights: insights,
      measurements: Map<String, double>.from(analysisData['measurements']),
    );
  }

  // Image preprocessing
  Future<Map<String, dynamic>> _preprocessImage(String imagePath) async {
    try {
      final file = File(imagePath);
      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Resize image for consistent processing
      final resizedImage = img.copyResize(image, width: 512, height: 512);
      
      // Convert to RGB if needed
      // Normalize pixel values
      final rgbImage = img.copyResize(resizedImage, width: 224, height: 224);
      
      // Extract image statistics for analysis
      final stats = _extractImageStatistics(rgbImage);
      
      return {
        'width': resizedImage.width,
        'height': resizedImage.height,
        'stats': stats,
        'quality_score': _calculateImageQuality(rgbImage),
      };
    } catch (e) {
      throw Exception('Image preprocessing failed: $e');
    }
  }

  // Simulated ML analysis (replace with TensorFlow Lite later)
  Future<Map<String, dynamic>> _performAnalysis(Map<String, dynamic> imageData) async {
    // Simulate AI processing
    await Future.delayed(const Duration(milliseconds: 500));
    
    final qualityScore = imageData['quality_score'] as double;
    final confidence = (0.85 + (_random.nextDouble() * 0.1)).clamp(0.0, 1.0);
    
    return {
      'confidence': confidence,
      'image_quality': qualityScore,
      'iris_detected': qualityScore > 0.7,
      'measurements': {
        'pupil_diameter': 3.2 + (_random.nextDouble() * 1.8),
        'iris_diameter': 11.5 + (_random.nextDouble() * 1.0),
        'color_variation': 0.3 + (_random.nextDouble() * 0.4),
        'texture_complexity': 0.6 + (_random.nextDouble() * 0.3),
        'symmetry_score': 0.8 + (_random.nextDouble() * 0.15),
      },
      'patterns': {
        'crypts': _random.nextInt(5) + 2,
        'furrows': _random.nextInt(3) + 1,
        'pigment_spots': _random.nextInt(4),
        'rings': _random.nextInt(2),
      },
      'health_indicators': {
        'circulation': 0.7 + (_random.nextDouble() * 0.25),
        'inflammation': _random.nextDouble() * 0.3,
        'nerve_integrity': 0.8 + (_random.nextDouble() * 0.15),
        'tissue_density': 0.75 + (_random.nextDouble() * 0.2),
      },
    };
  }

  // Generate health insights based on analysis
  List<HealthInsight> _generateHealthInsights(Map<String, dynamic> analysisData) {
    final insights = <HealthInsight>[];
    final healthIndicators = analysisData['health_indicators'] as Map<String, dynamic>;
    final measurements = analysisData['measurements'] as Map<String, dynamic>;
    
    // Circulation analysis
    final circulation = healthIndicators['circulation'] as double;
    if (circulation > 0.85) {
      insights.add(const HealthInsight(
        category: 'Circulation',
        title: 'Excellent Circulation',
        description: 'Iris patterns indicate healthy blood circulation',
        severity: 'positive',
        recommendations: ['Maintain current lifestyle', 'Continue regular exercise'],
      ));
    } else if (circulation < 0.6) {
      insights.add(const HealthInsight(
        category: 'Circulation',
        title: 'Circulation Patterns',
        description: 'Some variations in circulation-related iris patterns',
        severity: 'moderate',
        recommendations: [
          'Consider increasing cardiovascular exercise',
          'Ensure adequate hydration',
          'Discuss with healthcare provider'
        ],
      ));
    }

    // Inflammation analysis
    final inflammation = healthIndicators['inflammation'] as double;
    if (inflammation > 0.2) {
      insights.add(const HealthInsight(
        category: 'Inflammation',
        title: 'Inflammatory Markers',
        description: 'Iris patterns suggest possible inflammatory processes',
        severity: 'moderate',
        recommendations: [
          'Consider anti-inflammatory diet',
          'Ensure adequate rest',
          'Monitor symptoms and consult healthcare provider'
        ],
      ));
    }

    // Symmetry analysis
    final symmetry = measurements['symmetry_score'] as double;
    if (symmetry > 0.9) {
      insights.add(const HealthInsight(
        category: 'Structural',
        title: 'Excellent Symmetry',
        description: 'Iris structure shows excellent bilateral symmetry',
        severity: 'positive',
        recommendations: ['No specific recommendations needed'],
      ));
    }

    // Default positive insight if no issues found
    if (insights.isEmpty) {
      insights.add(const HealthInsight(
        category: 'Overall',
        title: 'Healthy Patterns',
        description: 'Iris analysis shows generally healthy patterns',
        severity: 'positive',
        recommendations: [
          'Continue current health practices',
          'Regular eye examinations recommended'
        ],
      ));
    }

    return insights;
  }

  // Calculate overall health indicator
  IrisHealthIndicator _calculateOverallHealth(Map<String, dynamic> analysisData) {
    final healthIndicators = analysisData['health_indicators'] as Map<String, dynamic>;
    final confidence = analysisData['confidence'] as double;
    
    // Calculate weighted health score
    double healthScore = 0.0;
    healthScore += (healthIndicators['circulation'] as double) * 0.3;
    healthScore += (1.0 - (healthIndicators['inflammation'] as double)) * 0.25;
    healthScore += (healthIndicators['nerve_integrity'] as double) * 0.25;
    healthScore += (healthIndicators['tissue_density'] as double) * 0.2;
    
    // Adjust for confidence
    healthScore *= confidence;
    
    if (healthScore >= 0.9) return IrisHealthIndicator.excellent;
    if (healthScore >= 0.8) return IrisHealthIndicator.good;
    if (healthScore >= 0.6) return IrisHealthIndicator.fair;
    if (healthScore >= 0.4) return IrisHealthIndicator.poor;
    return IrisHealthIndicator.needsAttention;
  }

  // Extract basic image statistics
  Map<String, dynamic> _extractImageStatistics(img.Image image) {
    int totalR = 0, totalG = 0, totalB = 0;
    int pixelCount = image.width * image.height;
    
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        totalR += pixel.r.toInt();
        totalG += pixel.g.toInt();
        totalB += pixel.b.toInt();
      }
    }
    
    return {
      'mean_r': totalR / pixelCount,
      'mean_g': totalG / pixelCount,
      'mean_b': totalB / pixelCount,
      'pixel_count': pixelCount,
    };
  }

  // Calculate image quality score
  double _calculateImageQuality(img.Image image) {
    // Simplified quality assessment based on various factors
    double score = 0.8; // Base score
    
    // Check image size (prefer larger images)
    if (image.width >= 512 && image.height >= 512) {
      score += 0.1;
    } else if (image.width < 256 || image.height < 256) {
      score -= 0.2;
    }
    
    // Add some randomness to simulate real quality assessment
    score += (_random.nextDouble() - 0.5) * 0.1;
    
    return score.clamp(0.0, 1.0);
  }

  // Generate unique ID
  String _generateId() {
    return 'iris_${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(1000)}';
  }

  // Batch analysis for multiple images
  Future<List<IrisAnalysisResult>> batchAnalyze(List<String> imagePaths) async {
    final results = <IrisAnalysisResult>[];
    
    for (final imagePath in imagePaths) {
      try {
        final result = await analyzeIrisImage(imagePath);
        results.add(result);
      } catch (e) {
        // Log error but continue with other images
        print('Failed to analyze image $imagePath: $e');
      }
    }
    
    return results;
  }

  // Compare two analysis results
  Map<String, dynamic> compareAnalysis(
    IrisAnalysisResult first,
    IrisAnalysisResult second,
  ) {
    final comparison = <String, dynamic>{};
    
    // Compare measurements
    final measurements1 = first.measurements;
    final measurements2 = second.measurements;
    
    for (final key in measurements1.keys) {
      if (measurements2.containsKey(key)) {
        final diff = measurements2[key]! - measurements1[key]!;
        comparison['${key}_difference'] = diff;
        comparison['${key}_change_percent'] = (diff / measurements1[key]!) * 100;
      }
    }
    
    // Compare overall health
    comparison['health_change'] = second.overallHealth.index - first.overallHealth.index;
    comparison['confidence_change'] = second.confidence - first.confidence;
    comparison['time_difference'] = second.timestamp.difference(first.timestamp).inDays;
    
    return comparison;
  }
}
