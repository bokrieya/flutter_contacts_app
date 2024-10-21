class Contact {
  final int? id;
  final String name;
  final String pseudo;
  final String phoneNumber;

  Contact({
    this.id,
    required this.name,
    required this.pseudo,
    required this.phoneNumber,
  });

  // Convert a Contact into a Map for database insertion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'pseudo': pseudo,
      'phoneNumber': phoneNumber,
    };
  }

  // Create a Contact from a Map (used when fetching from the database)
  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map['id'],
      name: map['name'],
      pseudo: map['pseudo'],
      phoneNumber: map['phoneNumber'],
    );
  }
}
