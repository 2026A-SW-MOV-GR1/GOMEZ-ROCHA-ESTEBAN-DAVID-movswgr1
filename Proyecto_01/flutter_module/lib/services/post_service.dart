import 'dart:convert';
import 'package:http/http.dart' as http;

class Post {
  final int id;
  String title;
  String body;

  Post({required this.id, required this.title, required this.body});

  factory Post.fromJson(Map<String, dynamic> json) => Post(
        id: json['id'],
        title: json['title'],
        body: json['body'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'userId': 1,
      };
}

class PostService {
  static const _base = 'https://jsonplaceholder.typicode.com';

  static Future<Post> getPost(int id) async {
    final response = await http.get(Uri.parse('$_base/posts/$id'));
    if (response.statusCode == 200) {
      return Post.fromJson(jsonDecode(response.body));
    }
    throw Exception('Error al obtener el post: ${response.statusCode}');
  }

  static Future<Post> updatePost(Post post) async {
    final response = await http.put(
      Uri.parse('$_base/posts/${post.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(post.toJson()),
    );
    if (response.statusCode == 200) {
      return Post.fromJson(jsonDecode(response.body));
    }
    throw Exception('Error al actualizar: ${response.statusCode}');
  }
}