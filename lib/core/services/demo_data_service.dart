import '../models/iris_analysis.dart';

class DemoDataService {
  static final DemoDataService _instance = DemoDataService._internal();
  factory DemoDataService() => _instance;
  DemoDataService._internal();

  List<IrisAnalysis> getDemoAnalyses() {
    return [
      IrisAnalysis(
        id: 'demo_analysis_1',
        userId: 'demo_user_123',
        imageUrl: 'assets/images/demo_iris_1.jpg',
        analysisResults: {
          'overall_health': 85,
          'cardiovascular_risk': 'Low',
          'digestive_health': 'Good',
          'stress_level': 'Moderate',
          'toxin_level': 'Low',
          'constitution_type': 'Mixed',
          'recommendations': [
            'Increase water intake',
            'Add more leafy greens to diet',
            'Consider meditation for stress management',
            'Regular cardiovascular exercise recommended'
          ],
          'detailed_analysis': {
            'pupil_size': 'Normal',
            'iris_density': 'Medium-High',
            'color_variations': ['Brown', 'Golden flecks'],
            'fiber_integrity': 'Good',
            'pigment_spots': 'Few',
            'nerve_rings': 'Minimal'
          }
        },
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        confidence: 0.87,
        processingTimeMs: 2340,
      ),
      
      IrisAnalysis(
        id: 'demo_analysis_2',
        userId: 'demo_user_123',
        imageUrl: 'assets/images/demo_iris_2.jpg',
        analysisResults: {
          'overall_health': 92,
          'cardiovascular_risk': 'Very Low',
          'digestive_health': 'Excellent',
          'stress_level': 'Low',
          'toxin_level': 'Very Low',
          'constitution_type': 'Strong',
          'recommendations': [
            'Maintain current lifestyle',
            'Continue regular exercise routine',
            'Consider adding omega-3 supplements',
            'Good sleep hygiene maintained'
          ],
          'detailed_analysis': {
            'pupil_size': 'Normal',
            'iris_density': 'High',
            'color_variations': ['Blue', 'Clear'],
            'fiber_integrity': 'Excellent',
            'pigment_spots': 'None',
            'nerve_rings': 'None'
          }
        },
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        confidence: 0.94,
        processingTimeMs: 1890,
      ),
      
      IrisAnalysis(
        id: 'demo_analysis_3',
        userId: 'demo_user_123',
        imageUrl: 'assets/images/demo_iris_3.jpg',
        analysisResults: {
          'overall_health': 76,
          'cardiovascular_risk': 'Moderate',
          'digestive_health': 'Fair',
          'stress_level': 'High',
          'toxin_level': 'Moderate',
          'constitution_type': 'Sensitive',
          'recommendations': [
            'Reduce caffeine intake',
            'Implement stress reduction techniques',
            'Consider digestive enzyme supplements',
            'Increase fiber intake',
            'Regular detox protocols recommended'
          ],
          'detailed_analysis': {
            'pupil_size': 'Slightly constricted',
            'iris_density': 'Medium',
            'color_variations': ['Green', 'Brown patches'],
            'fiber_integrity': 'Fair',
            'pigment_spots': 'Several',
            'nerve_rings': 'Moderate'
          }
        },
        createdAt: DateTime.now().subtract(const Duration(days: 14)),
        confidence: 0.81,
        processingTimeMs: 2876,
      ),
    ];
  }

  Map<String, dynamic> getDemoUserStats() {
    return {
      'total_analyses': 15,
      'avg_health_score': 84.3,
      'improvement_trend': 12.5, // percentage improvement over time
      'last_analysis_date': DateTime.now().subtract(const Duration(days: 2)),
      'health_categories': {
        'cardiovascular': 8.5,
        'digestive': 7.8,
        'stress_management': 6.9,
        'detoxification': 8.2,
      },
      'monthly_progress': [
        {'month': 'Oct', 'score': 79},
        {'month': 'Nov', 'score': 84},
      ],
    };
  }
}