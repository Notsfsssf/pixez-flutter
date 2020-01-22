import 'package:pixez/models/illust.dart';

abstract class PictureState {
  const PictureState();
}

class InitialPictureState extends PictureState {}

class DataState extends PictureState {
  final Illusts illusts;
  const DataState(this.illusts);
}
class BookMarkState extends PictureState {
  final bool isBookMark;

  BookMarkState(this.isBookMark);

}
