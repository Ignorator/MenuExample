
import 'package:cv/cv.dart';
import 'package:flutter/cupertino.dart';
import '../db/db.dart';
import '../model/model_constant.dart';

class DbNote extends DbRecord {
  final title = CvField<String>(columnTitle);
  final content = CvField<String>(columnContent);
  final price = CvField<String>(contentPrice);
  final type = CvField<String>(contentType);
  final date = CvField<int>(columnUpdated);
  final langName = CvField<String>(languageName);
  final picture = CvField<String>(contentPicture);

  @override
  List<CvField> get fields => [id, title, content, price, type, langName, picture, date];
}