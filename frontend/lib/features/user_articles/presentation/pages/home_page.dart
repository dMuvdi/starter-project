import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/user_article.dart';
import '../bloc/user_articles/user_articles_bloc.dart';
import '../bloc/user_articles/user_articles_event.dart';
import '../bloc/user_articles/user_articles_state.dart';
import '../widgets/featured_article_card.dart';
import '../widgets/article_list_card.dart';
import '../widgets/category_widgets.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart' as auth;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> _categories = [
    'For You',
    'Trending',
    'World',
    'Tech',
    'Politics',
    'Sports',
    'Business',
    'Science',
  ];
  String _selectedCategory = 'For You';
  int _selectedNavIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load published articles
    context.read<UserArticlesBloc>().add(const LoadPublishedArticles());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _selectedNavIndex,
          children: [
            _buildHomeFeed(),
            _buildMyArticlesPlaceholder(),
            _buildProfilePlaceholder(),
          ],
        ),
      ),
      floatingActionButton: _selectedNavIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, '/ArticleEditor');
              },
              backgroundColor: const Color(0xFF3B5BDB),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHomeFeed() {
    return Column(
      children: [
        _buildHeader(),
        _buildSearchBar(),
        const SizedBox(height: 16),
        CategoryTabBar(
          categories: _categories,
          selectedCategory: _selectedCategory,
          onCategorySelected: (category) {
            setState(() {
              _selectedCategory = category;
            });
            if (category == 'For You') {
              context
                  .read<UserArticlesBloc>()
                  .add(const LoadPublishedArticles());
            } else {
              context.read<UserArticlesBloc>().add(
                    LoadArticlesByCategory(category: category),
                  );
            }
          },
        ),
        const SizedBox(height: 16),
        Expanded(
          child: BlocBuilder<UserArticlesBloc, UserArticlesState>(
            builder: (context, state) {
              if (state is UserArticlesLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is UserArticlesLoaded) {
                final articles = state.articles ?? [];
                if (articles.isEmpty) {
                  return _buildEmptyState();
                }
                return _buildArticlesList(articles);
              }

              if (state is UserArticlesError) {
                return _buildErrorState(state.errorMessage);
              }

              return _buildEmptyState();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF3B5BDB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.article_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Daily News',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              // TODO: Notifications
            },
            icon: const Icon(Icons.notifications_outlined),
          ),
          BlocBuilder<AuthBloc, auth.AuthState>(
            builder: (context, state) {
              if (state is auth.Authenticated && state.user?.photoUrl != null) {
                return GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/Profile'),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundImage: CachedNetworkImageProvider(
                      state.user!.photoUrl!,
                    ),
                  ),
                );
              }
              return GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/Profile'),
                child: const CircleAvatar(
                  radius: 18,
                  backgroundColor: Color(0xFFF5C9A0),
                  child: Icon(Icons.person, color: Colors.white, size: 20),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Icon(Icons.search, color: Colors.grey[500]),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search news, topics, and more...',
                  hintStyle: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArticlesList(List<UserArticleEntity> articles) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<UserArticlesBloc>().add(const LoadPublishedArticles());
      },
      child: CustomScrollView(
        slivers: [
          // Featured article (first article)
          if (articles.isNotEmpty)
            SliverToBoxAdapter(
              child: FeaturedArticleCard(
                article: articles.first,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/UserArticleDetail',
                    arguments: articles.first,
                  );
                },
              ),
            ),
          // Top Stories header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Top Stories',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: View all
                    },
                    child: const Text(
                      'View All',
                      style: TextStyle(
                        color: Color(0xFF3B5BDB),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Article list
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                // Skip the first article (featured)
                final articleIndex = index + 1;
                if (articleIndex >= articles.length) {
                  return null;
                }
                return Column(
                  children: [
                    ArticleListCard(
                      article: articles[articleIndex],
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/UserArticleDetail',
                          arguments: articles[articleIndex],
                        );
                      },
                    ),
                    if (articleIndex < articles.length - 1)
                      const Divider(height: 1, indent: 16, endIndent: 16),
                  ],
                );
              },
              childCount: articles.length > 1 ? articles.length - 1 : 0,
            ),
          ),
          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 80),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.article_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No articles yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to publish an article!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String? message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            message ?? 'Something went wrong',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () {
              context
                  .read<UserArticlesBloc>()
                  .add(const LoadPublishedArticles());
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildMyArticlesPlaceholder() {
    // This will be replaced by actual navigation
    return const Center(
      child: Text('My Articles - Use navigation'),
    );
  }

  Widget _buildProfilePlaceholder() {
    // This will be replaced by actual navigation
    return const Center(
      child: Text('Profile - Use navigation'),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, 'Home', 0),
              _buildNavItem(Icons.bookmark_outline, 'My Articles', 1),
              _buildNavItem(Icons.person_outline, 'Profile', 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedNavIndex == index;

    return GestureDetector(
      onTap: () {
        if (index == 1) {
          Navigator.pushNamed(context, '/MyArticles');
        } else if (index == 2) {
          Navigator.pushNamed(context, '/Profile');
        } else {
          setState(() {
            _selectedNavIndex = index;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? _getFilledIcon(icon) : icon,
              color: isSelected ? const Color(0xFF3B5BDB) : Colors.grey[600],
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? const Color(0xFF3B5BDB) : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getFilledIcon(IconData icon) {
    if (icon == Icons.home) return Icons.home;
    if (icon == Icons.bookmark_outline) return Icons.bookmark;
    if (icon == Icons.person_outline) return Icons.person;
    return icon;
  }
}
