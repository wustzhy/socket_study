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

@property (nonatomic, assign) int clientSocket;


@property (weak, nonatomic) IBOutlet UITextField *IPTextField;
@property (weak, nonatomic) IBOutlet UITextField *portTextField;

@property (weak, nonatomic) IBOutlet UISwitch *connectStatusSwitch;

@property (weak, nonatomic) IBOutlet UITextField *textToSendTextField;
@property (weak, nonatomic) IBOutlet UITextField *receivedTextField;


@end

@implementation ViewController

- (IBAction)doConnect:(id)sender {
    
    BOOL connectSuccess = [self connetSocketWithHost:self.IPTextField.text port:self.portTextField.text.intValue ];
    [self.connectStatusSwitch setOn: connectSuccess animated:YES];
}
- (IBAction)doDisconnect:(id)sender {
    
    int closeSuccess = [self closeSocket];  // !(-1) = false    !(0) = true
    if (closeSuccess == 0) {
        [self.connectStatusSwitch setOn: NO animated:YES];
    }
}
- (IBAction)doSend:(id)sender {
    
    [self sendMessage:self.textToSendTextField.text];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.IPTextField.text = @"127.0.0.1";
    self.portTextField.text = @"12345";
}

- (BOOL)connetSocketWithHost:(NSString *)host port:(int)port{
    // 1. 创建socket
    /**
     参数
     domain:    协议域 AF_INET -> IPV4
     type:      socket类型 ,SOCK_STREAM -> TCP , SOCK_DGRAM -> UDP
     protocol:  IPPROTO_TCP, 如果0 , 自动选择,根据上个(第二个)参数而定
     返回
     return:    socket
     */
    self.clientSocket = socket(AF_INET, SOCK_STREAM, 0); // 6
    
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
    serverAddr.sin_port = htons(port); // htons 该宏 专用于写 端口号    // 20480(高地位互换)
    serverAddr.sin_addr.s_addr = inet_addr(host.UTF8String); // 底层ip地址也是一串二进制
    int connResult = connect(self.clientSocket, (const struct sockaddr *)&serverAddr, sizeof(serverAddr));
    if (connResult == 0) {
        NSLog(@"socket connet successfully");
        return YES;
    }else{
        NSLog(@"socket connet fail %zd",connResult);
        return NO;
    }
    // 终端 nc -lk 12345
    // nc - Netcat
    
}
- (int)closeSocket{
    // 长连接/短连接 , 取决于收发频次, 太高频次则长连接
    
    // 5.关闭连接   // 群聊,多对多其实就是单对单,原理:a发给b,同时发送给cde
    int closeSuccess = close(self.clientSocket);
    // 长连接: 建立连接收到数据关->短连接(eg:qq聊天发完data就断掉节约资源不然server爆掉)
    // 短连接: 不关->长连接 (iphone默认 苹果iOS长连接推送 只要有网就连接着(除非断网,网络恢复后连接成功并保持),这样就可以实时的接收通知)
    // 服务器 怎么减缓压力, 分布式(server机房/群), 如 华南区一台服务器负责南方的 , 华北区另一台服务器负责北方的, so总服务器压力 减轻
    if (closeSuccess == 0) {    // 0 ok, -1 fail
        NSLog(@"close socket successfully ~");
    }
    return closeSuccess;
}

-(void)sendMessage:(NSString *)msg{
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
    // 1个汉字3 bytes  //1个英文字符1 byte
    //const char * msg1 = "hello socket 1";
    ssize_t sendLen = send(self.clientSocket, msg.UTF8String, strlen(msg.UTF8String), 0);
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
    ssize_t recvLen = recv(self.clientSocket, buffer, sizeof(buffer), 0);
    NSLog(@"recieve %ld bytes",recvLen);      // 终端中输入str 回车
    NSData * data = [NSData dataWithBytes:buffer length:recvLen];
    NSString * str_recv = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"recieve msg: %@",str_recv);
    
    [self receiveMessage:str_recv];
    
}

-(void)receiveMessage:(NSString *)recvMsg{
    self.receivedTextField.text = recvMsg;
}



// xmpp 即时通讯 框架 , 多拨代理

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
