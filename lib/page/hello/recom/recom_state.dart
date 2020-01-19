
import 'package:pixez/models/illust.dart';

abstract class RecomState  {
  const RecomState();
}

class InitialRecomState extends RecomState {
  var illusts;

}

class DataRecomState extends RecomState {
  final List<Illusts> illusts;
  final String nextUrl;
  DataRecomState(this.illusts, this.nextUrl);

}
class FailRecomState extends RecomState{

}
class LoadMoreEndState extends RecomState {


}
class LoadMoreFailState extends RecomState {

}
