class User {
  int? id;
  String email;
  String password;
  String address;
  String birthday;

  User({
    this.id,
    required this.email,
    required this.password,
    required this.address,
    required this.birthday,
  });

  // Convert a User object into a Map object to store in the database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'address': address,
      'birthday': birthday,
    };
  }

  // Convert a Map object into a User object
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      email: map['email'],
      password: map['password'],
      address: map['address'],
      birthday: map['birthday'],
    );
  }
}
