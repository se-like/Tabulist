class Subject {
  final String id;
  final String name;
  final String? description;
  final int? color;

  Subject({
    required this.id,
    required this.name,
    this.description,
    this.color,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'color': color,
    };
  }

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      color: json['color'],
    );
  }
}

class Teacher {
  final String id;
  final String name;
  final String? email;
  final String? phone;

  Teacher({
    required this.id,
    required this.name,
    this.email,
    this.phone,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
    };
  }

  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
    );
  }
}

class Room {
  final String id;
  final String name;
  final String? building;
  final int? floor;
  final int? capacity;

  Room({
    required this.id,
    required this.name,
    this.building,
    this.floor,
    this.capacity,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'building': building,
      'floor': floor,
      'capacity': capacity,
    };
  }

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'],
      name: json['name'],
      building: json['building'],
      floor: json['floor'],
      capacity: json['capacity'],
    );
  }
} 