
class PayDeskImage{

  int mobID;
  int pid;
  String imageName;
  String path;
  String file;
  bool isDeleted = false;

  PayDeskImage({
    this.mobID,
    this.pid,
    this.imageName,
    this.path,
    this.file,
    this.isDeleted = false
  });

  factory PayDeskImage.fromMap(Map<String, dynamic> json) => PayDeskImage(
    mobID: json["mob_id"],
    pid: json["pid"],
    imageName: json["image_name"],
    path: json["path"],
    file: json["file"],
    isDeleted: json["is_deleted"] is int ? json["is_deleted"] == 1 ? true : false : json["is_deleted"],
  );

  Map<String, dynamic> toMap() => {
    "mob_id" : mobID,
    "pid" : pid,
    "image_name" : imageName,
    "path" : path,
    "file" : file,
    "is_deleted" : isDeleted ? 1 : 0,
  };

  Map<String, dynamic> toMapUpdate() => {
    "mob_id" : mobID,
    "pid" : pid,
    "path" : path,
    "is_deleted" : isDeleted ? 1 : 0,
  };

}