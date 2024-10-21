class User {
  final String username;
  final String password;
  final String address; // New attribute for address
  final String birthday; // New attribute for birthday

  User({
    required this.username,
    required this.password,
    required this.address, // Include the new attribute
    required this.birthday, 
 
  });

  // Convert a User into a Map for database insertion
  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'password': password,
      'address': address, // Add to map
      'birthday': birthday, // Add to map
    };
  }

  // Create a User from a Map (used when fetching from the database)
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      username: map['username'],
      password: map['password'],
      address: map['address'], 
      birthday: map['birthday'], 
    );
  }
}  