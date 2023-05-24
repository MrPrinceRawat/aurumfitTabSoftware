/// UserModel
/// Use to store user data
///
/// ### Parameters
/// This class has the following parameters:
///
/// | Type | Name | Description |
/// | :--- | :--- | :--- |
/// | String | profilePic | The profile picture of the user. |
/// | String | name | The name of the user. |
/// | String | userid | The user id of the user. |
/// | String | dob | The date of birth of the user. |
/// | String | Phone_number | The phone number of the user. |
/// | String | Address | The address of the user. |
/// | String | Gender | The gender of the user. |
/// | String | Membership_type | The membership type of the user. |
/// | int | Total_Payable_Amount | The total payable amount of the user. |
/// | int | amount_paid | The amount paid by the user. |
/// | String | Membership_duration | The membership duration of the user. |
/// | String | Membership_start_date | The membership start date of the user. |
/// | bool | active | The active status of the user. |
/// | bool | membershipStatus | The membership status of the user. |
/// | bool | attendanceStatus | The attendance status of the user. |
///
/// ### Examples
/// ```dart
/// UserModel user = UserModel(
///  userid: "123456789",
/// name: "John Doe",
/// dob: "01/01/2000",
/// Phone_number: "1234567890",
/// Address: "123, ABC Street, XYZ City",
/// profilePic: "https://www.example.com/profilepic.jpg",
/// );
/// ```
///
/// ### Methods
/// This class has the following methods:
///
/// #### checkIfAnyIsNull
/// This method is used to check if any of the parameters are null.
///
/// ##### Parameters
/// This method has no parameters.
///
/// #### toJson
/// This method is used to convert the data to JSON format.
/// This is used to store the data in the database.
/// This method is used by the [UserManagement] class.
///
/// ##### Parameters
/// This method has no parameters.
///
/// ##### Examples
/// ```dart
/// Map<String, dynamic> json = user.toJson();
/// ```
///
/// #### fromJson
/// This method is used to convert the JSON data to the [UserModel] object.
/// This method is used by the [UserManagement] class.
///
/// ##### Parameters
/// This method has the following parameters:
///
/// | Type | Name | Description |
/// | :--- | :--- | :--- |
/// | Map<String, dynamic> | json | The JSON object to be converted. |
///
/// ##### Examples
/// ```dart
/// UserModel user = UserModel.fromJson(json);
/// ```
///
/// #### toString
/// This method is used to convert the [UserModel] object to a string.
///
/// ##### Parameters
/// This method has no parameters.
///
/// ##### Examples
/// ```dart
/// String string = user.toString();
/// ```
///
/// #### operator ==
/// This method is used to check if two [UserModel] objects are equal.
///
/// ##### Parameters
/// This method has the following parameters:
///
/// | Type | Name | Description |
/// | :--- | :--- | :--- |
/// | Object | other | The other [UserModel] object to be compared. |
///
/// ##### Examples
/// ```dart
/// bool isEqual = user1 == user2;
/// ```
///
///
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
