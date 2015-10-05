//
//  ysocket.h
//  SwiftSocket
//
//  Created by C.W. Betts on 10/5/15.
//  Copyright © 2015 skysent. All rights reserved.
//

#ifndef ysocket_h
#define ysocket_h

#include <sys/types.h>

#pragma GCC visibility push(hidden)

#pragma mark - ytcpsocket.c

int ytcpsocket_connect(const char *host,in_port_t port,int timeout);
int ytcpsocket_close(int socketfd);
long ytcpsocket_send(int socketfd,const char *data,long len);
long ytcpsocket_pull(int socketfd,char *data,long len,int timeout_sec);

///return socket fd
int ytcpsocket_listen(const char *addr,in_port_t port);

///return client socket fd
int ytcpsocket_accept(int onsocketfd,char *remoteip,in_port_t* remoteport);

#pragma mark - yudpsocket.c

///return socket fd
int yudpsocket_server(const char *addr,in_port_t port);
long yudpsocket_recive(int socket_fd,char *outdata,long expted_len,char *remoteip,in_port_t* remoteport);
int yudpsocket_close(int socket_fd);

///return socket fd
int yudpsocket_client();
int yudpsocket_get_server_ip(const char *host,char *ip);

//send message to addr and port
long yudpsocket_sentto(int socket_fd,const char *msg,long len, const char *toaddr, in_port_t topotr);

#pragma GCC visibility pop


#endif /* ysocket_h */
