import 'package:meta/meta.dart';
import 'package:pixez/page/account/edit/bloc/account_edit_bloc.dart';

@immutable
abstract class AccountEditEvent {}

class FetchAccountEditEvent extends AccountEditEvent {
  final String newMailAddress, currentPassword, newPassword, newUserAccount,oldPassword;

  FetchAccountEditEvent( {this.newMailAddress, this.currentPassword,
      this.newPassword, this.newUserAccount,this.oldPassword,});
}


