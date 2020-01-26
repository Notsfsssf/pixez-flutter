import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixez/bloc/bloc.dart';
import 'package:pixez/bloc/iap_bloc.dart';
import 'package:pixez/bloc/iap_event.dart';
import 'package:pixez/generated/i18n.dart';

class IapPage extends StatefulWidget {
  @override
  _IapPageState createState() => _IapPageState();
}

class _IapPageState extends State<IapPage> {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<IapBloc>(context)..add(FetchIapEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<IapBloc, IapState>(
      listener: (context, state) {
        if (state is ThanksState) {
          BotToast.showNotification(title: (_) => Text('Thanks!'));
        }
      },
      child: BlocBuilder<IapBloc, IapState>(
        condition: (pre,now)=>now is DataIapState,
        builder: (context, snapshot) {
        return Scaffold(
          appBar: AppBar(
            title: Text(I18n.of(context).Donation),
          ),
          body: snapshot is DataIapState
              ? Container(
                  child: ListView.builder(
                    itemBuilder: (BuildContext context, int index) {
                   if(index<snapshot.products.length){
                        var product = snapshot.products[index];
                      print(product);
                      return Card(
                        child: ListTile(
                          subtitle: Text(snapshot.products[index].description),
                          title: Text(product.title),
                          trailing: Text('${product.localizedPrice}'),
                          onTap: () {
                            BlocProvider.of<IapBloc>(context)
                                .add(MakeIapEvent(product));
                          },
                        ),
                      );
                   }
                   var i = index-snapshot.products.length;
                   var item =snapshot.items[i];
                   return Card(
                        child: ListTile(
                      title: Text(item.productId),
                      onTap: () async {
                      },
                        ),
                      );
                    },
                    itemCount: snapshot.products.length+snapshot.items.length,
                  ),
                )
              : Container(),
        );
      }),
    );
  }
}
