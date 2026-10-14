/// 마이페이지 사용자 프로필 모델
class MyPageUserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? profileImageUrl;
  final bool isBusinessUser;
  final String? businessName;
  final String? businessNumber;

  const MyPageUserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.profileImageUrl,
    required this.isBusinessUser,
    this.businessName,
    this.businessNumber,
  });

  factory MyPageUserModel.fromJson(Map<String, dynamic> json) {
    if (json.isEmpty) {
      throw const FormatException('MyPageUserModel.fromJson: empty json');
    }
    return MyPageUserModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      profileImageUrl: json['profileImageUrl']?.toString(),
      isBusinessUser: json['isBusinessUser'] == true ||
          json['isBusinessUser'] == 'true',
      businessName: json['businessName']?.toString(),
      businessNumber: json['businessNumber']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'profileImageUrl': profileImageUrl,
        'isBusinessUser': isBusinessUser,
        'businessName': businessName,
        'businessNumber': businessNumber,
      };

  MyPageUserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? profileImageUrl,
    bool? isBusinessUser,
    String? businessName,
    String? businessNumber,
  }) =>
      MyPageUserModel(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        profileImageUrl: profileImageUrl ?? this.profileImageUrl,
        isBusinessUser: isBusinessUser ?? this.isBusinessUser,
        businessName: businessName ?? this.businessName,
        businessNumber: businessNumber ?? this.businessNumber,
      );

  @override
  String toString() =>
      'MyPageUserModel(id: $id, name: $name, email: $email, isBusinessUser: $isBusinessUser)';
}
