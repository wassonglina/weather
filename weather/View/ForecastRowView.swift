//
//  ForecastRowView.swift
//  Weather Pal
//
//  Created by Lina on 5/3/22.
//

import UIKit


class ForecastRowView: UIStackView {

    private let label = ForecastLabel()
    private let imageView = UIImageView()
    private let tempMinLabel = ForecastLabel()
    private let tempMaxLabel = ForecastLabel()

    init() {
        super.init(frame: .zero)
        spacing = 22
        alignment = .center
        addArrangedSubview(label)
        addArrangedSubview(imageView)
        let tempStack = UIStackView()
        let hyphen = ForecastLabel()
        hyphen.text = " - "
        addArrangedSubview(tempStack)
        tempStack.addArrangedSubview(tempMinLabel)
        tempStack.addArrangedSubview(hyphen)
        tempStack.addArrangedSubview(tempMaxLabel)
        imageView.tintColor = .white
        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor).isActive = true
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(day: String, image: UIImage, minTemp: String, maxTemp: String) {
        label.text = day
        imageView.image = image
        tempMinLabel.text = minTemp
        tempMaxLabel.text = maxTemp

    }

}


private class ForecastLabel: UILabel {

    init() {
        super.init(frame: .zero)
        let forecastFont = UIFont.scriptFont(size: 20, style: .medium)
        self.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: forecastFont)
        self.adjustsFontForContentSizeCategory = true
        self.textColor = .white
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
