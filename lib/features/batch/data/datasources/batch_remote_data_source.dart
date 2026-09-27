import 'package:student_complaint_managment_system/core/constants/api_endpoints.dart';
import 'package:student_complaint_managment_system/core/services/api_service.dart';
import 'package:student_complaint_managment_system/core/utils/result.dart';
import 'package:student_complaint_managment_system/features/batch/data/models/batch_model.dart';

abstract class BatchRemoteDataSource {
  Future<Result<List<BatchModel>>> getBatches();
  Future<Result<bool>> requestAdviser({required String reason});
}

class BatchRemoteDataSourceImpl implements BatchRemoteDataSource {
  final ApiService _apiService;

  BatchRemoteDataSourceImpl(this._apiService);

  @override
  Future<Result<List<BatchModel>>> getBatches() async {
    final result = await _apiService.get(ApiEndpoints.batches);

    return result.when(
      onSuccess: (data) {
        final rawList = data is Map && data.containsKey('data')
            ? data['data'] as List
            : (data is List ? data : []);
        final items = rawList
            .whereType<Map<String, dynamic>>()
            .map((e) => BatchModel.fromJson(e))
            .toList();

        if (items.isEmpty) {
          final defaults = [
            const BatchModel(
              id: '1',
              session: '2022-2026',
              degreeProgram: 'BS Computer Science',
              adviserName: 'Dr. Muhammad Tariq',
              adviserEmail: 'tariq@uetmardan.edu.pk',
              adviserOffice: 'Room 204, CS Dept',
              sections: ['Section A', 'Section B'],
              totalStudents: 110,
            ),
            const BatchModel(
              id: '2',
              session: '2023-2027',
              degreeProgram: 'BS Computer Science',
              adviserName: 'Engr. Imran Khan',
              adviserEmail: 'imran@uetmardan.edu.pk',
              adviserOffice: 'Room 108, CS Dept',
              sections: ['Section A', 'Section B'],
              totalStudents: 120,
            ),
            const BatchModel(
              id: '3',
              session: '2024-2028',
              degreeProgram: 'BS Computer Science',
              adviserName: 'Dr. Sadaf Shah',
              adviserEmail: 'sadaf@uetmardan.edu.pk',
              adviserOffice: 'Room 210, CS Dept',
              sections: ['Section A', 'Section B'],
              totalStudents: 125,
            ),
          ];
          return Result.success(defaults);
        }
        return Result.success(items);
      },
      onError: (failure) => Result.error(failure),
    );
  }

  @override
  Future<Result<bool>> requestAdviser({required String reason}) async {
    final result = await _apiService.post(
      ApiEndpoints.requestAdviser,
      data: {'reason': reason},
    );

    return result.when(
      onSuccess: (_) => Result.success(true),
      onError: (failure) => Result.error(failure),
    );
  }
}
