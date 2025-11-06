import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../core/services/iris_analysis_service.dart';
import '../../../core/services/cloud_storage_service.dart';
import '../../../core/services/report_generation_service.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras!.isNotEmpty) {
        _controller = CameraController(
          _cameras![0],
          ResolutionPreset.high,
          enableAudio: false,
        );
        await _controller!.initialize();
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
        }
      }
    } catch (e) {
      print('Error initializing camera: $e');
      // Fallback to image picker if camera fails
    }
  }

  Future<void> _takePicture() async {
    if (_controller != null && _controller!.value.isInitialized) {
      try {
        final XFile picture = await _controller!.takePicture();
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => IrisAnalysisScreen(imagePath: picture.path),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error taking picture: $e')),
        );
      }
    } else {
      // Fallback to image picker
      _pickFromGallery();
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 90,
      );
      if (image != null && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => IrisAnalysisScreen(imagePath: image.path),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Iris Capture'),
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
      ),
      body: _isInitialized && _controller != null
          ? _buildCameraView()
          : _buildFallbackView(),
    );
  }

  Widget _buildCameraView() {
    return Column(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.blue.shade900, width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: CameraPreview(_controller!),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: _pickFromGallery,
                icon: const Icon(Icons.photo_library),
                label: const Text('Gallery'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade600,
                  foregroundColor: Colors.white,
                ),
              ),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue.shade900,
                ),
                child: IconButton(
                  onPressed: _takePicture,
                  icon: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  // Switch camera (if multiple available)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Camera switch coming soon!')),
                  );
                },
                icon: const Icon(Icons.flip_camera_ios),
                label: const Text('Switch'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade600,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFallbackView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.camera_alt_outlined,
            size: 100,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 20),
          Text(
            'Camera not available',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'You can still upload images from your gallery',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: _pickFromGallery,
            icon: const Icon(Icons.photo_library),
            label: const Text('Choose from Gallery'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade900,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class IrisAnalysisScreen extends StatefulWidget {
  final String imagePath;

  const IrisAnalysisScreen({super.key, required this.imagePath});

  @override
  State<IrisAnalysisScreen> createState() => _IrisAnalysisScreenState();
}

class _IrisAnalysisScreenState extends State<IrisAnalysisScreen> {
  final IrisAnalysisService _analysisService = IrisAnalysisService();
  final CloudStorageService _storageService = CloudStorageService();
  final ReportGenerationService _reportService = ReportGenerationService();
  IrisAnalysisResult? _analysisResult;
  bool _isAnalyzing = true;
  bool _isSaving = false;
  bool _isGeneratingReport = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _performAnalysis();
  }

  Future<void> _performAnalysis() async {
    try {
      setState(() {
        _isAnalyzing = true;
        _error = null;
      });

      // Perform AI analysis
      final result = await _analysisService.analyzeIrisImage(widget.imagePath);
      
      if (mounted) {
        setState(() {
          _analysisResult = result;
          _isAnalyzing = false;
          _isSaving = true;
        });

        // Save to cloud storage in background
        _saveAnalysisToCloud(result);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isAnalyzing = false;
        });
      }
    }
  }

  Future<void> _saveAnalysisToCloud(IrisAnalysisResult result) async {
    try {
      await _storageService.saveAnalysisResult(result);
      
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Analysis saved to cloud'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save to cloud: ${e.toString()}'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Iris Analysis'),
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
      body: _isAnalyzing
          ? _buildLoadingView()
          : _error != null
              ? _buildErrorView()
              : _buildResultsView(),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            strokeWidth: 3,
          ),
          SizedBox(height: 24),
          Text(
            'Analyzing iris patterns...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'This may take a few moments',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              'Analysis Failed',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'An unexpected error occurred',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _performAnalysis,
              child: const Text('Retry Analysis'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsView() {
    if (_analysisResult == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Container(
            width: double.infinity,
            height: 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(
                File(widget.imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Overall Health Status
          _buildHealthStatusCard(),
          const SizedBox(height: 20),

          // Analysis Results
          const Text(
            'Analysis Results',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildAnalysisCard(
            'AI Confidence', 
            '${(_analysisResult!.confidence * 100).toStringAsFixed(1)}%', 
            _getConfidenceColor(_analysisResult!.confidence)
          ),
          
          _buildAnalysisCard(
            'Image Quality', 
            _getQualityLabel(_analysisResult!.detailedAnalysis['image_quality']), 
            Colors.blue
          ),
          
          _buildAnalysisCard(
            'Iris Detection', 
            _analysisResult!.detailedAnalysis['iris_detected'] ? 'Success' : 'Failed', 
            _analysisResult!.detailedAnalysis['iris_detected'] ? Colors.green : Colors.red
          ),

          const SizedBox(height: 20),

          // Health Insights
          _buildHealthInsights(),
          
          const SizedBox(height: 20),

          // Action Buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildHealthStatusCard() {
    final health = _analysisResult!.overallHealth;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: health.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: health.color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            _getHealthIcon(health),
            size: 48,
            color: health.color,
          ),
          const SizedBox(height: 12),
          Text(
            health.displayName,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: health.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            health.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthInsights() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Health Insights',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...(_analysisResult!.insights.map((insight) => _buildInsightCard(insight))),
      ],
    );
  }

  Widget _buildInsightCard(HealthInsight insight) {
    final color = _getSeverityColor(insight.severity);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getSeverityIcon(insight.severity),
                color: color,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  insight.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  insight.category,
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            insight.description,
            style: const TextStyle(fontSize: 14),
          ),
          if (insight.recommendations.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              'Recommendations:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            ...insight.recommendations.map((rec) => Padding(
              padding: const EdgeInsets.only(left: 8, top: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', style: TextStyle(color: color)),
                  Expanded(child: Text(rec, style: const TextStyle(fontSize: 13))),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isGeneratingReport ? null : _generateAndDownloadReport,
            icon: _isGeneratingReport 
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.file_download),
            label: Text(_isGeneratingReport ? 'Generating...' : 'Download Report'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.camera_alt),
            label: const Text('Take Another Photo'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalysisCard(String title, String value, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.9) return Colors.green;
    if (confidence >= 0.7) return Colors.orange;
    return Colors.red;
  }

  String _getQualityLabel(double quality) {
    if (quality >= 0.8) return 'High';
    if (quality >= 0.6) return 'Medium';
    return 'Low';
  }

  IconData _getHealthIcon(IrisHealthIndicator health) {
    switch (health) {
      case IrisHealthIndicator.excellent:
        return Icons.favorite;
      case IrisHealthIndicator.good:
        return Icons.thumb_up;
      case IrisHealthIndicator.fair:
        return Icons.info;
      case IrisHealthIndicator.poor:
        return Icons.warning;
      case IrisHealthIndicator.needsAttention:
        return Icons.priority_high;
    }
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'positive':
        return Colors.green;
      case 'low':
        return Colors.blue;
      case 'moderate':
        return Colors.orange;
      case 'high':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getSeverityIcon(String severity) {
    switch (severity.toLowerCase()) {
      case 'positive':
        return Icons.check_circle;
      case 'low':
        return Icons.info;
      case 'moderate':
        return Icons.warning;
      case 'high':
        return Icons.error;
      default:
        return Icons.help;
    }
  }

  Future<void> _generateAndDownloadReport() async {
    if (_analysisResult == null) return;

    setState(() => _isGeneratingReport = true);

    try {
      // Get patient name (in a real app, this would come from user profile)
      final patientName = 'Patient User'; // Replace with actual user name
      
      final reportFile = await _reportService.generateSimpleReport(
        _analysisResult!,
        patientName,
      );

      if (mounted) {
        setState(() => _isGeneratingReport = false);
        
        // Show options to view, share, or print
        _showReportOptionsDialog(reportFile);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isGeneratingReport = false);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate report: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showReportOptionsDialog(File reportFile) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Generated'),
        content: const Text('Your iris analysis report has been generated successfully. What would you like to do?'),
        actions: [
          TextButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _reportService.shareReport(reportFile);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to share report: $e')),
                );
              }
            },
            icon: const Icon(Icons.share),
            label: const Text('Share'),
          ),
          TextButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _reportService.printReport(reportFile);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to print report: $e')),
                );
              }
            },
            icon: const Icon(Icons.print),
            label: const Text('Print'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}