import 'package:equatable/equatable.dart';
import '../../../../shared/enums/user_role.dart';

class ProfileEntity extends Equatable {
  final String id;
  final String fullName;
  final String email;
  final UserRole role;
  final String? regNo;
  final String? batch;
  final String? section;
  final String? phone;
  final String? avatarUrl;
  final DateTime? joinedAt;

  const ProfileEntity({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    this.regNo,
    this.batch,
    this.section,
    this.phone,
    this.avatarUrl,
    this.joinedAt,
  });

  @override
  List<Object?> get props => [id, fullName, email, role, regNo, batch, section, phone, avatarUrl, joinedAt];
}
