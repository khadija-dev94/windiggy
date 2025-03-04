class Message {
  String message;
  String userID;
  String userName;
  String timestamp;
  String sentBy;
  Map duration;

  Message(
      {this.message,
      this.userID,
      this.userName,
      this.timestamp,
      this.sentBy,
      this.duration});
}
