/// 공항/도시 검색 응답 모델
class LocationSearchResponse {
  final int count;
  final List<LocationItem> locations;

  LocationSearchResponse({
    required this.count,
    required this.locations,
  });

  factory LocationSearchResponse.fromJson(Map<String, dynamic> json) {
    return LocationSearchResponse(
      count: json['count'] as int? ?? 0,
      locations: (json['locations'] as List<dynamic>?)
              ?.map((e) => LocationItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// 개별 공항/도시 정보
class LocationItem {
  final String iataCode;
  final String name;
  final String subType; // "AIRPORT" or "CITY"
  final LocationAddress? address;

  LocationItem({
    required this.iataCode,
    required this.name,
    required this.subType,
    this.address,
  });

  factory LocationItem.fromJson(Map<String, dynamic> json) {
    return LocationItem(
      iataCode: json['iata_code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      subType: json['sub_type'] as String? ?? '',
      address: json['address'] != null
          ? LocationAddress.fromJson(json['address'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// 공항 주소 정보
class LocationAddress {
  final String cityName;
  final String cityCode;
  final String countryName;
  final String countryCode;

  LocationAddress({
    required this.cityName,
    required this.cityCode,
    required this.countryName,
    required this.countryCode,
  });

  factory LocationAddress.fromJson(Map<String, dynamic> json) {
    return LocationAddress(
      cityName: json['cityName'] as String? ?? '',
      cityCode: json['cityCode'] as String? ?? '',
      countryName: json['countryName'] as String? ?? '',
      countryCode: json['countryCode'] as String? ?? '',
    );
  }
}
