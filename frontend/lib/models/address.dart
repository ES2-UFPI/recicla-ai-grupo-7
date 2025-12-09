class Address {
  final String id;
  final String street;
  final String number;
  final String city;
  final String state;
  final String zipcode;

  Address({
    required this.id,
    required this.street,
    required this.number,
    required this.city,
    required this.state,
    required this.zipcode,
  });

  String get fullText => '$street, $number - $city/$state';

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] as String,
      street: json['street'] as String,
      number: json['number'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      zipcode: json['zipcode'] as String,
    );
  }
}
