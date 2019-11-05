# WhatFlower

*** PLEASE NOTE THAT A CLONE OF THIS REPOSITORY WILL NOT COMPILE DUE TO THE "flowerclassification.mlmodel" FILE BEING TOO LARGE TO UPLOAD TO GITHUB


An app that uses machine learning to classify the name of any flower from its image.

Features: The view was designed using Autolayout and UIKit. I used Cocoapods to install the, Alamofire, SwiftyJSON, and SDWebImage frameworks. An Image Picker allows the user to choose a photo to analyze from their saved photos album. I used  Python PIP to convert a pre-trained model into the .mlmodel format to be used with Core ML. The chosen photo is then anazlyzed by the machine to determine which type of flower is shown. With Alamofire and SwiftyJSON a network request is sent to Wikipedia to get a description of the flower. SDWebImage is used to show a photo of the flower along with the description.
