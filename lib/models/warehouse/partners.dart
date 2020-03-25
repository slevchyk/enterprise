
class Partners {
 int mobID;
 int id;
 String userID;
 String name;

 Partners({
   this.mobID,
   this.id,
   this.userID,
   this.name
 });

 factory Partners.fromMap(Map<String, dynamic> json) => new Partners(
   mobID: json["mob_id"],
   id: json["id"],
   userID: json["user_id"],
   name: json["partner_name"],
 );

 Map<String, dynamic> toMap() => {
   "mob_id" : mobID,
   "id" : id,
   "user_id" : userID,
   "partner_name" : name,
 };
}