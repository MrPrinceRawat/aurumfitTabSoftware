import 'dart:ui';

import 'package:aurumfit/pages/payments/dynamicPayment.dart';
import 'package:flutter/cupertino.dart';

class DynamicPaymentWidget extends StatelessWidget {
  const DynamicPaymentWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (() {
        Navigator.push(
            context, CupertinoPageRoute(builder: (context) => DynamicQrCode()));
      }),
      child: ClipRRect(
        clipBehavior: Clip.antiAlias,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
          child: Container(
            width: MediaQuery.of(context).size.width / 2.5,
            height: MediaQuery.of(context).size.height / 4,
            decoration: BoxDecoration(
                color: CupertinoColors.white.withOpacity(.5),
                borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Text(
                        "Make Qr Code",
                        style: TextStyle(
                            color: CupertinoColors.darkBackgroundGray,
                            fontFamily: "SFPro"),
                      ),
                    ],
                  ),
                  Icon(
                    CupertinoIcons.qrcode_viewfinder,
                    color: Color.fromARGB(190, 255, 255, 255),
                    size: 130,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
