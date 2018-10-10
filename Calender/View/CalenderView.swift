//
//  CalenderView.swift
//  myCalender2
//
//  Created by Muskan on 10/22/17.
//  Updated by Jahid Hasan Polash: jahidhasanpolash@gmail.com
//  Copyright © 2017 akhil. All rights reserved.
//

import UIKit

struct Colors {
    static var darkGray = #colorLiteral(red: 0.3764705882, green: 0.3647058824, blue: 0.3647058824, alpha: 1)
}

struct Style {
    static var bgColor = UIColor.white
    static var monthViewLblColor = UIColor.black
    static var monthViewBtnRightColor = UIColor.black
    static var monthViewBtnLeftColor = UIColor.black
    static var activeCellLblColor = UIColor.white
    static var activeCellLblColorHighlighted = UIColor.black
    static var weekdaysLblColor = UIColor.black
    
    static func themeDark(){
        bgColor = Colors.darkGray
        monthViewLblColor = UIColor.white
        monthViewBtnRightColor = UIColor.white
        monthViewBtnLeftColor = UIColor.white
        activeCellLblColor = UIColor.white
        activeCellLblColorHighlighted = UIColor.black
        weekdaysLblColor = UIColor.white
    }
    
    static func themeLight(){
        bgColor = UIColor.white
        monthViewLblColor = UIColor.black
        monthViewBtnRightColor = UIColor.black
        monthViewBtnLeftColor = UIColor.black
        activeCellLblColor = UIColor.black
        activeCellLblColorHighlighted = UIColor.white
        weekdaysLblColor = UIColor.black
    }
}

class CalenderView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, MonthViewDelegate {
    var delegate: CalenderDelegate?
    
    var numOfDaysInMonth = [31,28,31,30,31,30,31,31,30,31,30,31]
    var currentMonthIndex: Int = 0
    var currentYear: Int = 0
    var presentMonthIndex = 0
    var presentYear = 0
    var todaysDate = 0
    var firstWeekDayOfMonth = 0   //(Sunday-Saturday 1-7)
  
    var bookedSlotDate = [12,27,6]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initializeView()
    }
    
    convenience init(theme: MyTheme) {
        self.init()
        
        if theme == .dark {
            Style.themeDark()
        } else {
            Style.themeLight()
        }
        
        initializeView()
        setTheme()
    }
    // Author: Jahid Hasan Polash
    // Forgot to set the theme initially
    func setTheme() {
        backgroundColor = Style.bgColor
        monthView.lblName.textColor = Style.monthViewLblColor
        // month view button colors can't be changed to white
        // because they are images not in Assets.xcassets
        // and not rendering as template image
        for view in weekdaysView.myStackView.arrangedSubviews {
            if let label = view as? UILabel {
                label.textColor = Style.weekdaysLblColor
            }
        }
    }
    
    func changeTheme() {
        myCollectionView.reloadData()
        
        monthView.lblName.textColor = Style.monthViewLblColor
        monthView.btnRight.setTitleColor(Style.monthViewBtnRightColor, for: .normal)
        monthView.btnLeft.setTitleColor(Style.monthViewBtnLeftColor, for: .normal)
        
        for i in 0..<7 {
            (weekdaysView.myStackView.subviews[i] as! UILabel).textColor = Style.weekdaysLblColor
        }
    }
    
    func initializeView() {
        currentMonthIndex = Calendar.current.component(.month, from: Date())
        currentYear = Calendar.current.component(.year, from: Date())
        todaysDate = Calendar.current.component(.day, from: Date())
        firstWeekDayOfMonth=getFirstWeekDay()
        
        //for leap years, make february month of 29 days
        if currentMonthIndex == 2 && currentYear % 4 == 0 {
            numOfDaysInMonth[currentMonthIndex-1] = 29
        }
        //end
        
        presentMonthIndex=currentMonthIndex
        presentYear=currentYear
        
        setupViews()
        addSwipeGestureToCollectionView()
        
        myCollectionView.delegate=self
        myCollectionView.dataSource=self
        myCollectionView.register(dateCVCell.self, forCellWithReuseIdentifier: "Cell")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numOfDaysInMonth[currentMonthIndex-1] + firstWeekDayOfMonth - 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell=collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! dateCVCell
        cell.backgroundColor=UIColor.clear
        if indexPath.item <= firstWeekDayOfMonth - 2 {
            cell.isHidden=true
        } else {
            let calcDate = indexPath.row-firstWeekDayOfMonth+2
            cell.isHidden=false
            cell.dateLbl.text="\(calcDate)"
            cell.isUserInteractionEnabled=true
            if calcDate == todaysDate && currentYear == presentYear && currentMonthIndex == presentMonthIndex  {
                cell.dateLbl.textColor = UIColor.white
                cell.currentDateBackgroundView.backgroundColor = CustomSetup.selectedBackgroundColor
                if bookedSlotDate.contains(calcDate){
                    cell.selectorView.backgroundColor = CustomSetup.selectorColor
                } else {
                    cell.selectorView.backgroundColor = UIColor.clear
                }
            }
            else {
                cell.dateLbl.textColor = Style.activeCellLblColor
                cell.currentDateBackgroundView.backgroundColor = .clear
                if bookedSlotDate.contains(calcDate){
                    cell.selectorView.backgroundColor = CustomSetup.selectorColor
                } else {
                    cell.selectorView.backgroundColor = UIColor.clear
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let calcDate = indexPath.row-firstWeekDayOfMonth+2
       delegate?.didTapDate(date: "Date:\(calcDate)/\(currentMonthIndex)/\(currentYear)", available: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width/7 - 8
        let devider: Double = ceil(Double(collectionView.numberOfItems(inSection: indexPath.section))/7.0)
        let height: CGFloat = (collectionView.bounds.height/CGFloat(devider))-8
        return CGSize(width: width, height: height)
    }
    // Utility Func
    // Author Jahid Hasan Polash
    func toNextInt(_ num: CGFloat) -> CGFloat {
        let ceilNum = ceil(num)
        if ceilNum < num {
            return ceilNum + 1
        }
        return ceilNum
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8.0
    }
    
    func getFirstWeekDay() -> Int {
        let day = ("\(currentYear)-\(currentMonthIndex)-01".date?.firstDayOfTheMonth.weekday)!
//        It was a logical error. Fixed
//        Author: Jahid Hasan Polash
//        return day == 7 ? 1 : day
        return day
    }
    
    func didChangeMonth(monthIndex: Int, year: Int) {
        currentMonthIndex=monthIndex+1
        print(currentMonthIndex)
        currentYear = year
        
        //for leap year, make february month of 29 days
        if monthIndex == 1 {
            if currentYear % 4 == 0 {
                numOfDaysInMonth[monthIndex] = 29
            } else {
                numOfDaysInMonth[monthIndex] = 28
            }
        }
        //end
        
        firstWeekDayOfMonth=getFirstWeekDay()
        
        myCollectionView.reloadData()
        
//        monthView.btnLeft.isEnabled = !(currentMonthIndex == presentMonthIndex && currentYear == presentYear)
    }
    
    func setupViews() {
        addSubview(monthView)
        monthView.topAnchor.constraint(equalTo: topAnchor).isActive=true
        monthView.leftAnchor.constraint(equalTo: leftAnchor).isActive=true
        monthView.rightAnchor.constraint(equalTo: rightAnchor).isActive=true
        monthView.heightAnchor.constraint(equalToConstant: UIDevice.current.userInterfaceIdiom == .pad ? 60 : 40).isActive=true
        monthView.delegate=self
        
        addSubview(weekdaysView)
        weekdaysView.topAnchor.constraint(equalTo: monthView.bottomAnchor, constant: UIDevice.current.userInterfaceIdiom == .pad ? 24 : 0).isActive=true
        weekdaysView.leftAnchor.constraint(equalTo: leftAnchor).isActive=true
        weekdaysView.rightAnchor.constraint(equalTo: rightAnchor).isActive=true
        weekdaysView.heightAnchor.constraint(equalToConstant: 30).isActive=true
        
        addSubview(myCollectionView)
        myCollectionView.topAnchor.constraint(equalTo: weekdaysView.bottomAnchor, constant: 0).isActive=true
        myCollectionView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive=true
        myCollectionView.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive=true
        myCollectionView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive=true
    }
    // Author: Jahid Hasan Polash
    func addSwipeGestureToCollectionView() {
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(calenderSwipedToRight(_:)))
        swipeRight.direction = .right
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(calenderSwipedToLeft(_:)))
        swipeLeft.direction = .left
        myCollectionView.addGestureRecognizer(swipeRight)
        myCollectionView.addGestureRecognizer(swipeLeft)
    }
    
    @objc func calenderSwipedToRight(_ sender: UISwipeGestureRecognizer) {
        monthView.currentMonthIndex -= 1
        if monthView.currentMonthIndex < 0 {
            monthView.currentMonthIndex = 11
            monthView.currentYear -= 1
        }
        monthView.lblName.text="\(monthView.monthsArr[monthView.currentMonthIndex]) \(monthView.currentYear)"
        monthView.delegate?.didChangeMonth(monthIndex: monthView.currentMonthIndex, year: monthView.currentYear)
    }
    
    @objc func calenderSwipedToLeft(_ sender: UISwipeGestureRecognizer) {
        monthView.currentMonthIndex += 1
        if monthView.currentMonthIndex > 11 {
            monthView.currentMonthIndex = 0
            monthView.currentYear += 1
        }
        monthView.lblName.text="\(monthView.monthsArr[monthView.currentMonthIndex]) \(monthView.currentYear)"
        monthView.delegate?.didChangeMonth(monthIndex: monthView.currentMonthIndex, year: monthView.currentYear)
    }
    
    let monthView: MonthView = {
        let v=MonthView()
        v.translatesAutoresizingMaskIntoConstraints=false
        return v
    }()
    
    let weekdaysView: WeekdaysView = {
        let v=WeekdaysView()
        v.translatesAutoresizingMaskIntoConstraints=false
        return v
    }()
    
    let myCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        let myCollectionView=UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        myCollectionView.showsHorizontalScrollIndicator = false
        myCollectionView.translatesAutoresizingMaskIntoConstraints=false
        myCollectionView.backgroundColor=UIColor.clear
        myCollectionView.allowsMultipleSelection=false
        return myCollectionView
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


protocol CalenderDelegate {
    func didTapDate(date:String, available:Bool)
}
class dateCVCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor=UIColor.clear
        setupViews()
    }
    
    func setupViews() {
        addSubview(currentDateBackgroundView)
        addSubview(dateLbl)
        addSubview(selectorView)
        
        dateLbl.leftAnchor.constraint(equalTo: leftAnchor).isActive=true
        dateLbl.rightAnchor.constraint(equalTo: rightAnchor).isActive=true
        dateLbl.bottomAnchor.constraint(equalTo: selectorView.topAnchor, constant: UIDevice.current.userInterfaceIdiom == .pad ? -16 : -8).isActive=true
        dateLbl.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        selectorView.heightAnchor.constraint(equalToConstant: UIDevice.current.userInterfaceIdiom == .pad ? 8 : 4).isActive = true
        selectorView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: UIDevice.current.userInterfaceIdiom == .pad ? 0.5 : 0.75).isActive = true
        selectorView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        currentDateBackgroundView.centerXAnchor.constraint(equalTo: dateLbl.centerXAnchor).isActive = true
        currentDateBackgroundView.centerYAnchor.constraint(equalTo: dateLbl.centerYAnchor).isActive = true
        currentDateBackgroundView.heightAnchor.constraint(equalToConstant: UIDevice.current.userInterfaceIdiom == .pad ? 40 : 24).isActive = true
        currentDateBackgroundView.widthAnchor.constraint(equalToConstant: UIDevice.current.userInterfaceIdiom == .pad ? 40 : 24).isActive = true
        currentDateBackgroundView.layer.cornerRadius = UIDevice.current.userInterfaceIdiom == .pad ? 20 : 12
        currentDateBackgroundView.layer.masksToBounds = true
    }
    
    let dateLbl: UILabel = {
        let label = UILabel()
        label.text = "00"
        label.textAlignment = .center
        label.font=CustomSetup.labelFont
        label.textColor=Colors.darkGray
        label.translatesAutoresizingMaskIntoConstraints=false
        return label
    }()
    
    let selectorView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.clear
        v.translatesAutoresizingMaskIntoConstraints=false
        return v
    }()
    
    let currentDateBackgroundView: UIView = {
        let roundView = UIView()
        roundView.backgroundColor = UIColor.clear
        roundView.translatesAutoresizingMaskIntoConstraints = false
        return roundView
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//get first day of the month
extension Date {
    var weekday: Int {
        return Calendar.current.component(.weekday, from: self)
    }
    var firstDayOfTheMonth: Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year,.month], from: self))!
    }
}

//get date from string
extension String {
    static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    var date: Date? {
        return String.dateFormatter.date(from: self)
    }
}
