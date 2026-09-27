import '../../../../shared/enums/user_role.dart';
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.fullName,
    required super.email,
    required super.role,
    super.regNo,
    super.batch,
    super.section,
    super.phone,
    super.avatarUrl,
    required super.isEmailVerified,
    required super.isProfileCompleted,
    super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      fullName: json['name'] ?? json['full_name'] ?? '',
      email: json['email'] ?? '',
      role: UserRole.fromString(json['role']?.toString()),
      regNo: json['reg_no'] ?? json['registration_number'],
      batch: json['batch'],
      section: json['section'],
      phone: json['phone'] ?? json['phone_number'],
      avatarUrl: json['avatar'] ?? json['avatar_url'],
      isEmailVerified: json['email_verified_at'] != null || json['is_email_verified'] == true,
      isProfileCompleted: json['is_profile_completed'] == true || (json['reg_no'] != null && json['batch'] != null),
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
      'avatar_url': avatarUrl,
      'is_email_verified': isEmailVerified,
      'is_profile_completed': isProfileCompleted,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
