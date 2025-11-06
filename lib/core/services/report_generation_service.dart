import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import '../services/iris_analysis_service.dart';
import '../services/cloud_storage_service.dart';

enum ReportType {
  simple,
  detailed,
  comparison,
  trend,
}

class ReportData {
  final String id;
  final DateTime generatedAt;
  final ReportType type;
  final String patientName;
  final String patientEmail;
  final List<IrisAnalysisResult> analyses;
  final Map<String, dynamic> metadata;

  const ReportData({
    required this.id,
    required this.generatedAt,
    required this.type,
    required this.patientName,
    required this.patientEmail,
    required this.analyses,
    required this.metadata,
  });
}

class ReportGenerationService {
  static final ReportGenerationService _instance = ReportGenerationService._internal();
  factory ReportGenerationService() => _instance;
  ReportGenerationService._internal();

  final CloudStorageService _storageService = CloudStorageService();

  // Generate simple analysis report
  Future<File> generateSimpleReport(IrisAnalysisResult analysis, String patientName) async {
    final pdf = pw.Document();
    
    // Load fonts and images
    final font = await PdfGoogleFonts.nunitoRegular();
    final boldFont = await PdfGoogleFonts.nunitoBold();
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            _buildHeader(patientName, font, boldFont),
            pw.SizedBox(height: 20),
            _buildAnalysisOverview(analysis, font, boldFont),
            pw.SizedBox(height: 20),
            _buildHealthInsights(analysis, font, boldFont),
            pw.SizedBox(height: 20),
            _buildMeasurements(analysis, font, boldFont),
            pw.SizedBox(height: 20),
            _buildRecommendations(analysis, font, boldFont),
            pw.SizedBox(height: 20),
            _buildFooter(font),
          ];
        },
      ),
    );

    return await _savePdfToFile(pdf, 'iris_report_${analysis.id}');
  }

  // Generate detailed report with multiple analyses
  Future<File> generateDetailedReport(List<IrisAnalysisResult> analyses, String patientName) async {
    final pdf = pw.Document();
    
    final font = await PdfGoogleFonts.nunitoRegular();
    final boldFont = await PdfGoogleFonts.nunitoBold();
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            _buildHeader(patientName, font, boldFont),
            pw.SizedBox(height: 20),
            _buildExecutiveSummary(analyses, font, boldFont),
            pw.SizedBox(height: 20),
            ..._buildDetailedAnalyses(analyses, font, boldFont),
            pw.SizedBox(height: 20),
            _buildTrendAnalysis(analyses, font, boldFont),
            pw.SizedBox(height: 20),
            _buildOverallRecommendations(analyses, font, boldFont),
            pw.SizedBox(height: 20),
            _buildFooter(font),
          ];
        },
      ),
    );

    return await _savePdfToFile(pdf, 'detailed_iris_report_${DateTime.now().millisecondsSinceEpoch}');
  }

  // Generate comparison report
  Future<File> generateComparisonReport(
    IrisAnalysisResult baseline,
    IrisAnalysisResult current,
    String patientName,
  ) async {
    final pdf = pw.Document();
    
    final font = await PdfGoogleFonts.nunitoRegular();
    final boldFont = await PdfGoogleFonts.nunitoBold();
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            _buildHeader(patientName, font, boldFont),
            pw.SizedBox(height: 20),
            _buildComparisonOverview(baseline, current, font, boldFont),
            pw.SizedBox(height: 20),
            _buildMeasurementComparison(baseline, current, font, boldFont),
            pw.SizedBox(height: 20),
            _buildHealthProgressAnalysis(baseline, current, font, boldFont),
            pw.SizedBox(height: 20),
            _buildProgressRecommendations(baseline, current, font, boldFont),
            pw.SizedBox(height: 20),
            _buildFooter(font),
          ];
        },
      ),
    );

    return await _savePdfToFile(pdf, 'comparison_report_${DateTime.now().millisecondsSinceEpoch}');
  }

  // Build PDF components
  pw.Widget _buildHeader(String patientName, pw.Font font, pw.Font boldFont) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Iris Analysis Report',
                  style: pw.TextStyle(font: boldFont, fontSize: 24, color: PdfColors.blue900),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  'AI-Powered Health Insights',
                  style: pw.TextStyle(font: font, fontSize: 14, color: PdfColors.grey700),
                ),
              ],
            ),
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                color: PdfColors.blue50,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Text(
                DateTime.now().toString().split(' ')[0],
                style: pw.TextStyle(font: font, fontSize: 12),
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 20),
        pw.Container(
          width: double.infinity,
          height: 1,
          color: PdfColors.blue200,
        ),
        pw.SizedBox(height: 20),
        pw.Row(
          children: [
            pw.Text(
              'Patient: ',
              style: pw.TextStyle(font: boldFont, fontSize: 16),
            ),
            pw.Text(
              patientName,
              style: pw.TextStyle(font: font, fontSize: 16),
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildAnalysisOverview(IrisAnalysisResult analysis, pw.Font font, pw.Font boldFont) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Analysis Overview',
          style: pw.TextStyle(font: boldFont, fontSize: 18, color: PdfColors.blue900),
        ),
        pw.SizedBox(height: 12),
        pw.Container(
          padding: const pw.EdgeInsets.all(16),
          decoration: pw.BoxDecoration(
            color: _getHealthColor(analysis.overallHealth),
            borderRadius: pw.BorderRadius.circular(8),
            border: pw.Border.all(color: _getHealthColor(analysis.overallHealth)),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Overall Health Status',
                    style: pw.TextStyle(font: boldFont, fontSize: 14),
                  ),
                  pw.Text(
                    analysis.overallHealth.displayName,
                    style: pw.TextStyle(
                      font: boldFont,
                      fontSize: 14,
                      color: _getHealthColor(analysis.overallHealth),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('AI Confidence:', style: pw.TextStyle(font: font, fontSize: 12)),
                  pw.Text(
                    '${(analysis.confidence * 100).toStringAsFixed(1)}%',
                    style: pw.TextStyle(font: boldFont, fontSize: 12),
                  ),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Analysis Date:', style: pw.TextStyle(font: font, fontSize: 12)),
                  pw.Text(
                    _formatDate(analysis.timestamp),
                    style: pw.TextStyle(font: font, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _buildHealthInsights(IrisAnalysisResult analysis, pw.Font font, pw.Font boldFont) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Health Insights',
          style: pw.TextStyle(font: boldFont, fontSize: 18, color: PdfColors.blue900),
        ),
        pw.SizedBox(height: 12),
        ...analysis.insights.map((insight) => pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 12),
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey50,
            borderRadius: pw.BorderRadius.circular(8),
            border: pw.Border.all(color: PdfColors.grey200),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    insight.title,
                    style: pw.TextStyle(font: boldFont, fontSize: 14),
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.blue100,
                      borderRadius: pw.BorderRadius.circular(12),
                    ),
                    child: pw.Text(
                      insight.category,
                      style: pw.TextStyle(font: font, fontSize: 10),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 6),
              pw.Text(
                insight.description,
                style: pw.TextStyle(font: font, fontSize: 12),
              ),
              if (insight.recommendations.isNotEmpty) ...[
                pw.SizedBox(height: 8),
                pw.Text(
                  'Recommendations:',
                  style: pw.TextStyle(font: boldFont, fontSize: 12),
                ),
                pw.SizedBox(height: 4),
                ...insight.recommendations.map((rec) => pw.Padding(
                  padding: const pw.EdgeInsets.only(left: 8, top: 2),
                  child: pw.Text(
                    '• $rec',
                    style: pw.TextStyle(font: font, fontSize: 11),
                  ),
                )),
              ],
            ],
          ),
        )),
      ],
    );
  }

  pw.Widget _buildMeasurements(IrisAnalysisResult analysis, pw.Font font, pw.Font boldFont) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Detailed Measurements',
          style: pw.TextStyle(font: boldFont, fontSize: 18, color: PdfColors.blue900),
        ),
        pw.SizedBox(height: 12),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.blue50),
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text('Measurement', style: pw.TextStyle(font: boldFont, fontSize: 12)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text('Value', style: pw.TextStyle(font: boldFont, fontSize: 12)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text('Status', style: pw.TextStyle(font: boldFont, fontSize: 12)),
                ),
              ],
            ),
            ...analysis.measurements.entries.map((entry) => pw.TableRow(
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(
                    _formatMeasurementKey(entry.key),
                    style: pw.TextStyle(font: font, fontSize: 11),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(
                    _formatMeasurementValue(entry.key, entry.value),
                    style: pw.TextStyle(font: font, fontSize: 11),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(
                    _getMeasurementStatus(entry.key, entry.value),
                    style: pw.TextStyle(font: font, fontSize: 11, color: PdfColors.green),
                  ),
                ),
              ],
            )),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildRecommendations(IrisAnalysisResult analysis, pw.Font font, pw.Font boldFont) {
    final allRecommendations = analysis.insights
        .expand((insight) => insight.recommendations)
        .toSet()
        .toList();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Overall Recommendations',
          style: pw.TextStyle(font: boldFont, fontSize: 18, color: PdfColors.blue900),
        ),
        pw.SizedBox(height: 12),
        pw.Container(
          padding: const pw.EdgeInsets.all(16),
          decoration: pw.BoxDecoration(
            color: PdfColors.green50,
            borderRadius: pw.BorderRadius.circular(8),
            border: pw.Border.all(color: PdfColors.green200),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: allRecommendations.map((rec) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 6),
              child: pw.Text(
                '• $rec',
                style: pw.TextStyle(font: font, fontSize: 12),
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }

  pw.Widget _buildFooter(pw.Font font) {
    return pw.Column(
      children: [
        pw.Container(
          width: double.infinity,
          height: 1,
          color: PdfColors.grey300,
        ),
        pw.SizedBox(height: 16),
        pw.Text(
          'This report is generated by AI-powered iris analysis and should not replace professional medical advice. Please consult with a healthcare provider for medical concerns.',
          style: pw.TextStyle(font: font, fontSize: 10, color: PdfColors.grey600),
          textAlign: pw.TextAlign.center,
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          'Generated by Iris Analysis App • www.irisanalysis.com',
          style: pw.TextStyle(font: font, fontSize: 10, color: PdfColors.grey600),
          textAlign: pw.TextAlign.center,
        ),
      ],
    );
  }

  // Additional methods for detailed and comparison reports would go here...
  pw.Widget _buildExecutiveSummary(List<IrisAnalysisResult> analyses, pw.Font font, pw.Font boldFont) {
    // Implementation for executive summary
    return pw.Container();
  }

  List<pw.Widget> _buildDetailedAnalyses(List<IrisAnalysisResult> analyses, pw.Font font, pw.Font boldFont) {
    // Implementation for detailed analyses
    return [];
  }

  pw.Widget _buildTrendAnalysis(List<IrisAnalysisResult> analyses, pw.Font font, pw.Font boldFont) {
    // Implementation for trend analysis
    return pw.Container();
  }

  pw.Widget _buildOverallRecommendations(List<IrisAnalysisResult> analyses, pw.Font font, pw.Font boldFont) {
    // Implementation for overall recommendations
    return pw.Container();
  }

  pw.Widget _buildComparisonOverview(IrisAnalysisResult baseline, IrisAnalysisResult current, pw.Font font, pw.Font boldFont) {
    // Implementation for comparison overview
    return pw.Container();
  }

  pw.Widget _buildMeasurementComparison(IrisAnalysisResult baseline, IrisAnalysisResult current, pw.Font font, pw.Font boldFont) {
    // Implementation for measurement comparison
    return pw.Container();
  }

  pw.Widget _buildHealthProgressAnalysis(IrisAnalysisResult baseline, IrisAnalysisResult current, pw.Font font, pw.Font boldFont) {
    // Implementation for health progress analysis
    return pw.Container();
  }

  pw.Widget _buildProgressRecommendations(IrisAnalysisResult baseline, IrisAnalysisResult current, pw.Font font, pw.Font boldFont) {
    // Implementation for progress recommendations
    return pw.Container();
  }

  // Helper methods
  Future<File> _savePdfToFile(pw.Document pdf, String filename) async {
    final bytes = await pdf.save();
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$filename.pdf');
    await file.writeAsBytes(bytes);
    return file;
  }

  PdfColor _getHealthColor(IrisHealthIndicator health) {
    switch (health) {
      case IrisHealthIndicator.excellent:
        return PdfColors.green;
      case IrisHealthIndicator.good:
        return PdfColors.lightGreen;
      case IrisHealthIndicator.fair:
        return PdfColors.orange;
      case IrisHealthIndicator.poor:
        return PdfColors.deepOrange;
      case IrisHealthIndicator.needsAttention:
        return PdfColors.red;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatMeasurementKey(String key) {
    return key.split('_').map((word) => 
      word[0].toUpperCase() + word.substring(1)
    ).join(' ');
  }

  String _formatMeasurementValue(String key, double value) {
    if (key.contains('diameter')) {
      return '${value.toStringAsFixed(1)} mm';
    } else if (key.contains('score') || key.contains('variation') || key.contains('complexity')) {
      return '${(value * 100).toStringAsFixed(0)}%';
    }
    return value.toStringAsFixed(2);
  }

  String _getMeasurementStatus(String key, double value) {
    // Simple status evaluation
    if (key.contains('score') && value > 0.8) return 'Good';
    if (key.contains('diameter') && value > 3.0 && value < 5.0) return 'Normal';
    return 'Normal';
  }

  // Print report
  Future<void> printReport(File reportFile) async {
    final bytes = await reportFile.readAsBytes();
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => bytes);
  }

  // Share report
  Future<void> shareReport(File reportFile) async {
    await Printing.sharePdf(
      bytes: await reportFile.readAsBytes(),
      filename: reportFile.path.split('/').last,
    );
  }
}