import '../../../../shared/enums/user_role.dart';
import '../../domain/entities/user_management_entity.dart';

class UserManagementModel extends UserManagementEntity {
  const UserManagementModel({
    required super.id,
    required super.fullName,
    required super.email,
    required super.role,
    super.regNo,
    super.batch,
    super.section,
    super.phone,
    required super.isEmailVerified,
    super.createdAt,
  });

  factory UserManagementModel.fromJson(Map<String, dynamic> json) {
    return UserManagementModel(
      id: json['id']?.toString() ?? '',
      fullName: json['name'] ?? json['full_name'] ?? '',
      email: json['email'] ?? '',
      role: UserRole.fromString(json['role']?.toString()),
      regNo: json['reg_no'] ?? json['registration_number'],
      batch: json['batch'],
      section: json['section'],
      phone: json['phone'] ?? json['phone_number'],
      isEmailVerified: json['email_verified_at'] != null || json['is_email_verified'] == true,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': fullName,
      'email': email,
      'role': role.value,
      'reg_no': regNo,
      'batch': batch,
      'section': section,
      'phone': phone,
      'is_email_verified': isEmailVerified,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
