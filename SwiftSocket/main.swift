/*
Copyright (c) <2014>, skysent
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
1. Redistributions of source code must retain the above copyright
notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.
3. All advertising materials mentioning features or use of this software
must display the following acknowledgement:
This product includes software developed by skysent.
4. Neither the name of the skysent nor the
names of its contributors may be used to endorse or promote products
derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY skysent ''AS IS'' AND ANY
EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL skysent BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
import Foundation
import Darwin.C

func testtcpclient(){
    //创建socket
    let client:TCPClient = TCPClient(address: "ixy.io", port: 80)
    //连接
    do {
        try client.connect(timeout: 1)
        try client.send(string:"GET / HTTP/1.0\n\n" )
        let data = try client.read(1024*10)
        if let str=String(bytes: data, encoding: NSUTF8StringEncoding){
            print(str)
        }

    } catch {
        print(error)
    }
}

func echoService(client c:TCPClient){
    print("newclient from:\(c.address)[\(c.port)]")
    do {
        let d = try c.read(1024*10)
        try c.send(data: d)
        try c.close()
    } catch {
        print(error)
    }
}

func testtcpserver(){
    let server:TCPServer = TCPServer(address: "127.0.0.1", port: 8080)
    do {
        try server.listen()
        while true {
            if let client = try? server.accept() {
                echoService(client: client)
            }else{
                print("accept error")
            }
        }
    } catch {
        print(error)
    }
}

//testclient()
func testudpserver(){
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
        let server:UDPServer=UDPServer(address:"127.0.0.1",port:8080)
        var run:Bool=true
        while run{
            do {
                let (data,remoteip,_) = try server.recv(1024)
                print("recive")
                if let d=data{
                    if let str=String(bytes: d, encoding: NSUTF8StringEncoding){
                        print(str)
                    }
                }
                print(remoteip)
                try server.close()
            } catch {
                print(error)
            }
            run = false
            break
        }
    })
}

func testudpclient(){
    let client:UDPClient=UDPClient(address: "localhost", port: 8080)
    print("send hello world")
    do {
        try client.send(string: "hello world")
        try client.close()
    } catch {}
}

testtcpclient()
testudpserver()
testudpclient()

var stdinput=NSFileHandle.fileHandleWithStandardInput()
stdinput.readDataToEndOfFile()

