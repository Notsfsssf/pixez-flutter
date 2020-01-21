import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:pixez/network/account_client.dart';
import './bloc.dart';

class AccountEditBloc extends Bloc<AccountEditEvent, AccountEditState> {
  @override
  AccountEditState get initialState => InitialAccountEditState();

  @override
  Stream<AccountEditState> mapEventToState(
    AccountEditEvent event,
  ) async* {
    if (event is FetchAccountEditEvent) {
      try {
        final client = AccountClient();
        var response = await client.accountEdit(
            newMailAddress: event.newMailAddress,
            newPassword: event.newPassword,
            currentPassword: event.oldPassword,
            newUserAccount: event.newUserAccount);
        print(response.data);
        yield SuccessAccountEditState();
      } catch (e) {
        print(e);
        yield FailAccountEditState(e);
      }
    }
  }
}
