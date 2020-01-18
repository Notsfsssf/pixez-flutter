import 'package:meta/meta.dart';
import 'package:package_info/package_info.dart';

@immutable
abstract class AboutState {}
  
class InitialAboutState extends AboutState {}
class DataAbouState extends AboutState{
final PackageInfo packageInfo;
  DataAbouState(this.packageInfo);
}