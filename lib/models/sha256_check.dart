class Sha256Check{
  String imageName;
  String sha256;

  Sha256Check({
    this.imageName,
    this.sha256,
  });

  factory Sha256Check.fromMap(Map<String, dynamic> json) => Sha256Check(
    imageName: json["image_name"],
    sha256: json["sha256"]
  );
}