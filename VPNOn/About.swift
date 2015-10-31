//
//  About.swift
//  VPNOn
//
//  Created by Lex Tang on 1/6/15.
//  Copyright (c) 2015 LexTang.com. All rights reserved.
//

import UIKit
import StoreKit
import MessageUI

private let kReviewCellIndex = 2
private let kFeedbackCellIndex = 3

class About : UITableViewController, MFMailComposeViewControllerDelegate {
    
    override func loadView() {
        super.loadView()
        tableView.backgroundView = LTViewControllerBackground()
    }
    
    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return appVersion()
    }
    
    private func appVersion() -> String {
        if let version = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as? String {
            return version
        }
        return ""
    }
    
    private func osVersion() -> String {
        return NSProcessInfo().operatingSystemVersionString
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.row {
        case kReviewCellIndex:
            presentAppStore()
            break
        case kFeedbackCellIndex:
            presentFeedback()
            break
        default:
            ()
        }
    }
    
    // MARK: - Feedback
    
    private func device() -> String {
        var sysInfo: [CChar] = Array(count: sizeof(utsname), repeatedValue: 0)
        let machine = sysInfo.withUnsafeMutableBufferPointer {
            (inout ptr: UnsafeMutableBufferPointer<CChar>) -> String in
            uname(UnsafeMutablePointer<utsname>(ptr.baseAddress))
            let machinePtr = ptr.baseAddress.advancedBy(Int(_SYS_NAMELEN * 4))
            return String.fromCString(machinePtr)!
        }
        return machine
    }
    
    func presentFeedback() {
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            presentViewController(mailComposeViewController, animated: true, completion: nil)
        } else {
            showSendMailErrorAlert()
        }
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setToRecipients(["lexrus@gmail.com"])
        mailComposerVC.setSubject("[VPN On] Feedback")
        
        let deviceInfo = "VPN On \(appVersion()) | iOS (\(NSProcessInfo().operatingSystemVersionString)) | #\(device()).\n"
        mailComposerVC.setMessageBody(deviceInfo, isHTML: false)
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let alert = UIAlertController(
            title: NSLocalizedString("Could Not Send Email", comment: ""),
            message: NSLocalizedString("Your device could not send email.  Please check email configuration and try again.", comment: ""),
            preferredStyle: .Alert)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Review
    
    func presentAppStore() {
        let productControlelr = SKStoreProductViewController()
        
        let parameters = [SKStoreProductParameterITunesItemIdentifier :
            NSNumber(integer: 951344279)]
        productControlelr.loadProductWithParameters(parameters, completionBlock: nil)
        
        navigationController?.presentViewController(productControlelr, animated: true) { () -> Void in }
    }

}
