
import 'package:fluent_ui/fluent_ui.dart';

class NewVersionChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(
        "New",
        style: TextStyle(color: Colors.white, fontSize: 12.0),
      ),
      padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 2),
      decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.all(Radius.circular(24.0))),
    );
  }
}
