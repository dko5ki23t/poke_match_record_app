import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:poke_reco/ad_helper.dart';

class AdBanner extends StatefulWidget {
  const AdBanner({
    Key? key,
    required this.size,
  }) : super(key: key);
  final AdSize size;

  @override
  AdBannerState createState() => AdBannerState();
}

class AdBannerState extends State<AdBanner> {
  late BannerAd banner;

  @override
  void initState() {
    super.initState();
    banner = _createBanner(widget.size);
  }

  @override
  void dispose() {
    banner.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: banner.size.width.toDouble(),
      height: banner.size.height.toDouble(),
      child: AdWidget(ad: banner),
    );
  }

  BannerAd _createBanner(AdSize size) {
    return BannerAd(
      size: size,
      adUnitId: AdHelper.bannerAdUnitId,   // gitには公開してない
      listener: BannerAdListener(
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          banner.dispose();
        },
      ),
      request: const AdRequest(),
    )..load();
  }
}
