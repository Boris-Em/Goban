//
//  SGFProperties.swift
//  GobanSampleProject
//
//  Created by John on 5/10/16.
//  Copyright © 2016 Boris Emorine. All rights reserved.
//

import Foundation

enum SGFMoveProperties: String {
    case B, KO, MN, W
}

enum SGFSetupProperties: String {
    case AB, AE, AW, PL
}

enum SGFNodeAnnotationProperties: String {
    case C, DM, GB, GW, HO, N, UC, V
}

enum SGFMoveAnnotationProperties: String {
    case BM, DO, IT, TE
}

enum SGFMarkupProperties: String {
    case AR, CR, DD, LB, LN, MA, SL, SQ, TR
}

enum SGFRootProperties: String {
    case AP, CA, FF, GM, ST, SZ
}

enum SGFGameInfoProperties: String {
    case AN, BR, BT, CP, DT, EV, GN, GC, ON, OT, PB, PC, PW, RE, RO, RU, SO, TM, US, WR, WT
}

enum SGFTimingProperties: String {
    case BL, OB, OW, WL
}

enum SGFMiscellaneousProperties {
    case FG, PM, VW
}

enum GoProperties: String {
    case HA, KM, TB, TW
}