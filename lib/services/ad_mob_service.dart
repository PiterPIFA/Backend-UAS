import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobService {
  static BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111',
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          // Handle ad loaded event
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose(); // Dispose the ad if it failed to load
        },
      ),
    )..load();
  }
}
