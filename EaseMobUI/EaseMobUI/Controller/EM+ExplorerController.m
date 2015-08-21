//
//  EM+ExplorerController.m
//  EaseMobUI
//
//  Created by 周玉震 on 15/8/7.
//  Copyright (c) 2015年 周玉震. All rights reserved.
//

#import "EM+ExplorerController.h"
#import "EM+ChatFileUtils.h"
#import "EM+ChatResourcesUtils.h"
#import "EM+ChatDateUtils.h"
#import "EM+Common.h"
#import "UIColor+Hex.h"

#import "EM+ChatWifiView.h"

#import "HTTPServer.h"
#import "EM+ChatExplorerConnection.h"
#include <ifaddrs.h>
#include <arpa/inet.h>

#define HEIGHT_HEADER   (44)
#define HEIGHT_FOOTER   (44)

@interface EM_ExplorerController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) HTTPServer *httpServer;
@property (nonatomic, assign) NSInteger currentFolderIndex;;
@end

@implementation EM_ExplorerController{
    UIScrollView *_headerView;
    UIView *_footerView;
    UITableView *_tableView;
    UIButton *_enterButton;
    
    NSArray *_folderArray;
    NSArray *_buttonArray;
    NSMutableArray *_selectedArray;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        _folderArray = [EM_ChatFileUtils folderArray];
        self.title = [EM_ChatResourcesUtils stringWithName:@"common.file"];
        _selectedArray = [[NSMutableArray alloc]init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _tableView = [[UITableView alloc]initWithFrame:self.view.frame];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.contentInset = UIEdgeInsetsMake(HEIGHT_HEADER, 0, HEIGHT_FOOTER, 0);
    [self.view addSubview:_tableView];
    
    _headerView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, STATUS_BAR_FRAME.size.height + NAVIGATION_BAR_FRAME.size.height, self.view.frame.size.width, HEIGHT_HEADER)];
    _headerView.backgroundColor = [UIColor whiteColor];
    CGFloat buttonWidth = self.view.frame.size.width / _folderArray.count;
    for (int i = 0; i < _folderArray.count; i++) {
        NSDictionary *dic = _folderArray[i];
        NSString *title = dic[kFolderTitle];
        UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(buttonWidth * i, 0, buttonWidth, HEIGHT_HEADER)];
        [button setTitle:title forState:UIControlStateNormal];
        [button setTitleColor:[UIColor colorWithHexRGB:TEXT_NORMAL_COLOR] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor colorWithHexRGB:TEXT_SELECT_COLOR] forState:UIControlStateHighlighted];
        [button setTitleColor:[UIColor colorWithHexRGB:TEXT_SELECT_COLOR] forState:UIControlStateSelected];
        [button addTarget:self action:@selector(folderClicked:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = i;
        button.selected = _currentFolderIndex == i;
        [_headerView addSubview:button];
    }
    _buttonArray = [NSArray arrayWithArray:_headerView.subviews];
    
    UIView *headerLine = [[UIView alloc]initWithFrame:CGRectMake(0, _headerView.frame.size.height - LINE_HEIGHT, _headerView.frame.size.width, LINE_HEIGHT)];
    headerLine.backgroundColor = [UIColor colorWithHEX:LINE_COLOR alpha:1.0];
    [_headerView addSubview:headerLine];
    [self.view addSubview:_headerView];
    
    _footerView = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height - HEIGHT_FOOTER, self.view.frame.size.width, HEIGHT_FOOTER)];
    _footerView.backgroundColor = [UIColor whiteColor];
    UIView *footerLine = [[UIView alloc]initWithFrame:CGRectMake(0, -LINE_HEIGHT, _headerView.frame.size.width, LINE_HEIGHT)];
    footerLine.backgroundColor = [UIColor colorWithHEX:LINE_COLOR alpha:1.0];
    [_footerView addSubview:footerLine];
    
    _enterButton = [[UIButton alloc]initWithFrame:CGRectMake(_footerView.frame.size.width - 80, 2, 60, _footerView.frame.size.height - 4)];
    _enterButton.backgroundColor = [UIColor blueColor];
    _enterButton.enabled = NO;
    [_enterButton setTitle:[EM_ChatResourcesUtils stringWithName:@"common.send"] forState:UIControlStateNormal];
    [_enterButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_enterButton addTarget:self action:@selector(sendFile:) forControlEvents:UIControlEventTouchUpInside];
    [_footerView addSubview:_enterButton];
    [self.view addSubview:_footerView];
    
    UIButton *cancel = [[UIButton alloc]init];
    [cancel addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    [cancel setTitle:[EM_ChatResourcesUtils stringWithName:@"common.cancel"] forState:UIControlStateNormal];
    [cancel setTitleColor:[UIColor colorWithHexRGB:TEXT_SELECT_COLOR] forState:UIControlStateNormal];
    [cancel setTitleColor:[UIColor colorWithHexRGB:TEXT_NORMAL_COLOR] forState:UIControlStateHighlighted];
    [cancel sizeToFit];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:cancel];
    
    UIButton *wifi = [[UIButton alloc]init];
    [wifi addTarget:self action:@selector(wifiUpload:) forControlEvents:UIControlEventTouchUpInside];
    [wifi setTitle:[EM_ChatResourcesUtils stringWithName:@"file.wifi_upload"] forState:UIControlStateNormal];
    [wifi setTitleColor:[UIColor colorWithHexRGB:TEXT_SELECT_COLOR] forState:UIControlStateNormal];
    [wifi setTitleColor:[UIColor colorWithHexRGB:TEXT_NORMAL_COLOR] forState:UIControlStateHighlighted];
    [wifi sizeToFit];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:wifi];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wifiFileUplod:) name:kEMNotificationFileUpload object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wifiFileDelete:) name:kEMNotificationFileDelete object:nil];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setCurrentFolderIndex:(NSInteger)currentFolderIndex{
    if (_currentFolderIndex != currentFolderIndex) {
        _currentFolderIndex = currentFolderIndex;
        for (UIButton *button in _buttonArray) {
            button.selected = _currentFolderIndex == button.tag;
        }
        [_tableView reloadData];
    }
}

- (HTTPServer *)httpServer{
    if (!_httpServer) {
        NSString *webPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"EM_Web.bundle"];
        _httpServer = [[HTTPServer alloc] init];
        [_httpServer setType:@"_http._tcp."];
        [_httpServer setPort:13131];
        [_httpServer setName:@"EaseMobUI"];
        [_httpServer setDocumentRoot:webPath];
        [_httpServer setConnectionClass:[EM_ChatExplorerConnection class]];
    }
    return _httpServer;
}

- (NSString *)deviceIPAdress {
    NSString *address = @"an error occurred when obtaining ip address";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    success = getifaddrs(&interfaces);
    
    if (success == 0) { // 0 表示获取成功
        
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if( temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    freeifaddrs(interfaces);
    return address;
}

- (void)wifiFileUplod:(NSNotification *)notification{
    NSDictionary *userInfo = notification.userInfo;
    WiFiFileUploadState state = [[userInfo objectForKey:kEMFileUploadState] integerValue];
    NSString *fileType = [userInfo objectForKey:kFileType];
    NSString *fileName = [userInfo objectForKey:kFileName];
    long long progress = [[userInfo objectForKey:kEMFIleUploadProgress] longLongValue];
    switch (state) {
        case WiFiFileUploadStateStart:{
            for (int i = 0;i < _folderArray.count;i++) {
                NSDictionary *folder = _folderArray[i];
                NSString *folderName = [folder objectForKey:kFolderName];
                if ([fileType isEqualToString:folderName]) {
                    NSMutableArray *files = [folder objectForKey:kFolderContent];
                    [files insertObject:[[NSURL alloc]initFileURLWithPath:[NSString stringWithFormat:@"%@/%@/%@",kChatFileFolderPath,fileType,fileName]] atIndex:0];
                    [folder setValue:files forKey:kFolderContent];
                    MAIN(^{
                        BOOL needReload = _currentFolderIndex == i;
                        self.currentFolderIndex = i;
                        if (needReload) {
                            [_tableView reloadData];
                        }
                    });
                    
                    break;
                }
            }
        }
            break;
        case WiFiFileUploadStateProcess:{
            NSLog(@"上传文件中 - %lld",progress);
        }
            break;
        case WiFiFileUploadStateEnd:{

        }
            break;
    }
}

- (void)wifiFileDelete:(NSNotification *)notification{
    NSDictionary *userInfo = notification.userInfo;
    
}

- (void)cancel:(id)sender{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)wifiUpload:(id)sender{
    EM_ChatWifiView *wifiView = [[EM_ChatWifiView alloc]initWithIPAdress:[NSString stringWithFormat:@"http://%@:%d",[self deviceIPAdress],self.httpServer.port]];
    [wifiView setAlertShowCompletedBlcok:^{
        if (self.httpServer.isRunning) {
            [self.httpServer stop:NO];
        }
        [self.httpServer start:nil];
    }];
    [wifiView setAlertDismissBlcok:^{
        if (self.httpServer.isRunning) {
            [self.httpServer stop:NO];
        }
    }];
    [wifiView show:UAlertPosition_Bottom offestY:0];
}

- (void)folderClicked:(UIButton *)sender{
    self.currentFolderIndex = sender.tag;
}

- (void)sendFile:(id)sender{
    if (_delegate && [_delegate respondsToSelector:@selector(didFileSelected:)] && _selectedArray.count > 0) {
        [_delegate didFileSelected:_selectedArray];
    }
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *contentArray = _folderArray[_currentFolderIndex][kFolderContent];
    return contentArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellId = @"cellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.detailTextLabel.numberOfLines = 0;
        cell.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.detailTextLabel.textColor = [UIColor blueColor];
        cell.separatorInset = UIEdgeInsetsMake(2, 0, 2, 0);
    }
    
    NSArray *contentArray = _folderArray[_currentFolderIndex][kFolderContent];
    NSURL *fileURL = contentArray[indexPath.row];
    
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:fileURL.path error:nil];
    
    cell.textLabel.text = fileURL.path.lastPathComponent;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@\n%@",[EM_ChatFileUtils stringFileSize:[attributes fileSize]],[EM_ChatDateUtils dateConvertToString:[attributes fileModificationDate] formatter:@"yyyy-MM-dd HH:mm"]];
    if (_currentFolderIndex == 0) {
        cell.imageView.image = [EM_ChatFileUtils thumbImageWithURL:fileURL];
    }else if(_currentFolderIndex == 1){
        cell.imageView.image = [EM_ChatFileUtils thumbAudioWithURL:fileURL];
    }else if(_currentFolderIndex == 2){
        cell.imageView.image = [EM_ChatFileUtils thumbVideoWithURL:fileURL];
    }else{
        cell.imageView.image = nil;
    }
    
    if ([_selectedArray containsObject:fileURL]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSArray *contentArray = _folderArray[_currentFolderIndex][kFolderContent];
    NSURL *fileURL = contentArray[indexPath.row];
    
    if ([_selectedArray containsObject:fileURL]) {
        [_selectedArray removeObject:fileURL];
    }else{
        [_selectedArray addObject:fileURL];
    }
    
    _enterButton.enabled = _selectedArray.count > 0;
    if (_enterButton.enabled) {
        [_enterButton setTitle:[NSString stringWithFormat:@"%@(%ld)",[EM_ChatResourcesUtils stringWithName:@"common.send"],_selectedArray.count] forState:UIControlStateNormal];
    }else{
        [_enterButton setTitle:[NSString stringWithFormat:@"%@",[EM_ChatResourcesUtils stringWithName:@"common.send"]] forState:UIControlStateNormal];
    }
    
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

@end