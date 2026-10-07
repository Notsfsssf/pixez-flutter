import 'package:material_ui/material_ui.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/page/search/suggest/search_suggestion_page.dart';

class SearchBar extends StatefulWidget {
  final VoidCallback? onSaucenao;
  const SearchBar({Key? key, this.onSaucenao}) : super(key: key);

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  late TextEditingController _textEditingController;
  @override
  void initState() {
    _textEditingController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      height: 48,
      child: Material(
        color: Colors.grey.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(24),
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => SearchSuggestionPage(),
              ),
            );
          },
          child: Padding(
            padding: EdgeInsetsGeometry.symmetric(horizontal: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 4,
              children: [
                IconButton(icon: Icon(Icons.search), onPressed: () {}),
                Expanded(
                  child: Container(
                    child: Text(
                      I18n.of(context).search_word_hint,
                      style: TextStyle(
                        fontSize: Theme.of(
                          context,
                        ).textTheme.titleMedium!.fontSize,
                        // color: Theme.of(context).textTheme.displaySmall!.color,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.image_search),
                  onPressed: () {
                    if (widget.onSaucenao != null) widget.onSaucenao!();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
