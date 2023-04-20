// import 'package:flutter/cupertino.dart';

// class printContent extends StatefulWidget {
//   const printContent({Key? key, required this.info}) : super(key: key);

//   final Map info;

//   @override
//   State<printContent> createState() => _printContentState();
// }

// class _printContentState extends State<printContent> {
//   @override
//   Widget build(BuildContext context) {
//     var info = {};

//     @override
//     void initState() {
//       super.initState();
//       info = widget.info;
//     }

//     return Column(
//       children: [
//         CupertinoFormSection.insetGrouped(
//           header: Text('User Info'),
//           children: [
//             CupertinoFormRow(
//                 prefix: Text('User ID'),
//                 child: CupertinoTextFormFieldRow(
//                   onChanged: (value) {
//                     findUser(value);
//                   },
//                   controller: userId,
//                   placeholder: 'user',
//                 )),
//             Container(
//                 height: users.length == 0 ? 0 : 150,
//                 child: ListView(
//                   children: [
//                     for (var i in users)
//                       CupertinoButton(
//                         alignment: Alignment.centerLeft,
//                         padding: EdgeInsets.only(left: 100),
//                         child: Text(i),
//                         onPressed: () {
//                           setState(() {
//                             userId.text = i;
//                             getUserInfo(i);
//                             users = [];
//                           });
//                         },
//                       )
//                   ],
//                 )),
//             CupertinoFormRow(
//                 prefix: Text('Name'),
//                 child: CupertinoTextFormFieldRow(
//                   controller: name,
//                   placeholder: 'Name',
//                 )),
//             CupertinoFormRow(
//                 prefix: Text('Phone'),
//                 child: CupertinoTextFormFieldRow(
//                   controller: phone,
//                   placeholder: '1122334455',
//                   keyboardType: TextInputType.number,
//                   keyboardAppearance: Brightness.dark,
//                 )),
//           ],
//         ),
//         CupertinoFormSection.insetGrouped(
//           header: Text('Membership Info'),
//           children: [
//             CupertinoFormRow(
//               prefix: Text('Payment Mode'),
//               child: CupertinoSlidingSegmentedControl(
//                   children: <String, Widget>{
//                     "Cash": Padding(
//                         padding: EdgeInsets.symmetric(horizontal: 20),
//                         child: Text(
//                           'Cash',
//                           style: TextStyle(
//                               fontFamily: "SFPro",
//                               color: CupertinoColors.black),
//                         )),
//                     "UPI": Padding(
//                         padding: EdgeInsets.symmetric(horizontal: 20),
//                         child: Text(
//                           'UPI',
//                           style: TextStyle(
//                               fontFamily: "SFPro",
//                               color: CupertinoColors.black),
//                         )),
//                   },
//                   groupValue: paymentModeInt,
//                   onValueChanged: (String? i) {
//                     setState(() {
//                       paymentModeInt = i ?? "Cash";
//                     });
//                   }),
//             ),
//             CupertinoFormRow(
//                 prefix: Text('Plan'),
//                 child: CupertinoTextFormFieldRow(
//                   readOnly: true,
//                   controller: plan,
//                   onTap: () {
//                     showCupertinoModalPopup(
//                         context: context,
//                         builder: (context) {
//                           return CupertinoActionSheet(
//                             title: Text('Plan'),
//                             message: Text('Select a Plan'),
//                             actions: <Widget>[
//                               CupertinoActionSheetAction(
//                                 isDefaultAction: true,
//                                 child: Text('Lite'),
//                                 onPressed: () {
//                                   Navigator.pop(context);
//                                   plan.value = TextEditingValue(text: "Lite");
//                                 },
//                               ),
//                               CupertinoActionSheetAction(
//                                 child: Text('Mid'),
//                                 onPressed: () {
//                                   Navigator.pop(context);
//                                   plan.value = TextEditingValue(text: "Mid");
//                                 },
//                               ),
//                               CupertinoActionSheetAction(
//                                 child: Text('Premium'),
//                                 onPressed: () {
//                                   Navigator.pop(context);
//                                   plan.value =
//                                       TextEditingValue(text: "Premium");
//                                 },
//                               ),
//                               CupertinoActionSheetAction(
//                                 child: Text('PT'),
//                                 onPressed: () {
//                                   Navigator.pop(context);
//                                   plan.value = TextEditingValue(text: "PT");
//                                 },
//                               ),
//                               CupertinoActionSheetAction(
//                                 child: Text('T-Shirt'),
//                                 onPressed: () {
//                                   Navigator.pop(context);
//                                   plan.value =
//                                       TextEditingValue(text: "T-Shirt");
//                                 },
//                               ),
//                             ],
//                             cancelButton: CupertinoActionSheetAction(
//                               child: Text('Cancel'),
//                               onPressed: () {
//                                 Navigator.pop(context);
//                               },
//                             ),
//                           );
//                         });
//                   },
//                 )),
//             CupertinoFormRow(
//               prefix: Text('Duration'),
//               child: CupertinoSlidingSegmentedControl(
//                   children: <int, Widget>{
//                     1: Padding(
//                         padding: EdgeInsets.symmetric(horizontal: 20),
//                         child: Text(
//                           '1',
//                           style: TextStyle(
//                               fontFamily: "SFPro",
//                               color: CupertinoColors.black),
//                         )),
//                     3: Padding(
//                         padding: EdgeInsets.symmetric(horizontal: 20),
//                         child: Text(
//                           '3',
//                           style: TextStyle(
//                               fontFamily: "SFPro",
//                               color: CupertinoColors.black),
//                         )),
//                     6: Padding(
//                         padding: EdgeInsets.symmetric(horizontal: 20),
//                         child: Text(
//                           '6',
//                           style: TextStyle(
//                               fontFamily: "SFPro",
//                               color: CupertinoColors.black),
//                         )),
//                     12: Padding(
//                         padding: EdgeInsets.symmetric(horizontal: 20),
//                         child: Text(
//                           '12',
//                           style: TextStyle(
//                               fontFamily: "SFPro",
//                               color: CupertinoColors.black),
//                         )),
//                   },
//                   groupValue: monthsInt,
//                   onValueChanged: (int? i) {
//                     setState(() {
//                       monthsInt = i ?? 1;
//                     });
//                   }),
//             ),
//           ],
//         ),
//         CupertinoFormSection.insetGrouped(
//             header: Text(
//               "Pricing Info",
//               style: TextStyle(fontFamily: 'SFPro'),
//             ),
//             children: [
//               CupertinoFormRow(
//                   prefix: Text('Subtotal'),
//                   child: CupertinoTextFormFieldRow(
//                     controller: subtotal,
//                     keyboardType: TextInputType.number,
//                   )),
//               CupertinoFormRow(
//                   prefix: Text('Paying Amount'),
//                   child: CupertinoTextFormFieldRow(
//                     controller: price,
//                     keyboardType: TextInputType.number,
//                   )),
//             ]),
//       ],
//     );
//   }
// }
