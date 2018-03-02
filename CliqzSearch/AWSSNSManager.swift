//
//  AWSSNSManager.swift
//  Client
//
//  Created by Sahakyan on 4/19/16.
//  Copyright © 2016 Mozilla. All rights reserved.
//

import Foundation

class AWSSNSManager {
    //MARK: - Internal Variables
    static let cognitoRegionID = AWSRegionType.usEast1
    private static let cognitoIdentityPoolID = "us-east-1:81faca92-4d48-437c-ad68-e28ca03411fe"
    
#if BETA
    
    // Debug
//    private static let notificationTopic = "arn:aws:sns:us-east-1:141047255820:mobile_news_staging"
//    private static let SNSAplicationArn = "arn:aws:sns:us-east-1:141047255820:app/APNS_SANDBOX/Cliqz_Beta_for_iOS"

    // TestFlight
    private static let notificationTopic = "arn:aws:sns:us-east-1:141047255820:mobile_news"
    private static let SNSAplicationArn = "arn:aws:sns:us-east-1:141047255820:app/APNS/Cliqz_Beta_Production_for_iOS"

#else
    // Note that we only subscribe for one topic and all notifications are sent to all users as a silent notification then will be filtered on the client side
    private static let notificationTopic = "arn:aws:sns:us-east-1:141047255820:mobile_news"
    
    // Release
    private static let SNSAplicationArn = "arn:aws:sns:us-east-1:141047255820:app/APNS/CLIQZ_Browser_for_iOS"
#endif
    
    private static let tokenKey = "DeviceToken"
    
    //MARK: - Public APIs
	class func configureCongnitoPool() {
		let credentialsProvider = AWSCognitoCredentialsProvider(
			regionType: cognitoRegionID,
			identityPoolId: cognitoIdentityPoolID)
		let defaultServiceConfiguration = AWSServiceConfiguration(
			region: cognitoRegionID,
			credentialsProvider: credentialsProvider)
		AWSServiceManager.default().defaultServiceConfiguration = defaultServiceConfiguration
	}
	
	class func createPlatformEndpoint(withDeviceToken deviceToken: String, completionHandler: @escaping (Bool) -> Void) {
		if let oldToken = (LocalDataStore.objectForKey(tokenKey) as? String), oldToken == deviceToken {
			return
		}

		let sns = AWSSNS.default()
		let request = AWSSNSCreatePlatformEndpointInput()
		request?.token = deviceToken
		request?.platformApplicationArn = SNSAplicationArn
		sns.createPlatformEndpoint(request!).continue(with: AWSExecutor.mainThread(), with: { (task: AWSTask!) -> AnyObject! in
			if task.error != nil {
				LocalDataStore.removeObjectForKey(tokenKey)
			} else if let createEndpointResponse = task.result,
                let endpointArn = createEndpointResponse.endpointArn {
                LocalDataStore.setObject(deviceToken, forKey: tokenKey)
                subscriptForNotification(endpointArn, completionHandler: completionHandler)
                return nil
            }
            completionHandler(false)
			return nil
		})
	}
	
	class func subscriptForNotification(_ endpointArn: String, completionHandler: @escaping (Bool) -> Void) {
		let sns = AWSSNS.default()
		let input = AWSSNSSubscribeInput()
		input?.topicArn = notificationTopic
		input?.endpoint = endpointArn
		input?.protocols = "application"
		sns.subscribe(input!, completionHandler: { (response, error) -> Void in
			if error != nil {
				debugPrint("Error subscribing for a topic: \(error.debugDescription)")
                completionHandler(false)
			} else {
				completionHandler(true)
			}
		})
	}
}
