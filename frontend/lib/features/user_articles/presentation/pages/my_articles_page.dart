import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/user_article.dart';
import '../bloc/user_articles/user_articles_bloc.dart';
import '../bloc/user_articles/user_articles_event.dart';
import '../bloc/user_articles/user_articles_state.dart';

class MyArticlesPage extends StatefulWidget {
  const MyArticlesPage({Key? key}) : super(key: key);

  @override
  State<MyArticlesPage> createState() => _MyArticlesPageState();
}

class _MyArticlesPageState extends State<MyArticlesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      final filter = [
        ArticleFilter.all,
        ArticleFilter.published,
        ArticleFilter.drafts,
      ][_tabController.index];

      context.read<UserArticlesBloc>().add(FilterArticles(filter: filter));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: BlocConsumer<UserArticlesBloc, UserArticlesState>(
        listener: (context, state) {
          if (state is UserArticlesActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage),
                backgroundColor: Colors.green,
              ),
            );
          }
          if (state is UserArticlesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'An error occurred'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is UserArticlesLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is UserArticlesLoaded ||
              state is UserArticlesActionInProgress) {
            final articles = state.filteredArticles ?? [];
            return _buildArticlesList(articles);
          }

          if (state is UserArticlesError) {
            return _buildErrorState(state.errorMessage);
          }

          return _buildEmptyState();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/ArticleEditor');
        },
        backgroundColor: const Color(0xFF3B5BDB),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'My Articles',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.black),
          onPressed: () {
            // TODO: Implement search
          },
        ),
      ],
      bottom: TabBar(
        controller: _tabController,
        labelColor: const Color(0xFF3B5BDB),
        unselectedLabelColor: Colors.grey[600],
        indicatorColor: const Color(0xFF3B5BDB),
        indicatorWeight: 3,
        tabs: const [
          Tab(text: 'Saved'),
          Tab(text: 'Published'),
          Tab(text: 'Drafts'),
        ],
      ),
    );
  }

  Widget _buildArticlesList(List<UserArticleEntity> articles) {
    if (articles.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<UserArticlesBloc>().add(const RefreshUserArticles());
      },
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: articles.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          return _ArticleListItem(
            article: articles[index],
            onTap: () => _onArticleTap(articles[index]),
            onDelete: () => _onDeleteArticle(articles[index]),
            onPublish: articles[index].isDraft
                ? () => _onPublishArticle(articles[index])
                : null,
          );
        },
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
            'Start writing your first article!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/ArticleEditor');
            },
            icon: const Icon(Icons.add),
            label: const Text('Create Article'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B5BDB),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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
              context.read<UserArticlesBloc>().add(const RefreshUserArticles());
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  void _onArticleTap(UserArticleEntity article) {
    if (article.isDraft) {
      Navigator.pushNamed(context, '/ArticleEditor', arguments: article);
    } else {
      Navigator.pushNamed(context, '/UserArticleDetail', arguments: article);
    }
  }

  void _onDeleteArticle(UserArticleEntity article) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Article'),
        content: const Text('Are you sure you want to delete this article?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<UserArticlesBloc>().add(
                    DeleteArticle(articleId: article.id!),
                  );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _onPublishArticle(UserArticleEntity article) {
    context.read<UserArticlesBloc>().add(
          PublishArticle(articleId: article.id!),
        );
  }
}

class _ArticleListItem extends StatelessWidget {
  final UserArticleEntity article;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback? onPublish;

  const _ArticleListItem({
    required this.article,
    required this.onTap,
    required this.onDelete,
    this.onPublish,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImage(),
            const SizedBox(width: 12),
            Expanded(child: _buildContent()),
            _buildStatusBadge(),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 80,
        height: 80,
        color: Colors.grey[200],
        child: article.thumbnailUrl != null
            ? CachedNetworkImage(
                imageUrl: article.thumbnailUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                errorWidget: (context, url, error) => Icon(
                  Icons.image_outlined,
                  color: Colors.grey[400],
                ),
              )
            : Icon(
                Icons.image_outlined,
                color: Colors.grey[400],
                size: 32,
              ),
      ),
    );
  }

  Widget _buildContent() {
    final timeAgo = _formatTimeAgo(
        article.updatedAt ?? article.createdAt ?? DateTime.now());
    final readTime = _calculateReadTime(article.content);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          article.title ?? '',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Text(
          article.isDraft
              ? 'Edited $timeAgo • Draft'
              : 'Saved $timeAgo • $readTime min read',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: article.isDraft
            ? Colors.grey[200]
            : const Color(0xFF3B5BDB).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        article.isDraft ? 'DRAFT' : 'READ',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: article.isDraft ? Colors.grey[700] : const Color(0xFF3B5BDB),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return '${(difference.inDays / 7).floor()} week${difference.inDays > 14 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  int _calculateReadTime(String? content) {
    if (content == null || content.isEmpty) return 1;
    final wordCount = content.split(RegExp(r'\s+')).length;
    return (wordCount / 200).ceil().clamp(1, 99);
  }
}
