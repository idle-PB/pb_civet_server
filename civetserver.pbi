; CivetServer.pbi 
; Idle (Andrew Ferguson)
; Pb Civet Server built on civetweb
; Civetweb project https://github.com/civetweb 
; PBVersion 0.9 for PB 5.62 x86 civetweb 1.10.0 
; Copyright (c) 2018 Andrew Ferguson

; * Permission is hereby granted, free of charge, To any person obtaining a copy
; * of this software And associated documentation files (the "Software"), To deal
; * in the Software without restriction, including without limitation the rights
; * To use, copy, modify, merge, publish, distribute, sublicense, And/Or sell
; * copies of the Software, And To permit persons To whom the Software is
; * furnished To do so, subject To the following conditions:
; *
; * The above copyright notice And this permission notice shall be included in
; * all copies Or substantial portions of the Software.
; *
; * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS Or
; * IMPLIED, INCLUDING BUT Not LIMITED To THE WARRANTIES OF MERCHANTABILITY,
; * FITNESS For A PARTICULAR PURPOSE And NONINFRINGEMENT. IN NO EVENT SHALL THE
; * AUTHORS Or COPYRIGHT HOLDERS BE LIABLE For ANY CLAIM, DAMAGES Or OTHER
; * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT Or OTHERWISE, ARISING FROM,
; * OUT OF Or IN CONNECTION With THE SOFTWARE Or THE USE Or OTHER DEALINGS IN
; * THE SOFTWARE.
; */

IncludeFile "civetweb.pbi"
IncludeFile "ezpack\EzPack.pbi"
IncludeFile "mimetypes.pbi" 


Structure Civet_Server_Tokens 
  name.s
  value.s 
EndStructure   
     
 Structure Civet_Server_Request
  ctx.i                              ; Context of connection
  Uri.s                              ; Uri of the request   
  RequestType.s                      ; Type of request GET POST   
  user.s                             ; not implimented  
  cookie.s                           ; not implimented 
  Auth.s                             ; not implimented  
  querystring.s                      ; Query string if any  
   
  Map mHeaders.Civet_Server_Tokens(128) ;map of header tokens name value pairs  
  Map mQuery.Civet_Server_Tokens(128)   ;map of query tokens name value pairs 
EndStructure 

Structure Civet_Server_Handler 
  *function 
  path.s 
EndStructure   

Prototype Civet_Server_PostProcess(ctx,*request.Civet_Server_Request) ;POST Callback prototype  
Prototype Civet_Server_GetProcess(ctx,*request.Civet_Server_Request)  ;GET  Callback Prototype 

Structure Civet_Server_Settings 
   cgi_pattern.s    ;**.cgi$|**.pl$|**.php$
   cgi_environment.s  ;comma seperated VARIABLE1=VALUE1,VARIABLE2=VALUE2
   cgi_interpreter.s  ;Path to an executable to use as CGI interpreter
   put_delete_auth_file.s ;Passwords file for PUT and DELETE requests.
   protect_uri.s    ;Comma separated list of URI=PATH pairs
   authentication_domain.s ;Authorization realm used for HTTP digest authentication.used in the encoding of the .htpasswd auth 
   enable_auth_domain_check.s ;yes
   ssi_pattern.s              ;**.shtml$|**.shtm$
   throttle.s                 ; * limit all or x.x.x.x/mask subnet or uri_prefix_pattern eg /downloads/=5k  
   access_log_file.s          ;Path To a file For access logs defaults none 
   enable_directory_listing.s ;yes or no default yes 
   error_log_file.s           ;Path to a file for error logs. defaults none
   global_auth_file.s         ;Path to a global passwords file form user:realm:digest \r\n test:test.com:ce0220efc2dd2fad6185e1f1af5a4327
   index_files.s              ;Comma-separated list of files to be treated as directory index files. 
   enable_keep_alive.s        ;yes or no 
   access_control_list.s      ;; -0.0.0.0/0,+192.168/16    deny all accesses, only allow 192.168/16 subnet
   extra_mime_types.s         ;.cpp=plain/text,.java=plain/text
   listening_ports.s           ;eg 127.0.0.1:80,443s  or [::1]:8080 ipv6
   document_root.s            ;the directory to serve. "." currentdir but better to use absolute path
   ssl_certificate.s          ;Path to the SSL certificate file.only if ssl port listening
   num_threads.s              ;number of concurrent HTTP connections eg 50 
   run_as_user.s              ;eg run_as_user webserver
   url_rewrite_patterns.s     ;eg **.doc$=/path/to/cgi-bin/handle_doc.cgi
   hide_files_patterns.s      ;eg secret.txt|**.hide
   request_timeout_ms.s       ;30000
   keep_alive_timeout_ms.s    ;eg 500 Or 0 Idle timeout between two requests in one keep-alive connection.
   cgi_timeout_ms.s           ;Maximum allowed Runtime For CGI scripts. default is no timeout
   linger_timeout_ms.s        ;Set TCP socket linger timeout before closing sockets or 0 abortive close, -1 turn off linger -2 wont set linger
   websocket_timeout_ms.s     ;Timeout for network read and network write operations for websockets, WS(S), in milliseconds
   enable_websocket_ping_pong.s ;yes no 
   websocket_root.s             ;if different than document root 
   access_control_allow_origin.s;* Access-Control-Allow-Origin header field, used for cross-origin resource sharing (CORS).
   access_control_allow_methods.s ;*
   access_control_allow_headers.s ;*
   error_pages.s                  ;This option may be used to specify a directory for user defined error pages.
   tcp_nodelay.s                  ;0 or 1 default 0=Keep the default: Nagel's algorithm enabled
   static_file_max_age.s          ;3600 Set the maximum time (in seconds) a cache may store a static files.
   strict_transport_security_max_age.s ;Set the Strict-Transport-Security header, and set the max-age value. force https
   decode_url.s                       ;default yes but note only if you let civet handle it 
   ssl_verify_peer.s                   ;yes no Enable client's certificate verification by the server.
   ssl_ca_path.s                       ;Name of a directory containing trusted CA certificates.
   ssl_ca_file.s                       ;Path to a .pem file containing trusted certificates
   ssl_verify_depth.s                  ;9 Sets maximum depth of certificate chain. 
   ssl_default_verify_paths.s          ;yes Loads default trusted certificates locations set at openssl compile time.
   ssl_cipher_list.s                   ;eg ALL or AES128:!MD5   AES 128 with digests other than MD5
   ssl_protocol_version.s              ;0 =SSL2+SSL3+TLS1.0+TLS1.1+TLS1.2 or 1 = SSL3+TLS1.0+TLS1.1+TLS1.2 .. 4
   ssl_short_trust.s                   ;no  Enables the use of short lived certificates.
   allow_sendfile_call.s               ;yes linux only 
   case_sensitive.s                    ;no This option can be uset to enable case URLs for Windows servers
   allow_index_script_resource.s       ;no 
   additional_header.s                 ;Send additional HTTP response header line for every request "X-Frame-Options: SAMEORIGIN"
 EndStructure  

  Structure Civet_Server
    *packAddress  ;if served from memory ?start  
    packsize.l    ; ?end - ?start 
    DirRelitive.s ;eg path to zip archive to index.html eg "www" 
    Civet_Context.i ; passed around by civetweb 
    http_port.s     ;filled in by civet server on start up  
    https_port.s    ;filled in by civet server on start up  
    Server_Features.i   ; eg #MG_FEATURE_SUPPORT_CACHING | #MG_FEATURE_SUPPORTS_HTTPS
    Server_Settings.Civet_Server_Settings ;server configuration settings 
    Server_CallBacks.mg_callbacks            ;prototype callback functions useful for debug eg cb_begin_request()
    Map Server_handlers.Civet_server_handler() ;map of uri handlers eg /login   
        
    ;user call back funtions 
    cbpost.Civet_Server_PostProcess;  ;user call back for processing POST data
    cbget.Civet_Server_GetProcess  ;  ;user call back for processing GET query string data  
                          ;cbput.protPutProcess  ;  ;user call back for processing PUT requests 
                          ;cbDelete.protDeleteProcess ;user call back for processing DELETE request
  EndStructure 
  
  Global Civet_Server_Log_Access_File.i 
  Global Civet_Server_Log_Error_File.i
  
  DeclareC.l _Civet_Server_Handler(ctx,*app.Civet_Server) 
  Declare Civet_Server_Stop(*app.Civet_Server) 
  ;utility function to create a pack of your website once you've finished editing 
  ;call it before starting the server and it will create or overwrite the pack file 
  Procedure Civet_Server_Create_Pack(*app.Civet_Server)
     Protected pack.iEzPack = NewEzPack() 
     Protected file.s = *app\Server_Settings\document_root + ".ezp" 
     pack\BuildSourceFileList(*app\Server_Settings\document_root)
     pack\CreatePack(file) 
     pack\Free() 
  EndProcedure   
      
  Procedure Civet_Server_AddHandler(*app.Civet_Server,*function,path.s) 
    
    If Not FindMapElement(*app\Server_handlers(),path)
      *app\Server_handlers(path)\function = *function 
      *app\Server_handlers(path)\path = path 
     If mg_set_request_handler(*app\Civet_Context,path,*function,*app)
       ProcedureReturn 1 
     Else 
       ProcedureReturn -1     
     EndIf
   Else 
      ProcedureReturn 0 
   EndIf   
 EndProcedure 
   
  Procedure Civet_Server_RemoveHandler(*app.Civet_Server,path.s) 
    If FindMapElement(*app\Server_handlers(),path)
      DeleteMapElement(*app\Server_handlers()) 
      If mg_set_request_handler(*app\Civet_Context,path,0,0)
       ProcedureReturn 1 
     Else 
       ProcedureReturn -1     
     EndIf
   Else 
      ProcedureReturn 0 
   EndIf   
    
  EndProcedure  
  
 Procedure.s Civet_Server_GetMimeType(file.s) 
   ProcedureReturn MimeTypes_LookUp(file)
 EndProcedure  
 
ProcedureC Civet_Server_log_access(connection,*message)
  Protected msg.s 
  msg = PeekS(*message,-1,#PB_UTF8) 
  If IsFile(Civet_Server_log_access_file)
    WriteString(Civet_Server_log_access_file,msg,#PB_Unicode)
    WriteString(Civet_Server_log_access_file,#CRLF$,#PB_Unicode)
  EndIf   
  CompilerIf Defined(CIVET_WEB_DEBUG,#PB_Constant)
     Debug "Access " + msg 
  CompilerEndIf    
  ProcedureReturn 1
EndProcedure 

ProcedureC Civet_Server_log_Error(connection,*message)
  Protected msg.s 
  msg = PeekS(*message,-1,#PB_UTF8) 
  If IsFile(Civet_Server_Log_Error_File)
    WriteString(Civet_Server_Log_Error_File,msg,#PB_Unicode)
    WriteString(Civet_Server_Log_Error_File,#CRLF$,#PB_Unicode)
  EndIf   
  CompilerIf Defined(CIVET_WEB_DEBUG,#PB_Constant)  
    Debug "Error " + msg 
  CompilerEndIf   
  ProcedureReturn 1
EndProcedure 

  
 Procedure Civet_Server_Try_Start(*app.Civet_Server) 
  Protected features,a,b 
  Dim options(104) 
  features = mg_init_library(*app\Server_Features)
  If features <> *app\Server_Features
    Debug " features "  ;check your feature flags 
  EndIf 
  
  If Not  mimetypes\init
     mimetypes\init = MimeTypes_Init() 
  EndIf   
  
  If *app\Server_Settings\access_control_allow_headers 
    options(a) = UTF8("access_control_allow_headers") 
    a+1 
    options(a) = UTF8(*app\Server_Settings\access_control_allow_headers) 
    a+1
  EndIf 
  If *app\Server_Settings\access_control_allow_methods 
    options(a) = UTF8("access_control_allow_methods") 
    a+1 
    options(a) = UTF8(*app\Server_Settings\access_control_allow_methods) 
    a+1
  EndIf 
  If *app\Server_Settings\access_control_allow_origin 
    options(a) = UTF8("access_control_allow_origin") 
    a+1 
    options(a) = UTF8(*app\Server_Settings\access_control_allow_origin) 
    a+1
  EndIf 
  If *app\Server_Settings\access_control_list <> "" 
    options(a) = UTF8("access_control_list") 
    a+1 
    options(a) = UTF8(*app\Server_Settings\access_control_list) 
    a+1
  EndIf 
  If *app\Server_Settings\access_log_file 
    options(a) = UTF8("access_log_file") 
    a+1 
    options(a) = UTF8(*app\Server_Settings\access_log_file)
    Civet_Server_log_access_file = OpenFile(#PB_Any,*app\Server_Settings\access_log_file,#PB_File_Append)   
    a+1
  EndIf 
  If *app\Server_Settings\additional_header 
    options(a) = UTF8("additional_header") 
    a+1 
    options(a) = UTF8(*app\Server_Settings\additional_header) 
    a+1
  EndIf 
  If *app\Server_Settings\allow_index_script_resource 
    options(a) = UTF8("allow_index_script_resource") 
    a+1 
    options(a) = UTF8(*app\Server_Settings\allow_index_script_resource) 
    a+1
  EndIf 
  If *app\Server_Settings\allow_sendfile_call 
    options(a) = UTF8("allow_sendfile_call") 
    a+1 
    options(a) = UTF8(*app\Server_Settings\allow_sendfile_call) 
    a+1
  EndIf 
  If *app\Server_Settings\authentication_domain 
    options(a) = UTF8("authentication_domain") 
    a+1 
    options(a) = UTF8(*app\Server_Settings\authentication_domain) 
    a+1
  EndIf 
  If *app\Server_Settings\case_sensitive 
    options(a) = UTF8("case_sensitive") 
    a+1 
    options(a) = UTF8(*app\Server_Settings\case_sensitive) 
    a+1
  EndIf 
  If *app\Server_Settings\cgi_environment 
    options(a) = UTF8("cgi_environment") 
    a+1 
    options(a) = UTF8(*app\Server_Settings\cgi_environment) 
    a+1
  EndIf 
  If *app\Server_Settings\cgi_interpreter 
    options(a) = UTF8("cgi_interpreter") 
    a+1 
    options(a) = UTF8(*app\Server_Settings\cgi_interpreter) 
    a+1
  EndIf 
  If *app\Server_Settings\cgi_pattern 
    options(a) = UTF8("cgi_pattern") 
    a+1 
    options(a) = UTF8(*app\Server_Settings\cgi_pattern) 
    a+1
  EndIf 
  If *app\Server_Settings\cgi_timeout_ms 
    options(a) = UTF8("cgi_timeout_ms") 
    a+1 
    options(a) = UTF8(*app\Server_Settings\cgi_timeout_ms) 
    a+1
  EndIf 
  If *app\Server_Settings\decode_url 
    options(a) = UTF8("decode_url") 
    a+1 
    options(a) = UTF8(*app\Server_Settings\decode_url) 
    a+1
  EndIf 
  If *app\Server_Settings\document_root 
    options(a) = UTF8("document_root") 
    a+1 
    options(a) = UTF8(*app\Server_Settings\document_root) 
    a+1
  EndIf 
  If *app\Server_Settings\enable_auth_domain_check 
    options(a) = UTF8("enable_auth_domain_check") 
    a+1 
    options(a) = UTF8(*app\Server_Settings\enable_auth_domain_check) 
    a+1
  EndIf 
  If *app\Server_Settings\enable_directory_listing 
    options(a) = UTF8("enable_directory_listing") 
    a+1 
    options(a) = UTF8(*app\Server_Settings\enable_directory_listing) 
    a+1
  EndIf 
  If *app\Server_Settings\enable_keep_alive 
    options(a) = UTF8("enable_keep_alive") 
    a+1 
    options(a) = UTF8(*app\Server_Settings\enable_keep_alive) 
    a+1
  EndIf 
  If *app\Server_Settings\enable_websocket_ping_pong 
    options(a) = UTF8("enable_websocket_ping_pong") 
    a+1 
    options(a) = UTF8(*app\Server_Settings\enable_websocket_ping_pong) 
    a+1
  EndIf 
  If *app\Server_Settings\error_log_file 
    options(a) = UTF8("error_log_file") 
    a+1 
    options(a) = UTF8(*app\Server_Settings\error_log_file) 
    Civet_Server_Log_Error_File = OpenFile(#PB_Any,*app\Server_Settings\error_log_file,#PB_File_Append)  
    a+1
  EndIf 
  If *app\Server_Settings\error_pages 
    options(a) = UTF8("error_pages") 
    a+1 
    options(a) = UTF8(*app\Server_Settings\error_pages) 
    a+1
  EndIf 
  If *app\Server_Settings\extra_mime_types 
    options(a) = UTF8("extra_mime_types") 
    a+1 
    options(a) = UTF8(*app\Server_Settings\extra_mime_types) 
    a+1
  EndIf 
  If *app\Server_Settings\global_auth_file 
    options(a) = UTF8("global_auth_file") 
    a+1 
    options(a) = UTF8(*app\Server_Settings\global_auth_file) 
    a+1
  EndIf 
  If *app\Server_Settings\hide_files_patterns 
    options(a) = UTF8("hide_files_patterns") 
    a+1 
    options(a) = UTF8(*app\Server_Settings\hide_files_patterns) 
    a+1
  EndIf 
  If *app\Server_Settings\index_files 
    options(a) = UTF8("index_files") 
    a+1 
    options(a) = UTF8(*app\Server_Settings\index_files) 
    a+1
  EndIf 
  If *app\Server_Settings\keep_alive_timeout_ms 
    options(a) = UTF8("keep_alive_timeout_ms") 
    a+1 
    options(a) = UTF8(*app\Server_Settings\keep_alive_timeout_ms) 
    a+1
  EndIf 
  If *app\Server_Settings\linger_timeout_ms 
    options(a) = UTF8("linger_timeout_ms") 
    a+1 
    options(a) = UTF8(*app\Server_Settings\linger_timeout_ms) 
    a+1
  EndIf 
  If *app\Server_Settings\listening_ports 
    options(a) = UTF8("listening_ports") 
    a+1 
    options(a) = UTF8(*app\Server_Settings\listening_ports) 
    a+1
  EndIf 
  If *app\Server_Settings\num_threads 
    options(a) = UTF8("num_threads") 
    a+1 
    options(a) = UTF8(*app\Server_Settings\num_threads) 
    a+1
  EndIf 
  If *app\Server_Settings\protect_uri 
    options(a) = UTF8("protect_uri") 
    a+1 
    options(a) = UTF8(*app\Server_Settings\protect_uri) 
    a+1
  EndIf 
  If *app\Server_Settings\put_delete_auth_file 
    options(a) = UTF8("put_delete_auth_file") 
    a+1 
    options(a) = UTF8(*app\Server_Settings\put_delete_auth_file) 
    a+1
  EndIf 
  If *app\Server_Settings\request_timeout_ms 
    options(a) = UTF8("request_timeout_ms") 
    a+1 
    options(a) = UTF8(*app\Server_Settings\request_timeout_ms) 
    a+1
  EndIf 
  If *app\Server_Settings\run_as_user 
    options(a) = UTF8("run_as_user") 
    a+1 
    options(a) = UTF8(*app\Server_Settings\run_as_user) 
    a+1
  EndIf 
  If *app\Server_Settings\ssi_pattern 
    options(a) = UTF8("ssi_pattern") 
    a+1 
    options(a) = UTF8(*app\Server_Settings\ssi_pattern) 
    a+1
  EndIf 
  If *app\Server_Settings\ssl_ca_file 
    options(a) = UTF8("ssl_ca_file") 
    a+1 
    options(a) = UTF8(*app\Server_Settings\ssl_ca_file) 
    a+1
  EndIf 
  If *app\Server_Settings\ssl_ca_path 
    options(a) = UTF8("ssl_ca_path") 
    a+1 
    options(a) = UTF8(*app\Server_Settings\ssl_ca_path) 
    a+1
  EndIf 
  If *app\Server_Settings\ssl_certificate 
    options(a) = UTF8("ssl_certificate") 
    a+1 
    options(a) = UTF8(*app\Server_Settings\ssl_certificate) 
    a+1
  EndIf 
  If *app\Server_Settings\ssl_cipher_list 
    options(a) = UTF8("ssl_cipher_list") 
    a+1 
    options(a) = UTF8(*app\Server_Settings\ssl_cipher_list) 
    a+1
  EndIf 
  If *app\Server_Settings\ssl_default_verify_paths 
    options(a) = UTF8("ssl_default_verify_paths") 
    a+1 
    options(a) = UTF8(*app\Server_Settings\ssl_default_verify_paths) 
    a+1
  EndIf 
  If *app\Server_Settings\ssl_protocol_version 
    options(a) = UTF8("ssl_protocol_version") 
    a+1 
    options(a) = UTF8(*app\Server_Settings\ssl_protocol_version) 
    a+1
  EndIf 
  If *app\Server_Settings\ssl_short_trust 
    options(a) = UTF8("ssl_short_trust") 
    a+1 
    options(a) = UTF8(*app\Server_Settings\ssl_short_trust) 
    a+1
  EndIf 
  If *app\Server_Settings\ssl_verify_depth 
    options(a) = UTF8("ssl_verify_depth") 
    a+1 
    options(a) = UTF8(*app\Server_Settings\ssl_verify_depth) 
    a+1 
  EndIf 
  If *app\Server_Settings\ssl_verify_peer 
    options(a) = UTF8("ssl_verify_peer") 
    a+1 
    options(a) = UTF8(*app\Server_Settings\ssl_verify_peer) 
    a+1
  EndIf 
  If *app\Server_Settings\static_file_max_age 
    options(a) = UTF8("static_file_max_age") 
    a+1 
    options(a) = UTF8(*app\Server_Settings\static_file_max_age) 
    a+1
  EndIf 
  If *app\Server_Settings\strict_transport_security_max_age 
    options(a) = UTF8("strict_transport_security_max_age") 
    a+1 
    options(a) = UTF8(*app\Server_Settings\strict_transport_security_max_age) 
    a+1
  EndIf 
  If *app\Server_Settings\tcp_nodelay 
    options(a) = UTF8("tcp_nodelay") 
    a+1 
    options(a) = UTF8(*app\Server_Settings\tcp_nodelay) 
    a+1 
  EndIf 
  If *app\Server_Settings\throttle 
    options(a) = UTF8("throttle") 
    a+1 
    options(a) = UTF8(*app\Server_Settings\throttle) 
    a+1 
  EndIf 
  If *app\Server_Settings\url_rewrite_patterns 
    options(a) = UTF8("url_rewrite_patterns") 
    a+1 
    options(a) = UTF8(*app\Server_Settings\url_rewrite_patterns) 
    a+1
  EndIf 
  If *app\Server_Settings\websocket_root 
    options(a) = UTF8("websocket_root") 
    a+1 
    options(a) = UTF8(*app\Server_Settings\websocket_root) 
    a+1
  EndIf 
  If *app\Server_Settings\websocket_timeout_ms 
    options(a) = UTF8("websocket_timeout_ms") 
    a+1 
    options(a) = UTF8(*app\Server_Settings\websocket_timeout_ms) 
  EndIf   
    
  If *app\Server_Settings\access_log_file 
    *app\Server_CallBacks\log_Access = @Civet_Server_log_access()
  EndIf   
   If *app\Server_Settings\error_log_file 
    *app\Server_CallBacks\http_error = @Civet_Server_log_Error()
  EndIf
  
  
  *app\Civet_Context = mg_start(*app\Server_CallBacks,0,@options(0));
  
  For b = 0 To a -1
    FreeMemory(options(b)) 
  Next   
  
  SetFeature_Browser_Emulation()  
  
  If Civet_Server_AddHandler(*app,@_Civet_Server_Handler(),"/") = 1
    ProcedureReturn *app\Civet_Context 
  EndIf 
      
EndProcedure  


Procedure Civet_Server_Start(*app.Civet_Server,httpPort.i,httpsPort.i,IP.s="localhost",try=10) 
  Protected ctx,a
  For a = 0 To try 
    *app\http_port = Str(httpPort+a) 
    *app\https_port = Str(httpsPort+a) 
    *app\Server_Settings\listening_ports = IP + ":" + *app\http_Port +"," + *app\https_Port + "s" 
    ctx =  Civet_Server_Try_Start(*app) 
    If ctx 
      ProcedureReturn ctx 
    Else 
      Civet_Server_Stop(*app)
  EndIf   
  Next 
EndProcedure   

Procedure Civet_Server_Stop(*app.Civet_Server) 
  
   Civet_Server_RemoveHandler(*app,"/")
   mg_stop(*app\Civet_Context);
   mg_exit_library()          ; 
   DelFeature_Browser_Emulation()
   If Civet_Server_log_access_file 
     CloseFile(Civet_Server_log_access_file) 
   EndIf   
   If Civet_Server_Log_Error_File 
      CloseFile(Civet_Server_Log_Error_File) 
   EndIf   
 EndProcedure 
 
;-Send a responce to the client with either a file or in memory object
; note this function is to be only called from within a Post or Get callback  
; uri: full path with the file extension of the the resource even if it's a memory object  
; *mem: pointer to the in memory resource, the uri is still required to work out content type 
; MemSize: note if data is UTF8(text) specify the memsize-1  
Procedure Civet_Server_Send_Response(Ctx,Uri.s="",*Mem=0,MemSize=0,Response.s="200 OK") 
      ;need to change this to include headers info to keep connection alive 
      Protected content.s = Civet_Server_GetMimeType(Uri) 
           
      If Uri =""      
        Protected *header = Ascii("HTTP/1.1 " + Response + #CRLF$ + "Connection: close" + #CRLF$ + "Content-Length: "  + Str(MemSize) + #CRLF$ + "Content-Type: " + content + #CRLF$  +"Cache-Control: no-cache" + #CRLF$ +  #CRLF$)
        Protected hlen = MemorySize(*header)-1
        Protected result = mg_write(ctx,*header,hlen) 
        If result > 0 
          FreeMemory(*header)
          If (*mem And MemSize)
            ProcedureReturn mg_Write(ctx,*mem,MemSize) 
          Else 
            ProcedureReturn 1
          EndIf   
        Else 
          FreeMemory(*header)
          ProcedureReturn result 
        EndIf 
      ElseIf uri <> ""
        mg_send_file(ctx,uri)
        ProcedureReturn 1 
      EndIf   
      
 EndProcedure 
 
 Structure tm
   tm_sec.l;   // seconds after the minute - [0, 60] including leap second
   tm_min.l;   // minutes after the hour - [0, 59]
   tm_hour.l;  // hours since midnight - [0, 23]
   tm_mday.l;  // day of the month - [1, 31]
   tm_mon.l;   // months since January - [0, 11]
   tm_year.l;  // years since 1900
   tm_wday.l;  // days since Sunday - [0, 6]
   tm_yday.l;  // days since January 1 - [0, 365]
   tm_isdst.l; // daylight savings time flag
 EndStructure 
 
 ImportC "" 
   time(*tm)
   gmtime(*tm) 
 EndImport  
 
 Procedure.s _Civet_Server_Get_Date()
   Protected time.tm,*time.tm,date.s,day.s  
   time(@time)
   *time = gmtime(@time) 
      
   Select *time\tm_wday 
     Case 0 
       day = "Sun"
     Case 1 
       day = "Mon"
     Case 2 
       day = "Tue" 
     Case 3 
       day = "Wed"
     Case 4 
       day = "Thu" 
     Case 5 
       day = "Fri" 
     Case 6 
       day = "Sat" 
   EndSelect     
   
    date + Day + ", " + RSet(Str(*time\tm_mday),2,"0") + " " + RSet(Str(1 + *time\tm_mon),2,"0") + " " + Str(1900 + *time\tm_year) + " " + RSet(Str(*time\tm_hour),2,"0") + ":" + RSet(Str(*time\tm_min),2,"0") + ":" + RSet(Str(*time\tm_sec),2,"0") + " UTC" 
    ProcedureReturn date 
  EndProcedure  
 
Procedure _Civet_Server_ProcessQueryString(Query.s,*request.Civet_Server_Request)
  Protected a,ct,sep,key.s,value.s,keypair.s  
  ct = CountString(Query,"&") +1
  For a = 1 To ct 
    keypair = StringField(Query,a,"&") 
    sep = FindString(keypair,"=",1) 
    key = URLDecoder(Left(keypair,sep-1)) 
    value = URLDecoder(Right(keypair,Len(keypair)-sep))  
    *request\mquery(key)\name = key 
    *request\mquery(key)\Value = value 
  Next    
EndProcedure 

Procedure _Civet_Server_ProcessPost(ctx,*request.Civet_Server_Request,*cbPostProcess.Civet_Server_PostProcess=0)
  Protected *req.mg_request_info,*reqheader.mg_header,len,*buf,a,result 
  *req = mg_get_request_info(ctx)
  
  len = *req\content_length 
  If len 
    *buf = AllocateMemory(len) 
    If *buf 
     result = mg_read(ctx,*buf,len)
     If result > 0 
       _Civet_Server_ProcessQueryString(PeekS(*buf,len,#PB_UTF8),*request)
     ElseIf result = 0 
       ProcedureReturn 400 ;connection closed by client bad request 
     Else 
       ProcedureReturn 413 ;no more data could be read 
     EndIf
     FreeMemory(*buf)
   Else   
     ;failed to allocate memory, reqest size + str(len) 
     ProcedureReturn 400 
   EndIf 
  EndIf 
  
  If *cbPostProcess 
    ProcedureReturn *cbPostProcess(ctx,*request)
  EndIf 
   
EndProcedure 

;procedure is threaded and rentrant calls will be made concurrently, any external resources must be thread safe or locally scoped  
ProcedureC.l _Civet_Server_Handler(ctx,*app.Civet_Server) 
  Protected *req.mg_request_info,*reqheader.mg_header,nhead,a,result   
  Protected uri.s,filenum,*output,*header,hlen,content.s,clen,strResult.s 
  Protected key.s,value.s,time   
  Protected Request.Civet_Server_Request

  *req = mg_get_request_info(ctx)
  If  *req\num_headers 
    For a = 0 To *req\num_headers-1 
      *reqheader = *req\http_headers[a] 
      key.s = PeekS(@*reqheader\name,-1,#PB_UTF8)
      value.s = PeekS(@*reqheader\value,-1,#PB_UTF8) 
      Request\mheaders(key)\name = key
      Request\mheaders(key)\value = value 
      Debug Key + " " + value 
    Next 
  EndIf 
  
  uri = PeekS(@*req\request_uri,-1,#PB_UTF8)
  ReplaceString(uri,"/","\",#PB_String_InPlace)
  
  Request\Uri = uri 
  Request\RequestType = PeekS(@*req\request_method,-1,#PB_UTF8)
  
  Debug "Method " + Request\RequestType +" URI " + uri 
  
  If Request\RequestType = "POST" 
    Result =_Civet_Server_ProcessPost(ctx,@Request,*app\cbpost) 
    If Result <> 0
      ProcedureReturn result  
    Else
      If *app\packAddress = 0
        mg_send_file(ctx,*app\DirRelitive + Request\Uri) 
        ProcedureReturn 200
      EndIf
    EndIf   
  EndIf
  
  If *req\query_string ;if theres a query string
    Request\querystring = URLDecoder(PeekS(@*req\query_string,-1,#PB_UTF8))
    
    _Civet_Server_ProcessQueryString(Request\querystring,@Request) 
    If *app\cbget 
      Result = *app\cbget(ctx,@Request) 
      If Result <> 0
        ProcedureReturn result 
      Else
        If *app\packAddress = 0
          mg_send_file(ctx,*app\DirRelitive + Request\Uri) 
          ProcedureReturn 200
        EndIf
      EndIf   
    EndIf 
  EndIf 
  
  If *app\packAddress
    
    Protected pack.iEzPack = NewEzPack() 
    
    If Not pack\OpenPackFromMemory(*app\packAddress,*app\packsize)
      MessageRequester("EzPack","Failed to Catch Archive") 
      Civet_Server_Stop(*app) 
      End 
    EndIf 
    
    If Request\Uri = "\" ;if uri is root then display index  
      filenum = pack\OpenFile(*app\DirRelitive + "\index.html");
      content = "text/html"
    Else 
      filenum = pack\OpenFile(*app\DirRelitive + Request\URI) 
      content = Civet_Server_GetMimeType(Request\uri) 
      Debug content 
    EndIf 
    
    If filenum
      
      *output = pack\CatchFile(filenum)  
      
      clen = pack\getfilesize(filenum) 
      
           
      If UCase(Request\mheaders("Connection")\value) = "KEEP-ALIVE"
        *header = Ascii("HTTP/1.1 200 OK" + #CRLF$ + "Date: " + _Civet_Server_Get_Date() + #CRLF$ + "Connection: Keep-Alive" + #CRLF$ + "Content-Length: "  + Str(clen) + #CRLF$ + "Content-Type: " + content + #CRLF$  +"Cache-Control: no-cache" + #CRLF$ +  #CRLF$)
      Else 
        *header = Ascii("HTTP/1.1 200 OK" + #CRLF$ + "Date: " + _Civet_Server_Get_Date() + #CRLF$ + "Connection: Close" + #CRLF$ + "Content-Length: "  + Str(clen) + #CRLF$ + "Content-Type: " + content + #CRLF$  +"Cache-Control: no-cache" + #CRLF$ +  #CRLF$)
      EndIf  
      hlen = MemorySize(*header)-1 ;important don't send null char at end of header string len-1
           
      result = mg_write(ctx,*header,hlen) 
      FreeMemory(*header)
      
      If result > 0 
        result = mg_Write(ctx,*output,clen) 
        If result > 0         
          result = 200 
        ElseIf result = 0 
          result = 444 
        Else 
          result = 500 
        EndIf   
      ElseIf result = 0 
        result = 444  
      Else 
        result = 500 
      EndIf 
      
      pack\CloseFile(filenum)  
      pack\Free() 
          
      ProcedureReturn result 
    Else 
      pack\Free()
      ProcedureReturn 404 
    EndIf 
    
  EndIf  
  
EndProcedure  


; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 5
; Folding = ---
; EnableXP