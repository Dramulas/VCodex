import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:valorant_client/valorant_client.dart';
import 'package:valorant_daily_store/models/store_item.dart';

import '../models/account_model.dart';

class AccountProvider extends ChangeNotifier {
  // Dio client
  Dio dio = Dio();

  // Valorant Client
  late ValorantClient client;

  // Item UUID List
  List<String> itemsUuids = [];

  // Store Items List
  List<StoreItem> storeItems = [];

  // String error
  bool errorState = false;

  // User Region
  late Region region;

  // Error status code
  List<String> errorStatusCode = [];

  // Valorant Points
  var valorantPoints = 0;

  // Radiant Points
  var radianitePoints = 0;

  // add account to hive box
  void addAccount(Account newAccount) {
    saveHive(newAccount);
    notifyListeners();
  }

  // create user account and save it to hive
  void createUser(Account account) async {
    account.region == 'NA'
        ? region = Region.na
        : account.region == 'EU'
            ? region = Region.eu
            : account.region == 'KR'
                ? region = Region.ko
                : region = Region.eu;
    notifyListeners();

    client = ValorantClient(
      UserDetails(
          userName: account.username,
          password: account.password,
          region: region),
      shouldPersistSession: true,
      callback: Callback(
        onError: (String error) {
          errorState = true;
          errorStatusCode.add(error);
          notifyListeners();
        },
        onRequestError: (DioError error) {},
      ),
    );
  }

  // init client with account info
  Future<void> initClient(Account account) async {
    // create user account and save it to hive
    createUser(account);

    // client init
    await client.init(true);

    // update error state
    errorState = false;
    // var balance = await client.playerInterface.getBalance();

    // get items uuids
    final store = client.playerInterface.getStorefront();
    // final store2 = client.playerInterface.getStoreOffers();
    await Future<void>.delayed(const Duration(seconds: 1));

    final assets = await client.assetInterface.getAssets();

    if (assets == null) {
      return;
    }

    final storefront = await client.playerInterface.getStorefront();

    if (storefront != null && storefront.skinsPanelLayout != null) {
      for (var item in storefront.skinsPanelLayout!.singleItemOffers) {}
    }
    // get item skins by uuids
    await store.then((value) =>
        itemsUuids = value?.skinsPanelLayout?.singleItemOffers ?? []);
  }

  // get store items
  Future<List<StoreItem>> getItems() async {
    storeItems = [];
    for (var s in itemsUuids) {
      storeItems.add(await getStoreItems(s));
    }
    getCurrencies();
    return storeItems;
  }

  // get store item by uuid
  Future<StoreItem> getStoreItems(String itemUuid) async {
    late StoreItem items;
    try {
      // Get response
      Response response = await dio
          .get('https://valorant-api.com/v1/weapons/skinlevels/$itemUuid');
      items = StoreItem.fromJson(response.data['data']);
    } on DioError catch (e) {
      if (e.response != null) {
      } else {
// Error due to setting up or sending the request
      }
    }
    return items;
  }

  Future<void> getCurrencies() async {
    var currencies = await client.playerInterface.getBalance();
    valorantPoints = currencies?.valorantPoints ?? 0;
    radianitePoints = currencies?.radianitePoints ?? 0;
    notifyListeners();
  }

  // delete account on hive box
  void deleteHive(int index) {
    Box<Account> boxDelete = Hive.box<Account>('accounts');
    boxDelete.deleteAt(index);
    notifyListeners();
  }

  // save account to hive
  Future<void> saveHive(Account account) async {
    // Account turunde veri tutacak bir hive box actik
    Box<Account> boxSave = Hive.box<Account>('accounts');
    // Direk account listesi kayit etmek yerine tek tek accountlari kayit ediyoruz.
    // Hive zaten kendi icinde liste gibi bunlara index veriyor
    boxSave.add(account);
    notifyListeners();
  }
}