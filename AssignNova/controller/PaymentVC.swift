//
//  PaymentVC.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-04-08.
//

import UIKit
import EmptyDataSet_Swift
import SafariServices

class PaymentVC: UIViewController {
	
	@IBOutlet weak var stackView: UIStackView!
	@IBOutlet weak var creditCardView: UIView!
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var updateCardButton: UIButton!
	@IBOutlet weak var renewalOn: UILabel!
	
	var invoices = [Invoice]()
	
	var card: CreditCardView?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let c1 = UIColor(hex: "#484957")!
		let c2 = UIColor(hex: "#6C70CA")!
		let c3 = UIColor(hex: "#97C1D9")!
		
		self.card = CreditCardView(
			frame: creditCardView.frame,
			template: .Basic(c1, c2, c3))
		self.creditCardView.addSubview(card!)
		self.creditCardView.layoutIfNeeded()
		
		card!.center = creditCardView.convert(creditCardView.center, from: creditCardView.superview)
		
		card!.layer.applySketchShadow(color: .label, alpha: 0.5, x: 0, y: 2, blur: 32, spread: 0)
		
		updateCardDetails()
		
		tableView.sectionHeaderTopPadding = 0
		
		tableView.emptyDataSetSource = self
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		CloudFunctionsHelper.getSubscriptionInvoices(){ invoices in
			self.invoices = invoices ?? []
			self.tableView.reloadData()
		}
		
	}
	
	func updateCardDetails(){
		guard let card = self.card else {return}
		if let employee = ActiveEmployee.instance?.employee, let subscriptionDetail = ActiveEmployee.instance?.subscriptionDetail, let paymentMethod = subscriptionDetail.paymentMethod{
			card.nameLabel.text = employee.name
			card.expLabel.text = "\(String(format:"%02d", paymentMethod.expMonth))/\(paymentMethod.expYear % 100)"
			card.numLabel.text = "XXXX XXXX XXXX \(paymentMethod.last4)"
			card.brandLabel.text = "VISA"
			card.brandImageView.image = UIImage()
			
			updateCardButton.isHidden = true
			
			renewalOn.isHidden = false
			if let canceledAt = subscriptionDetail.canceledAt{
				renewalOn.text = "Cancelled on \(Date(timeIntervalSince1970: canceledAt).format(to: "EEE, MMM dd, yyyy"))"
			} else {
				renewalOn.text = "Renews on \(Date(timeIntervalSince1970: subscriptionDetail.renewalDate).format(to: "EEE, MMM dd, yyyy"))"
			}
		} else {
			card.nameLabel.text = "---- ----"
			card.expLabel.text = "--/--"
			card.numLabel.text = "XXXX XXXX XXXX XXXX"
			card.brandLabel.text = "----"
			card.brandImageView.image = UIImage()
			
			updateCardButton.setTitle("Authorize Payment", for: .normal)
			updateCardButton.setImage(UIImage(systemName: "creditcard.trianglebadge.exclamationmark"), for: .normal)
			
			renewalOn.isHidden = true
		}
	}
	
	@IBAction func onUpdateCardPress(_ sender: Any) {
		if let business = ActiveEmployee.instance?.business{
			self.startLoading()
			CloudFunctionsHelper.updateSubscription(business: business){ paymentDetails in
				self.stopLoading(){
					PaymentHelper.authorizePayment(controller: self, paymentDetails: paymentDetails, preventRefresh: true){ paymentResult in
						self.startLoading()
						CloudFunctionsHelper.refreshData(){activeEmployee in
							self.stopLoading(){
								self.updateCardDetails()
							}
						}
					}
				}
			}
		}
	}
}

extension PaymentVC: UITableViewDelegate, UITableViewDataSource{
	

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return invoices.count
    }

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		
		var configuration = cell.defaultContentConfiguration()
		
		let item = invoices[indexPath.row]
		configuration.text = "Paid $\(String(format:"%.2f", Double(item.amountPaid)/100))"
		configuration.secondaryText = Date(timeIntervalSince1970: item.invoiceDate!).format(to: "EEE, MMM dd, yyyy")
		
		
		cell.contentConfiguration = configuration
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let header = tableView.dequeueReusableCell(withIdentifier: "header") as! SectionHeaderCell
		
		header.sectionTitle.text = "Invoices"
		
		return header.contentView
	}
	
	func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		let item = self.invoices[indexPath.row]
		
		let downloadAction = UIContextualAction(style: .normal, title: "", handler: {
			(action, sourceView, completionHandler) in
			
			if let url = URL(string: item.hostedUrl!) {
				let vc = SFSafariViewController(url: url)
				vc.delegate = self
				
				self.present(vc, animated: true)
			}
			
			completionHandler(true)
		}
												
		)
		downloadAction.backgroundColor = UIColor(named: "AccentColor")
		downloadAction.image = UIImage(systemName: "newspaper.fill")
		
		let swipeConfiguration = UISwipeActionsConfiguration(actions: [downloadAction])
		return swipeConfiguration
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		
		let item = self.invoices[indexPath.row]

		if let url = URL(string: item.hostedUrl!) {
			let vc = SFSafariViewController(url: url)
			vc.delegate = self
			
			self.present(vc, animated: true)
		}
	}
}

extension PaymentVC: EmptyDataSetSource{
	func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
		let message = NSMutableAttributedString(string: "No Invoices Found", attributes: [
			.font: UIFont.preferredFont(forTextStyle: .body)
		])
		return message
	}
}

extension PaymentVC: SFSafariViewControllerDelegate{
	func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
		dismiss(animated: true)
	}
}
