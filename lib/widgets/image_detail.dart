
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ImageDetail extends StatelessWidget {
  final List<ImageProvider> listImages;
  final int initialPage;

  ImageDetail({
    @required this.listImages,
    this.initialPage = 0,
  });


  @override
  Widget build(BuildContext context) {
    PageController _pageController = PageController(initialPage: initialPage);
    return Scaffold(
      body: GestureDetector(
        child: Center(
          child: Hero(
            tag: 'imageHero',
            child: PhotoViewGallery.builder(
                itemCount: listImages.length,
                pageController: _pageController,
                builder: (BuildContext context, int index){
                  return PhotoViewGalleryPageOptions(
                    imageProvider: listImages.elementAt(index),
                  );
                }
            ),
          ),
        ),
        onTap: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}