//
//  NewsItemTableViewCell.swift
//  guardian
//
//  Created by Sachin Rao on 05/12/21.
//

import UIKit

class NewsItemTableViewCell: UITableViewCell, ReusableCell, NibLoadableView {
  @IBOutlet var thumbnail: UIImageView!
  @IBOutlet var title: UILabel!
  @IBOutlet var body: UILabel!
  @IBOutlet var date: UILabel!
  func configure(newsItem: News) {
    self.title.text = newsItem.webTitle
    self.body.text = newsItem.fields?.body?.stripOutHtml()

    let currentFormatter = DateFormatter()
    currentFormatter.dateFormat = "dd-MMMM-yyyy hh:mm:ss a"
    self.date.text = currentFormatter.string(from: newsItem.dateTime())

    // set thumbnail
    let imageUrl = URL(string: (newsItem.fields?.thumbnail)!)
    self.thumbnail.kf.indicatorType = .activity
    self.thumbnail.kf.setImage(with: imageUrl, options: [.transition(.fade(0.2))])
    self.thumbnail.layer.cornerRadius = 8
    self.thumbnail.clipsToBounds = true
  }
}
