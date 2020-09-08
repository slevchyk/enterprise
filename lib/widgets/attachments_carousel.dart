import 'dart:io';

import 'package:enterprise/models/models.dart';
import 'package:f_logs/f_logs.dart';
import 'package:flutter/material.dart';

class AttachmentsCarousel extends StatelessWidget {
  final List<File> files;
  final bool readOnly;
  final Function(File deletedFile) onDelete;
  final List<bool> isError;

  AttachmentsCarousel({
    this.files,
    this.readOnly,
    this.onDelete,
    @required this.isError,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 330.0,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: files.length,
        itemBuilder: (BuildContext context, int index) {
          ImageProvider _image = FileImage(File(files[index].path));
          return GestureDetector(
            onTap: (){
              if(!File(_image.toString()).existsSync()){
                return;
              }
              List<ImageProvider> toReturn = [];
              files.forEach((element) {
                toReturn.add(FileImage(File(element.path)));
              });
              RouteArgs routeArgs = RouteArgs(
                listImage: toReturn,
                initialPage: index,
              );
              Navigator.pushNamed(context, "/image/detail", arguments: routeArgs);
            },
            child: Container(
              margin: EdgeInsets.all(10.0),
              width: 210.0,
              child: Stack(
                alignment: Alignment.topCenter,
                children: <Widget>[
//                Positioned(
//                  bottom: 15.0,
//                  child: Container(
//                    height: 65.0,
//                    width: 200.0,
//                    decoration: BoxDecoration(
//                        color: Colors.white,
//                        borderRadius: BorderRadius.circular(10.0)),
//                    child: Padding(
//                      padding: const EdgeInsets.all(8.0),
//                      child: Column(
//                        mainAxisAlignment: MainAxisAlignment.end,
//                        crossAxisAlignment: CrossAxisAlignment.start,
//                        children: <Widget>[
//                          Text(basename(files[index].path)),
//                        ],
//                      ),
//                    ),
//                  ),
//                ),
                  Positioned(
                    top: 15.0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            offset: Offset(0.0, 2.0),
                            blurRadius: 6.0,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20.0),
                        child: _showImage(files[index].path, _image),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: !readOnly,
                    child: Positioned(
                      top: -5.0,
                      right: -25.0,
                      child: RawMaterialButton(
                        onPressed: () {
                          onDelete(files[index]);
                        },
                        child: Icon(
                          Icons.clear,
                          color: Colors.white,
                          size: 20.0,
                        ),
                        shape: CircleBorder(),
                        elevation: 3.0,
                        fillColor: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _showImage(String path, ImageProvider _image){
    if(!File(path).existsSync()){
      if(!isError.first){
        var _allPaths = StringBuffer();
        files.forEach((element) {
          _allPaths.write("${element.path}\n");
        });
        FLog.error(
          exception: Exception("File not found"),
          text: "image paths: $_allPaths",
        );
        isError.first = true;
      }
      return Container(
        height: 220,
        width: 180,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Image(
      height: 220.0,
      width: 180.0,
      image: _image,
    );
  }
}
