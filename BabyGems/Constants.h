//
//  Constants.h
//  BabyGems
//
//  Created by Bobby Ren on 11/15/14.
//  Copyright (c) 2014 BobbyRenTech. All rights reserved.
//

#ifndef BabyGems_Constants_h
#define BabyGems_Constants_h

// testing constants
#define AIRPLANE_MODE 0
#define TESTING 1

// string constants
#define PLACEHOLDER_TEXT @"Click here to add a quote"

/// enumerations
// cell enumeration
typedef enum GemCellStyleEnum {
    CellStyleFirst,
    CellStyleBottom = CellStyleFirst,
    CellStyleFull,
    CellStyleMax
} GemCellStyle;

typedef enum GemBorderStyleEnum {
    BorderStyleFirst,
    BorderStyleRound = BorderStyleFirst,
    BorderStyleNone,
    BorderStyleMax
} GemBorderStyle;


#endif
