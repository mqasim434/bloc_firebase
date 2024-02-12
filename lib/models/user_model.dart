class UserModel {
  String? name;
  String? email;
  String? phone;
  String? password;
  String? imageUrl;

  UserModel({this.name, this.email, this.phone, this.password,this.imageUrl});

  UserModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    password = json['password'];
    imageUrl = json['imageUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['name'] = name;
    data['email'] = email;
    data['phone'] = phone;
    data['password'] = password;
    data['imageUrl'] = imageUrl;
    return data;
  }
}