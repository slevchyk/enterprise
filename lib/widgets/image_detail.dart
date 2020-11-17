
import 'package:f_logs/f_logs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ImageDetail extends StatelessWidget {
  final List<ImageProvider> listImages;
  final int initialPage;
  final String path;

  ImageDetail({
    @required this.listImages,
    this.initialPage = 0,
    this.path,
  });


  @override
  Widget build(BuildContext context) {
    PageController _pageController = PageController(initialPage: initialPage);
    return Scaffold(
      body: GestureDetector(
        child: Center(
          child: Hero(
            tag: path,
            child: PhotoViewGallery.builder(
                itemCount: listImages.length,
                pageController: _pageController,
                builder: (BuildContext context, int index){
                 try{
                   return PhotoViewGalleryPageOptions(
                     maxScale: PhotoViewComputedScale.covered,
                     minScale: PhotoViewComputedScale.contained,
                     imageProvider: listImages.elementAt(index),
                   );
                 } catch (e, s){
                   FLog.error(
                     exception: Exception(e.toString()),
                     text: "response error",
                     stacktrace: s,
                   );
                   return null;
                 }
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