// DataSource kết nối với Firebase Firestore.
// Thực hiện các thao tác CRUD trên collection global_wardrobe và users.

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/clothing_item_model.dart';

abstract class WardrobeRemoteDataSource {
  Future<List<ClothingItemModel>> getWardrobeItems({String? category});
  Future<ClothingItemModel> addClothingItem(ClothingItemModel item);
  Future<List<String>> getUserFavorites(String userId);
  Future<void> toggleFavorite(String userId, String itemId);
}

class WardrobeRemoteDataSourceImpl implements WardrobeRemoteDataSource {
  final FirebaseFirestore _firestore;

  WardrobeRemoteDataSourceImpl(this._firestore);

  @override
  Future<List<ClothingItemModel>> getWardrobeItems({String? category}) async {
    // Lấy tất cả items, sắp xếp theo createdAt
    final snapshot = await _firestore
        .collection('global_wardrobe')
        .orderBy('createdAt', descending: true)
        .get();

    var items = snapshot.docs
        .map((doc) => ClothingItemModel.fromFirestore(doc))
        .toList();

    // Filter theo category ở phía client (tránh cần composite index)
    if (category != null && category.isNotEmpty) {
      items = items.where((item) => item.category == category).toList();
    }

    return items;
  }

  @override
  Future<ClothingItemModel> addClothingItem(ClothingItemModel item) async {
    final docRef = await _firestore
        .collection('global_wardrobe')
        .add(item.toFirestore());
    return item.copyWith(id: docRef.id);
  }

  @override
  Future<List<String>> getUserFavorites(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists && doc.data() != null) {
      final data = doc.data()!;
      return List<String>.from(data['favoriteItems'] ?? []);
    }
    return [];
  }

  @override
  Future<void> toggleFavorite(String userId, String itemId) async {
    final docRef = _firestore.collection('users').doc(userId);
    final doc = await docRef.get();

    if (doc.exists) {
      final favorites = List<String>.from(doc.data()?['favoriteItems'] ?? []);
      if (favorites.contains(itemId)) {
        favorites.remove(itemId);
      } else {
        favorites.add(itemId);
      }
      await docRef.update({'favoriteItems': favorites});
    } else {
      // Tạo document mới nếu chưa tồn tại
      await docRef.set({
        'favoriteItems': [itemId],
      });
    }
  }
}
