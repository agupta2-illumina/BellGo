import 'package:equatable/equatable.dart';

enum PhoneVerificationStatus {
  unverified,
  pending,
  verified,
  failed;

  String get displayName {
    switch (this) {
      case PhoneVerificationStatus.unverified:
        return 'Not Verified';
      case PhoneVerificationStatus.pending:
        return 'Pending';
      case PhoneVerificationStatus.verified:
        return 'Verified';
      case PhoneVerificationStatus.failed:
        return 'Failed';
    }
  }
}

/// Represents a phone number with verification status
class PhoneNumber extends Equatable {
  const PhoneNumber({
    required this.countryCode,
    required this.number,
    required this.status,
    this.verifiedAt,
  });

  final String countryCode;
  final String number;
  final PhoneVerificationStatus status;
  final DateTime? verifiedAt;

  String get fullNumber => '+$countryCode$number';
  String get formattedNumber {
    if (number.length == 10) {
      return '($countryCode) ${number.substring(0, 3)}-${number.substring(3, 6)}-${number.substring(6)}';
    }
    return fullNumber;
  }

  bool get isVerified => status == PhoneVerificationStatus.verified;

  @override
  List<Object?> get props => [countryCode, number, status, verifiedAt];

  PhoneNumber copyWith({
    String? countryCode,
    String? number,
    PhoneVerificationStatus? status,
    DateTime? verifiedAt,
  }) {
    return PhoneNumber(
      countryCode: countryCode ?? this.countryCode,
      number: number ?? this.number,
      status: status ?? this.status,
      verifiedAt: verifiedAt ?? this.verifiedAt,
    );
  }
}
