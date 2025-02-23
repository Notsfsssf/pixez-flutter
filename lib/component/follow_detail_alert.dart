import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/network/api_client.dart';

class FollowDetailAlert extends StatefulHookConsumerWidget {
  final int id;
  final Function(bool follow, String restrict) onConfirm;
  const FollowDetailAlert({
    super.key,
    required this.id,
    required this.onConfirm,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _State();
}

class _State extends ConsumerState<FollowDetailAlert> {
  late final id = widget.id;
  bool _isFollowed = false;
  String _restrict = '';
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    _init();
  }

  _init() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final followDetail = await apiClient.getUserFollowDetail(id);
      if (mounted) {
        setState(() {
          _isFollowed = followDetail.isFollowed;
          _restrict = followDetail.restrict;
          _isLoading = false;
        });
      }
    } catch (e) {
      print(e);
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).pop();
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          child: Center(
            child: GestureDetector(
              onTap: () {},
              child: Container(
                margin: const EdgeInsets.all(16),
                constraints: BoxConstraints(maxWidth: 300),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Theme.of(context).colorScheme.surface,
                ),
                child: _isLoading
                    ? Container(
                        height: 100,
                        child: const Center(child: CircularProgressIndicator()))
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SwitchListTile(
                            value: _restrict == 'private',
                            title: Text(I18n.of(context).quietly_follow),
                            onChanged: (value) {
                              setState(() {
                                _restrict = value ? 'private' : 'public';
                              });
                            },
                          ),
                          Divider(
                            height: 1,
                          ),
                          if (_isFollowed)
                            Container(
                              child: TextButton(
                                onPressed: () {
                                  widget.onConfirm(false, _restrict);
                                  Navigator.of(context).pop();
                                },
                                child: Text(I18n.of(context).cancel_follow),
                              ),
                            ),
                          Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(I18n.of(context).cancel),
                                ),
                              ),
                              Expanded(child: _rightButton())
                            ],
                          )
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _rightButton() {
    if (_isFollowed)
      return TextButton(
        onPressed: () {
          widget.onConfirm(true, _restrict);
          Navigator.of(context).pop();
        },
        child: Text(I18n.of(context).save),
      );
    else
      return TextButton(
        onPressed: () {
          widget.onConfirm(true, _restrict);
          Navigator.of(context).pop();
        },
        child: Text(I18n.of(context).start_follow),
      );
  }
}
