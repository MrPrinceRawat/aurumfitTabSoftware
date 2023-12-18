import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AFSBlock extends ConsumerStatefulWidget {
  const AFSBlock({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AFSBlockState();
}

class _AFSBlockState extends ConsumerState<AFSBlock> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              border: Border.all(
                  color: CupertinoColors.darkBackgroundGray, width: 2),
              borderRadius: BorderRadius.circular(10)),
          child: Text("AFS Block")),
    );
  }
}
