import 'dart:convert';
import 'package:http/http.dart' as http;

class IsbnService {
  static Future<Map<String, dynamic>?> fetchBookByIsbn(String isbn) async {
    try {
      // Nettoyer l'ISBN (retirer les tirets et espaces)
      final cleanIsbn = isbn.replaceAll(RegExp(r'[- ]'), '');

      // Essayer d'abord avec l'API Google Books
      final googleBooksResult = await _fetchFromGoogleBooks(cleanIsbn);
      if (googleBooksResult != null) {
        return googleBooksResult;
      }

      // Si Google Books ne fonctionne pas, essayer Open Library
      final openLibraryResult = await _fetchFromOpenLibrary(cleanIsbn);
      return openLibraryResult;
    } catch (e) {
      print('Erreur lors de la récupération du livre: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> _fetchFromGoogleBooks(
      String isbn) async {
    try {
      final url =
          Uri.parse('https://www.googleapis.com/books/v1/volumes?q=isbn:$isbn');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;

        if (data['totalItems'] == 0) {
          return null;
        }

        final item = data['items'][0];
        final volumeInfo = item['volumeInfo'] as Map<String, dynamic>;

        String titre = volumeInfo['title'] ?? '';
        String auteur = '';

        if (volumeInfo.containsKey('authors')) {
          final authors = volumeInfo['authors'] as List;
          auteur = authors.join(', ');
        }

        String thematique = '';
        if (volumeInfo.containsKey('categories')) {
          final categories = volumeInfo['categories'] as List;
          thematique = categories.join(', ');
        }

        String? description;
        if (volumeInfo.containsKey('description')) {
          description = volumeInfo['description'];
          // Nettoyer les balises HTML si présentes
          if (description != null) {
            description = _cleanHtml(description);
          }
        }

        // Si pas de description, essayer d'utiliser le subtitle ou publisher
        if (description == null || description.isEmpty) {
          if (volumeInfo.containsKey('subtitle')) {
            description = volumeInfo['subtitle'];
          } else if (volumeInfo.containsKey('publisher')) {
            description = 'Publié par ${volumeInfo['publisher']}';
            if (volumeInfo.containsKey('publishedDate')) {
              description += ' en ${volumeInfo['publishedDate']}';
            }
          }
        }

        // Récupérer l'URL de la couverture
        String? coverUrl;
        if (volumeInfo.containsKey('imageLinks')) {
          final imageLinks = volumeInfo['imageLinks'] as Map<String, dynamic>;
          // Essayer d'obtenir la meilleure qualité disponible
          coverUrl = imageLinks['large'] ??
              imageLinks['medium'] ??
              imageLinks['small'] ??
              imageLinks['thumbnail'] ??
              imageLinks['smallThumbnail'];
        }

        return {
          'titre': titre,
          'auteur': auteur,
          'thematique': thematique,
          'description': description,
          'coverUrl': coverUrl,
          'isbn': isbn,
        };
      }

      return null;
    } catch (e) {
      print('Erreur Google Books: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> _fetchFromOpenLibrary(
      String isbn) async {
    try {
      final url = Uri.parse(
          'https://openlibrary.org/api/books?bibkeys=ISBN:$isbn&format=json&jscmd=data');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;

        if (data.isEmpty) {
          return null;
        }

        final bookKey = 'ISBN:$isbn';
        if (!data.containsKey(bookKey)) {
          return null;
        }

        final bookData = data[bookKey] as Map<String, dynamic>;

        String titre = bookData['title'] ?? '';
        String auteur = '';

        if (bookData.containsKey('authors') &&
            bookData['authors'] is List &&
            (bookData['authors'] as List).isNotEmpty) {
          final authors = bookData['authors'] as List;
          auteur = authors
              .map((a) => a['name'] ?? '')
              .where((n) => n.isNotEmpty)
              .join(', ');
        }

        String thematique = '';
        if (bookData.containsKey('subjects') &&
            bookData['subjects'] is List &&
            (bookData['subjects'] as List).isNotEmpty) {
          final subjects = bookData['subjects'] as List;
          thematique = subjects
              .map((s) => s is Map ? (s['name'] ?? '') : s.toString())
              .where((n) => n.isNotEmpty)
              .take(3)
              .join(', ');
        }

        String? description;
        if (bookData.containsKey('notes')) {
          description = bookData['notes'];
        } else if (bookData.containsKey('excerpts') &&
            bookData['excerpts'] is List &&
            (bookData['excerpts'] as List).isNotEmpty) {
          description = (bookData['excerpts'] as List).first['text'];
        }

        // Récupérer l'URL de la couverture
        String? coverUrl;
        if (bookData.containsKey('cover')) {
          final cover = bookData['cover'] as Map<String, dynamic>;
          coverUrl = cover['large'] ?? cover['medium'] ?? cover['small'];
        }

        return {
          'titre': titre,
          'auteur': auteur,
          'thematique': thematique,
          'description': description,
          'coverUrl': coverUrl,
          'isbn': isbn,
        };
      }

      return null;
    } catch (e) {
      print('Erreur Open Library: $e');
      return null;
    }
  }

  // Nettoyer les balises HTML de la description
  static String _cleanHtml(String text) {
    // Remplacer les balises HTML courantes
    return text
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&quot;', '"')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&nbsp;', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
