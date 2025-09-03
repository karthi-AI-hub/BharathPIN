/// Model class representing a Post Office with all relevant details
class PostOffice {
  final String name;
  final String branchType;
  final String district;
  final String state;
  final String pincode;
  final String? circle;
  final String? division;
  final String? region;
  final String deliveryStatus;
  final String? block;

  PostOffice({
    required this.name,
    required this.branchType,
    required this.district,
    required this.state,
    required this.pincode,
    required this.deliveryStatus,
    this.circle,
    this.division,
    this.region,
    this.block,
  });

  /// Factory constructor to create PostOffice from JSON
  factory PostOffice.fromJson(Map<String, dynamic> json) {
    return PostOffice(
      name: json['Name'] ?? 'Unknown',
      branchType: json['BranchType'] ?? 'Unknown',
      district: json['District'] ?? 'Unknown',
      state: json['State'] ?? 'Unknown',
      pincode: json['Pincode'] ?? 'Unknown',
      circle: json['Circle'],
      division: json['Division'],
      region: json['Region'],
      deliveryStatus: json['DeliveryStatus'] ?? 'Unknown',
      block: json['Block'],
    );
  }

  /// Convert PostOffice to JSON (useful for caching or debugging)
  Map<String, dynamic> toJson() {
    return {
      'Name': name,
      'BranchType': branchType,
      'District': district,
      'State': state,
      'Pincode': pincode,
      'Circle': circle,
      'Division': division,
      'Region': region,
      'DeliveryStatus': deliveryStatus,
      'Block': block,
    };
  }

  /// Get formatted address string
  String get fullAddress {
    List<String> addressParts = [name, district, state, pincode];
    return addressParts.join(', ');
  }

  /// Check if this is a head post office
  bool get isHeadPostOffice => branchType.toLowerCase().contains('head');
  
  /// Check if this is a sub post office
  bool get isSubPostOffice => branchType.toLowerCase().contains('sub');
  
  /// Check if delivery is available
  bool get isDeliveryAvailable => deliveryStatus.toLowerCase() == 'delivery';
}
