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
//        if validCell.isSelected {
//            validCell.selectedView.isHidden = false
//        } else {
//            validCell.selectedView.isHidden = true
//        }
        switch cellState.selectedPosition() {
        case .full, .left, .right:
            validCell.selectedView.isHidden = false
            validCell.selectedView.backgroundColor = UIColor.yellow // Or you can put what ever you like for your rounded corners, and your stand-alone selected cell
        case .middle:
            validCell.selectedView.isHidden = false
            validCell.selectedView.backgroundColor = UIColor.blue // Or what ever you want for your dates that land in the middle
        default:
            validCell.selectedView.isHidden = true
            validCell.selectedView.backgroundColor = nil // Have no selection when a cell is not selected
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
    }

}
extension ViewController: JTAppleCalendarViewDataSource {
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        formatter.dateFormat = "yyyy MM dd"
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale

        let startDate = formatter.date(from: "2017 01 01")
        let endDate = formatter.date(from: "2017 12 31")

        let parameters = ConfigurationParameters(startDate: startDate!, endDate: endDate!)
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
        } else {
            firstDate = date
        }
    }

    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        handleCellTextColor(cell, cellState: cellState)
        handleCellSelected(cell, cellState: cellState)
    }

    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        setupViewsOfCalendar(from: visibleDates)
    }
}
