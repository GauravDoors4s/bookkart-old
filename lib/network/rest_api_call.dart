import 'dart:convert';

import 'package:flutterapp/model/LoginResponse.dart';
import 'package:flutterapp/utils/Constant.dart';
import 'package:flutterapp/utils/utils.dart';
import 'package:http/http.dart';
import 'package:nb_utils/nb_utils.dart';

import 'NetworkUtils.dart';

bool isSuccessful(int code) {
  return code >= 200 && code <= 206;
}

Future responseHandler(Response response,
    {req,
    isBookDetails = false,
    isPurchasedBook = false,
    isBookMarkBook = false}) async {
  if (isSuccessful(response.statusCode)) {
    if (response.body.contains("jwt_auth_no_auth_header")) {
      // toastLong("Authorization header not found.");
      throw 'Authorization header not found.';
    } else if (response.body.contains("jwt_auth_invalid_token")) {
      printLogs("jwt_auth_invalid_token");
      var password = await getString(PASSWORD);
      var email = await getString(EMAIL);
      if (email != "" && password != "") {
        var request = {"username": email, "password": password};
        await isNetworkAvailable().then((bool) async {
          if (bool) {
            await getLoginUserRestApi(request).then((res) {
              LoginResponse response = LoginResponse.fromJson(res);
              setString(TOKEN, response.token);
              // Call Existing api
              if (isBookDetails) {
                getBookDetailsRestApi(req);
              } else if (isPurchasedBook) {
                getPurchasedRestApi();
              } else if (isBookMarkBook) {
                getBookmarkRestApi();
              } else {
                openSignInScreen();
              }
            }).catchError((onError) {
              openSignInScreen();
            });
          } else {
            openSignInScreen();
          }
        });
      } else {
        openSignInScreen();
      }
    } else {
      return jsonDecode(response.body);
    }
  } else {
    if (response.statusCode == 404) {
      if (response.body.contains("email_missing")) {
        throw 'Email Not Found';
      }
      if (response.body.contains("not_found")) {
        throw 'Current password is invalid';
      }
      if (response.body.contains("empty_wishlist")) {
        throw 'No Product Available';
      }
      else {
        throw 'Page Not Found';
      }
    } else if (response.statusCode == 405) {
      //toast("Error: Method Not Allowed");
      throw 'Method Not Allowed';
    } else if (response.statusCode == 500) {
      // toast("Error: Internal Server Error");
      throw 'Internal Server Error';
    } else if (response.statusCode == 501) {
      // toast("Error: Not Implemented");
      throw 'Not Implemented';
    } else if (response.statusCode == 403) {
      if (response.body.contains("jwt_auth")) {
        // toast("Invalid Credential.Try again");
        throw 'Invalid Credential.';
      } else {
        //toast("Error: Forbidden");
        throw 'Forbidden';
      }
    } else if (response.statusCode == 401) {
      // toast("Error: Unauthorized");
      throw 'Unauthorized';
    } else if (response.statusCode == 400) {
      // toast("Bad Request");
      throw 'Bad Request';
    } else if (await isJsonValid(response.body)) {
      // toast("Error: Invalid Json");
      throw 'Invalid Json';
    } else {
      throw 'Please try again later.';
    }
  }
}

openSignInScreen() async {
  toastLong("Your token has been Expired. Please login again.");
  var pref = await getSharedPref();
  pref.remove(TOKEN);
  pref.remove(USERNAME);
  pref.remove(FIRST_NAME);
  pref.remove(LAST_NAME);
  pref.remove(USER_DISPLAY_NAME);
  pref.remove(USER_ID);
  pref.remove(USER_EMAIL);
  pref.remove(USER_ROLE);
  pref.remove(AVATAR);
  pref.remove(PROFILE_IMAGE);
  pref.setBool(IS_LOGGED_IN, false);
  // TODO Globle context here
  //SignInScreen().launch(context, isNewTask: true);
}

Future<bool> isJsonValid(json) async {
  try {
    // ignore: unnecessary_statements
    jsonDecode(json) as Map<String, dynamic>;
    return true;
  } catch (e) {
    printLogs(e.toString());
  }
  return false;
}

Future getLoginUserRestApi(request) async {
  return responseHandler(
      await APICall().postMethod("jwt-auth/v1/token", request));
}

Future getRegisterUserRestApi(request) async {
  return responseHandler(await APICall()
      .postMethod("iqonic-api/api/v1/woocommerce/customer/register", request));
}

Future getDashboardDataRestApi() async {
  return responseHandler(
      await APICall().getMethod("iqonic-api/api/v1/woocommerce/get-dashboard"));
}

Future getAuthorBookListRestApi(id) async {
  return responseHandler(await APICall().getMethod(
      "iqonic-api/api/v1/woocommerce/get-vendor-products?vendor_id=$id"));
}

Future getAllBookRestApi(request) async {
  return responseHandler(await APICall()
      .postMethod("iqonic-api/api/v1/woocommerce/get-product", request));
}

Future getPurchasedRestApi() async {
  return responseHandler(
      await APICall().getMethod(
          "iqonic-api/api/v1/woocommerce/get-customer-orders",
          requireToken: true),
      isPurchasedBook: true);
}
//bookmarks
Future getBookmarkRestApi() async {
  return responseHandler(
      await APICall().getMethod("iqonic-api/api/v1/wishlist/get-wishlist",
          requireToken: true),
      isBookMarkBook: true);
}

Future getRemoveFromBookmarkRestApi(request) async {
  return responseHandler(await APICall().postMethod(
      'iqonic-api/api/v1/wishlist/delete-wishlist/', request,
      requireToken: true));
}

Future getAddToBookmarkRestApi(request) async {
  return responseHandler(await APICall().postMethod(
      'iqonic-api/api/v1/wishlist/add-wishlist', request,
      requireToken: true));
}

Future getBookDetailsRestApi(request) async {
  if (await getBool(IS_LOGGED_IN, defaultValue: false)) {
    return responseHandler(
        await APICall().postMethod(
            "iqonic-api/api/v1/woocommerce/get-product-details", request,
            requireToken: true),
        req: request,
        isBookDetails: true);
  } else {
    return responseHandler(
        await APICall().postMethod(
            "iqonic-api/api/v1/woocommerce/get-product-details", request,
            requireToken: false),
        req: request,
        isBookDetails: true);
  }
}

Future deleteOrderRestApi(request) async {
  return responseHandler(
      await APICall().getMethod("wc/v3/orders/$request?force=true"));
}

Future bookOrderRestApi(request) async {
  return responseHandler(
      await APICall().postMethod("wc/v3/orders", request, requireToken: true));
}

Future updateOrderRestApi(request, orderId) async {
  return responseHandler(await APICall()
      .postMethod("wc/v3/orders/$orderId", request, requireToken: true));
}

Future checkoutURLRestApi(request) async {
  return responseHandler(await APICall().postMethod(
      "iqonic-api/api/v1/woocommerce/get-checkout-url", request,
      requireToken: true));
}

Future bookReviewRestApi(request) async {
  return responseHandler(await APICall()
      .postMethod("wc/v3/products/reviews", request, requireToken: true));
}

Future getPaidBookFileListRestApi(request) async {
  if (await getBool(IS_LOGGED_IN, defaultValue: false)) {
    return responseHandler(await APICall().postMethod(
        "iqonic-api/api/v1/woocommerce/get-book-downloads", request,
        requireToken: true));
  } else {
    return responseHandler(await APICall().postMethod(
        "iqonic-api/api/v1/woocommerce/get-book-downloads", request,
        requireToken: false));
  }
}

Future getAuthorListRestApi() async {
  return responseHandler(
      await APICall().getMethod("iqonic-api/api/v1/woocommerce/get-vendors"));
}

Future getCatListRestApi(page, perPage) async {
  return responseHandler(await APICall().getMethod(
      "wc/v3/products/categories?parent=0&page=$page&per_page=$perPage"));
}

Future changePassword(request) async {
  return responseHandler(await APICall().postMethod(
      'iqonic-api/api/v1/woocommerce/change-password', request,
      requireToken: true));
}

Future saveProfileImage(request) async {
  return responseHandler(await APICall().postMethod(
      'iqonic-api/api/v1/customer/save-profile-image', request,
      requireToken: true));
}

Future getCustomer(id) async {
  return responseHandler(await APICall().getMethod('wc/v3/customers/$id'));
}

Future updateCustomer(id, request) async {
  return responseHandler(
      await APICall().postMethod('wc/v3/customers/$id', request));
}

Future forgetPassword(request) async {
  return responseHandler(await APICall()
      .postMethod('iqonic-api/api/v1/customer/forget-password', request));
}

Future getProductReviews(id) async {
  return responseHandler(
      await APICall().getMethod('wc/v1/products/$id/reviews'));
}
