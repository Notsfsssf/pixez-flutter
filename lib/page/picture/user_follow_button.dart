import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pixez/i18n.dart';

class UserFollowButton extends StatefulWidget {
  final bool followed;
  final VoidCallback onPressed;
  const UserFollowButton({super.key, required this.followed, required this.onPressed});

  @override
  State<UserFollowButton> createState() => _UserFollowButtonState();
}

class _UserFollowButtonState extends State<UserFollowButton> {
  late bool _followed;
  late VoidCallback _onPressed;
  @override
  void initState() {
    _followed = widget.followed;
    _onPressed = widget.onPressed;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant UserFollowButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.followed != widget.followed) {
      setState(() {
        _followed = widget.followed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_followed) {
      return Container(
        height: 32,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            I18n.of(context).followed,
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
      );
    }
    return Container(
      height: 32,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Text(
          I18n.of(context).follow,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).colorScheme.secondary,
      ),
    );
  }
}
