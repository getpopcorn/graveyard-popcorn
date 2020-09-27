//
//  SettingsViewController.swift
//  Popcorn-iOS
//
//  Created by Antique on 19/7/20.
//  Copyright © 2020 Jarrod Norwell. All rights reserved.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation
import QuickTableViewController
import UIKit

class SettingsViewController : QuickTableViewController {
    var people = [[String?]]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        
        
        do {
            let JSON = try NSString(contentsOf: URL(string: "https://raw.githubusercontent.com/getpopcorn/getpopcorn.github.io/master/members.json")!, encoding: String.Encoding.utf8.rawValue) as String
            let data = Data(JSON.utf8)
            if let formattedJSON = try JSONSerialization.jsonObject(with: data, options: []) as? [Dictionary<String, Any>] {
                for person in formattedJSON {
                    
                    
                    let name = person["Name"] as? String
                    let patronSince = person["Patronage Since Date"] as! String
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSS"
                    let date = dateFormatter.date(from: patronSince)
                    
                    
                    let date1 = date!
                    let date2 = Date()

                    let components = Calendar.current.dateComponents([.day], from: date1, to: date2)
                    
                    if !people.contains([name, "\(components.day ?? 0)"]) {
                        people.append([name, "\(components.day ?? 0)"])
                    }
                }
            }
        } catch {
            print(error.localizedDescription)
        }
        
        var rows = [NavigationRow]()
        for person in people.sorted(by: { (one, two) -> Bool in
            return one[0]?.lowercased() ?? "" < two[0]?.lowercased() ?? ""
        }) {
            rows.append(NavigationRow(text: person[0] ?? "No name available", detailText: .subtitle("Patron for \(person[1] ?? "0") days")))
        }
        
        
        tableContents = [
            Section(title: "Popcorn x Firebase", rows: [
                TapActionRow(text: UserDefaults.standard.bool(forKey: "isSignedIn") ? Auth.auth().currentUser?.email ?? "Signed in" : "Sign in to Popcorn", action: { (row) in
                    if !UserDefaults.standard.bool(forKey: "isSignedIn") {
                        let alert = UIAlertController(title: "Account", message: "Sign in or create an account to gain access to a brand new way of saving media to your watchlist and when added, the new way of saving watched progress.", preferredStyle: .actionSheet)
                        alert.addAction(UIAlertAction(title: "Register", style: .default, handler: { (action) in
                            guard let email = alert.textFields![0].text, let password = alert.textFields![1].text else {
                                return
                            }
                            
                            
                            Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
                                if let error = error {
                                    print(error.localizedDescription)
                                } else {
                                    UserDefaults.standard.setValue(email, forKey: "email")
                                    UserDefaults.standard.setValue(password, forKey: "password")
                                    
                                    
                                    Firestore.firestore().collection("users").document(email).setData([
                                        "liked_movies" : [],
                                        "liked_shows" : []
                                    ])
                                    
                                    
                                    Firestore.firestore().collection("watchlist").document(result!.user.uid).setData([
                                        "watchlist_movies" : [],
                                        "watchlist_shows" : []
                                    ])
                                    
                                    self.tableView.reloadData()
                                }
                            }
                        }))
                        
                        
                        alert.addAction(UIAlertAction(title: "Sign in", style: .default, handler: { (action) in
                            guard let email = alert.textFields![0].text, let password = alert.textFields![1].text else {
                                return
                            }
                            
                            Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
                                if let error = error {
                                    print(error.localizedDescription)
                                } else {
                                    UserDefaults.standard.setValue(email, forKey: "email")
                                    UserDefaults.standard.setValue(password, forKey: "password")
                                    
                                    self.tableView.reloadData()
                                }
                            }
                        }))
                        
                        
                        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                            
                            
                        alert.addTextField { (textField) in
                            textField.placeholder = "Email"
                        }
                            
                        alert.addTextField { (textField) in
                            textField.placeholder = "Password"
                        }
                        
                        self.present(alert, animated: true, completion: nil)
                    }
                })
            ]),
            Section(title: "General".localized, rows: [
                SwitchRow(text: "Clear cache on exit".localized, switchValue: self.loadSetting(key: "clearCacheOnExit") as? Bool ?? false, action: { (row) in
                    self.saveSetting(key: "clearCacheOnExit", value: !(self.loadSetting(key: "clearCacheOnExit") as? Bool ?? false))
                })
            ]),
            Section(title: "Subtitles".localized, rows: [
                NavigationRow(text: "Minimum subtitle rating".localized, detailText: .value1(SubtitleSettings.Quality(rawValue: self.loadSetting(key: "minimumSubtitleRating") as? Double ?? 8.0)?.localizedString ?? "Medium"), icon: nil, customization: nil, action: { (row) in
                    let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                    alertController.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel, handler: { (row) in
                        self.tableView.reloadData()
                    }))
                    SubtitleSettings.Quality.array.forEach { (rating) in
                        alertController.addAction(UIAlertAction(title: rating.localizedString, style: .default, handler: { (action) in
                            self.saveSetting(key: "minimumSubtitleRating", value: Double(rating.rawValue))
                        }))
                    }
                    self.present(alertController, animated: true, completion: nil)
                }, accessoryButtonAction: nil),
                NavigationRow(text: "Default language".localized, detailText: .value1(self.loadSetting(key: "defaultLanguage") as? String ?? "None"), icon: nil, customization: nil, action: { (row) in
                    let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                    alertController.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel, handler: { (row) in
                        self.tableView.reloadData()
                    }))
                    Locale.commonLanguages.sorted().forEach { (locale) in
                        alertController.addAction(UIAlertAction(title: locale, style: .default, handler: { (action) in
                            self.saveSetting(key: "defaultLanguage", value: locale)
                        }))
                    }
                    self.present(alertController, animated: true, completion: nil)
                }, accessoryButtonAction: nil),
                NavigationRow(text: "Default font family".localized, detailText: .value1(self.loadSetting(key: "defaultFontFamily") as? String ?? "System".localized), action: { (row) in
                    let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                    alertController.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel, handler: { (row) in
                        self.tableView.reloadData()
                    }))
                    
                    var fontNames = UIFont.familyNames
                    fontNames.append(UIFont.boldSystemFont(ofSize: 13).familyName)
                    
                    fontNames.sorted().forEach { (family) in
                        alertController.addAction(UIAlertAction(title: family, style: .default, handler: { (action) in
                            self.saveSetting(key: "defaultFontFamily", value: family)
                        }))
                    }
                    self.present(alertController, animated: true, completion: nil)
                }),
                NavigationRow(text: "Default font size".localized, detailText: .value1(SubtitleSettings.Size(rawValue: self.loadSetting(key: "defaultFontSize") as? Float ?? 15)?.localizedString ?? "Medium"), icon: nil, customization: nil, action: { (row) in
                    let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                    alertController.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel, handler: { (row) in
                        self.tableView.reloadData()
                    }))
                    SubtitleSettings.Size.array.forEach { (size) in
                        alertController.addAction(UIAlertAction(title: size.localizedString, style: .default, handler: { (action) in
                            self.saveSetting(key: "defaultFontSize", value: Float(size.rawValue))
                        }))
                    }
                    self.present(alertController, animated: true, completion: nil)
                }, accessoryButtonAction: nil)
            ]),
            Section(title: "UI".localized, rows: [
                SwitchRow(text: "Use 3 columns".localized, switchValue: self.loadSetting(key: "useThreeColumns") as? Bool ?? false, action: { (row) in
                    self.saveSetting(key: "useThreeColumns", value: !(self.loadSetting(key: "useThreeColumns") as? Bool ?? false))
                    
                    
                    let alertController = UIAlertController(title: "Changes Saved".localized, message: "Popcorn needs to be relaunched for the changes to take effect correctly.".localized, preferredStyle: .actionSheet)
                    alertController.addAction((UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil)))
                    alertController.addAction(UIAlertAction(title: "Exit".localized, style: .destructive, handler: { (action) in
                        exit(0)
                    }))
                    self.present(alertController, animated: true, completion: nil)
                }),
                SwitchRow(text: "Display media titles".localized, switchValue: self.loadSetting(key: "displayMediaTitles") as? Bool ?? false, action: { (row) in
                    self.saveSetting(key: "displayMediaTitles", value: !(self.loadSetting(key: "displayMediaTitles") as? Bool ?? false))
                    
                    
                    let alertController = UIAlertController(title: "Changes Saved".localized, message: "Popcorn needs to be relaunched for the changes to take effect correctly.".localized, preferredStyle: .actionSheet)
                    alertController.addAction((UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil)))
                    alertController.addAction(UIAlertAction(title: "Exit".localized, style: .destructive, handler: { (action) in
                        exit(0)
                    }))
                    self.present(alertController, animated: true, completion: nil)
                })
            ]),
            Section(title: "Credits".localized, rows: [
                NavigationRow(text: "Spanish Translation".localized, detailText: .value1("@cachetes092"), action: { (row) in
                    if UIApplication.shared.canOpenURL(URL(string: "https://twitter.com/cachetes092")!) {
                        UIApplication.shared.open(URL(string: "https://twitter.com/cachetes092")!)
                    }
                })
            ], footer: "Submit subtitles for other languages to @antique_dev on Twitter to help translate Popcorn and get listed above!".localized),
            Section(title: String(format: "%@ (%i)", "Patrons".localized, people.count), rows: rows, footer: "Thank you to all the patrons who have and are still continuing to support Popcorn!".localized),
            Section(title: "Icons", rows: [
                NavigationRow(text: "Popcorn", detailText: .subtitle("Introduced in v2.1"), icon: .image(UIImage(named: "newpopcorn")!), action: { (row) in
                    self.changeIcon(to: nil)
                    self.tableView.reloadData()
                }, accessoryButtonAction: nil),
                NavigationRow(text: "Old Popcorn", detailText: .subtitle("Introduced in v1.x"), icon: .image(UIImage(named: "oldpopcorn")!), action: { (row) in
                    self.changeIcon(to: "oldpopcorn")
                    self.tableView.reloadData()
                }, accessoryButtonAction: nil),
                NavigationRow(text: "PopcornTime", detailText: .subtitle("The original PopcornTime icon"), icon: .image(UIImage(named: "popcorntime")!), action: { (row) in
                    self.changeIcon(to: "popcorntime")
                    self.tableView.reloadData()
                }, accessoryButtonAction: nil)
            ])
        ]
    }
    
    
    func setup() {
        setupNavigationBar()
    }
    
    
    func setupNavigationBar() {
        title = "Settings".localized
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.setLeftBarButton(UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeSettings)), animated: true)
        navigationItem.setRightBarButton(UIBarButtonItem(image: UIImage(systemName: "exclamationmark.octagon"), style: .plain, target: self, action: #selector(resetSettings)), animated: true)
        navigationItem.rightBarButtonItem?.tintColor = .systemRed
    }
    
    
    @objc func closeSettings() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func resetSettings() {
        let alertController = UIAlertController(title: "Reset".localized, message: "This will reset all settings to their default values, are you sure you want to continue?".localized, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Reset".localized, style: .destructive, handler: { (action) in
            self.saveSetting(key: "clearCacheOnExit", value: false)
            
            self.saveSetting(key: "minimumSubtitleRating", value: 8.0)
            self.saveSetting(key: "defaultLanguage", value: "None")
            self.saveSetting(key: "defaultFontSize", value: 13)
            self.saveSetting(key: "defaultFontFamily", value: UIFont.boldSystemFont(ofSize: 13).familyName)
            
            self.saveSetting(key: "useThreeColumns", value: false)
            self.saveSetting(key: "displayMediaTitles", value: false)
            
            
            let alertController = UIAlertController(title: "Done".localized, message: nil, preferredStyle: .actionSheet)
            self.present(alertController, animated: true, completion: nil)
                
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.5) {
                alertController.dismiss(animated: true, completion: nil)
            }
        }))
        
        present(alertController, animated: true, completion: nil)
    }
    
    
    func saveSetting(key: String, value: Any) {
        UserDefaults.standard.set(value, forKey: key)
        tableView.reloadData()
    }
    
    func loadSetting(key: String) -> Any? {
        return UserDefaults.standard.value(forKey: key)
    }
    
    
    func changeIcon(to iconName: String?) {
        guard UIApplication.shared.supportsAlternateIcons else {
            return
        }
        
        UIApplication.shared.setAlternateIconName(iconName, completionHandler: { (error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("App icon changed successfully")
            }
        })
    }
}
