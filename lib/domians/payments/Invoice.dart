import 'package:aurumfit/domians/payments/models/models.dart';
import 'package:billing/billing.dart';

class Invoice {
  /// User id of the user whose invoice is to be fetched.
  final String userid;

  /// This class is used to fetch the invoice of a user.
  /// It takes the user id as a parameter.
  /// It returns the invoice of the user.
  /// It throws an exception if the user does not have an active invoice.
  /// It throws an exception if the user id is not provided.
  /// It throws an exception if the user id is invalid.
  ///
  /// @param userid
  ///
  ///  - userid: User id of the user whose invoice is to be fetched.
  ///
  /// @returns [InvoiceModel]
  ///
  ///
  ///
  /// Usage:
  /// ```dart
  /// Invoice invoice = Invoice(userid: userid);
  /// try {
  ///  invoiceModel = await invoice.getInvoice(token);
  /// } catch (e) {
  /// print(e);
  /// }
  /// ```
  ///
  /// For more information, see:
  /// * [InvoiceModel]
  /// * [Billing]
  /// * [BillingModel]
  /// * [Exception]
  ///
  ///
  Invoice({required this.userid});

  /// This function is used to fetch the invoice of a user.
  /// It takes the token as a parameter.
  /// It returns the invoice of the user.
  /// It throws an exception if the user does not have an active invoice.
  ///
  /// @param token
  ///   - token: Token of the user.
  ///
  /// @returns [InvoiceModel]
  Future<InvoiceModel> getInvoice(token) async {
    Billing billing = Billing();
    var data =
        await billing.getUserCurrentInvoice(token, BillingModel(id: userid));
    if (data.isEmpty) {
      throw Exception('No active invoice found.');
    }
    return InvoiceModel.fromJson(data);
  }
}
