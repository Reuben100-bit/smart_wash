
class OrderAddress {
  String location;
  String hostelName;
  String roomNumber;

  OrderAddress({
    required this.location,
    required this.hostelName,
    required this.roomNumber,
  });

  // Method to convert a OrderAddress instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'location': location,
      'hostelName': hostelName,
      'roomNumber': roomNumber,
    };
  }

  // Factory method to create a OrderAddress instance from a JSON map
  factory OrderAddress.fromJson(Map<String, dynamic> json) {
    return OrderAddress(
      location: json['location'],
      hostelName: json['hostelName'],
      roomNumber: json['roomNumber'],
    );
  }
}
