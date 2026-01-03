// Entity đại diện cho một món đồ trong tủ đồ cộng đồng.
// Bao gồm thông tin về loại, độ ấm, chất liệu, phong cách.

import 'package:equatable/equatable.dart';

class ClothingItem extends Equatable {
  final String id;
  final String name;
  final String category;
  final int warmthLevel;
  final String imageUrl;
  final String material;
  final String style;
  final String gender;
  final String contributedBy;
  final DateTime createdAt;

  const ClothingItem({
    required this.id,
    required this.name,
    required this.category,
    required this.warmthLevel,
    required this.imageUrl,
    required this.material,
    required this.style,
    required this.gender,
    required this.contributedBy,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    category,
    warmthLevel,
    imageUrl,
    material,
    style,
    gender,
    contributedBy,
    createdAt,
  ];
}
