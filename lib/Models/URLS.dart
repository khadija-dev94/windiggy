class URLS {
  ////////////////////////////////////////////////////////////////URLS
  static const String BASEURL = '';
  static const String notifyServer =
      BASEURL + '/index.php/mobile/gameplay/gamewon';
  static const String signUp = BASEURL + '/index.php/mobile/usermobile/signup';
  static const String login = BASEURL + '/index.php/mobile/Usermobile/login';
  static const String getTimeZone =
      BASEURL + '/index.php/mobile/Timesync/synctime';
  static const String signupVerif =
      BASEURL + '/index.php/mobile/usermobile/checkuser';
  static const String profileUpdate =
      BASEURL + '/index.php/mobile/usermobile/updateprofile/';
  static const String profilePicUpdate =
      BASEURL + '/index.php/mobile/usermobile/updateprofileimage/';

  static const String wordSearchURL =
      BASEURL + '/index.php/mobile/puzzle_mobile/getpuzzlebyid/';
  static const String MCQsURL =
      BASEURL + '/index.php/mobile/mcq_mobile/getmcqsbyid/';
  static const String imageDiffURL =
      BASEURL + '/index.php/mobile/find_difference/getgame/';
  static const String customLogin =
      BASEURL + '/index.php/mobile/usermobile/customlogin';
  static const String dashboardURL =
      BASEURL + '/index.php/mobile/gamedashboard/dashboard/';
  static const String profileInfo =
      BASEURL + '/index.php/mobile/usermobile/userprofileID/';
  static const String quizURL =
      BASEURL + '/index.php/mobile/mcq_mobile/getmcqsbyid/';
  static const String winnerURL =
      BASEURL + '/index.php/mobile/gamedashboard/winners';
  static const String chatURL = BASEURL + '/index.php/messages/getall/';
  static const String pickOddOneURL = BASEURL + '/index.php/odd_one/getgame/';
  static const String dailyPracticeURL =
      BASEURL + '/index.php/Dailygame/addnew';
  static const String scoreBoardURL = BASEURL + '/index.php/user/userscore/';
}
