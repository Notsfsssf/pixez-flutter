import 'package:flutter/material.dart';
import 'package:pixez/i18n.dart';

class UserFollowButton extends StatefulWidget {
  final bool followed;
  final Future<Null> Function() onPressed;
  const UserFollowButton(
      {super.key, required this.followed, required this.onPressed});

  @override
  State<UserFollowButton> createState() => _UserFollowButtonState();
}

class _UserFollowButtonState extends State<UserFollowButton> {
  late bool _followed;
  late Future<Null> Function() _onPressed;
  bool _loading = false;
  @override
  void initState() {
    _followed = widget.followed;
    _onPressed = widget.onPressed;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant UserFollowButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_followed != widget.followed) {
      setState(() {
        _followed = widget.followed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Container(
        height: 32,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 1,
                )),
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
    if (_followed) {
      return GestureDetector(
        onTap: () async {
          setState(() {
            _loading = true;
            _onPressed().then((value) {
              _loading = false;
            });
          });
        },
        child: Container(
          height: 32,
          child: Center(
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
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ),
      );
    }
    return GestureDetector(
      onTap: () {
        _onPressed();
      },
      child: Container(
        height: 32,
        child: Center(
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
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
    );
  }
}
