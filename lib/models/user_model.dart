class UserModel {
  String? name;
  String? email;
  String? phone;
  String? password;
  bool isTyping = false;
  bool isOnline = false;
  String? imageUrl;
  String? lastSeen;
  String? lastMessage;

  UserModel({this.name, this.email, this.phone, this.password,this.imageUrl,this.isTyping=false,this.isOnline=false,this.lastSeen,this.lastMessage});

  UserModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    password = json['password'];
    imageUrl = json['imageUrl'];
    isTyping = json['isTyping'];
    isOnline = json['isOnline'];
    lastSeen = json['lastSeen'];
    lastMessage = json['lastMessage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['email'] = email;
    data['phone'] = phone;
    data['password'] = password;
    data['imageUrl'] = imageUrl;
    data['isTyping'] = isTyping;
    data['isOnline'] = isOnline;
    data['lastSeen'] = lastSeen;
    data['lastMessage'] = lastMessage;
    return data;
  }
}