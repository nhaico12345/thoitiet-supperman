// Màn hình quản lý vị trí yêu thích.
// Cho phép tìm kiếm, thêm, xóa vị trí và sử dụng GPS lấy vị trí hiện tại.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../bloc/location_bloc.dart';
import '../../domain/entities/location.dart';

class LocationsPage extends StatelessWidget {
  const LocationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LocationBloc>(
      create: (context) =>
          getIt<LocationBloc>()..add(const LoadSavedLocations()),
      child: const LocationsView(),
    );
  }
}

class LocationsView extends StatefulWidget {
  const LocationsView({super.key});

  @override
  State<LocationsView> createState() => _LocationsViewState();
}

class _LocationsViewState extends State<LocationsView> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final hintColor = isDark ? Colors.white70 : Colors.black54;
    final cursorColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? Theme(
                data: Theme.of(context).copyWith(
                  textSelectionTheme: TextSelectionThemeData(
                    cursorColor: cursorColor,
                    selectionColor: isDark ? Colors.white24 : Colors.black12,
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm thành phố...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: hintColor),
                  ),
                  style: TextStyle(color: textColor),
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      context.read<LocationBloc>().add(SearchLocation(value));
                    }
                  },
                ),
              )
            : const Text('Quản lý vị trí'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.add),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchController.clear();
                  context.read<LocationBloc>().add(const LoadSavedLocations());
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Current Location Button
          Container(
            margin: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.5)),
            ),
            child: ListTile(
              leading: const Icon(Icons.my_location, color: Colors.blue),
              title: const Text(
                'Sử dụng vị trí hiện tại',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              subtitle: const Text('Tự động xác định qua GPS'),
              onTap: () {
                context.read<LocationBloc>().add(
                  const GetCurrentLocationEvent(),
                );
              },
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Địa điểm đã lưu',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
          Expanded(
            child: BlocConsumer<LocationBloc, LocationState>(
              listener: (context, state) {
                if (state is LocationSelected) {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/');
                  }
                }
                if (state is LocationError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.error.toString())),
                  );
                }
              },
              builder: (context, state) {
                if (state is LocationLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is LocationSearchSuccess) {
                  return _buildSearchResults(context, state.searchResults);
                }
                if (state is LocationLoaded) {
                  return _buildSavedLocations(context, state.savedLocations);
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(
    BuildContext context,
    List<LocationEntity> results,
  ) {
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final location = results[index];
        return ListTile(
          title: Text(location.name),
          subtitle: Text(location.country ?? ''),
          trailing: IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              context.read<LocationBloc>().add(AddLocation(location));
              // Also select it?
              context.read<LocationBloc>().add(SelectLocation(location));
            },
          ),
          onTap: () {
            context.read<LocationBloc>().add(SelectLocation(location));
          },
        );
      },
    );
  }

  Widget _buildSavedLocations(
    BuildContext context,
    List<LocationEntity> locations,
  ) {
    if (locations.isEmpty) {
      return const Center(child: Text('Chưa có địa điểm nào được lưu.'));
    }
    return ListView.builder(
      itemCount: locations.length,
      itemBuilder: (context, index) {
        final location = locations[index];
        return Dismissible(
          key: Key('${location.name}_${location.country}'),
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          direction: DismissDirection.endToStart,
          onDismissed: (direction) {
            context.read<LocationBloc>().add(RemoveLocation(location));
          },
          child: ListTile(
            title: Text(location.name),
            subtitle: Text(location.country ?? ''),
            onTap: () {
              context.read<LocationBloc>().add(SelectLocation(location));
            },
          ),
        );
      },
    );
  }
}
