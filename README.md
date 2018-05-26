# Classifi

[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/nextseto/Classifi/master/LICENSE)

An open source iOS application and nodeJS backend that allows Machine Learning engineers with the ability to deploy trained machine learning models to iOS 11 compatible devices and collect training data for further research and network development. 

## Repository contains...

 - **mobile-application**: iOS application using CoreML (put in your own MLModel for image classification)
 - **external-server**: nodeJS application to forward iOS application payloads to an `internal` server
 - **internal-server**: nodeJS application to store transfered images

## Requirements

- 10.13+ High Sierra
- iOS 11+
- Xcode 9.2+ (with Swift 4 support)

## License

All source code in **Classifi** is released under the MIT license. See LICENSE for details.
