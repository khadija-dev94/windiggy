class Player {
  String playerID;
  String playerName;
  String points;
  int timeStampinMilli;
  String timeStamp;
  int position;
  String appVer;
  Player({this.playerID, this.playerName});

  Player.name({this.playerID,this.playerName,this.timeStampinMilli,this.timeStamp});
  Player.name2({this.playerID,this.playerName,this.timeStamp,this.timeStampinMilli,this.appVer});

  Player.name3(this.playerID, this.playerName, this.points, this.position);


}
