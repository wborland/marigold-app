//
//  CoreDataHelper.swift
//  MariGold
//
//  Created by Devin Sova on 3/3/18.
//  Copyright © 2018 MariGold. All rights reserved.
//

import UIKit
import CoreData

struct CoreDataHelper {
	static let context: NSManagedObjectContext = {
		guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
			fatalError()
		}
		let context = appDelegate.persistentContainer.viewContext
		return context
	}()
	
	static func newMed() -> Medication {
		let med = NSEntityDescription.insertNewObject(forEntityName: "Medication", into: context) as! Medication
		return med
	}
	
	static func deleteMed(medication: Medication) {
		context.delete(medication)
		saveCoreData()
	}
	
	static func deleteAllMeds() {
		for med in retrieveMeds() {
			deleteMed(medication: med)
		}
		saveCoreData()
	}
	
	static func retrieveMeds() -> [Medication] {
		do {
			let fetchRequest = NSFetchRequest<Medication>(entityName: "Medication")
			let results = try context.fetch(fetchRequest)
			return results
		} catch let error {
			NSLog("Could not fetch \(error.localizedDescription)")
			return []
		}
	}
	
	static func saveCoreData() {
		do {
			try context.save()
		} catch let error {
			NSLog("Could not save \(error.localizedDescription)")
		}
	}
	
	static func newConflict() -> Conflict {
		let conf = NSEntityDescription.insertNewObject(forEntityName: "Conflict", into: context) as! Conflict
		return conf
	}
	
	static func deleteConflict(conflict: Conflict) {
		context.delete(conflict)
		saveCoreData()
	}
	
	static func deleteAllConflicts() {
		for conf in retrieveAllConflicts() {
			deleteConflict(conflict: conf)
		}
		saveCoreData()
	}
	
	static func retrieveAllConflicts() -> [Conflict] {
		do {
			let fetchRequest = NSFetchRequest<Conflict>(entityName: "Conflict")
			let results = try context.fetch(fetchRequest)
			return results
		} catch let error {
			NSLog("Could not fetch \(error.localizedDescription)")
			return []
		}
	}
	
	static func retrieveConflictsForID(id: Int) -> [Conflict] {
		let conflicts = retrieveAllConflicts()
		var validConflicts = [Conflict]()
		for conf in conflicts {
			if(conf.drug1id == id || conf.drug2id == id) {
				validConflicts.append(conf)
			}
		}
		return validConflicts
	}
}
