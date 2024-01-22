import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:testes/services/provider_service.dart';
import 'package:testes/services/ad_mob_service.dart';
import 'package:testes/screen/news_detail_screen.dart';

class NewsScreen extends StatefulWidget {
  @override
  _NewsScreenState createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  List<dynamic> articles = [];
  late BannerAd _bannerAd;

  @override
  void initState() {
    super.initState();
    _bannerAd = AdMobService.createBannerAd();
    fetchNews();
  }

  void fetchNews() async {
    try {
      final List<dynamic> fetchedArticles = await NewsProvider().fetchNews();

      setState(() {
        articles = fetchedArticles;
      });

      // Load the banner ad once the news is fetched
      _bannerAd.load();
    } catch (e) {
      print('Error fetching news: $e');
    }
  }

  @override
  void dispose() {
    _bannerAd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Top Headlines'),
      ),
      body: articles.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_bannerAd != null && _bannerAd.size != null)
                  Container(
                    width: _bannerAd.size.width.toDouble(),
                    height: _bannerAd.size.height.toDouble(),
                    child: AdWidget(ad: _bannerAd),
                  ),
                Expanded(
                  child: ListView.builder(
                    itemCount: articles.length,
                    itemBuilder: (context, index) {
                      var article = articles[index];
                      return ListTile(
                        title: Text(article['title']),
                        subtitle: Text(article['description'] ??
                            'No description available'),
                        leading: article['urlToImage'] != null
                            ? Image.network(
                                article['urlToImage'],
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: 50,
                                height: 50,
                                color: Colors.grey,
                              ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NewsDetailScreen(article),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
