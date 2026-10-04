// ignore_for_file: use_super_parameters, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:englishfun/navigation/app_router.dart';
import 'package:englishfun/core/widgets/custom_widgets.dart';
import 'package:englishfun/core/constants/app_constants.dart';
import 'package:englishfun/core/theme/app_theme.dart';
import 'package:englishfun/services/auth_provider.dart';

class VocabularyListScreen extends ConsumerStatefulWidget {
  const VocabularyListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<VocabularyListScreen> createState() =>
      _VocabularyListScreenState();
}

class _VocabularyListScreenState extends ConsumerState<VocabularyListScreen> {
  late TextEditingController _searchController;
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vocabAsync = ref.watch(
        vocabularyProvider(_selectedFilter == 'All' ? null : _selectedFilter));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vocabulary'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRouter.home),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppConstants.spacing16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search words...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusMedium),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: AppConstants.spacing16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  'All',
                  'Beginner',
                  'Intermediate',
                  'Advanced',
                  'Favorites'
                ].map((filter) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedFilter = filter),
                      child: Chip(
                        label: Text(filter),
                        backgroundColor: _selectedFilter == filter
                            ? AppColors.primary
                            : Colors.grey[300],
                        labelStyle: TextStyle(
                          color: _selectedFilter == filter
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            child: vocabAsync.when(
              data: (vocabList) {
                final filtered = vocabList.where((v) {
                  return v.word
                      .toLowerCase()
                      .contains(_searchController.text.toLowerCase());
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text('No words found'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(AppConstants.spacing16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final word = filtered[index];
                    return GestureDetector(
                      onTap: () =>
                          context.go('${AppRouter.vocabulary}/${word.id}'),
                      child: CustomCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        word.word,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        word.partOfSpeech,
                                        style: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _getLevelColor(word.level),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    word.level,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              word.meaning,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, st) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }

  Color _getLevelColor(String level) {
    switch (level) {
      case 'Beginner':
        return Colors.green;
      case 'Intermediate':
        return Colors.orange;
      case 'Advanced':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}
