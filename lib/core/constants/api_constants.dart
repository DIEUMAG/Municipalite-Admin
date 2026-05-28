class ApiConstants {
  // Switch between local and production
  static const bool isProduction = false; // ← change this

  static const String baseUrl = isProduction
      ? 'https://dieumags.pythonanywhere.com/api'
      : 'http://127.0.0.1:8000/api';
}

// Set isProduction = false when developing locally
// Set isProduction = true before building and deploying