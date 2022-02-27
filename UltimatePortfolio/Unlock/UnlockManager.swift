//
//  UnlockManager.swift
//  UltimatePortfolio
//
//  Created by Andrew CP Markham on 19/2/22.
//

import Combine
import StoreKit

class UnlockManager: NSObject, ObservableObject, SKPaymentTransactionObserver, SKProductsRequestDelegate {

    private let dataController: DataController
    private let request: SKProductsRequest
    private var loadedProducts = [SKProduct]()

    var canMakePayments: Bool {
        SKPaymentQueue.canMakePayments()
    }

    enum RequestState {
        case loading
        case loaded(SKProduct)
        case failed(Error?)
        case purchased
        case deferred
    }

    private enum StoreError: Error {
        case invalidIdentifiers, missingProduct
    }

    @Published var requestState = RequestState.loading

    init( dataController: DataController) {
        // Store the data controller we were sent
        self.dataController = dataController

        // Prepare to look for our unlock product.
        let productIDs = Set(["com.xercisepro.UltimatePortfolio.unlock"])
        request = SKProductsRequest(productIdentifiers: productIDs)

        // This is required because we inherit from NSObject
        super.init()

        // Start watching the payment queue
        SKPaymentQueue.default().add(self)

        // Check to see if the app is already in a full state
        guard dataController.fullVersionUnlocked == false else {return}

        // Set ourselves up to be notified whe the product request completes
        request.delegate = self

        // Start the request
        request.start()

    }

    deinit {
        // Purposefully remove this object from the payment que cbseerver when the app is terminated
        // This is so to stop the possibility of an update anomoly between the app store and the app
        // where the store thinks the app has been notified but the app hasn't
        SKPaymentQueue.default().remove(self)
    }

    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        // respond back in the main thread
        DispatchQueue.main.async {
            // Store the returned products for later, if we need them
            self.loadedProducts = response.products

            // We currently have only one product
            guard let unlock = self.loadedProducts.first else {
                self.requestState = .failed(StoreError.missingProduct)
                return
            }

            // We souldn't have asked for any products with invalid identifiers
            if response.invalidProductIdentifiers.isEmpty == false {
                print("ALERT: Recieved invalid product identifiers: \(response.invalidProductIdentifiers)")
                self.requestState = .failed(StoreError.invalidIdentifiers)
                return
            }

            self.requestState  = .loaded(unlock)

        }
    }

    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        DispatchQueue.main.async { [self] in
            for transaction in transactions {
                switch transaction.transactionState {
                case .purchased, .restored:
                    self.dataController.fullVersionUnlocked = true
                    self.requestState = .purchased
                    queue.finishTransaction(transaction)

                case .failed:
                    if let product = loadedProducts.first {
                        self.requestState = .loaded(product)
                    } else {
                        self.requestState = .failed(transaction.error)
                    }
                    queue.finishTransaction(transaction)

                case .deferred:
                    self.requestState = .deferred

                default:
                    break
                }
            }
        }
    }

    // Method to request payment for a IAP product
    func buy(product: SKProduct) {
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }

    // Method to restore any IAP purchased products
    // This method can be a little flakey between Xcode Versions but works fine in production
    func restore() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
}
