//
//  ViewController.swift
//  WCalendar
//
//  Created by WaiLynnZaw on 8/17/17.
//  Copyright © 2017 moandlab. All rights reserved.
//

import UIKit
import JTAppleCalendar
class ViewController: UIViewController {
    let formatter = DateFormatter()
    @IBOutlet var calendarView: JTAppleCalendarView!
    @IBOutlet var monthLabel: UILabel!
    @IBOutlet var departDay: UILabel!
    @IBOutlet var departMonth: UILabel!
    @IBOutlet var departWDay: UILabel!
    @IBOutlet var departHighLightView: UIView!
    @IBOutlet var returnDay: UILabel!
    @IBOutlet var returnMonth: UILabel!
    @IBOutlet var returnWDay: UILabel!
    @IBOutlet var returnHighlightView: UIView!
    
    var firstDate: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpCalendarView()
    }
    
    func setUpCalendarView(){
        calendarView.minimumLineSpacing = 0
        calendarView.minimumInteritemSpacing = 0
        calendarView.allowsMultipleSelection = true
        calendarView.isRangeSelectionUsed = true
        calendarView.visibleDates { (visibleDates) in
            self.setupViewsOfCalendar(from: visibleDates)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func handleCellSelected(_ view: JTAppleCell?, cellState: CellState) {
        guard let validCell = view as? DateCell else { return }
        
        switch cellState.selectedPosition() {
        case .full:
            validCell.selectedView.isHidden = false
            validCell.middleView.isHidden = true
            validCell.leftView.isHidden = true
            validCell.rightView.isHidden = true
        case .left:
            validCell.selectedView.isHidden = false
            validCell.middleView.isHidden = true
            validCell.leftView.isHidden = false
            validCell.rightView.isHidden = true
        case .right:
            validCell.selectedView.isHidden = false
            validCell.middleView.isHidden = true
            validCell.leftView.isHidden = true
            validCell.rightView.isHidden = false
        case .middle:
            validCell.selectedView.isHidden = true
            validCell.middleView.isHidden = false
            validCell.leftView.isHidden = true
            validCell.rightView.isHidden = true
        default:
            validCell.selectedView.isHidden = true
            validCell.middleView.isHidden = true
            validCell.leftView.isHidden = true
            validCell.rightView.isHidden = true
        }
    }
    func handleCellTextColor(_ view: JTAppleCell?, cellState: CellState) {
        guard let validCell = view as? DateCell else { return }
        if cellState.isSelected {
            validCell.dateLabel.textColor = UIColor.white
        } else {
            if cellState.dateBelongsTo == .thisMonth {
                validCell.dateLabel.textColor = UIColor.darkGray
            } else {
                validCell.dateLabel.textColor = UIColor.lightGray
            }
        }
    }
    
    func setupViewsOfCalendar(from visibleDates: DateSegmentInfo) {
        let date =  visibleDates.monthDates.first!.date
        
        self.formatter.dateFormat = "MMMM yyyy"
        self.monthLabel.text = self.formatter.string(from: date)
        self.showHeaderDate(date, date)
        self.departHighLightView.isHidden = false
        self.returnHighlightView.isHidden = true

    }
    
    func showHeaderDate(_ depart: Date, _ returnDate: Date){
        self.formatter.dateFormat = "dd"
        self.departDay.text = self.formatter.string(from: depart)
        self.returnDay.text = self.formatter.string(from: returnDate)
        
        self.formatter.dateFormat = "MMM"
        self.departMonth.text = self.formatter.string(from: depart)
        self.returnMonth.text = self.formatter.string(from: returnDate)
        
        self.formatter.dateFormat = "EEE"
        self.departWDay.text = self.formatter.string(from: depart)
        self.returnWDay.text = self.formatter.string(from: returnDate)
    }
    
    @IBAction func doneAction(_ sender: UIBarButtonItem) {
        let selectedDates = calendarView.selectedDates
        formatter.dateFormat = "yyyy-MM-dd"
        print("FROM \(formatter.string(from: selectedDates.first!)) -> TO \(formatter.string(from: selectedDates.last!))")
        
    }
    
}
extension ViewController: JTAppleCalendarViewDataSource {
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        formatter.dateFormat = "yyyy MM dd"
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale
        
        let startDate = Date()
        let endDate = formatter.date(from: "2100 12 31")
        
        let parameters = ConfigurationParameters(startDate: startDate, endDate: endDate!, calendar: Calendar.current)
        return parameters
    }
}

extension ViewController: JTAppleCalendarViewDelegate {
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "dateCell", for: indexPath) as! DateCell
        cell.dateLabel.text = cellState.text
        handleCellTextColor(cell, cellState: cellState)
        handleCellSelected(cell, cellState: cellState)
        return cell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        handleCellTextColor(cell, cellState: cellState)
        handleCellSelected(cell, cellState: cellState)
        if firstDate != nil {
            calendarView.selectDates(from: firstDate!, to: date,  triggerSelectionDelegate: false, keepSelectionIfMultiSelectionAllowed: true)
            showHeaderDate(firstDate!, date)
        } else {
            firstDate = date
        }
    }
    
    func calendar(_ calendar: JTAppleCalendarView, shouldSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) -> Bool {
        let selectedDates = calendar.selectedDates
        if selectedDates.contains(date) {
        if (selectedDates.count > 2 && selectedDates.first != date && selectedDates.last != date) {
                let indexOfDate = selectedDates.index(of: date)
                let dateBeforeDeselectedDate = selectedDates[indexOfDate!-1]
                calendar.deselectAllDates()
                calendar.selectDates(
                    from: selectedDates.first!,
                    to: dateBeforeDeselectedDate,
                    triggerSelectionDelegate: true,
                    keepSelectionIfMultiSelectionAllowed: true)
                calendar.reloadData()
            }
            
        }
        return true
    }
    
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        handleCellTextColor(cell, cellState: cellState)
        handleCellSelected(cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        setupViewsOfCalendar(from: visibleDates)
    }
}
