import 'package:mockito/annotations.dart';

// Auth Feature
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';
import 'package:news_app_clean_architecture/features/auth/data/data_sources/remote/auth_remote_data_source.dart';

// User Articles Feature
import 'package:news_app_clean_architecture/features/user_articles/domain/repository/user_article_repository.dart';
import 'package:news_app_clean_architecture/features/user_articles/data/data_sources/remote/article_remote_data_source.dart';
import 'package:news_app_clean_architecture/features/user_articles/data/data_sources/remote/cloudinary_service.dart';

/// Generate mocks for all repository interfaces and data sources.
/// Run: flutter pub run build_runner build --delete-conflicting-outputs
@GenerateMocks([
  // Domain layer repositories (mocked when testing use cases)
  AuthRepository,
  UserArticleRepository,

  // Data layer data sources (mocked when testing repository implementations)
  AuthRemoteDataSource,
  ArticleRemoteDataSource,
  CloudinaryService,
])
void main() {}
