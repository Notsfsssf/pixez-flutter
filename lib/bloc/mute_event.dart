import 'package:meta/meta.dart';

@immutable
abstract class MuteEvent {}

class FetchMuteEvent extends MuteEvent {}

class InsertBanUserEvent extends MuteEvent {
  final String id;
  final String name;

  InsertBanUserEvent(this.id, this.name);
}

class InsertBanTagEvent extends MuteEvent {
  final String name, translateName;

  InsertBanTagEvent(this.name, this.translateName);
}

class InsertBanIllustEvent extends MuteEvent {
  final String id;
  final String name;

  InsertBanIllustEvent(this.id, this.name);
}

class DeleteIllustEvent extends MuteEvent {
  final int id;

  DeleteIllustEvent(this.id);
}

class DeleteUserEvent extends MuteEvent {
  final int id;

  DeleteUserEvent(this.id);
}

class DeleteTagEvent extends MuteEvent {
  final int id;

  DeleteTagEvent(this.id);
}
