import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixez/bloc/bloc.dart';
import 'package:pixez/bloc/iap_bloc.dart';
import 'package:pixez/bloc/iap_event.dart';

class IapPage extends StatefulWidget {
  @override
  _IapPageState createState() => _IapPageState();
}

class _IapPageState extends State<IapPage> {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<IapBloc>(context)..add(InitialEvent())..add(FetchIapEvent());
  }
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<IapBloc,IapState>(
      builder: (context, snapshot) {
        return Scaffold(
          appBar: AppBar(title: Text('IAP'),),
          body: snapshot is DataIapState? Container(
            child: ListView.builder(itemBuilder: (BuildContext context, int index) {
              var product =snapshot.products[index];
              print(product);
              return Card(
                child: ListTile(
                  subtitle: Text(snapshot.products[index].description),
                  title: Text(product.title),
                  trailing: Text(product.price),
                  onTap: (){
                  BlocProvider.of<IapBloc>(context).add(MakeIapEvent(product));
                  },
                ),
              );
            },itemCount: snapshot.products.length,
            ),
          ):Container(),
        );
      }
    );
  }
}