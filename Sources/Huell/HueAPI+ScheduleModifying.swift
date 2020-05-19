//
//  HueAPI+ScheduleModifying.swift
//  Sol
//
//  Created by Zane Whitney on 1/28/20.
//  Copyright © 2020 Kitsch. All rights reserved.
//

import Foundation
import Siesta

protocol ScheduleModifying {
    func clearExistingCircadianSchedules() throws
    func postCircadianSchedule() throws
    func listenForSchedulesResource(withService service: Service)
}

// MARK: POSTing Schedules
extension HueAPI: ScheduleModifying {
    public func updateHueCircadianSchedules() {
        try? HueAPI.sharedInstance.clearExistingCircadianSchedules()
        try? HueAPI.sharedInstance.postCircadianSchedule()
    }
    
    public func cycleThoughLightSchedules() throws {
        guard let service = service else {
            throw NetworkError.serviceNotInitialized
        }
        
        cycleThoughLightSchedules(withService: service)
    }
    
    public func cycleThoughLightSchedules(withService service: Service) {
        if let stringList = try? postStrings(fromSchedules: [testDawnSchedule, testMorningSchedule, testMiddaySchedule, testSunsetSchedule, testEveningSchedule]) {
            chainPosts(stringList, forEndpoint: schedulesEndpoint, service: service)
        }
    }
    
    public func postWeeklyCircadianSchedule() throws -> Request {
        guard let service = service else {
            throw NetworkError.serviceNotInitialized
        }

        return try postWeeklyCircadianSchedule(withService: service)
    }
    
    public func postWeeklyCircadianSchedule(withService service: Service) throws -> Request {
        let now = Date()
        
        let sunriseStartString = try postString(fromSchedule: recurringWeeklySunriseStartSchedule(forWeekContainingDate: now))
        let morningString = try postString(fromSchedule: recurringWeeklyMorningSchedule(forWeekContainingDate: now))
        let solarNoonString = try postString(fromSchedule: recurringWeeklySolarNoonSchedule(forWeekContainingDate: now))
        let halfSetString = try postString(fromSchedule: recurringWeeklyHalfSetSchedule(forWeekContainingDate: now))
        let sunsetStartString = try postString(fromSchedule: recurringWeeklySunsetEndSchedule(forWeekContainingDate: now))
        
        return service.resource(schedulesEndpoint).request(.post, text: sunriseStartString).onSuccess({
            _ in
            service.resource(self.schedulesEndpoint).request(.post, text: morningString).onSuccess({
                _ in
                service.resource(self.schedulesEndpoint).request(.post, text: solarNoonString).onSuccess({
                    _ in
                    service.resource(self.schedulesEndpoint).request(.post, text: halfSetString).onSuccess({
                        _ in
                        service.resource(self.schedulesEndpoint).request(.post, text: sunsetStartString).onSuccess({
                            _ in
                            print("Successfully posted the schedule!!! 🤩")
                        })
                    })
                })
            })
        })
    }
    
    public func postCircadianSchedule() throws {
        do {
            let scheduleList = createFutureSchedules(daysAhead: Constants.numDaysScheduledAhead)
            if let stringList = try? postStrings(fromSchedules: scheduleList) {
                stringList.forEach({ print("\(String(describing: $0))") })
                
                guard let service = service else {
                    throw NetworkError.serviceNotInitialized
                }
                
                chainPosts(stringList, forEndpoint: schedulesEndpoint, service: service)
            }
        } catch {
            throw NetworkError.cannotEncodeModelRequest
        }
    }
    
    fileprivate func chainPosts(_ queue: [String], forEndpoint endpoint: String, service: Service) {
        guard let thing = queue.first else { return }
        service.resource(endpoint).request(.post, text: thing).onSuccess {
            entity in
            print("Successfully posted \(entity.text)")
        }.onFailure {
            requestError in
            print("There was a problem posting \(String(describing: requestError.entity?.text))")
        }.onCompletion {
            _ in
            self.chainPosts(Array(queue[1 ..< queue.count]), forEndpoint: endpoint, service: service)
        }
    }
    
    fileprivate func chainDeletes(forEndpoints endpoints: [String], service: Service) {
        guard let endpoint = endpoints.first else { return }
        service.resource(endpoint).request(.delete).onSuccess {
            entity in
            print("Successfully deleted \(entity.text)")
        }.onFailure {
            requestError in
            print("There was a problem deleting \(String(describing: requestError.entity?.text))")
        }.onCompletion {
            _ in
            self.chainDeletes(forEndpoints: Array(endpoints[1 ..< endpoints.count]), service: service)
        }
    }
    
    public func clearExistingCircadianSchedules() throws {
        guard let service = service else {
            throw NetworkError.serviceNotInitialized
        }
        
        clearExistingCircadianSchedules(withService: service)
    }
    
    func clearExistingCircadianSchedules(withService service: Service) {
        // 1. serialize all the schedules
        // 2. filter out all relevant ids
        // 3. generate an array of ids to delete and delete them
        let deletionEndpoints = currentCircadianScheduleIds?.map { return singleScheduleEndpoint(forScheduleId: $0) }
        chainDeletes(forEndpoints: deletionEndpoints ?? [], service: service)
    }
    
    func listenForResourceUpdates(withService service: Service, endpoint: String, identifierExtractor extractor:  @escaping ((Data) throws -> Void)) {
        service.resource(endpoint).addObserver(owner: self, closure: {
            [weak self] resource, event in
            // TODO: why won't this auto-update based on changes in resource state
                if let weakSelf = self {
                    let data = resource.latestData?.content as? Data
                    
                    if let serializedData = data {
                        do {
                            try extractor(serializedData)
                            print("\(String(describing: weakSelf.currentCircadianScheduleIds))")
                        } catch {
                            print("\(error)")
                        }
                    }
                }
        }).loadIfNeeded()
    }
    
    func listenForSchedulesResource(withService service: Service) {
        listenForResourceUpdates(withService: service, endpoint: schedulesEndpoint, identifierExtractor: {
            [weak self] data in
                if let weakSelf = self {
                    let schedules = try weakSelf.jsonDecoder.decode([String : Schedule].self, from: data)
                    weakSelf.currentCircadianScheduleIds = schedules.keys.filter {
                    return schedules[$0]!.name.contains("(Sol)")
                }
            }
        })
    }
}
