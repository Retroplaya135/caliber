import 'package:purchases_flutter/purchases_flutter.dart' as rc;

import 'billing_provider.dart';
import 'entitlement_policy.dart';

abstract interface class RevenueCatPackageResolver {
  Future<rc.Package> resolvePackage(String packageId);
}

final class PurchasesFlutterBillingProvider implements BillingProvider {
  PurchasesFlutterBillingProvider({
    required this.backend,
    required this.packageResolver,
  });

  final ServerBillingBackend backend;
  final RevenueCatPackageResolver packageResolver;
  final Map<String, Future<PurchaseResult>> _purchaseRequests = {};
  final Map<String, Future<PurchaseResult>> _restoreRequests = {};

  @override
  Future<EntitlementSnapshot> fetchServerEntitlement({
    required String accountId,
  }) {
    return backend.fetchServerEntitlement(accountId: accountId);
  }

  @override
  Future<PurchaseResult> purchasePackage({
    required String accountId,
    required String packageId,
    required String clientRequestId,
  }) async {
    final key = '$accountId:$clientRequestId';
    return _purchaseRequests.putIfAbsent(
      key,
      () async {
        final package = await packageResolver.resolvePackage(packageId);
        await rc.Purchases.purchase(rc.PurchaseParams.package(package));
        return backend.recordClientPurchaseIntent(
          accountId: accountId,
          packageId: packageId,
          clientRequestId: clientRequestId,
        );
      },
    );
  }

  @override
  Future<PurchaseResult> restorePurchases({
    required String accountId,
    required String clientRequestId,
  }) async {
    final key = '$accountId:$clientRequestId';
    return _restoreRequests.putIfAbsent(
      key,
      () async {
        await rc.Purchases.restorePurchases();
        return backend.restoreViaServer(
          accountId: accountId,
          clientRequestId: clientRequestId,
        );
      },
    );
  }
}
