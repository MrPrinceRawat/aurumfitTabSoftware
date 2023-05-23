class User {
  // USER
  late final String? profilePic;
  late final String name;
  final String userid;
  late final String dob;
  late final String? Phone_number;
  late final String? Address;
  late final String gender;

  // MEMBERSHIP

  late final String? Membership_type;
  late final int? Total_Payable_Amount;
  late final int? amount_paid;
  late final String? Membership_duration;
  late final String? Membership_start_date;

  // MISC

  late final bool? active;
  late final bool membershipStatus;
  late final bool? attendanceStatus;

  User({
    required this.userid,
    this.name = "",
    this.dob = "",
    this.Phone_number = "",
    this.Address = "",
    this.profilePic = "",
    this.gender = "",
    this.Membership_type = "",
    this.Total_Payable_Amount = 0,
    this.amount_paid = 0,
    this.Membership_duration = "",
    this.Membership_start_date = "",
    this.active = false,
    this.membershipStatus = false,
    this.attendanceStatus = false,
  });

  bool checkIfAnyIsNull() {
    return [
      name,
      Address,
      Phone_number,
      Membership_type,
      Total_Payable_Amount,
      amount_paid,
      Membership_duration,
      Membership_start_date,
      active,
      membershipStatus,
      attendanceStatus,
    ].contains(null);
  }

  User.fromJson(Map<String, dynamic> json)
      : name = json["name"],
        userid = json["userid"],
        dob = json["dob"],
        Phone_number = json["Phone_number"],
        Address = json["Address"],
        profilePic = json["profilePic"],
        Membership_type = json["Membership_type"],
        Total_Payable_Amount = json["Total_Payable_Amount"],
        amount_paid = json["amount_paid"],
        Membership_duration = json["Membership_duration"],
        Membership_start_date = json["Membership_start_date"],
        active = json["active"],
        membershipStatus = json["membershipStatus"],
        attendanceStatus = json["attendanceStatus"];

  Map<String, dynamic> toJson() => {
        "name": name,
        "userid": userid,
        "dob": dob,
        "Phone_number": Phone_number,
        "Address": Address,
        "profilePic": profilePic,
        "Membership_type": Membership_type,
        "Total_Payable_Amount": Total_Payable_Amount,
        "amount_paid": amount_paid,
        "Membership_duration": Membership_duration,
        "Membership_start_date": Membership_start_date,
        "active": active,
        "membershipStatus": membershipStatus,
        "attendanceStatus": attendanceStatus,
      };

  @override
  String toString() {
    return 'User{name: $name, userid: $userid, dob: $dob, Phone_number: $Phone_number, Address: $Address, profilePic: $profilePic, Membership_type: $Membership_type, Total_Payable_Amount: $Total_Payable_Amount, amount_paid: $amount_paid, Membership_duration: $Membership_duration, Membership_start_date: $Membership_start_date, active: $active, membershipStatus: $membershipStatus, attendanceStatus: $attendanceStatus}';
  }
}
