/// Rental contract model — matches the contracts table and API response.
class Contract {
  final int? id;
  final String contractRef;
  final String? bookingRef;
  final String userUid;
  final String? userEmail;
  final String? userName;
  final String vehicleType;
  final String vehicleName;
  final String? vehicleImage;
  final DateTime startDate;
  final DateTime endDate;
  final int days;
  final double price;
  final String? location;
  final String status;
  final String? agreementSlug;
  final String? contractHtml;
  final String? source;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? contractUrl;

  Contract({
    this.id,
    required this.contractRef,
    this.bookingRef,
    required this.userUid,
    this.userEmail,
    this.userName,
    this.vehicleType = 'car',
    required this.vehicleName,
    this.vehicleImage,
    required this.startDate,
    required this.endDate,
    this.days = 1,
    this.price = 0.0,
    this.location,
    this.status = 'active',
    this.agreementSlug,
    this.contractHtml,
    this.source,
    this.createdAt,
    this.updatedAt,
    this.contractUrl,
  });

  factory Contract.fromMap(Map<String, dynamic> map) {
    final startDateVal = _parseDate(map['start_date'] ?? map['startDate']);
    final endDateVal = _parseDate(map['end_date'] ?? map['endDate']);
    return Contract(
      id: map['id'] is int ? map['id'] : int.tryParse('${map['id'] ?? 0}'),
      contractRef: map['contract_ref'] ?? map['contractRef'] ?? '',
      bookingRef: map['booking_ref'] ?? map['bookingRef'],
      userUid: map['user_uid'] ?? map['userUid'] ?? '',
      userEmail: map['user_email'] ?? map['userEmail'],
      userName: map['user_name'] ?? map['userName'],
      vehicleType: map['vehicle_type'] ?? map['vehicleType'] ?? 'car',
      vehicleName: map['vehicle_name'] ?? map['vehicleName'] ?? '',
      vehicleImage: map['vehicle_image'] ?? map['vehicleImage'],
      startDate: startDateVal ?? DateTime.now(),
      endDate: endDateVal ?? DateTime.now(),
      days: map['days'] is int
          ? map['days']
          : int.tryParse('${map['days'] ?? 1}') ?? 1,
      price: map['price'] is num
          ? (map['price'] as num).toDouble()
          : double.tryParse('${map['price'] ?? 0}') ?? 0.0,
      location: map['location'],
      status: map['status'] ?? 'active',
      agreementSlug: map['agreement_slug'] ?? map['agreementSlug'],
      contractHtml: map['contract_html'] ?? map['contractHtml'],
      source: map['source'],
      createdAt: _parseDate(map['created_at'] ?? map['createdAt']),
      updatedAt: _parseDate(map['updated_at'] ?? map['updatedAt']),
      contractUrl: map['contract_url'] ?? map['contractUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'contract_ref': contractRef,
      'booking_ref': bookingRef,
      'user_uid': userUid,
      'user_email': userEmail,
      'user_name': userName,
      'vehicle_type': vehicleType,
      'vehicle_name': vehicleName,
      'vehicle_image': vehicleImage,
      'start_date': startDate.toIso8601String().substring(0, 10),
      'end_date': endDate.toIso8601String().substring(0, 10),
      'days': days,
      'price': price,
      'location': location,
      'status': status,
      'agreement_slug': agreementSlug,
      'contract_html': contractHtml,
      'source': source,
    };
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    final s = value.toString();
    try {
      return DateTime.parse(s);
    } catch (_) {
      return null;
    }
  }

  String get priceFormatted => '€${price.toStringAsFixed(2)}';
  String get daysLabel => days == 1 ? '1 day' : '$days days';
  String get periodLabel =>
      '${_fmt(startDate)} → ${_fmt(endDate)} ($daysLabel)';
  String get shortRef => contractRef.replaceFirst(RegExp(r'^ACT-'), '');

  static String _fmt(DateTime? d) {
    if (d == null) return '—';
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }
}

/// Input for creating a contract via POST /api/contracts
class CreateContractInput {
  final String userUid;
  final String? userEmail;
  final String? userName;
  final String? bookingRef;
  final String vehicleType;
  final String vehicleName;
  final String? vehicleImage;
  final String startDate;
  final String endDate;
  final int? days;
  final double? price;
  final String? location;
  final String? status;
  final String? source;

  CreateContractInput({
    required this.userUid,
    this.userEmail,
    this.userName,
    this.bookingRef,
    this.vehicleType = 'car',
    required this.vehicleName,
    this.vehicleImage,
    required this.startDate,
    required this.endDate,
    this.days,
    this.price,
    this.location,
    this.status,
    this.source,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_uid': userUid,
      'user_email': userEmail,
      'user_name': userName,
      'booking_ref': bookingRef,
      'vehicle_type': vehicleType,
      'vehicle_name': vehicleName,
      'vehicle_image': vehicleImage,
      'start_date': startDate,
      'end_date': endDate,
      'days': days,
      'price': price,
      'location': location,
      'status': status,
      'source': source,
    }..removeWhere((_, v) => v == null);
  }
}
