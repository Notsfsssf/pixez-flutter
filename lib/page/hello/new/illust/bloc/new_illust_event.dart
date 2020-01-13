import 'package:flutter/cupertino.dart';
import 'package:pixez/models/illust.dart';

@immutable
abstract class NewIllustEvent {
  const NewIllustEvent();
}

class FetchIllustEvent extends NewIllustEvent {
  final String restrict;

  FetchIllustEvent(this.restrict);
}

class RefreshIllustEvent extends NewIllustEvent {}

class LoadMoreEvent extends NewIllustEvent {
  final String nextUrl;
  final List<Illusts> illusts;

  LoadMoreEvent(this.nextUrl, this.illusts);
}