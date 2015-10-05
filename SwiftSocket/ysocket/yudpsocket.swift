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

@asmname("yudpsocket_server") func c_yudpsocket_server(host: UnsafePointer<Int8>, port: in_port_t) -> Int32
@asmname("yudpsocket_recive") func c_yudpsocket_recive(fd:Int32, buffer:UnsafeMutablePointer<UInt8>, length: Int, ip:UnsafeMutablePointer<CChar>, port:UnsafeMutablePointer<in_port_t>) -> Int
@asmname("yudpsocket_close") func c_yudpsocket_close(fd:Int32) -> Int32
@asmname("yudpsocket_client") func c_yudpsocket_client() -> Int32
@asmname("yudpsocket_get_server_ip") func c_yudpsocket_get_server_ip(host: UnsafePointer<Int8>, ip: UnsafeMutablePointer<Int8>) -> Int32
@asmname("yudpsocket_sentto") func c_yudpsocket_sentto(fd: Int32, buff: UnsafePointer<UInt8>, len: Int, ip: UnsafePointer<CChar>, port: in_port_t) -> Int

public class UDPClient: YSocket {
    public override init(addr a:String,port p:in_port_t){
        super.init()
        var remoteipbuff:[Int8] = [Int8](count:16,repeatedValue:0x0)
        let ret=c_yudpsocket_get_server_ip(a, ip: &remoteipbuff)
        if ret==0{
            if let ip=String(CString: remoteipbuff, encoding: NSUTF8StringEncoding){
                self.addr=ip
                self.port=p
                let fd:Int32=c_yudpsocket_client()
                if fd>0{
                    self.fd=fd
                }
            }
        }
    }
	
    ///send data
    ///return success or fail with message
    public func send(data d:[UInt8]) throws {
        if let fd:Int32=self.fd{
            let sendsize=c_yudpsocket_sentto(fd, buff: d, len: d.count, ip: self.addr, port: self.port)
            if Int(sendsize)==d.count{
                return //(true,"send success")
            }else{
                throw Errors.SendFailure
            }
        }else{
            throw Errors.SocketNotOpen
        }
    }
	
    ///send string
    ///return success or fail with message
    public func send(string s:String) throws {
        if let fd:Int32=self.fd{
            if let cStr = s.cStringUsingEncoding(NSUTF8StringEncoding) {
                let cStrSize = cStr.count - 1 //Remove the trailing null
                let sendsize=c_yudpsocket_sentto(fd, buff: UnsafePointer<UInt8>(cStr), len: cStrSize, ip: self.addr, port: self.port)
                if sendsize==cStrSize{
                    return //(true,"send success")
                }else{
                    throw Errors.SendFailure
                }
            } else {
                throw Errors.SendFailure
            }
        }else{
            throw Errors.SocketNotOpen
        }
    }
	
    /// send nsdata
    public func send(data d:NSData)throws {
        if let fd:Int32=self.fd{
            let sendsize=c_yudpsocket_sentto(fd, buff: UnsafePointer<UInt8>(d.bytes), len: d.length, ip: self.addr,port: self.port)
            if sendsize==d.length{
                return //(true,"send success")
            }else{
                throw Errors.SendFailure
            }
        }else{
            throw Errors.SocketNotOpen
        }
    }
    public func close() throws {
        if let fd:Int32=self.fd{
            c_yudpsocket_close(fd)
            self.fd=nil
            return //(true,"close success")
        }else{
            throw Errors.SocketNotOpen
        }
    }
    //TODO: add multycast and boardcast
}

public class UDPServer:YSocket{
    public override init(addr a:String,port p:in_port_t){
        super.init(addr: a, port: p)
        let fd:Int32 = c_yudpsocket_server(self.addr, port: self.port)
        if fd>0{
            self.fd=fd
        }
    }
    //TODO: add multycast and boardcast
    public func recv(expectlen:Int) throws -> ([UInt8]?,String,in_port_t) {
        if let fd:Int32 = self.fd{
            var buff:[UInt8] = [UInt8](count:expectlen,repeatedValue:0x0)
            var remoteipbuff:[Int8] = [Int8](count:16,repeatedValue:0x0)
            var remoteport:in_port_t=0
            let readLen=c_yudpsocket_recive(fd, buffer: &buff, length: expectlen, ip: &remoteipbuff, port: &remoteport)
            let port:in_port_t=in_port_t(remoteport)
            var addr:String=""
            if let ip=String(CString: remoteipbuff, encoding: NSUTF8StringEncoding){
                addr=ip
            }
            if readLen<=0{
                return (nil,addr,port)
            }
            let rs=buff[0..<Int(readLen)]
            let data:[UInt8] = Array(rs)
            return (data,addr,port)
        }
        throw Errors.NoIP
    }
    public func close() throws {
        if let fd:Int32=self.fd{
            c_yudpsocket_close(fd)
            self.fd=nil
            return //(true,"close success")
        }else{
            throw Errors.SocketNotOpen
        }
    }
}
