import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:pixez/bloc/save_state.dart';
import 'package:pixez/models/illust.dart';

@immutable
abstract class SaveEvent {}
class SaveImageEvent extends SaveEvent{
  final Illusts illusts;
  final int index;

  SaveImageEvent(this.illusts, this.index);

}
class SaveChoiceImageEvent extends SaveEvent{
  final Illusts illusts;
  final List<bool> indexs;

  SaveChoiceImageEvent(this.illusts, this.indexs);


}
class SaveProgressImageEvent extends SaveEvent{

  final Map<String,ProgressNum> progressMaps;

  SaveProgressImageEvent(this.progressMaps);
}
class SaveToPictureFoldEvent extends SaveEvent{
 final  Uint8List uint8list;

  SaveToPictureFoldEvent(this.uint8list);
}