//
//  UdeskChatToolBarMoreView.m
//  UdeskSDK
//
//  Created by xuchen on 2018/3/20.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import "UdeskChatToolBarMoreView.h"
#import "UdeskButton.h"
#import "UIImage+UdeskSDK.h"
#import "UdeskBundleUtils.h"
#import "UdeskSDKMacro.h"
#import "UdeskCustomButtonConfig.h"
#import "UdeskSDKConfig.h"
#import "UdeskImageUtil.h"
#import "UdeskAgent.h"

// 每行有4个
#define kUdeskPerRowItemCount 4
#define kUdeskPerColum 2
#define kUdeskMoreItemWidth 64
#define kUdeskMoreItemHeight 88

@interface UdeskChatToolBarMoreView()<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView  *scrollview;
@property (nonatomic, strong) UIPageControl *pageControl;

@property (nonatomic, strong) UdeskButton *photoButton;
@property (nonatomic, strong) UdeskButton *cameraButton;
@property (nonatomic, strong) UdeskButton *surveyButton;
@property (nonatomic, strong) UdeskButton *locationButton;
@property (nonatomic, strong) UdeskButton *videoCallButton;

@property (nonatomic, assign) BOOL enableSurvey;
@property (nonatomic, assign) BOOL enableVideoCall;

@property (nonatomic, strong) NSMutableArray *allItems;

@end

@implementation UdeskChatToolBarMoreView

- (instancetype)initWithEnableSurvey:(BOOL)enableSurvey enableVideoCall:(BOOL)enableVideoCall
{
    self = [super init];
    if (self) {
        
        _enableVideoCall = enableVideoCall;
        _enableSurvey = enableSurvey;
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    
    _scrollview = [[UIScrollView alloc] init];
    _scrollview.delegate = self;
    _scrollview.canCancelContentTouches = NO;
    _scrollview.delaysContentTouches = YES;
    _scrollview.backgroundColor = self.backgroundColor;
    _scrollview.showsHorizontalScrollIndicator = NO;
    _scrollview.showsVerticalScrollIndicator = NO;
    [_scrollview setScrollsToTop:NO];
    _scrollview.pagingEnabled = YES;
    [self addSubview:_scrollview];
    
    _pageControl = [[UIPageControl alloc] init];
    _pageControl.currentPage = 0;
    _pageControl.numberOfPages = 1;
    _pageControl.backgroundColor = self.backgroundColor;
    _pageControl.hidesForSinglePage = YES;
    _pageControl.defersCurrentPageDisplay = YES;
    _pageControl.currentPageIndicatorTintColor = [UIColor colorWithRed:0.545f  green:0.545f  blue:0.545f alpha:1];
    _pageControl.pageIndicatorTintColor = [UIColor colorWithRed:0.733f  green:0.733f  blue:0.733f alpha:1];
    [self addSubview:_pageControl];
    
    [self setupAdditionalAreaButtons];
}

//添加附加区的功能按钮
- (void)setupAdditionalAreaButtons {
    
    UdeskSDKConfig *sdkConfig = [UdeskSDKConfig customConfig];
    
    if (sdkConfig.isShowAlbumEntry) {
        _photoButton = [self buttonWithImage:[UIImage udDefaultChatBarMorePhotoImage] title:getUDLocalizedString(@"udesk_album")];
        _photoButton.tag = 9347 + 0;
        [_scrollview addSubview:_photoButton];
        [self.allItems addObject:_photoButton];
    }
    
    if (sdkConfig.isShowCameraEntry) {
        _cameraButton = [self buttonWithImage:[UIImage udDefaultChatBarMoreCameraImage] title:getUDLocalizedString(@"udesk_shooting")];
        _cameraButton.tag = 9347 + 1;
        [_scrollview addSubview:_cameraButton];
        [self.allItems addObject:_cameraButton];
    }
    
    if (_enableSurvey) {
        [self appendSurveyButton];
    }
    
    if (sdkConfig.isShowLocationEntry) {
        _locationButton = [self buttonWithImage:[UIImage udDefaultChatBarMoreLocationImage] title:getUDLocalizedString(@"udesk_location")];
        _locationButton.tag = 9347 + 2;
        [_scrollview addSubview:_locationButton];
        [self.allItems addObject:_locationButton];
    }
    
    if (_enableVideoCall) {
        _videoCallButton = [self buttonWithImage:[UIImage udDefaultChatBarMoreVideoCallImage] title:getUDLocalizedString(@"udesk_video_call")];
        _videoCallButton.tag = 9347 + 4;
        [_scrollview addSubview:self.videoCallButton];
        [self.allItems addObject:self.videoCallButton];
    }
    
    self.customMenuItems = [UdeskSDKConfig customConfig].customButtons;
}

- (void)setAgent:(UdeskAgent *)agent {
    _agent = agent;
    
    if (agent.statusType == UDAgentStatusResultOffline ||
        agent.statusType == UDAgentStatusResultQueue) {
        [self removeAllAreaButtons];
        [self setupAdditionalAreaButtons];
        [self removeSurveyAndVideoCallButton];
        [self setNeedsLayout];
    }
    else if (agent.statusType == UDAgentStatusResultOnline) {
        [self removeAllAreaButtons];
        [self setupAdditionalAreaButtons];
        [self setNeedsLayout];
    }
}

- (void)setCustomMenuItems:(NSArray *)customMenuItems {
    if (!customMenuItems || customMenuItems == (id)kCFNull) return ;
    if (![customMenuItems isKindOfClass:[NSArray class]]) return ;
    if (!customMenuItems.count) return;
    if (![customMenuItems.firstObject isKindOfClass:[UdeskCustomButtonConfig class]]) return;
    
    //没有在更多view里的自定义按钮
    NSArray *types = [customMenuItems valueForKey:@"type"];
    if (![types containsObject:@1]) return;
    
    _customMenuItems = customMenuItems;
    
    NSMutableArray *agentCustomButton = [NSMutableArray array];
    NSMutableArray *robotCustomButton = [NSMutableArray array];
    for (UdeskCustomButtonConfig *customButton in customMenuItems) {
        switch (customButton.scenesType) {
            case UdeskCustomButtonConfigScenesAgent:
                [agentCustomButton addObject:customButton];
                break;
            case UdeskCustomButtonConfigScenesRobot:
                [robotCustomButton addObject:customButton];
                break;
                
            default:
                break;
        }
    }
    
    NSArray *customeButtonArray = self.isRobotSession?robotCustomButton:agentCustomButton;
    if (!customeButtonArray || customeButtonArray == (id)kCFNull || !customeButtonArray.count) return ;
    
    for (UdeskCustomButtonConfig *customButton in customeButtonArray) {
        if (![customButton isKindOfClass:[UdeskCustomButtonConfig class]]) return;
        
        if (customButton.type == UdeskCustomButtonConfigTypeInMoreView) {
         
            UdeskButton *button = [self buttonWithImage:[UdeskImageUtil imageResize:customButton.image toSize:CGSizeMake(60, 60)] title:customButton.title];
            button.tag = 9347 + [customMenuItems indexOfObject:customButton] + 5;
            [_scrollview addSubview:button];
            [self.allItems addObject:button];
        }
    }
}

- (void)appendSurveyButton {
    
    _surveyButton = [self buttonWithImage:[UIImage udDefaultChatBarMoreSurveyImage] title:getUDLocalizedString(@"udesk_survey")];
    _surveyButton.tag = 9347 + 3;
    [_scrollview addSubview:_surveyButton];
    [self.allItems addObject:_surveyButton];
}

- (void)removeSurveyButton {
    
    [self.surveyButton removeFromSuperview];
    if ([self.allItems containsObject:self.surveyButton]) {
        [self.allItems removeObject:self.surveyButton];
    }
}

- (void)removeVideoCallButton {
    
    [self.videoCallButton removeFromSuperview];
    if ([self.allItems containsObject:self.videoCallButton]) {
        [self.allItems removeObject:self.videoCallButton];
    }
}

- (UdeskButton *)buttonWithImage:(UIImage *)image title:(NSString *)title {
    
    UdeskButton *button = [UdeskButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(itemButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [button setImage:image forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithRed:0.471f  green:0.471f  blue:0.471f alpha:1] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:11.0];
    
    if (image) {
        button.imageEdgeInsets = UIEdgeInsetsMake(-10, 0, 15, 0);
        button.titleEdgeInsets = UIEdgeInsetsMake(45, -64, -20, 0);
    }
    
    return button;
}

//人工会话
- (void)setIsAgentSession:(BOOL)isAgentSession {
    _isAgentSession = isAgentSession;
    
    [self removeAllAreaButtons];
    [self setupAdditionalAreaButtons];
    
    [self setNeedsLayout];
}

//机器人会话
- (void)setIsRobotSession:(BOOL)isRobot {
    _isRobotSession = isRobot;
    
    //机器人
    if (isRobot) {
        
        [self removeAllAreaButtons];
        [self appendSurveyButton];
        self.customMenuItems = [UdeskSDKConfig customConfig].customButtons;
        [self setNeedsLayout];
    }
}

//无消息过滤会话
- (void)setIsPreSession:(BOOL)isPreSession {
    _isPreSession = isPreSession;
    
    //无消息对话过滤
    if (isPreSession) {
        
        [self removeAllAreaButtons];
        [self setupAdditionalAreaButtons];
        [self removeSurveyAndVideoCallButton];
        [self setNeedsLayout];
    }
}

//移除评价和直播按钮
- (void)removeSurveyAndVideoCallButton {
    
    if (self.surveyButton && _enableSurvey) {
        [self removeSurveyButton];
    }
    
    if (self.videoCallButton && _enableVideoCall) {
        [self removeVideoCallButton];
    }
}

//移除所有按钮
- (void)removeAllAreaButtons {
    
    for (UIView *view in [self.scrollview subviews]) {
        if ([view isKindOfClass:[UdeskButton class]]) {
            [view removeFromSuperview];
        }
    }

    [self.allItems removeAllObjects];
}

- (void)itemButtonAction:(UdeskButton *)button {
    
    NSInteger index = button.tag - 9347;
    if (index > 4) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectCustomMoreMenuItem:atIndex:)]) {
            [self.delegate didSelectCustomMoreMenuItem:self atIndex:index-5];
        }
        return;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectMoreMenuItem:itemType:)]) {
        [self.delegate didSelectMoreMenuItem:self itemType:button.tag - 9347];
    }
}

#pragma mark - UIScrollView delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    @try {
     
        //每页宽度
        CGFloat pageWidth = scrollView.frame.size.width;
        //根据当前的坐标与页宽计算当前页码
        NSInteger currentPage = floor((scrollView.contentOffset.x - pageWidth/2)/pageWidth)+1;
        [self.pageControl setCurrentPage:currentPage];
        
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (!self.allItems.count) return;
    
    _pageControl.frame = CGRectMake(0, CGRectGetHeight(self.frame) - 20, CGRectGetWidth(self.frame), 20);
    _pageControl.numberOfPages = (self.allItems.count / (kUdeskPerRowItemCount * 2) + (self.allItems.count % (kUdeskPerRowItemCount * 2) ? 1 : 0));
    
    _scrollview.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - CGRectGetHeight(_pageControl.frame));
    [_scrollview setContentSize:CGSizeMake(((self.allItems.count / (kUdeskPerRowItemCount * 2) + (self.allItems.count % (kUdeskPerRowItemCount * 2) ? 1 : 0)) * CGRectGetWidth(self.bounds)), CGRectGetHeight(_scrollview.bounds))];
    
    CGFloat paddingX = (UD_SCREEN_WIDTH-(kUdeskMoreItemWidth * 4))/5;
    CGFloat paddingY = 20;
    for (UdeskButton *button in self.allItems) {
        NSInteger index = [self.allItems indexOfObject:button];
        NSInteger page = index / (kUdeskPerRowItemCount * kUdeskPerColum);
        
        CGRect itemFrame = CGRectMake((index % kUdeskPerRowItemCount) * (kUdeskMoreItemWidth + paddingX) + paddingX + (page * CGRectGetWidth(self.bounds)), ((index / kUdeskPerRowItemCount) - kUdeskPerColum * page) * (kUdeskMoreItemHeight + paddingY) + paddingY, kUdeskMoreItemWidth, kUdeskMoreItemHeight);
        
        button.frame = itemFrame;
    }
}

#pragma mark - lazy
- (NSMutableArray *)allItems {
    if (!_allItems) {
        _allItems = [NSMutableArray array];
    }
    return _allItems;
}

@end
