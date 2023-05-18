import 'package:dio/dio.dart';

class ApiClient {
  final Dio dio = Dio(
    BaseOptions(headers: {
      "Access-Control-Allow-Origin": "*",
      'Content-Type': 'application/json',
      'Accept': '*/*'
    }),
  );

  final String baseUrl = 'https://valorant-api.com/v1/weapons/skinlevels/';
}
