//
//  ViewController.swift
//  SQLiteExemple
//
//  Created by João on 02/11/20.
//  Copyright © 2020 João. All rights reserved.
//

import UIKit
import CryptoKit
import SQLite

class ViewController: UIViewController {
    
    let db = try! Connection("/Users/joao/Documents/Projects/SQLiteExemple/SQLiteExemple/database.db")
    
    let response = """
    {
        "UPDATE": [
                    {
                        "attribute01": "Loja",
                        "attribute02": 10,
                        "attribute03": 123.5,
                        "attribute04": "Casa",
                        "attribute05": "Order",
                        "attribute06": 1288,
                        "attribute07": 158.88
                    },
                    {
                        "attribute01": "Maior",
                        "attribute02": 58,
                        "attribute03": 698.5,
                        "attribute04": "Ap",
                        "attribute05": "Bud",
                        "attribute06": 2587,
                        "attribute07": 368.55
                    }
                ],
        "TABLE": "SALES_ORDER"
    }
    """.uppercased()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = URL(string: "https://swiftquiz-app.herokuapp.com/question")!
        
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            if let _ = data {
//                let response = String(data: data, encoding: .utf8)
        
                var path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last!
                let pathFileTFSync = path + "/marvel.tfsync"
                
                try! self.response.write(toFile: pathFileTFSync, atomically: true, encoding: .utf8)
                let dataFromPath = NSData(contentsOfFile: pathFileTFSync)
                let dataStr = String(data: dataFromPath! as Data, encoding: .utf8)!
                
                let json = try! JSONSerialization.jsonObject(with: dataFromPath! as Data, options: .mutableContainers) as? [String: Any]
                
//                print("Path: " + path)
//                print("Data from responde: \(response ?? "")")
//                print("Data string: \(dataStr)")
//                print("Data from path: \(dataFromPath)")
                print(json)
                let table = json!["TABLE"] as! String
                let update = json!["UPDATE"] as! [[String: Any]]
                self.deleteTable()
                for i in 0..<update.count {
                    var columns = ""
                    var values = ""
                    let element = update[i]
                    for (column, value) in element {
                        columns += "\(column), "
                        values += value is String ? "'\(value)', " : "\(value), "
                    }
                    columns.removeSubrange(columns.index(columns.endIndex, offsetBy: -2)..<columns.endIndex)
                    values.removeSubrange(values.index(values.endIndex, offsetBy: -2)..<values.endIndex)
                    let insertSql = "INSERT INTO \(table) (\(columns)) VALUES (\(values))"
                    print(insertSql)
                    try! self.db.execute(insertSql)
                }
                
            }
        }
        
        task.resume()
    }
    
    func createFinalUrl() -> String {
        let ts = Int(Date().timeIntervalSince1970)
        let privateKey = "833c93cf646d4326ffd8593ab545dab0b98537c6"
        let publicKey = "c002e5302091a328f109e13314d9f017"
        let tsAndKeys = String(ts) + privateKey + publicKey
        
        return "http://gateway.marvel.com/v1/public/characters?ts=\(ts)&apikey=\(publicKey)&hash=\(MD5(string: tsAndKeys))"
    }

    func MD5(string: String) -> String {
        let md5 = Insecure.MD5.hash(data: string.data(using: .utf8) ?? Data())
        return md5.map {
            String(format: "%02hhx", $0)
        }.joined()
    }
    
    func deleteTable() {
        try! db.execute("DELETE FROM SALES_ORDER")
    }
    
}

