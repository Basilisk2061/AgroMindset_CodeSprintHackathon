class UserModel {
  final int? id;
  final String email;
  final String password;
  final String confirmPassword;

  UserModel({
    this.id,
    required this.email,
    required this.password,
    required this.confirmPassword,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'email': email,
        'password': password,
        'confirm_password': confirmPassword,
      };

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
        id: map['id'],
        email: map['email'],
        password: map['password'],
        confirmPassword: map['confirm_password'],
      );
}
