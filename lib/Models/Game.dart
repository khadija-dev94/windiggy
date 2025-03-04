import 'Winner.dart';

class Game {
  String gameID;
  String gamePrizeEng;
  String gamePrizeUrd;
  String gameType;
  String gameStatus;
  String wonBy;
  String screenshot;
  String finishTime;
  String startTime;
  bool next;
  String winnerNaame;
  String winEngMsg;
  String winUrdMsg;
  String status;
  List<Winner> winners;
  bool bonusGame;
  int index;
  String gameName;
  bool showGame;

  Game({
    this.gameID,
    this.gamePrizeEng,
    this.gamePrizeUrd,
    this.gameType,
    this.gameStatus,
    this.wonBy,
    this.screenshot,
    this.finishTime,
    this.startTime,
    this.winnerNaame,
    this.next,
    this.status,
    this.winEngMsg,
    this.winUrdMsg,
    this.winners,
    this.bonusGame,
    this.index,
    this.gameName,
    this.showGame,
  });
}
