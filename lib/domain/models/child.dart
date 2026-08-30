import 'package:equatable/equatable.dart';

/// Represents a child/student
class Child extends Equatable {
  const Child({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.grade,
    required this.schoolId,
  });

  final String id;
  final String firstName;
  final String lastName;
  final int grade;
  final String schoolId;

  String get fullName => '$firstName $lastName';

  @override
  List<Object?> get props => [id, firstName, lastName, grade, schoolId];

  Child copyWith({
    String? id,
    String? firstName,
    String? lastName,
    int? grade,
    String? schoolId,
  }) {
    return Child(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      grade: grade ?? this.grade,
      schoolId: schoolId ?? this.schoolId,
    );
  }
}
