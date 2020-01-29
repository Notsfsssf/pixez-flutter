import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixez/bloc/account_bloc.dart';
import 'package:pixez/bloc/account_event.dart';
import 'package:pixez/component/painter_avatar.dart';
import 'package:pixez/generated/i18n.dart';
import 'package:pixez/models/account.dart';
import 'package:pixez/page/account/select/account_select_bloc.dart';
import 'package:pixez/page/account/select/account_select_event.dart';
import 'package:pixez/page/account/select/account_select_state.dart';
import 'package:pixez/page/login/login_page.dart';

class AccountSelectPage extends StatefulWidget {
  @override
  _AccountSelectPageState createState() => _AccountSelectPageState();
}

class _AccountSelectPageState extends State<AccountSelectPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<AccountSelectBloc>(
      child: Scaffold(
        body: BlocListener<AccountSelectBloc, AccountSelectState>(
          listener: (context, state) {
            if (state is SelectState) {
              BlocProvider.of<AccountBloc>(context).add(FetchDataBaseEvent());
            }
          },
          child: BlocBuilder<AccountSelectBloc, AccountSelectState>(
              builder: (context, snapshot) {
            if (snapshot is AllAccountSelectState) {
              return Container(
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    AccountPersist accountPersist = snapshot.accounts[index];
                    return ListTile(
                      leading: PainterAvatar(
                          url: snapshot.accounts[index].userImage),
                      title: Text(accountPersist.name),
                      subtitle: Text(accountPersist.mailAddress),
                      trailing: snapshot.selectNum == index
                          ? Icon(Icons.check)
                          : IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                BlocProvider.of<AccountSelectBloc>(context).add(
                                    DeleteAccountSelectEvent(
                                        accountPersist.id));
                              },
                            ),
                      onTap: () {
                        if (snapshot.selectNum != index) {
                          BlocProvider.of<AccountSelectBloc>(context)
                              .add(SelectAccountSelectEvent(index));
                        }
                      },
                    );
                  },
                  itemCount: snapshot.accounts.length,
                ),
              );
            }
            return Container();
          }),
        ),
        appBar: AppBar(
          title: Text(I18n.of(context).Account_change),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () => Navigator.of(context, rootNavigator: true)
                  .push(MaterialPageRoute(builder: (_) => LoginPage())),
            )
          ],
        ),
      ),
      create: (BuildContext context) =>
          AccountSelectBloc()..add(FetchAllAccountSelectEvent()),
    );
  }
}
