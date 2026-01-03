// Trang hiển thị Tủ Đồ Cộng Đồng.
// Cho phép xem, lọc và thêm món đồ mới.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/repositories/wardrobe_repository.dart';
import '../bloc/wardrobe_bloc.dart';
import '../widgets/outfit_suggestion_widget.dart';
import '../../../home/presentation/bloc/weather_bloc.dart';

class WardrobePage extends StatelessWidget {
  const WardrobePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          WardrobeBloc(getIt<WardrobeRepository>())
            ..add(const LoadWardrobeItems()),
      child: const WardrobeView(),
    );
  }
}

class WardrobeView extends StatefulWidget {
  const WardrobeView({super.key});

  @override
  State<WardrobeView> createState() => _WardrobeViewState();
}

class _WardrobeViewState extends State<WardrobeView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const List<String> categories = [
    'Tất cả',
    'T-Shirt',
    'Hoodie',
    'Jacket',
    'Jeans',
    'Shorts',
    'Dress',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tủ Đồ Cộng Đồng'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.checkroom), text: 'Tủ đồ'),
            Tab(icon: Icon(Icons.auto_awesome), text: 'Gợi ý AI'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Tủ đồ
          Column(
            children: [
              _buildCategoryFilter(context),
              Expanded(child: _buildClothingGrid(context)),
            ],
          ),
          // Tab 2: Gợi ý AI
          _buildAISuggestionTab(context),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await context.push('/wardrobe/add');
          if (result == true && context.mounted) {
            context.read<WardrobeBloc>().add(const LoadWardrobeItems());
          }
        },
        icon: const Icon(Icons.add_a_photo),
        label: const Text('Đóng góp'),
      ),
    );
  }

  Widget _buildAISuggestionTab(BuildContext context) {
    // Lấy thời tiết thực từ WeatherBloc
    final weatherBloc = getIt<WeatherBloc>();
    final weatherState = weatherBloc.state;

    // Lấy nhiệt độ và weather code thực
    final double temperature = weatherState.weather?.temperature ?? 25.0;
    final int weatherCode = weatherState.weather?.weatherCode ?? 0;
    final String? locationName = weatherState.weather?.locationName;

    return BlocBuilder<WardrobeBloc, WardrobeState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info_outline, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Chưa có đồ trong tủ',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                const Text('Hãy đóng góp đồ để nhận gợi ý!'),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              // Hiển thị thông tin thời tiết hiện tại
              if (locationName != null)
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade400, Colors.blue.shade600],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.white),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          locationName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        '${temperature.round()}°C',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

              // Widget gợi ý outfit
              OutfitSuggestionWidget(
                temperature: temperature,
                weatherCode: weatherCode,
                allItems: state.items,
                favoriteIds: state.favoriteIds,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryFilter(BuildContext context) {
    return BlocBuilder<WardrobeBloc, WardrobeState>(
      builder: (context, state) {
        return Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected =
                  (state.selectedCategory == null && index == 0) ||
                  state.selectedCategory == (index == 0 ? null : category);

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (_) {
                    context.read<WardrobeBloc>().add(
                      FilterByCategory(index == 0 ? null : category),
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildClothingGrid(BuildContext context) {
    return BlocBuilder<WardrobeBloc, WardrobeState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Lỗi: ${state.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<WardrobeBloc>().add(const LoadWardrobeItems());
                  },
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        }

        if (state.items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.checkroom, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Chưa có món đồ nào',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  'Hãy là người đầu tiên đóng góp!',
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            context.read<WardrobeBloc>().add(
              LoadWardrobeItems(category: state.selectedCategory),
            );
          },
          child: GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: state.items.length,
            itemBuilder: (context, index) {
              final item = state.items[index];
              return _ClothingCard(
                item: item,
                isFavorite: state.favoriteIds.contains(item.id),
              );
            },
          ),
        );
      },
    );
  }
}

class _ClothingCard extends StatelessWidget {
  final dynamic item;
  final bool isFavorite;

  const _ClothingCard({required this.item, required this.isFavorite});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Ảnh
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: item.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  placeholder: (_, __) => Container(
                    color: Colors.grey[200],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    color: Colors.grey[200],
                    child: Icon(
                      Icons.image_not_supported,
                      color: Colors.grey[400],
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getWarmthColor(item.warmthLevel),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${item.warmthLevel}/10',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: GestureDetector(
                    onTap: () {},
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.white,
                      shadows: const [Shadow(blurRadius: 4)],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Thông tin
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${item.category} • ${item.style}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getWarmthColor(int level) {
    if (level <= 3) return Colors.blue;
    if (level <= 6) return Colors.orange;
    return Colors.red;
  }
}
