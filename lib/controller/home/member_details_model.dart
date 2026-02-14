class MemberDetailsModel {
  final Map<String, dynamic> raw;

  MemberDetailsModel(this.raw);

  factory MemberDetailsModel.fromJson(Map<String, dynamic> json) {
    return MemberDetailsModel(json);
  }

  String get id => (raw['_id'] ?? '').toString();
  String get name => (raw['name'] ?? '').toString();
  String get profileImage => (raw['profile_image'] ?? '').toString();
}
