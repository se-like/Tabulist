class Class {
  final String id;
  final String name;
  final String teacher;
  final String room;
  final int dayOfWeek;
  final int startTime;
  final int endTime;
  final String? memo;

  Class({
    required this.id,
    required this.name,
    required this.teacher,
    required this.room,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.memo,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'teacher': teacher,
      'room': room,
      'dayOfWeek': dayOfWeek,
      'startTime': startTime,
      'endTime': endTime,
      'memo': memo,
    };
  }

  factory Class.fromJson(Map<String, dynamic> json) {
    return Class(
      id: json['id'],
      name: json['name'],
      teacher: json['teacher'],
      room: json['room'],
      dayOfWeek: json['dayOfWeek'],
      startTime: json['startTime'],
      endTime: json['endTime'],
      memo: json['memo'],
    );
  }
}
