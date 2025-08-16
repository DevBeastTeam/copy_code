import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:rent/Auth/login.dart';
import 'package:rent/Auth/profile_update_page.dart';
import 'package:rent/Auth/profile_details_page.dart';
import 'package:rent/constants/goto.dart';
import 'package:rent/constants/toast.dart';
import 'package:rent/design/home_page.dart';

final userDataClass = ChangeNotifierProvider<UserData>((ref) => UserData());

class UserData with ChangeNotifier {
  var userdata = <String, dynamic>{};

  //////
  bool isLoading = false;
  setLoading(bool value) {
    notifyListeners();
    isLoading = value;
    notifyListeners();
  }

  register({String? name, String? email, String? password}) async {
    try {
      setLoading(true);
      notifyListeners();

      if (name == null || email == null || password == null) {
        toast("Please fill all fields", backgroundColor: Colors.red);
        setLoading(false);
        return;
      }

      final url = Uri.parse('https://thelocalrent.com/api/register');

      setLoading(true);
      final response = await http.post(
        url,
        body: {'name': name, 'email': email, 'password': password},
      );

      // debugPrint("👉Response status: ${response.statusCode}");
      // debugPrint("Response body: ${response.body}");

      final data = json.decode(response.body);

      await Future.delayed(const Duration(seconds: 3), () {});
      setLoading(false);

      if (response.statusCode == 200 || response.statusCode == 201) {
        toast(
          data['msg'] ?? "Signup successful",
          backgroundColor: Colors.green,
        );
        goto(LoginPage(), canBack: false);
      } else {
        toast(data['errors'].toString(), backgroundColor: Colors.red);
      }

      setLoading(false);
    } catch (e) {
      setLoading(false);
      toast("Error: $e", backgroundColor: Colors.red);
    }
  }

  Future login({required String email, required String password}) async {
    try {
      setLoading(true);
      final response = await http.post(
        Uri.parse("https://thelocalrent.com/api/login"),
        body: {'email': email, 'password': password},
      );
      debugPrint("Response status: ${response.statusCode}");
      debugPrint("Response body: ${response.body}");
      var result = json.decode(response.body);
      print("👉 Response: $result");

      setLoading(false);
      if (response.statusCode == 200 || response.statusCode == 201) {
        toast(result['msg'], backgroundColor: Colors.green);

        userdata = result['user'];
        // ignore: use_build_context_synchronously
        goto(const HomePage(), canBack: false);
      } else {
        toast(result['msg'], backgroundColor: Colors.red);
      }
      setLoading(false);
    } catch (e) {
      setLoading(false);
    }
  }
  /////////////// get profile data

  Future getProfileData() async {
    try {
      setLoading(true);
      final response = await http.get(
        Uri.parse("https://thelocalrent.com/api/getuserbyid/${userdata['id']}"),
      );
      debugPrint("👉 Response status: ${response.statusCode}");
      debugPrint(" 👉 Response body: ${response.body}");
      var result = json.decode(response.body);
      print("👉 Response: $result");

      setLoading(false);
      if (response.statusCode == 200 || response.statusCode == 201) {
        userdata = result['user'];
      } else {
        toast(result['msg'], backgroundColor: Colors.red);
      }
      setLoading(false);
    } catch (e) {
      setLoading(false);
    }
  }

  Future updateProfile({
    required String name,
    required String phone,
    required String email,
    required String aboutUs,
    required String address,
    String imagePath = "",
  }) async {
    try {
      ////
      setLoading(true);
      var req = http.MultipartRequest(
        "POST",
        Uri.parse("https://thelocalrent.com/api/updateprofile"),
      );

      req.headers['Content-Type'] = 'application/json';

      req.fields['uid'] = userdata['id'].toString();
      req.fields['name'] = name;
      req.fields['phone'] = phone.toString();
      req.fields['email'] = email;
      req.fields['aboutUs'] = aboutUs;
      req.fields['address'] = address;

      if (imagePath.isNotEmpty) {
        req.files.add(await http.MultipartFile.fromPath('image', imagePath));
      }

      var sendedRequest = await req.send();
      var response = await sendedRequest.stream.bytesToString();

      debugPrint("😊 sendedRequest status: ${sendedRequest.statusCode}");
      debugPrint("😊 response data: ${response}");

      if (sendedRequest.statusCode == 200 || sendedRequest.statusCode == 201) {
        toast("Successfully updated", backgroundColor: Colors.green);
        getProfileData();

        setLoading(false);
        goto(const ProfileDetailsPage(), canBack: false);
      } else {
        toast("Failed to update", backgroundColor: Colors.red);
      }
      setLoading(false);
    } catch (e) {
      setLoading(false);
    }
  }

  static fetchMyItems() {}
}



















// {
//    "success":true,
//    "msg":"Login successful",
//    "user":{
//       "id":68,
//       "image":"images/dp.png",
//       "activeUser":1,
//       "name":"hasanameer",
//       "phone":null,
//       "email":"hassanameer@gmail.com",
//       "address":null,\
//       "aboutUs":null,
//       "verifiedBy":"google",
//       "sendEmail":1,
//       "password":12345678,
//       "created_at":"2025-08-06T09":"43":26.000000Z,
//       "updated_at":"2025-08-06T09":"43":26.000000Z,
//       "deleted_at":null
//    }
// }
