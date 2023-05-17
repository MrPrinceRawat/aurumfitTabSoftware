import 'package:aurumfit/domians/storage/fileHandling.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrintServer extends StatefulWidget {
  const PrintServer({Key? key}) : super(key: key);

  @override
  State<PrintServer> createState() => _PrintServerState();
}

class _PrintServerState extends State<PrintServer> {
  var controller = new TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadIp();
  }

  String ip = "";
  bool _loading = false;

  Future<void> _loadIp() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      ip = prefs.getString('print_server_ip') ?? "";
    });
  }

  bool CheckDone() {
    if (controller.text.isNotEmpty) {
      return true;
    }
    return false;
  }

  Future<void> Setip() async {
    _loading = true;
    saveServerIp(controller.text);
    _loading = false;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: const Text('Print Server'),
          trailing: _loading
              ? CupertinoActivityIndicator()
              : CupertinoButton(
                  child: const Text('Done'),
                  padding: EdgeInsets.zero,
                  onPressed: CheckDone()
                      ? () {
                          Setip();
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
              child: Column(
                children: <Widget>[
                  CupertinoFormSection.insetGrouped(children: <Widget>[
                    CupertinoFormRow(
                      prefix: Text('IP'),
                      child: CupertinoTextFormFieldRow(
                        placeholder: 'IP',
                        keyboardType: TextInputType.number,
                        controller: controller,
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          ),
        ));
  }
}
