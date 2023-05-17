import 'package:aurumfit/config/backgrounds.dart';
import 'package:flutter/cupertino.dart';

class changeDefaultBackground extends StatefulWidget {
  const changeDefaultBackground({Key? key}) : super(key: key);

  @override
  State<changeDefaultBackground> createState() =>
      _changeDefaultBackgroundState();
}

class _changeDefaultBackgroundState extends State<changeDefaultBackground> {
  String defaultBackground = "";
  bool _loading = false;
  var backgrounds = [];
  var selected = 0;

  @override
  void initState() {
    super.initState();
    loadDefaultBackgrounds();
  }

  loadDefaultBackgrounds() async {
    var gotback = await Backgrounds.getBackgrounds();
    var defback = await Backgrounds.getDefaultBackground();
    var updatedGotBack = [];
    gotback.forEach((element) => updatedGotBack.add(element.name));
    setState(() {
      backgrounds = updatedGotBack;
      defaultBackground = defback!;
      selected = updatedGotBack.indexOf(defback);
    });
  }

  checkChange() {
    if (backgrounds.indexOf(defaultBackground) != selected) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: const Text('Change Default Background'),
          trailing: _loading
              ? CupertinoActivityIndicator()
              : CupertinoButton(
                  child: const Text('Done'),
                  padding: EdgeInsets.zero,
                  onPressed: checkChange()
                      ? () {
                          Backgrounds.setDefaultBackground(
                              backgrounds[selected]);
                        }
                      : null,
                ),
        ),
        child: Container(
            // color: CupertinoColors.systemGrey6,
            padding: EdgeInsets.only(left: 10, right: 10),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: GridView.builder(
                    itemCount: backgrounds.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                    ),
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: ClipRect(
                          clipBehavior: Clip.hardEdge,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selected = index;
                              });
                            },
                            child: Container(
                                decoration: BoxDecoration(
                                    border: selected == index
                                        ? Border.all(
                                            width: 3,
                                            color: CupertinoColors.activeBlue,
                                          )
                                        : null,
                                    borderRadius: BorderRadius.circular(20)),
                                child: Image.asset("assets/backgrounds/" +
                                    backgrounds[index])),
                          ),
                        ),
                      );
                    }),
              ),
            )));
  }
}
