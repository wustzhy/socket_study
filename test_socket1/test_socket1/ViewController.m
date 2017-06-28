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
     参数
         domain:    协议域 AF_INET -> IPV4
         type:      socket类型 ,SOCK_STREAM -> TCP , SOCK_DGRAM -> UDP
         protocol:
     返回
         return:    socket
     */
    int clientSocket = socket(AF_INET, SOCK_STREAM, 0); // 6
    
    // 2. 连接
    /** 
     参数
        client socket:
        (地址)指针:           指向 结构体sockaddr (目标(server)的 port ip)
        结构体数据长度:
     返回
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
    
    // 3. 发送数据
    /** 
     参数
        client socket:
        发送内容指针
        发送内容长度
        发送方式标志, 一般为0
     返回值
        如果成功, 则返回字节数
     */
    NSString * msg = @"hello socket";
    //const char * msg1 = "hello socket 1";
    ssize_t sendLen = send(clientSocket, msg.UTF8String, strlen(msg.UTF8String), 0);
    NSLog(@"send %ld",sendLen);
    
    // 4. 读取数据
    /**
     参数
     客户端socket
     接收内容缓冲区
     buffer长度
     接收方式        0表示阻塞 , 必须等待着服务器返回数据 (下面的代码不执行 除非收到msg)
     返回值
     
     */
    uint8_t buffer[1024];
    ssize_t recvLen = recv(clientSocket, buffer, sizeof(buffer), 0);
    NSLog(@"recieve %ld",recvLen);      // 终端中输入str 回车
    
    //
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
