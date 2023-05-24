import 'package:aurumfit/domians/payments/models/models.dart';
import 'package:billing/billing.dart';

class Invoice {
  final String userid;

  Invoice({required this.userid});

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
