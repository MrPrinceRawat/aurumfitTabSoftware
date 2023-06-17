class AdminData {
  late final List data;
  late final int count;

  AdminData({required this.data, required this.count});

  factory AdminData.fromJson(Map<String, dynamic> json) {
    return AdminData(
      data: json['users'],
      count: json['count'],
    );
  }

  Map<String, dynamic> toJson() => {
        'users': data,
        'count': count,
      };

  @override
  String toString() {
    return 'AdminData{data: $data, count: $count}';
  }
}
