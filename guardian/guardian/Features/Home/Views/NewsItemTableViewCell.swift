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
  override func prepareForReuse() {
    super.prepareForReuse()
    imageView?.kf.cancelDownloadTask()
    // second, prevent kingfisher from setting previous image
    imageView?.kf.setImage(with: URL(string: ""))
    imageView?.image = nil
  }

  func configure(newsItem: News) {
    self.title.text = newsItem.webTitle?.trimmed()
    self.body.text = newsItem.fields?.body?.stripOutHtml().trimmed()
    self.date.text = newsItem.formattedDate().trimmed()

    // set thumbnail
    if let imageUrl = newsItem.fields?.thumbnail, let url = URL(string: imageUrl) {
      self.thumbnail.kf.indicatorType = .activity
      self.thumbnail.kf.setImage(with: url, options: [.transition(.fade(0.3))])
      self.thumbnail.layer.cornerRadius = 8
      self.thumbnail.clipsToBounds = true
    }
  }
}
