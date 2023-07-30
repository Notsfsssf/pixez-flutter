part of 'platform_page.dart';

class _PlatformPageStateWindow extends State<PlatformPage> {
  String path = "";

  @override
  void initState() {
    super.initState();
    initVoid();
  }

  initVoid() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      version = packageInfo.version;
    });
    String path = (await DocumentPlugin.getPath())!;
    if (mounted) {
      setState(() {
        this.path = path;
      });
    }
  }

  String version = "";
  bool singleFolder = false;

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: ListTile(
        title: Text("Platform Setting"),
        subtitle: Text(
          "For Windows",
          style: TextStyle(color: Colors.blue),
        ),
      ),
      content: Observer(builder: (_) {
        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // TODO: 此处是指定文件保存位置相关的代码 目前不考虑实现
              // ListTile(
              //   leading: Icon(FluentIcons.folder),
              //   title: Text(
              //       '${I18n.of(context).save_path}(${userSetting.saveMode != 0 ? (userSetting.saveMode == 2 ? I18n.of(context).old_way : 'SAF') : "Media"})'),
              //   subtitle: Text(path),
              //   onPressed: () async {
              //     await showPathDialog(context);
              //     final path = await DocumentPlugin.getPath();
              //     if (mounted) {
              //       setState(() {
              //         this.path = path!;
              //       });
              //     }
              //   },
              // ),
              // TODO: 没有实现 JSEvalPlugin 所以这里不能用
              ListTile(
                leading: Icon(FluentIcons.format_painter),
                title: Text(I18n.of(context).save_format),
                subtitle: Text(userSetting.fileNameEval == 1
                    ? "Eval"
                    : userSetting.format ?? ""),
                onPressed: () async {
                  if (userSetting.fileNameEval == 1) {
                    // await showDialog(
                    //   context: context,
                    //   builder: (context) => SaveEvalPage(),
                    //   useRootNavigator: false,
                    // );
                  } else {
                    final result = await showDialog(
                      context: context,
                      builder: (context) => SaveFormatPage(),
                      useRootNavigator: false,
                    );
                    if (result is String) {
                      userSetting.setFormat(result);
                    }
                  }
                },
                // trailing: PixEzButton(
                //   onPressed: () async {
                //     await showDialog(
                //       context: context,
                //       builder: (context) => SaveEvalPage(),
                //       useRootNavigator: false,
                //     );
                //   },
                //   child: Container(
                //     margin: EdgeInsets.all(8),
                //     child: userSetting.fileNameEval == 1
                //         ? Text(
                //             "Script",
                //             style: TextStyle(
                //                 color: FluentTheme.of(context).accentColor),
                //           )
                //         : Text("Script"),
                //   ),
                // ),
              ),
              Observer(
                builder: (context) {
                  return ListTile(
                    leading: Icon(FluentIcons.folder),
                    title: Text(I18n.of(context).separate_folder),
                    subtitle: Text(I18n.of(context).separate_folder_message),
                    trailing: ToggleSwitch(
                      checked: userSetting.singleFolder,
                      onChanged: (bool value) async {
                        if (value) {
                          showSnackbar(
                            context,
                            InfoBar(
                              title: Text("可能会造成保存等待时间过长"),
                            ),
                          );
                        }
                        await userSetting.setSingleFolder(value);
                      },
                    ),
                  );
                },
              ),
              Observer(
                builder: (context) {
                  return ListTile(
                    leading: Icon(FluentIcons.folder_open),
                    title: Text("Sanity Single Folder"),
                    trailing: ToggleSwitch(
                      checked: userSetting.overSanityLevelFolder,
                      onChanged: (bool value) async {
                        await userSetting.setOverSanityLevelFolder(value);
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        );
      }),
      actions: [
        FilledButton(
          child: Text(I18n.of(context).ok),
          onPressed: Navigator.of(context).pop,
        ),
      ],
    );
  }
}
