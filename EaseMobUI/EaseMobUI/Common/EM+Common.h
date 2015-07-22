//
//  EM+Common.h
//  EaseMobUI
//
//  Created by 周玉震 on 15/7/1.
//  Copyright (c) 2015年 周玉震. All rights reserved.
//

#ifndef EaseMobUI_EM_Common_h
#define EaseMobUI_EM_Common_h

#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

#define IS_PAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

#define COMMON_PADDING (IS_PAD ? 8 : 5)
#define LEFT_PADDING (IS_PAD ? 20 : 15)
#define RIGHT_PADDING (LEFT_PADDING)

#define HEIGHT_INDICATOR_OF_DEFAULT (IS_PAD ? 10 : 6)

#define HEIGHT_INPUT_OF_DEFAULT (50)
#define HEIGHT_INPUT_OF_MAX (IS_PAD ? 320 : 200)
#define HEIGHT_MORE_TOOL_OF_DEFAULT ((SCREEN_WIDTH - LEFT_PADDING - RIGHT_PADDING) / 2 + HEIGHT_INDICATOR_OF_DEFAULT * 2)

#define LINE_COLOR (@"#CCCCCC")
#define TEXT_NORMAL_COLOR (@"#C2C2C2")
#define TEXT_SELECT_COLOR   (@"#9370DB")

#endif