/*****************************************************************************
 * UpdateAvailableResult.swift
 * UpdateAvailableKit
 *****************************************************************************
 * Copyright (c) 2022 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import Foundation

public enum UpdateAvailableResult: Equatable {
    case updateAvailable(newVersion: String)
    case noUpdatesAvailable
}
