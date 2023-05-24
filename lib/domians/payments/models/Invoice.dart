/// This class a model for the Invoice
///
/// @param params for the InvoiceModel
///  - userid: User id of the user whose invoice is to be fetched.
///  - InvoiceID: Invoice id of the user whose invoice is to be fetched.
///  - date: Date of the invoice.
///  - amount: Amount of the invoice.
///  - amount_paid: Amount paid of the invoice.
///  - plan: Plan of the invoice.
///  - duration: Duration of the invoice.
///  - payments: Payments of the invoice.
///  - paid: Paid of the invoice.
///
/// @returns [InvoiceModel]
///
/// Usage:
/// ```dart
/// InvoiceModel invoiceModel = InvoiceModel(
///  userid: userid,
/// InvoiceID: InvoiceID,
/// date: date,
/// amount: amount,
/// amount_paid: amount_paid,
/// plan: plan,
/// duration: duration,
/// payments: payments,
/// paid: paid,
/// );
/// ```
///
///
class InvoiceModel {
  late String userid;
  late String InvoiceID;
  late String date;
  late double amount;
  late double amount_paid;
  late String plan;
  late int duration;
  late Map<String, dynamic> payments;
  late bool paid;

  InvoiceModel(
      {required this.userid,
      required this.InvoiceID,
      required this.date,
      required this.amount,
      required this.amount_paid,
      required this.plan,
      required this.duration,
      required this.payments,
      required this.paid});

  /// This function is used to convert the InvoiceModel object to json.
  ///
  /// @param json
  ///  - json: Json object of the InvoiceModel.
  ///
  /// @returns [Map<String, dynamic>]
  ///  - Map<String, dynamic>: Json object of the InvoiceModel.
  ///
  InvoiceModel.fromJson(Map<String, dynamic> json) {
    InvoiceID = json['InvoiceID'];
    date = json['date'];
    amount = json['amount'];
    amount_paid = json['amount_paid'];
    plan = json['plan'];
    duration = json['duration'];
    payments = json['payments'];
    paid = json['paid'];
  }

  /// This function is used to convert the InvoiceModel object to json.
  ///
  /// @returns [Map<String, dynamic>]
  /// - Map<String, dynamic>: Json object of the InvoiceModel.
  ///
  ///
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userid'] = this.userid;
    data['date'] = this.date;
    data['amount'] = this.amount;
    data['amount_paid'] = this.amount_paid;
    data['plan'] = this.plan;
    data['duration'] = this.duration;
    data['payments'] = this.payments;
    data['paid'] = this.paid;
    return data;
  }

  // Getters
  String get getInvoiceID => InvoiceID;
  String get getUserid => userid;
  String get getDate => date;
  double get getAmount => amount;
  double get getAmountPaid => amount_paid;
  String get getPlan => plan;
  int get getDuration => duration;
  Map<String, dynamic> get getPayments => payments;
  bool get getPaid => paid;
}
