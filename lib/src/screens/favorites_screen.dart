import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:convert';
import '../core/widgets/responsive_media_grid.dart';
import '../models/media_item.dart';
import '../utils/storage_utils.dart';
import '../widgets/media_card.dart';
import '../screens/single_movie_screen.dart';
import '../screens/single_series_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<MediaItemWithTimestamp> _favorites = [];
  bool _isLoading = true;
  String _selectedType = 'all'; // 'all', 'movie', 'series'

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final favorites = await StorageUtils.loadFavoritesWithTimestamp();
      setState(() {
        _favorites = favorites;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('خطا در بارگذاری علاقه‌مندی‌ها')),
        );
      }
    }
  }

  List<MediaItemWithTimestamp> get _filteredFavorites {
    if (_selectedType == 'movie') {
      return _favorites.where((f) => f.mediaItem.type == 'movie').toList();
    }
    if (_selectedType == 'series') {
      return _favorites.where((f) => f.mediaItem.type != 'movie').toList();
    }
    return _favorites;
  }

  Widget _buildTypePill(String label, String type) {
    final isSelected = _selectedType == type;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => _selectedType = type),
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFE50914)
                : isDarkMode
                ? const Color(0xFF171924)
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFFE50914)
                  : isDarkMode
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.08),
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.vazirmatn(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected
                  ? Colors.white
                  : isDarkMode
                  ? const Color(0xFFA0A3B1)
                  : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _clearAllFavorites() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'حذف همه علاقه‌مندی‌ها',
          style: GoogleFonts.vazirmatn(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'آیا از حذف همه علاقه‌مندی‌ها اطمینان دارید؟',
          style: GoogleFonts.vazirmatn(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('لغو', style: GoogleFonts.vazirmatn()),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'حذف',
              style: GoogleFonts.vazirmatn(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await StorageUtils.clearAllFavorites();
        setState(() {
          _favorites = [];
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('همه علاقه‌مندی‌ها حذف شدند')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('خطا در حذف علاقه‌مندی‌ها')),
          );
        }
      }
    }
  }

  Future<void> _exportFavorites() async {
    try {
      // Get favorites data
      final favorites = await StorageUtils.loadFavoritesWithTimestamp();

      // Convert to JSON
      final jsonData = favorites.map((item) => item.toJson()).toList();
      final jsonString = jsonEncode(jsonData);

      // Open file picker for save location
      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'ذخیره علاقه‌مندی‌ها',
        fileName: 'favorites.json',
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        // Write to file
        final file = File(result);
        await file.writeAsString(jsonString);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('علاقه‌مندی‌ها با موفقیت ذخیره شدند')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('خطا در ذخیره علاقه‌مندی‌ها')),
        );
      }
    }
  }

  Future<void> _importFavorites() async {
    try {
      // Open file picker for selecting file
      final result = await FilePicker.platform.pickFiles(
        dialogTitle: 'انتخاب فایل علاقه‌مندی‌ها',
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        // Read file content
        final file = File(result.files.single.path!);
        final jsonString = await file.readAsString();
        final jsonData = jsonDecode(jsonString) as List<dynamic>;

        // Convert JSON to MediaItem objects
        final importedFavorites = jsonData
            .map((item) => MediaItem.fromJson(item as Map<String, dynamic>))
            .toList();

        // Clear existing favorites and save imported ones
        await StorageUtils.clearAllFavorites();
        for (final item in importedFavorites) {
          await StorageUtils.addToFavorites(item);
        }

        // Reload favorites
        await _loadFavorites();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${importedFavorites.length} علاقه‌مندی با موفقیت بارگذاری شد',
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('خطا در بارگذاری علاقه‌مندی‌ها')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(8, 20, 8, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                children: [
                  Text(
                    'علاقه‌مندی‌ها',
                    style: GoogleFonts.vazirmatn(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (_favorites.isNotEmpty)
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      onSelected: (value) {
                        switch (value) {
                          case 'export':
                            _exportFavorites();
                            break;
                          case 'import':
                            _importFavorites();
                            break;
                          case 'delete_all':
                            _clearAllFavorites();
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'export',
                          child: Row(
                            children: [
                              const Icon(Icons.upload_file, size: 20),
                              const SizedBox(width: 10),
                              Text(
                                'ذخیره علاقه‌مندی‌ها',
                                style: GoogleFonts.vazirmatn(),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'import',
                          child: Row(
                            children: [
                              const Icon(Icons.file_download, size: 20),
                              const SizedBox(width: 10),
                              Text(
                                'بارگذاری علاقه‌مندی‌ها',
                                style: GoogleFonts.vazirmatn(),
                              ),
                            ],
                          ),
                        ),
                        const PopupMenuDivider(),
                        PopupMenuItem(
                          value: 'delete_all',
                          child: Row(
                            children: [
                              const Icon(Icons.delete_forever, size: 20),
                              const SizedBox(width: 10),
                              Text('حذف همه', style: GoogleFonts.vazirmatn()),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Cinevex Filter Pills (همه، فیلم‌ها، سریال‌ها)
            if (_favorites.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  children: [
                    _buildTypePill('همه (${_favorites.length})', 'all'),
                    const SizedBox(width: 10),
                    _buildTypePill(
                      'فیلم (${_favorites.where((f) => f.mediaItem.type == 'movie').length})',
                      'movie',
                    ),
                    const SizedBox(width: 10),
                    _buildTypePill(
                      'سریال (${_favorites.where((f) => f.mediaItem.type != 'movie').length})',
                      'series',
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            // Favorites grid
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredFavorites.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.favorite_border,
                            size: 64,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'علاقه‌مندی‌ای یافت نشد',
                            style: GoogleFonts.vazirmatn(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'فیلم‌ها و سریال‌های مورد علاقه خود را اضافه کنید',
                            style: GoogleFonts.vazirmatn(
                              fontSize: 16,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.color,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton.icon(
                                onPressed: _importFavorites,
                                icon: const Icon(Icons.file_download),
                                label: Text(
                                  'بارگذاری علاقه‌مندی‌ها',
                                  style: GoogleFonts.vazirmatn(),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  : ResponsiveMediaGrid(
                      itemCount: _filteredFavorites.length,
                      itemBuilder: (context, index) {
                        final mediaItem = _filteredFavorites[index].mediaItem;
                        return MediaCard(
                          mediaItem: mediaItem,
                          showFavoriteButton: false,
                          onTap: () async {
                            if (mediaItem.type == 'movie') {
                              if (context.mounted) {
                                await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        SingleMovieScreen(movie: mediaItem),
                                  ),
                                );
                                _loadFavorites();
                              }
                            } else if (mediaItem.type == 'serie' ||
                                mediaItem.type == 'series') {
                              if (context.mounted) {
                                await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        SingleSeriesScreen(series: mediaItem),
                                  ),
                                );
                                _loadFavorites();
                              }
                            }
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
