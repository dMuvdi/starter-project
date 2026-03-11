import 'package:news_app_clean_architecture/core/config/env_config.dart';

const String newsAPIBaseURL = 'https://newsapi.org/v2';

/// API key from environment variable, with fallback for development
String get newsAPIKey => EnvConfig.newsApiKey.isNotEmpty
    ? EnvConfig.newsApiKey
    : '344e0a0ca5fb4898aaa44edd24855f29'; // fallback for dev
const String countryQuery = 'us';
const String categoryQuery = 'general';
const String kDefaultImage =
    "https://www.google.com/search?q=default+image&client=firefox-b-d&sxsrf=APq-WBskmtr-ix6NUAqqiHFNpsJX6JSOTg:1650026644151&source=lnms&tbm=isch&sa=X&ved=2ahUKEwjEi_qfjJb3AhXvQd8KHd02BKUQ_AUoAXoECAEQAw#imgrc=A0pMe2lq2NT_jM";
