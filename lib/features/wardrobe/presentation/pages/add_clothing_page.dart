// Trang thêm món đồ mới vào tủ đồ cộng đồng.
// Bao gồm form nhập thông tin và chọn ảnh từ camera/gallery.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/entities/clothing_item.dart';
import '../../domain/repositories/wardrobe_repository.dart';
import '../../../../core/resources/data_state.dart';

class AddClothingPage extends StatefulWidget {
  const AddClothingPage({super.key});

  @override
  State<AddClothingPage> createState() => _AddClothingPageState();
}

class _AddClothingPageState extends State<AddClothingPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  File? _selectedImage;
  String _category = 'T-Shirt';
  int _warmthLevel = 5;
  String _material = 'cotton';
  String _style = 'casual';
  String _gender = 'unisex';
  bool _isSubmitting = false;

  static const List<String> categories = [
    'T-Shirt',
    'Hoodie',
    'Jacket',
    'Jeans',
    'Shorts',
    'Dress',
    'Sweater',
    'Coat',
  ];

  static const List<String> materials = [
    'cotton',
    'polyester',
    'wool',
    'denim',
    'leather',
    'nylon',
  ];

  static const List<String> styles = [
    'casual',
    'formal',
    'streetwear',
    'sporty',
    'vintage',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi chọn ảnh: $e')));
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Chụp ảnh'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Chọn từ thư viện'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ảnh cho món đồ')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final item = ClothingItem(
        id: '',
        name: _nameController.text.trim(),
        category: _category,
        warmthLevel: _warmthLevel,
        imageUrl: '',
        material: _material,
        style: _style,
        gender: _gender,
        contributedBy: 'anonymous',
        createdAt: DateTime.now(),
      );

      // Gọi trực tiếp WardrobeRepository từ DI
      final repository = getIt<WardrobeRepository>();
      final result = await repository.addClothingItem(item, _selectedImage);

      if (mounted) {
        setState(() => _isSubmitting = false);

        if (result is DataSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã đóng góp món đồ thành công! 🎉'),
              backgroundColor: Colors.green,
            ),
          );
          context.pop(true); // Trả về true để WardrobePage reload
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Lỗi: ${result.error?.toString() ?? "Không xác định"}',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đóng Góp Món Đồ'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isSubmitting
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Đang upload ảnh...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Image picker
                    _buildImagePicker(),
                    const SizedBox(height: 24),

                    // Tên món đồ
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Tên món đồ *',
                        hintText: 'Ví dụ: Áo hoodie xám',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.edit),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập tên món đồ';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Loại đồ
                    _buildDropdown(
                      label: 'Loại đồ',
                      value: _category,
                      items: categories,
                      icon: Icons.category,
                      onChanged: (v) => setState(() => _category = v!),
                    ),
                    const SizedBox(height: 16),

                    // Độ giữ nhiệt
                    _buildWarmthSlider(),
                    const SizedBox(height: 16),

                    // Chất liệu
                    _buildDropdown(
                      label: 'Chất liệu',
                      value: _material,
                      items: materials,
                      icon: Icons.texture,
                      onChanged: (v) => setState(() => _material = v!),
                    ),
                    const SizedBox(height: 16),

                    // Phong cách
                    _buildStyleChips(),
                    const SizedBox(height: 16),

                    // Giới tính
                    _buildGenderChips(),
                    const SizedBox(height: 32),

                    // Submit button
                    ElevatedButton.icon(
                      onPressed: _submitForm,
                      icon: const Icon(Icons.upload),
                      label: const Text('ĐÓNG GÓP'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _showImageSourceDialog,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[400]!),
        ),
        child: _selectedImage != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(_selectedImage!, fit: BoxFit.cover),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black54,
                        ),
                        onPressed: () => setState(() => _selectedImage = null),
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo, size: 48, color: Colors.grey[500]),
                  const SizedBox(height: 8),
                  Text(
                    'Nhấn để chọn ảnh *',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required IconData icon,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
      items: items.map((item) {
        return DropdownMenuItem(value: item, child: Text(item));
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildWarmthSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.thermostat, color: Colors.grey),
            const SizedBox(width: 8),
            const Text('Độ giữ nhiệt'),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: _getWarmthColor(_warmthLevel),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$_warmthLevel/10',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        Slider(
          value: _warmthLevel.toDouble(),
          min: 1,
          max: 10,
          divisions: 9,
          label: _getWarmthLabel(_warmthLevel),
          onChanged: (v) => setState(() => _warmthLevel = v.round()),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Mỏng',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            Text(
              'Dày/Ấm',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStyleChips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.style, color: Colors.grey),
            SizedBox(width: 8),
            Text('Phong cách'),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: styles.map((s) {
            final isSelected = _style == s;
            return ChoiceChip(
              label: Text(s),
              selected: isSelected,
              onSelected: (_) => setState(() => _style = s),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildGenderChips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.people, color: Colors.grey),
            SizedBox(width: 8),
            Text('Dành cho'),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: ['male', 'female', 'unisex'].map((g) {
            final isSelected = _gender == g;
            final label = g == 'male'
                ? 'Nam'
                : g == 'female'
                ? 'Nữ'
                : 'Unisex';
            return ChoiceChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (_) => setState(() => _gender = g),
            );
          }).toList(),
        ),
      ],
    );
  }

  Color _getWarmthColor(int level) {
    if (level <= 3) return Colors.blue;
    if (level <= 6) return Colors.orange;
    return Colors.red;
  }

  String _getWarmthLabel(int level) {
    if (level <= 3) return 'Mát/Mỏng';
    if (level <= 6) return 'Trung bình';
    return 'Ấm/Dày';
  }
}
