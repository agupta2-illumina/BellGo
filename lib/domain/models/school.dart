import 'package:equatable/equatable.dart';

/// Represents a school
class School extends Equatable {
  const School({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.gradeRangeStart,
    required this.gradeRangeEnd,
    required this.latitude,
    required this.longitude,
  });

  final String id;
  final String name;
  final String address;
  final String city;
  final String state;
  final String zipCode;
  final int gradeRangeStart;
  final int gradeRangeEnd;
  final double latitude;
  final double longitude;

  String get fullAddress => '$address, $city, $state $zipCode';
  String get gradeRange => 'Grades $gradeRangeStart-$gradeRangeEnd';

  @override
  List<Object?> get props => [
        id,
        name,
        address,
        city,
        state,
        zipCode,
        gradeRangeStart,
        gradeRangeEnd,
        latitude,
        longitude,
      ];

  School copyWith({
    String? id,
    String? name,
    String? address,
    String? city,
    String? state,
    String? zipCode,
    int? gradeRangeStart,
    int? gradeRangeEnd,
    double? latitude,
    double? longitude,
  }) {
    return School(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      gradeRangeStart: gradeRangeStart ?? this.gradeRangeStart,
      gradeRangeEnd: gradeRangeEnd ?? this.gradeRangeEnd,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}
