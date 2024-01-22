// news_detail.dart
import 'package:flutter/material.dart';

class NewsDetailScreen extends StatelessWidget {
  final dynamic article;

  NewsDetailScreen(this.article);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('News Detail'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article['urlToImage'] != null)
              Image.network(
                article['urlToImage'],
                width: MediaQuery.of(context).size.width,
                height: 200,
                fit: BoxFit.cover,
              ),
            SizedBox(height: 16),
            Text(
              article['title'],
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              article['description'] ?? 'No description available',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              article['content'] ?? 'No content available',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
