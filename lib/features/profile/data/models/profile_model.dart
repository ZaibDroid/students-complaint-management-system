import '../../../../shared/enums/user_role.dart';
import '../../domain/entities/profile_entity.dart';

class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.id,
    required super.fullName,
    required super.email,
    required super.role,
    super.regNo,
    super.batch,
    super.section,
    super.phone,
    super.avatarUrl,
    super.joinedAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id']?.toString() ?? '',
      fullName: json['name'] ?? json['full_name'] ?? '',
      email: json['email'] ?? '',
      role: UserRole.fromString(json['role']?.toString()),
      regNo: json['reg_no'] ?? json['registration_number'],
      batch: json['batch'],
      section: json['section'],
      phone: json['phone'] ?? json['phone_number'],
      avatarUrl: json['avatar'] ?? json['avatar_url'],
      joinedAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
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
      'created_at': joinedAt?.toIso8601String(),
    };
  }
}
