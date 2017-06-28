//
//  ViewController.m
//  test_socket1
//
//  Created by Ray on 2017/6/28.
//  Copyright © 2017年 Yestin. All rights reserved.
//

#import "ViewController.h"

#import <sys/socket.h>  // socket
#import <netinet/in.h>  // 互联网
#import <arpa/inet.h>   // 互联网参数

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 1. 创建socket
    /**
         domain:    协议域 AF_INET -> IPV4
         type:      socket类型 ,SOCK_STREAM -> TCP , SOCK_DGRAM -> UDP
         protocol:
     
         return:    socket
     */
    int clientSocket = socket(AF_INET, SOCK_STREAM, 0); // 6
    
    // 2. 连接
    /** 
        client socket:
        (地址)指针:           指向 结构体sockaddr (目标(server)的 port ip)
        结构体数据长度:
     
        return:             0 成功
     */
    struct sockaddr_in serverAddr;
    serverAddr.sin_port = htons(12345); // htons 该宏 专用于写 端口号    // 20480(高地位互换)
    serverAddr.sin_addr.s_addr = inet_addr("127.0.0.1"); // 底层ip地址也是一串二进制
    int connResult = connect(clientSocket, (const struct sockaddr *)&serverAddr, sizeof(serverAddr));
    if (connResult == 0) {
        NSLog(@"socket connet successfully");
    }else{
        NSLog(@"socket connet fail %zd",connResult);
        return;
    }
    // 终端 nc -lk 12345
    // nc - Netcat
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
