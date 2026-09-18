import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';

import '../../../Presentation/Screens/update.dart';

Future<void> statusHandler(BuildContext context, Response response) async {
  switch (response.statusCode) {
    case 100:
      {}
      break;
    case 101:
      {}
      break;
    case 102:
      {}
      break;
    case 103:
      {}
      break;
    case 200:
      {}
      break;
    case 201:
      {}
      break;
    case 202:
      {}
      break;
    case 204:
      {}
      break;
    case 300:
      {}
      break;
    case 301:
      {}
      break;

    case 302:
      {}
      break;
    case 303:
      {}
      break;
    case 304:
      {}
      break;
    case 307:
      {}
      break;
    case 400:
      {}
      break;
    case 401:
      {}
      break;
    case 403:
      {}
      break;
    case 404:
      {}
      break;
    case 405:
      {}
      break;
    case 406:
      {}
      break;
    case 412:
      {}
      break;
    case 415:
      {}
      break;
    case 500:
      {}
      break;
    case 501:
      {}
      break;
    case 502:
      {}
      break;
    case 503:
      {}
      break;
    case 504:
      {}
      break;
    case 505:
      {}
      break;
    case 506:
      {}
      break;
    case 507:
      {}
      break;
    case 508:
      {}
      break;
    case 510:
      {}
      break;
    case 511:
      {}
      break;

    default:
      {}
      break;
  }

  switch (response.data['Status']) {
    case 900:
      {}
      break;
    case 901:
      {}
      break;
    case 902:
      {}
      break;
    case 903:
      {
        DelightToastBar(
          autoDismiss: true,
          position: DelightSnackbarPosition.top,
          snackbarDuration: const Duration(milliseconds: 2500),
          builder: (context) => const ToastCard(
            color: Colors.red,
            leading: Icon(
              Iconsax.warning_2_outline,
              size: 28,
              color: Colors.white,
            ),
            title: Text(
              'نسخه برنامه پیدا نشد لطفا نسبت به بروزرسانی اقدام نمایید',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
        ).show(context);
      }
      break;
    case 904:
      {
       await update(context, infoNewApp: response.data['App']);
      }
      break;

    default:
      {}

      break;
  }
}
