//
//  MovieDataAdapter.swift
//  InterfaceAdapters
//
//  Created by Sasmito Adibowo on 15/3/20.
//  Copyright © 2020 Basil Salad Software. All rights reserved.
//

import Foundation
import DomainEntities
import BusinessLogic


class MovieDataAdapter: MovieDataStore {    
    
    static let appLogicSubsystem = AppLogicSubsystem.defaultInstance

    var lastFetchCount: Int
    
    let dataSource: MovieDataProvider
    
    let syncQueue: DispatchQueue

    init(dataSource: MovieDataProvider) {
        let subsystemQueue = type(of: self).appLogicSubsystem.subsystemQueue
        syncQueue = DispatchQueue(label:"MovieDataAdapter-sync",qos: .userInitiated, target:subsystemQueue)

        self.dataSource = dataSource
        lastFetchCount = dataSource.defaultPageSize
    }
    
    
    func calculatePagination(fetchOffset: Int, fetchLimit: Int) -> (firstPageNumber: Int, lastPageNumber: Int, firstPageSkip: Int, lastPageCount: Int, totalPages: Int) {
        let pageSize = lastFetchCount
        let firstPageNumber = (fetchOffset / pageSize) + 1
        let firstPageSkip = fetchOffset - (firstPageNumber - 1) * pageSize
        let lastPageNumber = (fetchOffset + fetchLimit - 1) / pageSize + 1
        let lastPageCount =  fetchOffset + fetchLimit - (lastPageNumber - 1) * pageSize
        let totalPages = lastPageNumber - firstPageNumber + 1
        return (firstPageNumber, lastPageNumber, firstPageSkip, lastPageCount, totalPages)
    }
    
    // MARK: MovieDataStore
    
    func fetchMovieSummary(filter: ListMoviesFilter, fetchOffset: Int, fetchLimit: Int, resultReceiver: @escaping (Result<[MovieSummary]>) -> Void) {
        let (firstPageNumber, lastPageNumber, firstPageSkip, lastPageCount, totalPages) = calculatePagination(fetchOffset: fetchOffset, fetchLimit: fetchLimit)
        var fetchResultByPageNumber = Dictionary<Int, Result<MovieSummaryResult> >()
        fetchResultByPageNumber.reserveCapacity(totalPages)
        let checkCompletion = {
            guard fetchResultByPageNumber.count >= totalPages else {
                return
            }
            var summaryResults = [MovieSummary]()
            summaryResults.reserveCapacity(fetchLimit)
            for pageNumber in firstPageNumber...lastPageNumber {
                guard let pageResponse = fetchResultByPageNumber[pageNumber],
                    case let .success(pageResult) = pageResponse,
                    let summaryList = pageResult.results else {
                    continue
                }
                if pageNumber == firstPageNumber {
                    summaryResults.append(contentsOf: summaryList[firstPageSkip...])
                } else if pageNumber == lastPageNumber {
                    summaryResults.append(contentsOf: summaryList[..<lastPageCount])
                } else {
                    summaryResults.append(contentsOf: summaryList)
                }
            }
            DispatchQueue.main.async {
                resultReceiver(.success(summaryResults))
            }
        }
        for pageNumber in firstPageNumber...lastPageNumber {
            dataSource.discoverMovies(pageNumber: pageNumber) {
                (response) in
                self.syncQueue.async {
                    if case let .success(result) = response {
                        if let resultCount = result.results?.count, resultCount > 0 {
                            self.lastFetchCount = resultCount
                        }
                    }
                    fetchResultByPageNumber[pageNumber] = response
                    checkCompletion()
                }
            }
        }
    }

        
}
