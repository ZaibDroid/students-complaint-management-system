import 'dart:io';
import '../../../../core/services/api_client.dart';
import '../../../../core/config/api_config.dart';
import '../../domain/entities/user.dart';

class ApiAuthRepository {
  final ApiClient _apiClient;

  ApiAuthRepository([ApiClient? apiClient]) : _apiClient = apiClient ?? ApiClient();

  Future<User?> getCurrentUser() async {
    try {
      final token = await _apiClient.getToken();
      if (token == null) return null;
      final data = await _apiClient.get(ApiConfig.me);
      if (data is Map<String, dynamic>) {
        return User.fromJson(data);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<User> login(String email, String password) async {
    final response = await _apiClient.post(ApiConfig.login, body: {
      'email': email,
      'password': password,
    });

    if (response is Map<String, dynamic>) {
      final token = response['token'] as String?;
      if (token != null) {
        await _apiClient.setToken(token);
      }
      final userData = response['user'] as Map<String, dynamic>;
      return User.fromJson(userData);
    }
    throw ApiException('Invalid response format');
  }

  Future<User> register({
    required String name,
    required String email,
    required String password,
    String? year,
    String? batch,
    String? section,
    String? adviser,
    String? phone,
    bool isCR = false,
  }) async {
    final response = await _apiClient.post(ApiConfig.register, body: {
      'name': name,
      'email': email,
      'password': password,
      'year': year,
      'batch': batch,
      'section': section,
      'adviser': adviser,
      'phone': phone,
      'isCR': isCR,
    });

    if (response is Map<String, dynamic>) {
      final token = response['token'] as String?;
      if (token != null) {
        await _apiClient.setToken(token);
      }
      final userData = response['user'] as Map<String, dynamic>;
      return User.fromJson(userData);
    }
    throw ApiException('Invalid response format');
  }

  Future<void> createStaffAccount({
    required String name,
    required String email,
    required String password,
    required String role,
    String? batch,
    String? section,
    String? semester,
    List<Map<String, dynamic>>? assignedSections,
  }) async {
    await _apiClient.post('/users/staff', body: {
      'name': name,
      'email': email,
      'password': password,
      'role': role,
      'batch': batch,
      'section': section,
      'semester': semester,
      'assigned_sections': assignedSections,
    });
  }

  Future<void> updateStaffAccount(String uid, {
    required String name,
    required String batch,
    required String section,
    required String semester,
  }) async {
    await _apiClient.put('/users/staff/$uid', body: {
      'name': name,
      'batch': batch,
      'section': section,
      'semester': semester,
    });
  }

  Future<void> deleteStaffAccount(String uid) async {
    await _apiClient.delete('/users/staff/$uid');
  }

  Future<void> updateUserStatus(String uid, String status) async {
    await _apiClient.put('/users/$uid/status', body: {'status': status});
  }

  Future<void> updateUserAdviser(String uid, String adviserId) async {
    await _apiClient.put('/users/$uid/adviser', body: {'adviser_id': adviserId});
  }

  Future<int> handoverStudents(String oldAdviserName, String newAdviserName) async {
    try {
      final response = await _apiClient.put('/users/handover-students', body: {
        'old_adviser': oldAdviserName,
        'new_adviser': newAdviserName,
      });
      return response is Map<String, dynamic> && response['count'] != null ? response['count'] as int : 1;
    } catch (_) {
      return 0;
    }
  }

  Future<int> handoverAdvisers(String oldCoordinatorName, String newCoordinatorName) async {
    try {
      final response = await _apiClient.put('/users/handover-advisers', body: {
        'old_coordinator': oldCoordinatorName,
        'new_coordinator': newCoordinatorName,
      });
      return response is Map<String, dynamic> && response['count'] != null ? response['count'] as int : 1;
    } catch (_) {
      return 0;
    }
  }

  Future<void> updatePersonalInfo(String uid, {
    required String name,
    required String year,
    required String batch,
    required String section,
    required String phone,
    String? department,
  }) async {
    final body = <String, dynamic>{
      'name': name,
      'year': year,
      'batch': batch,
      'section': section,
      'phone': phone,
    };
    if (department != null) {
      body['department'] = department;
    }
    await _apiClient.put(ApiConfig.updateProfile, body: body);
  }

  Future<void> updatePassword({required String oldPassword, required String newPassword}) async {
    await _apiClient.put(ApiConfig.changePassword, body: {
      'old_password': oldPassword,
      'new_password': newPassword,
    });
  }

  Future<String> uploadProfileImage(String uid, File imageFile) async {
    final response = await _apiClient.postMultipart(
      ApiConfig.uploadProfileImage,
      files: [imageFile],
      fileFieldName: 'image',
    );
    if (response is Map<String, dynamic> && response['profile_image_url'] != null) {
      return response['profile_image_url'];
    }
    return '';
  }

  Future<void> logout() async {
    try {
      await _apiClient.post(ApiConfig.logout);
    } catch (_) {}
    await _apiClient.clearToken();
  }
}
