//
//  FilterViewController.swift
//  Vinishko
//
//  Created by Денис on 05.10.2022.
//

import UIKit
import RealmSwift

class FilterViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    
    // options titles
    var colorTitle = ""
    var purchaseTitle = ""
    var countryTitle = ""
    // color otions titles
    var redColorTitle = ""
    var whiteColorTitle = ""
    var otherColorTitle = ""
    
    var bottles: Results<Bottle>!
    private var redWine: Results<Bottle>!
    private var whiteWine: Results<Bottle>!
    private var otherWine: Results<Bottle>!
    private let shared = FilterManager.shared
    
    @IBOutlet weak var pieView: PieView!
    @IBOutlet weak var filterByColorButton: UIButton!
    @IBOutlet weak var filterByPlaceOfPurchaseButton: UIButton!
    @IBOutlet weak var filterByCountryButton: UIButton!
    
    @IBOutlet weak var cancelColorButton: UIButton!
    @IBOutlet weak var cancelPurchaseButton: UIButton!
    @IBOutlet weak var cancelCountryButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bottles = realm.objects(Bottle.self)
        setupOptionsTitles()
        setupStatistics()
        setupCancelButtons()
        setupButtonTitles()
    }
    
    private func setupOptionsTitles() {
        // options titles
        colorTitle = LocalizableText.colorTitle
        purchaseTitle = LocalizableText.purchaseTitle
        countryTitle = LocalizableText.countryTitle
        // color otions titles
        redColorTitle = LocalizableText.redColorTitle
        whiteColorTitle = LocalizableText.whiteColorTitle
        otherColorTitle = LocalizableText.otherColorTitle
    }
    
    func updateChartData() {
        let redWineCount = CGFloat(redWine.count)
        let whiteWineCount = CGFloat(whiteWine.count)
        let otherWineCount = CGFloat(otherWine.count)

        pieView.setValues([redWineCount, whiteWineCount, otherWineCount])
    }
    
    private func setupStatistics() {
        redWine = bottles.filter("wineColor == 0")
        whiteWine = bottles.filter("wineColor == 1")
        otherWine = bottles.filter("wineColor == 2")
        
        updateChartData()
    }
    
    private func setupCancelButtons() {
        cancelColorButton.isEnabled = false
        cancelPurchaseButton.isEnabled = false
        cancelCountryButton.isEnabled = false
    }
    
    private func setupButtonTitles() {
        // setup colorButton
        if shared.colorIdOptionInfo != nil {
            switch shared.colorIdOptionInfo {
            case 0:
                filterByColorButton.setTitle(redColorTitle, for: .normal)
            case 1:
                filterByColorButton.setTitle(whiteColorTitle, for: .normal)
                
            case 2:
                filterByColorButton.setTitle(otherColorTitle, for: .normal)
                
            default:
                break
            }
            cancelColorButton.isEnabled = true
        }
        // setup placeOfPurchaseButton
        if shared.placeOfPurchaseOptionInfo != nil {
            filterByPlaceOfPurchaseButton.setTitle(shared.placeOfPurchaseOptionInfo, for: .normal)
            cancelPurchaseButton.isEnabled = true
        }
        // setup countryButton
        if shared.countryOptionInfo != nil {
            filterByCountryButton.setTitle(shared.countryOptionInfo, for: .normal)
            cancelCountryButton.isEnabled = true
        }
    }
    
    @IBAction func cancelAllButtonAction(_ sender: Any) {
        shared.colorIdOptionInfo = nil
        shared.placeOfPurchaseOptionInfo = nil
        shared.countryOptionInfo = nil
        filterByColorButton.setTitle(colorTitle, for: .normal)
        filterByPlaceOfPurchaseButton.setTitle(purchaseTitle, for: .normal)
        filterByCountryButton.setTitle(countryTitle, for: .normal)
        setupCancelButtons()
    }
    
    @IBAction func cancelOptionButtonAction(_ sender: Any) {
        let tag = (sender as AnyObject).tag
        
        switch tag {
        case 0:
            shared.colorIdOptionInfo = nil
            filterByColorButton.setTitle(colorTitle, for: .normal)
            cancelColorButton.isEnabled = false
        case 1:
            shared.placeOfPurchaseOptionInfo = nil
            filterByPlaceOfPurchaseButton.setTitle(purchaseTitle, for: .normal)
            cancelPurchaseButton.isEnabled = false
        case 2:
            shared.countryOptionInfo = nil
            filterByCountryButton.setTitle(countryTitle, for: .normal)
            cancelCountryButton.isEnabled = false
        default:
            break
        }
    }
    
    @IBAction func filterButtonAction(_ sender: Any) {
        checkAvailabilityOfBottles()
        guard let popoverTableViewController = storyboard?.instantiateViewController(withIdentifier: "popoverTableView") as? PopoverTableViewController else { return }
        popoverTableViewController.modalPresentationStyle = .popover
        popoverTableViewController.delegate = self
        let popover = popoverTableViewController.popoverPresentationController
        popover?.delegate = self
        
        let tag = (sender as AnyObject).tag
        
        switch tag {
        case 0:
            popover?.sourceView = filterByColorButton
            popover?.sourceRect = CGRect(x: filterByColorButton.bounds.midX, y: filterByColorButton.bounds.midY, width: 0, height: 0)
            popoverTableViewController.optionsArrayId = tag
        case 1:
            popover?.sourceView = filterByPlaceOfPurchaseButton
            popover?.sourceRect = CGRect(x: filterByPlaceOfPurchaseButton.bounds.midX, y: filterByPlaceOfPurchaseButton.bounds.midY, width: 0, height: 0)
            popoverTableViewController.optionsArrayId = tag
        case 2:
            popover?.sourceView = filterByCountryButton
            popover?.sourceRect = CGRect(x: filterByCountryButton.bounds.midX, y: filterByCountryButton.bounds.midY, width: 0, height: 0)
            popoverTableViewController.optionsArrayId = tag
        default:
            break
        }
        popoverTableViewController.bottles = bottles
        popoverTableViewController.preferredContentSize = CGSize(width: 200, height: 200)
        present(popoverTableViewController, animated: true)
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func checkAvailabilityOfBottles() {
        bottles = realm.objects(Bottle.self)
        if shared.colorIdOptionInfo != nil && shared.colorIdOptionInfo != 9 {
            let filtered = bottles.where { $0.wineColor == shared.colorIdOptionInfo }
            bottles = filtered
        }
        
        if shared.placeOfPurchaseOptionInfo != nil {
            let filtered = bottles.where { $0.placeOfPurchase == shared.placeOfPurchaseOptionInfo }
            bottles = filtered
        }
        
        if shared.countryOptionInfo != nil {
            let filtered = bottles.where { $0.wineCountry == shared.countryOptionInfo }
            bottles = filtered
        }
    }
    
}

// MARK: Titles for buttons setting up
extension FilterViewController: FilterOptionsProtocol {
    func getOptionName(name: String, tag: Int) {
        switch tag {
        case 0:
            filterByColorButton.setTitle(name, for: .normal)
            cancelColorButton.isEnabled = true
        case 1:
            filterByPlaceOfPurchaseButton.setTitle(name, for: .normal)
            cancelPurchaseButton.isEnabled = true
        case 2:
            filterByCountryButton.setTitle(name, for: .normal)
            cancelCountryButton.isEnabled = true
        default:
            break
        }
    }
    
    func getColorOption(colorId: Int) {}
}
