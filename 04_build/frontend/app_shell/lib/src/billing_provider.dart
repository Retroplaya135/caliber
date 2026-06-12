import 'entitlement_policy.dart';

class PurchaseResult {
  const PurchaseResult({
    required this.accountId,
    required this.serverSnapshot,
    required this.providerEventId,
  });

  final String accountId;
  final EntitlementSnapshot serverSnapshot;
  final String providerEventId;
}

abstract interface class BillingProvider {
  Future<PurchaseResult> purchasePackage({
    required String accountId,
    required String packageId,
    required String clientRequestId,
  });

  Future<EntitlementSnapshot> fetchServerEntitlement({
    required String accountId,
  });

  Future<PurchaseResult> restorePurchases({
    required String accountId,
    required String clientRequestId,
  });
}

final class RevenueCatBillingProvider implements BillingProvider {
  RevenueCatBillingProvider({required this.backend});

  final ServerBillingBackend backend;

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
    return backend.recordClientPurchaseIntent(
      accountId: accountId,
      packageId: packageId,
      clientRequestId: clientRequestId,
    );
  }

  @override
  Future<PurchaseResult> restorePurchases({
    required String accountId,
    required String clientRequestId,
  }) async {
    return backend.restoreViaServer(
      accountId: accountId,
      clientRequestId: clientRequestId,
    );
  }
}

abstract interface class ServerBillingBackend {
  Future<EntitlementSnapshot> fetchServerEntitlement({
    required String accountId,
  });

  Future<PurchaseResult> recordClientPurchaseIntent({
    required String accountId,
    required String packageId,
    required String clientRequestId,
  });

  Future<PurchaseResult> restoreViaServer({
    required String accountId,
    required String clientRequestId,
  });
}
