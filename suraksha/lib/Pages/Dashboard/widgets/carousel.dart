import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:suraksha/Pages/Dashboard/widgets/articleDesc.dart';
import 'package:suraksha/Pages/Dashboard/widgets/safewebview.dart';
import 'package:suraksha/Helpers/constants.dart';

class SafeCarousel extends StatelessWidget {
  final List<GlobalKey> keyList;
  const SafeCarousel({Key? key, required this.keyList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Showcase(
      key: keyList[0],
      title: "Carousel",
      description: "Tap to view full article",
      child: CarouselSlider(
        options: CarouselOptions(
          autoPlay: true,
          aspectRatio: 2.0,
          enlargeCenterPage: true,
        ),
        items: List.generate(
            imageSliders.length,
            (index) => Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: InkWell(
                  onTap: () {
                    if (index == 0) {
                      navigateToRoute(
                          context,
                          SafeWebView(
                              index: index,
                              title: "Pakistani women inspiring the country",
                              url:
                                  "https://gulfnews.com/world/asia/pakistan/womens-day-10-pakistani-women-inspiring-the-country-1.77696239"));
                    } else if (index == 1) {
                      navigateToRoute(
                          context,
                          SafeWebView(
                              index: index,
                              title: "We have to end Violance",
                              url:
                                  "https://plan-international.org/ending-violence/16-ways-end-violence-girls"));
                    } else if (index == 2) {
                      navigateToRoute(context, ArticleDesc(index: index));
                    } else {
                      navigateToRoute(
                          context,
                          SafeWebView(
                              index: index,
                              title: "You are strong",
                              url:
                                  "https://www.healthline.com/health/womens-health/self-defense-tips-escape"));
                    }
                  },
                  child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          image: DecorationImage(
                              image: NetworkImage(imageSliders[index]),
                              fit: BoxFit.cover)),
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                                colors: [
                                  Colors.black.withOpacity(0.5),
                                  Colors.transparent
                                ],
                                begin: Alignment.bottomLeft,
                                end: Alignment.topRight)),
                        child: Align(
                            alignment: Alignment.bottomLeft,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 8.0, bottom: 8),
                              child: Text(articleTitle[index],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.white)),
                            )),
                      )),
                ))),
      ),
    );
  }

  void navigateToRoute(
    BuildContext context,
    Widget route,
  ) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => route,
      ),
    );
  }
}
