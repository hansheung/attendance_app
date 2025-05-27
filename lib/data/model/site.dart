class Site {
  final String? docId;
  final String sitename;
  final double latitude;
  final double longitude;
  final int distanceFromSite;

  Site({
    this.docId,
    required this.sitename,
    required this.latitude,
    required this.longitude,
    required this.distanceFromSite

  });

  Site copy({String? docId, String? sitename, double? latitude, double? longitude, int? distanceFromSite}) {
    return Site(
      docId: docId?? this.docId,
      sitename: sitename ?? this.sitename,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      distanceFromSite: distanceFromSite ?? this.distanceFromSite
    );
  }

  factory Site.fromMap(Map<String, dynamic> map) {
    return Site(
      docId: map['docId'],
      sitename: map['sitename'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      distanceFromSite: map['distanceFromSite']
    );
  }

  Map<String, dynamic> toMap() {
    return {'sitename': sitename, 'latitude': latitude, 'longitude': longitude, 'distanceFromSite': distanceFromSite};
  }
}
