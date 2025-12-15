enum SearchResultType {
  COUNTRY,
  CITY,
  AIRPORT,
}

class Airport {
  final String cityName;
  final String cityCode; // 도시 코드 추가 (예: NYC)
  final String airportName;
  final String airportCode;
  final String country;
  final String locationType;
  final SearchResultType type; // UI 표시를 위한 타입

  const Airport({
    required this.cityName,
    required this.cityCode,
    required this.airportName,
    required this.airportCode,
    required this.country,
    required this.locationType,
    this.type = SearchResultType.AIRPORT, // 기본값 AIRPORT
  });

  // Helper method to check if airport matches search query
  bool matchesQuery(String query) {
    final lowerQuery = query.toLowerCase();
    return cityName.toLowerCase().contains(lowerQuery) ||
        airportName.toLowerCase().contains(lowerQuery) ||
        airportCode.toLowerCase().contains(lowerQuery);
  }
}
