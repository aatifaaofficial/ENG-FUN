// ignore_for_file: deprecated_member_use, use_super_parameters, avoid_print

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:englishfun/models/vocabulary_model.dart';
import 'package:englishfun/core/constants/app_constants.dart';
import 'package:englishfun/navigation/app_router.dart';

class VocabularyDetailScreen extends StatefulWidget {
  final String vocabularyId;

  const VocabularyDetailScreen({
    Key? key,
    required this.vocabularyId,
  }) : super(key: key);

  @override
  State<VocabularyDetailScreen> createState() => _VocabularyDetailScreenState();
}

class _VocabularyDetailScreenState extends State<VocabularyDetailScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  VocabularyModel? _vocabulary;
  bool _isLoading = true;
  bool _isFavoriteLoading = false;
  String? _errorMessage;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _fetchVocabularyDetails();
    _checkIfFavorite();
  }

  Future<void> _fetchVocabularyDetails() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final response = await _supabase
          .from('vocabulary')
          .select()
          .eq('id', widget.vocabularyId)
          .maybeSingle();

      if (response != null) {
        setState(() {
          _vocabulary = VocabularyModel.fromJson(response);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = "Vocabulary data not found.";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error loading data: $e";
        _isLoading = false;
      });
    }
  }

  Future<void> _checkIfFavorite() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final response = await _supabase
          .from('user_favorites')
          .select()
          .eq('user_id', userId)
          .eq('vocabulary_id', widget.vocabularyId)
          .maybeSingle();

      if (response != null && mounted) {
        setState(() => _isFavorite = true);
      }
    } catch (e) {
      print('Error checking favorite: $e');
    }
  }

  Future<void> _toggleFavorite() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login first.')),
      );
      return;
    }

    if (_isFavoriteLoading) return;

    setState(() => _isFavoriteLoading = true);

    try {
      if (_isFavorite) {
        await _supabase
            .from('user_favorites')
            .delete()
            .eq('user_id', userId)
            .eq('vocabulary_id', widget.vocabularyId);
        if (mounted) setState(() => _isFavorite = false);
      } else {
        await _supabase.from('user_favorites').insert({
          'user_id': userId,
          'vocabulary_id': widget.vocabularyId,
        });
        if (mounted) setState(() => _isFavorite = true);
      }
    } catch (e) {
      print('Error toggling favorite: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update favorite: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isFavoriteLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vocabulary Detail'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(AppRouter.home),
        ),
        actions: [
          if (_vocabulary != null)
            IconButton(
              icon: _isFavoriteLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                    ),
              color: _isFavorite ? Colors.red : null,
              onPressed: _toggleFavorite,
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0D47A1)),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacing20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchVocabularyDetails,
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }

    if (_vocabulary == null) return const SizedBox.shrink();

    final vocab = _vocabulary!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Word Header Card
          Card(
            color: const Color(0xFF0D47A1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spacing16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          vocab.word,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(
                                    AppConstants.radiusSmall),
                              ),
                              child: Text(
                                vocab.partOfSpeech,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(
                                    AppConstants.radiusSmall),
                              ),
                              child: Text(
                                vocab.level,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Meaning Section
          const Text(
            'Meaning',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spacing16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vocab.meaning,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '(Bangla) ${vocab.bangla}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.blue[800],
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Synonyms Section
          if (vocab.synonyms.isNotEmpty) ...[
            const Text(
              'Synonyms',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: vocab.synonyms.map((synonym) {
                return Chip(
                  label: Text(synonym),
                  backgroundColor: Colors.blue.withOpacity(0.1),
                  side: BorderSide.none,
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],

          // Examples Section
          if (vocab.examples.isNotEmpty) ...[
            const Text(
              'Examples',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: vocab.examples.map((example) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Card(
                    color: const Color(0xFFF5F7FA),
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(AppConstants.spacing12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Expanded(
                            child: Text(
                              example,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(height: 1.3),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _toggleFavorite,
                  icon: Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border),
                  label: Text(_isFavorite
                      ? 'Remove from Favorites'
                      : 'Add to Favorites'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _isFavorite ? Colors.red[100] : Colors.grey[300],
                    foregroundColor:
                        _isFavorite ? Colors.red[900] : Colors.black87,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to practice for this vocabulary (optional)
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Practice feature coming soon!')),
                    );
                  },
                  child: const Text('Practice'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
