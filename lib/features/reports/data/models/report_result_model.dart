import '../../domain/entities/report_result.dart';

class ReportResultModel extends ReportResult {
  const ReportResultModel({required super.type, required super.data});

  factory ReportResultModel.fromResponse(
    String type,
    Map<String, dynamic> response,
  ) => ReportResultModel(type: type, data: response['data']);
}
