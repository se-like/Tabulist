class Class {
  final String id;
  final String subjectId;
  final String teacherId;
  final String roomId;
  final int startTime;
  final int endTime;
  final int dayOfWeek;
  final String? memo;
  final int periodNumber;

  Class({
    required this.id,
    required this.subjectId,
    required this.teacherId,
    required this.roomId,
    required this.startTime,
    required this.endTime,
    required this.dayOfWeek,
    this.memo,
    required this.periodNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subjectId': subjectId,
      'teacherId': teacherId,
      'roomId': roomId,
      'startTime': startTime,
      'endTime': endTime,
      'dayOfWeek': dayOfWeek,
      'memo': memo,
      'periodNumber': periodNumber,
    };
  }

  factory Class.fromJson(Map<String, dynamic> json) {
    return Class(
      id: json['id'] as String,
      subjectId: json['subjectId'] as String,
      teacherId: json['teacherId'] as String,
      roomId: json['roomId'] as String,
      startTime: json['startTime'] as int,
      endTime: json['endTime'] as int,
      dayOfWeek: json['dayOfWeek'] as int,
      memo: json['memo'] as String?,
      periodNumber: json['periodNumber'] as int? ?? 1,
    );
  }
}
