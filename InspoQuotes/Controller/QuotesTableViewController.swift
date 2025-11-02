//
//  QuotesTableViewController.swift
//  InspoQuotes
//
//  Created by Apple on 20/09/25.
//

import UIKit
import StoreKit

@MainActor
class QuotesTableViewController: UITableViewController {
    
    let productID = "com.sagarrai123.InspoQuote.PremiumQuotes"
    private var premiumProduct: Product?

    var quotesToShow = [
        "Our greatest glory is not in never falling, but in rising every time we fall. — Confucius",
        "All our dreams can come true, if we have the courage to pursue them. – Walt Disney",
        "It does not matter how slowly you go as long as you do not stop. – Confucius",
        "Everything you’ve ever wanted is on the other side of fear. — George Addair",
        "Success is not final, failure is not fatal: it is the courage to continue that counts. – Winston Churchill",
        "Hardships often prepare ordinary people for an extraordinary destiny. – C.S. Lewis"
    ]
    
    let premiumQuotes = [
        "Believe in yourself. You are braver than you think, more talented than you know, and capable of more than you imagine. ― Roy T. Bennett",
        "I learned that courage was not the absence of fear, but the triumph over it. The brave man is not he who does not feel afraid, but he who conquers that fear. – Nelson Mandela",
        "There is only one thing that makes a dream impossible to achieve: the fear of failure. ― Paulo Coelho",
        "It’s not whether you get knocked down. It’s whether you get up. – Vince Lombardi",
        "Your true success in life begins only when you make the commitment to become excellent at what you do. — Brian Tracy",
        "Believe in yourself, take on your challenges, dig deep within yourself to conquer fears. Never let anyone bring you down. You got to keep going. – Chantal Sutherland"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Task {
            await loadProduct()
        }
    }
    
    
    
    func loadProduct() async {
        do {
            let products = try await Product.products(for: [productID])
            if let product = products.first {
                premiumProduct = product
                print("Product loaded: \(product.displayName)")
            } else {
                print("Product not found.")
            }
        } catch {
            print("Failed to load product: \(error)")
        }
    }
    
    
    
    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
    
    
    
    enum StoreError: Error {
        case failedVerification
    }
    
    
    
    func startPurchase() async {
        if premiumProduct == nil {
            await loadProduct()
        }
        
        guard let product = premiumProduct else {
            print("Product unavailable for purchase.")
            return
        }
        
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                print("Purchase successful, transaction finished.")
                if !quotesToShow.contains(premiumQuotes[0]) {
                    quotesToShow.append(contentsOf: premiumQuotes)
                    tableView.reloadData()
                }
            case .userCancelled:
                print("User cancelled the purchase.")
            case .pending:
                print("Purchase pending.")
            @unknown default:
                print("Unknown purchase result.")
            }
        } catch {
            print("Purchase failed: \(error)")
        }
    }
    
    // MARK: - Table view data source and delegate methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quotesToShow.count + 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier", for: indexPath)
        cell.textLabel?.numberOfLines = 0
        
        if indexPath.row == quotesToShow.count {
            cell.textLabel?.text = "Click to buy Premium Quotes"
            cell.textLabel?.textColor = .blue
            cell.accessoryType = .disclosureIndicator
        } else {
            cell.textLabel?.text = quotesToShow[indexPath.row]
            cell.textLabel?.textColor = .label
            cell.accessoryType = .none
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == quotesToShow.count {
            Task {
                await startPurchase()
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func RestoreButtonPressed(_ sender: UIBarButtonItem) {
        Task {
            await restorePurchases()
        }
    }
    
    func restorePurchases() async {
        var restored = false
        do {
            for await result in Transaction.currentEntitlements {
                let transaction = try checkVerified(result)
                if transaction.productID == productID {
                    if !quotesToShow.contains(premiumQuotes[0]) {
                        quotesToShow.append(contentsOf: premiumQuotes)
                        tableView.reloadData()
                        print("Purchase restored and premium quotes unlocked.")
                    }
                    restored = true
                }
            }
            if !restored {
                print("No purchases to restore.")
            }
        } catch {
            print("Failed to restore purchases: \(error)")
        }
    }
}




/*
 /
 //  QuotesTableViewController.swift
 //  InspoQuotes
 //
 //  Created by Apple on 20/09/25.
 //

 import UIKit
 import StoreKit

 class QuotesTableViewController: UITableViewController, SKProductsRequestDelegate, SKPaymentTransactionObserver {
     
     
     func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
         if let aproduct = response.products.first {
             print("product is available")
             self.purchase( product : aproduct)
         } else {
             print("the product you have asked for is not avaible")
         }
     }
     
     func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
         for transaction in transactions {
             switch transaction.transactionState {
             case  .purchased:
                 SKPaymentQueue.default().finishTransaction(transaction)
                 quotesToShow.append(contentsOf: premiumQuotes)
                 tableView.reloadData()
             case .failed:
                 SKPaymentQueue.default().finishTransaction(transaction)
                 print("Transactions can be failed")
             default : break
             }
         }
     }
     
     
     func purchase( product : SKProduct){
         let payment = SKPayment(product: product)
         SKPaymentQueue.default().add(self)
         SKPaymentQueue.default().add(payment)
     }

     var quotesToShow = [
         "Our greatest glory is not in never falling, but in rising every time we fall. — Confucius",
         "All our dreams can come true, if we have the courage to pursue them. – Walt Disney",
         "It does not matter how slowly you go as long as you do not stop. – Confucius",
         "Everything you’ve ever wanted is on the other side of fear. — George Addair",
         "Success is not final, failure is not fatal: it is the courage to continue that counts. – Winston Churchill",
         "Hardships often prepare ordinary people for an extraordinary destiny. – C.S. Lewis"
     ]
     
     let premiumQuotes = [
         "Believe in yourself. You are braver than you think, more talented than you know, and capable of more than you imagine. ― Roy T. Bennett",
         "I learned that courage was not the absence of fear, but the triumph over it. The brave man is not he who does not feel afraid, but he who conquers that fear. – Nelson Mandela",
         "There is only one thing that makes a dream impossible to achieve: the fear of failure. ― Paulo Coelho",
         "It’s not whether you get knocked down. It’s whether you get up. – Vince Lombardi",
         "Your true success in life begins only when you make the commitment to become excellent at what you do. — Brian Tracy",
         "Believe in yourself, take on your challenges, dig deep within yourself to conquer fears. Never let anyone bring you down. You got to keep going. – Chantal Sutherland"
     ]
     
          let productID: Set<String> = ["com.sagarrai123.InspoQuote.PremiumQuotes"]
    
     
     override func viewDidLoad() {
         super.viewDidLoad()

     }
     
     // data source methods of tbale view controller
     override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return quotesToShow.count + 1
     }
     
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier", for: indexPath)
         cell.textLabel?.numberOfLines = 0
         if indexPath.row == quotesToShow.count {
             cell.textLabel?.text = "Click to buy Premium Quotes"
             cell.textLabel?.textColor = .blue
             cell.accessoryType = .disclosureIndicator
         } else {
             cell.textLabel?.text = quotesToShow[indexPath.row]
         }
         return cell
         
     }
     
     override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         
         if indexPath.row == quotesToShow.count {
             if SKPaymentQueue.canMakePayments() {
 //                let productIDs : Set<String> = productID
                 let productrequest = SKProductsRequest(productIdentifiers: productID)
                 productrequest.delegate = self
                 productrequest.start()
             }
         }
         tableView.deselectRow(at: indexPath, animated: true)
     }

     @IBAction func RestoreButtonPressed(_ sender: UIBarButtonItem) {
     }
 }

 */
