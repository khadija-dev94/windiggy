class Question {
  String questionEng;
  String questionUrd;

  String optionAEng;
  String optionBEng;
  String optionCEng;
  String optionDEng;
  String correctOptionEng;
  String optionAUrd;
  String optionBUrd;
  String optionCUrd;
  String optionDUrd;
  String correctOptionUrd;
  bool answerSubmit;
  String url;
  String MCQType;

  Question(
      this.questionEng,
      this.optionAEng,
      this.optionBEng,
      this.optionCEng,
      this.optionDEng,
      this.correctOptionEng,
      this.questionUrd,
      this.optionAUrd,
      this.optionBUrd,
      this.optionCUrd,
      this.optionDUrd,
      this.correctOptionUrd,
      this.answerSubmit,this.url,this.MCQType);
}
