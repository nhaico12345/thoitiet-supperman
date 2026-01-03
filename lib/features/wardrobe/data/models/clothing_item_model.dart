// Model cho ClothingItem với chuyển đổi Firestore.
// Kế thừa từ ClothingItem entity và thêm các phương thức serialize.

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/clothing_item.dart';

class ClothingItemModel extends ClothingItem {
  const ClothingItemModel({
    required super.id,
    required super.name,
    required super.category,
    required super.warmthLevel,
    required super.imageUrl,
    required super.material,
    required super.style,
    required super.gender,
    required super.contributedBy,
    required super.createdAt,
  });

  /// Tạo model từ Firestore DocumentSnapshot
  factory ClothingItemModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ClothingItemModel(
      id: doc.id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      warmthLevel: _parseWarmthLevel(data['warmthLevel']),
      imageUrl: data['imageUrl'] ?? '',
      material: data['material'] ?? 'cotton',
      style: data['style'] ?? 'casual',
      gender: data['gender'] ?? 'unisex',
      contributedBy: data['contributedBy'] ?? '',
      createdAt: _parseDateTime(data['createdAt']),
    );
  }

  static int _parseWarmthLevel(dynamic value) {
    if (value == null) return 5;
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) return int.tryParse(value) ?? 5;
    return 5;
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    if (value is DateTime) return value;
    return DateTime.now();
  }

  Map<String, dynamic> toFirestore() => {
    'name': name,
    'category': category,
    'warmthLevel': warmthLevel,
    'imageUrl': imageUrl,
    'material': material,
    'style': style,
    'gender': gender,
    'contributedBy': contributedBy,
    'createdAt': FieldValue.serverTimestamp(),
  };

  ClothingItemModel copyWith({
    String? id,
    String? name,
    String? category,
    int? warmthLevel,
    String? imageUrl,
    String? material,
    String? style,
    String? gender,
    String? contributedBy,
    DateTime? createdAt,
  }) {
    return ClothingItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      warmthLevel: warmthLevel ?? this.warmthLevel,
      imageUrl: imageUrl ?? this.imageUrl,
      material: material ?? this.material,
      style: style ?? this.style,
      gender: gender ?? this.gender,
      contributedBy: contributedBy ?? this.contributedBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
