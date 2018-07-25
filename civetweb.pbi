; Civetweb.pbi 
; Idle (Andrew Ferguson) 
; Civetweb project https://github.com/civetweb 
; PBVersion 0.9 for PB 5.62 x86 civetweb 1.10 
; 
; Logging to file is currently broken if you want to log use the callbacks and write to file
; a patch has been made in civetserver to do access logs.  
;
;
;/*
;/* Copyright (c) 2013-2017 the Civetweb developers
; * Copyright (c) 2004-2013 Sergey Lyubka
; *
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

;-================================================ 
;-CONSTANTS
;-================================================ 
CompilerIf #PB_Compiler_Debugger 
#CIVET_WEB_DEBUG = 1
CompilerEndIf 

#MG_MAX_HEADERS = 60

#MG_FEATURE_SUPPORTS_FILES=1  ;serve files (NO_FILES Not set)
#MG_FEATURE_SUPPORTS_HTTPS = 2;support HTTPS (NO_SSL Not set)
#MG_FEATURE_SUPPORTS_CGI = 4  ;   4  support CGI (NO_CGI Not set)
#MG_FEATURE_SUPPORTS_IPV6 = 8 ;         8  support IPv6 (USE_IPV6 set)
#MG_FEATURE_SUPPORTS_WEBSOCKETS = 16 ;        16  support WebSocket (USE_WEBSOCKET set)
#MG_FEATURE_SUPPORTS_LUA = 32        ;        32  support Lua scripts And Lua server pages (USE_LUA is set)
#MG_FEATURE_SUPPORTS_JAVASCRIPT = 64 ;        64  support server side JavaScript (USE_DUKTAPE is set)
#MG_FEATURE_SUPPORT_CACHING = 128    ;       128  support caching (NO_CACHING Not set)
#MG_FEATURE_SUPPORT_STATS= 256       ;       256  support server side stats 

#MG_CONFIG_TYPE_UNKNOWN = $0
#MG_CONFIG_TYPE_NUMBER = $1
#MG_CONFIG_TYPE_STRING = $2
#MG_CONFIG_TYPE_FILE = $3
#MG_CONFIG_TYPE_DIRECTORY = $4
#MG_CONFIG_TYPE_BOOLEAN = $5
#MG_CONFIG_TYPE_EXT_PATTERN = $6
#MG_CONFIG_TYPE_STRING_LIST = $7
#MG_CONFIG_TYPE_STRING_MULTILINE = $8

#MG_WEBSOCKET_OPCODE_CONTINUATION = $0
#MG_WEBSOCKET_OPCODE_TEXT = $1
#MG_WEBSOCKET_OPCODE_BINARY = $2
#MG_WEBSOCKET_OPCODE_CONNECTION_CLOSE = $8
#MG_WEBSOCKET_OPCODE_PING = $9
#MG_WEBSOCKET_OPCODE_PONG = $a

#MG_FORM_FIELD_STORAGE_SKIP = $0
;	/* Get the field value. */
#MG_FORM_FIELD_STORAGE_GET = $1
;	/* Store the field value into a file. */
#MG_FORM_FIELD_STORAGE_STORE = $2
;	/* Stop parsing this request. Skip the remaining fields. */
#MG_FORM_FIELD_STORAGE_ABORT = $10

#MG_TIMEOUT_INFINITE = -1;   

Structure mg_context : EndStructure ;    /* Handle for the HTTP service itself */
Structure mg_connection : EndStructure; /* Handle for the individual connection */

Structure mg_header 
  name.s;  utf8   ; /* HTTP header name */
  value.s; utf8;  ; /* HTTP header value */
EndStructure

Structure mg_server_ports ;{
  protocol.l              ;    /* 1 = IPv4, 2 = IPv6, 3 = both */
  port.l                  ;        /* port number */
  is_ssl.l                ;      /* https port: 0 = no, 1 = yes */
  is_redirect.l           ; /* redirect all requests: 0 = no, 1 = yes */
  _reserved1.l            ;
  _reserved2.l            ;
  _reserved3.l            ;
  _reserved4.l            ;
EndStructure 

Structure mg_option ;{
  name.s            ;
  type.l            ;
  default_value.s   ;
EndStructure 

Structure mg_client_cert ;{
  subject.s              ;
  issuer.s               ;
  serial.s               ;
  finger.s               ;
EndStructure             ;

Structure mg_client_options ;{
  host.s                    ;
  port.l                    ;
  client_cert.s             ;
  server_cert.s             ;
EndStructure 

;/* This Structure contains information about the HTTP request. */
;/* This Structure may be extended in future versions. */
Structure  mg_response_info ;{
  status_code.l             ;          /* E.g. 200 */
  status_text.s; utf8             ;  /* E.g. "OK" */
  http_version.s; utf8            ; /* E.g. "1.0", "1.1" */
  content_length.q          ; /* Length (in bytes) of the request body,
                            ;   can be -1 If no length was given. */
  num_headers.l             ; /* Number of HTTP headers */
  http_headers.mg_header[#MG_MAX_HEADERS]; /* Allocate maximum headers */
EndStructure                             ;

;/* This Structure contains information about the HTTP request. */
Structure mg_request_info 
  request_method.s; utf8; /* "GET", "POST", etc */
  request_uri.s; utf8   ;    /* URL-decoded URI (absolute or relative, As in the request) */
  local_uri.s     ;      /* URL-decoded URI (relative). Can be NULL
                  ; * If the request_uri does Not address a
                  ; * resource at the server host. */
  http_version.s; utf8  ; /* E.g. "1.0", "1.1" */
  query_string.s; utf8  ; /* URL part after '?', not including '?', or NULL */
  remote_user.s; utf8   ;  /* Authenticated user, or NULL if no auth  used */
  remote_addr.a[48];     /* Client's IP address as a string. */
  
  content_length.q   ; /* Length (in bytes) of the request body, can be -1 If no length was given. */
  remote_port.l      ;          /* Client's port */
  is_ssl.l           ;               /* 1 if SSL-ed, 0 if not */
  *user_data         ;          /* User data pointer passed to mg_start() */
  *conn_data         ;          /* Connection-specific user data */
  
  num_headers.l; /* Number of HTTP headers */
  http_headers.mg_header[#MG_MAX_HEADERS]; /* Allocate maximum headers */
  *client_cert.mg_client_cert            ; /* Client certificate information */
  
  acceptedWebSocketSubprotocol.s ;utf8; /* websocket subprotocol, accepted during handshake */
EndStructure 

PrototypeC field_found(key.p-Unicode,filename.p-Unicode,path.p-Unicode,pathlen.i,*user_data);
PrototypeC field_get(key.p-Unicode,value.p-Unicode,valuelen.i,*user_data)           ;
PrototypeC field_store(path.p-Unicode,file_size.q,*user_data);

Structure mg_form_data_handler  
  *Cbfield_found.field_found 
  *Cbfield_get.field_get 
  *Cbfield_store.field_store 
  *user_data 
EndStructure  

  
; /* This Structure contains callback functions For handling form fields.
;    It is used As an argument To mg_handle_form_request. */
; struct mg_form_data_handler {
; 	/* This callback function is called, If a new field has been found.
; 	 * The Return value of this callback is used To Define how the field
; 	 * should be processed.
; 	 *
; 	 * Parameters:
; 	 *   key: Name of the field ("name" property of the HTML input field).
; 	 *   filename: Name of a file To upload, at the client computer.
; 	 *             Only set For input fields of type "file", otherwise NULL.
; 	 *   path: Output parameter: File name (incl. path) To store the file
; 	 *         at the server computer. Only used If FORM_FIELD_STORAGE_STORE
; 	 *         is returned by this callback. Existing files will be
; 	 *         overwritten.
; 	 *   pathlen: Length of the buffer For path.
; 	 *   user_data: Value of the member user_data of mg_form_data_handler
; 	 *
; 	 * Return value:
; 	 *   The callback must Return the intended storage For this field
; 	 *   (See FORM_FIELD_STORAGE_*).
; 	 */
; 	Int (*field_found)(const char *key,
; 	                   const char *filename,
; 	                   char *path,
; 	                   size_t pathlen,
; 	                   void *user_data);
; 
; 	/* If the "field_found" callback returned FORM_FIELD_STORAGE_GET,
; 	 * this callback will receive the field Data.
; 	 *
; 	 * Parameters:
; 	 *   key: Name of the field ("name" property of the HTML input field).
; 	 *   value: Value of the input field.
; 	 *   user_data: Value of the member user_data of mg_form_data_handler
; 	 *
; 	 * Return value:
; 	 *   TO: Needs To be defined.
; 	 */
; 	Int (*field_get)(const char *key,
; 	                 const char *value,
; 	                 size_t valuelen,
; 	                 void *user_data);
; 
; 	/* If the "field_found" callback returned FORM_FIELD_STORAGE_STORE,
; 	 * the Data will be stored into a file. If the file has been written
; 	 * successfully, this callback will be called. This callback will
; 	 * Not be called For only partially uploaded files. The
; 	 * mg_handle_form_request function will either store the file completely
; 	 * And call this callback, Or it will remove any partial content And
; 	 * Not call this callback function.
; 	 *
; 	 * Parameters:
; 	 *   path: Path of the file stored at the server.
; 	 *   file_size: Size of the stored file in bytes.
; 	 *   user_data: Value of the member user_data of mg_form_data_handler
; 	 *
; 	 * Return value:
; 	 *   TO dO: Needs To be defined.
; 	 */
; 	Int (*field_store)(const char *path, long long file_size, void *user_data);
; 
; 	/* User supplied argument, passed To all callback functions. */
; 	void *user_data;
; };

;-================================================ 
 ImportC "civetwebSSL.lib" 
     
  ;/* Initialize this library. This should be called once before any other
  ;* function from this library. This function is Not guaranteed To be
  ;* thread safe.
  ;* Parameters:
  ;*   features: bit mask For features To be initialized.
  ;* Return value:
  ;*   initialized features
  ;*   if = features ok else error 
  ;-mg_init_library(features.i);  
  ;-================================================  
  mg_init_library(features.i);
  
  ;/* Un-initialize this library.
  ;* Return value:
  ;*   0: error
  ;-mg_exit_library();
  ;-================================================ 
  mg_exit_library();
  
  ;/* Start web server.
  
  ;  Parameters:
  ;    callbacks: mg_callbacks Structure With user-defined callbacks.
  ;    options: NULL terminated List of option_name, option_value pairs that
  ;             specify Civetweb configuration parameters.
  
  ;  Side-effects: on UNIX, ignores SIGCHLD And SIGPIPE signals. If custom
  ;     processing is required For these, signal handlers must be set up
  ;     after calling mg_start().
  
  
  ;  Example:
  ;    const char *options[] = {
  ;      "document_root", "/var/www",
  ;      "listening_ports", "80,443s",
  ;      NULL
  ;    };
  ;    struct mg_context *ctx = mg_start(&my_func, NULL, options);;
  
  ;  Refer To https://github.com/civetweb/civetweb/blob/master/docs/UserManual.md
  ;  For the List of valid option And their possible values.
  
  ;  Return:
  ;    web server context, Or NULL on error. */
  ;-================================================ 
  ;-mg_start(*callbacks,*user_data,*configuration_options)  
   mg_start(*callbacks,*user_data,*configuration_options)
  
  ;/* Stop the web server.
  ;  Must be called last, when an application wants To stop the web server And
  ;  release all associated resources. This function blocks Until all Civetweb
  ;  threads are stopped. Context pointer becomes invalid. */
  ;-================================================ 
  ;- mg_stop(context.i);
  mg_stop(context.i);
  
  ; /* mg_request_handler
  
  ;   Called when a new request comes in.  This callback is URI based
  ;   And configured With mg_set_request_handler().
  
  ;   Parameters:
  ;      conn: current connection information.
  ;      cbdata: the callback Data configured With mg_set_request_handler().
  ;   Returns:
  ;      0: the handler could Not handle the request, so fall through.
  ;      1 - 999: the handler processed the request. The Return code is
  ;               stored As a HTTP status code For the access log. */
  ;-================================================ 
  ;- mg_request_handler(conection.i,*cbdata=0); 
  ;mg_request_handler(conection.i,*cbdata=0);
                                           ;/* mg_set_request_handler
  
  ;   Sets Or removes a URI mapping For a request handler.
  ;   This function uses mg_lock_context internally.
  
  ;   URI's are ordered and prefixed URI's are supported. For example,
  ;   consider two URIs: /a/b And /a
  ;           /a   matches /a
  ;           /a/b matches /a/b
  ;           /a/c matches /a
  
  ;   Parameters:
  ;      ctx: server context
  ;      uri: the URI (exact Or pattern) For the handler
  ;      handler: the callback handler To use when the URI is requested.
  ;               If NULL, an already registered handler For this URI will
  ;               be removed.
  ;               The URI used To remove a handler must match exactly the
  ;               one used To register it (Not only a pattern match).
  ;      cbdata: the callback Data To give To the handler when it is called. */
  ;-================================================  
  ;-mg_set_request_handler(context,uri.s,*handler,*cbdata=0);
  mg_set_request_handler(context,uri.p-utf8,*handler,*cbdata=0);  *handler.mg_request_handler
  
  ;/* Callback types For websocket handlers in C/C++.
  
  ;   mg_websocket_connect_handler
  ;       Is called when the client intends To establish a websocket connection,
  ;       before websocket handshake.
  ;       Return value:
  ;         0: civetweb proceeds With websocket handshake.
  ;         1: connection is closed immediately.
  
  ;   mg_websocket_ready_handler
  ;       Is called when websocket handshake is successfully completed, And
  ;       connection is ready For Data exchange.
  
  ;   mg_websocket_data_handler
  ;       Is called when a Data frame has been received from the client.
  ;       Parameters:
  ;         bits: first byte of the websocket frame, see websocket RFC at
  ;               http://tools.ietf.org/html/rfc6455, section 5.2
  ;         Data, data_len: payload, With mask (If any) already applied.
  ;       Return value:
  ;         1: keep this websocket connection open.
  ;         0: close this websocket connection.
  
  ;   mg_connection_close_handler
  ;       Is called, when the connection is closed.*/
  ;typedef Int (*mg_websocket_connect_handler)(const struct mg_connection *,
  ;                                           void *);
  ;typedef void (*mg_websocket_ready_handler)(struct mg_connection *, void *);
  ;typedef Int (*mg_websocket_data_handler)(struct mg_connection *,
  ;                                         int,
  ;                                         char *,
  ;                                         size_t,
  ;                                         void *);
  ;typedef void (*mg_websocket_close_handler)(const struct mg_connection *,
  ;                                           void *);
  
  ;/* struct mg_websocket_subprotocols
  ; *
  ; * List of accepted subprotocols
  ; */
  ;struct mg_websocket_subprotocols {
  ;	int nb_subprotocols;
  ;	char **subprotocols;
  ;};
  
  ;/* mg_set_websocket_handler
  
  ;   Set Or remove handler functions For websocket connections.
  ;   This function works similar To mg_set_request_handler - see there. */
  ;-================================================ 
  ;-mg_set_websocket_handler(context,uri.s,*connect_handler,*ready_handler,*data_handler,*close_handler,*cbdata=0); 
  mg_set_websocket_handler(context,uri.p-utf8,*connect_handler,*ready_handler,*data_handler,*close_handler,*cbdata=0);
  
  ;/* mg_authorization_handler
  
  ;   Callback function definition For mg_set_auth_handler
  
  ;   Parameters:
  ;      conn: current connection information.
  ;      cbdata: the callback Data configured With mg_set_request_handler().
  ;   Returns:
  ;      0: access denied
  ;      1: access granted
  ; */
  ;typedef Int (*mg_authorization_handler)(struct mg_connection *conn,
  ;                                        void *cbdata);
  ;/* mg_set_auth_handler
  
  ;   Sets Or removes a URI mapping For an authorization handler.
  ;   This function works similar To mg_set_request_handler - see there. */
  ;-================================================ 
  ;-mg_set_auth_handler(context,uri.s,*handler,*cbdata=0);
  mg_set_auth_handler(context,uri.p-utf8,*handler,*cbdata=0);
  
  ;/* Get the value of particular configuration parameter.
  ;   The value returned is Read-only. Civetweb does Not allow changing
  ;   configuration at run time.
  ;   If given parameter name is Not valid, NULL is returned. For valid
  ;   names, Return value is guaranteed To be non-NULL. If parameter is Not
  ;   set, zero-length string is returned. */
  ;-================================================ 
  ;-mg_get_option(context,name.s);  returns string 
  mg_get_option(context,name.p-utf8);  returns string 
  
  ;/* Get context from connection. */
  ;-================================================ 
  ;-mg_get_context(connection);
  mg_get_context(connection);
  
  ;/* Get user Data passed To mg_start from context. */
  ;-================================================ 
  ;-mg_get_user_data(context);
  mg_get_user_data(context);
  
  ;/* Set user Data For the current connection. */
  ;-================================================ 
  ;-mg_set_user_connection_data(connection,*usrData=0);
  mg_set_user_connection_data(connection,*usrData=0);
  
  ;* Get user Data set For the current connection. */
  ;-================================================ 
  ;-mg_get_user_connection_data(connection);
  mg_get_user_connection_data(connection);
  
  ;/* Get a formatted link corresponding To the current request
  
  ;   Parameters:
  ;      conn: current connection information.
  ;      buf: string buffer (out)
  ;      buflen: length of the string buffer
  ;   Returns:
  ;      <0: error
  ;      >=0: ok */
  ;
  ;-================================================ 
  ;-mg_get_request_link(connection,*buf,buflen.i);
  mg_get_request_link(connection,*buf,buflen.i);
  
  ;/* Return Array of struct mg_option, representing all valid configuration
  ;   options of civetweb.c.
  ;   The Array is terminated by a NULL name option. */
  ;-================================================ 
  ;-mg_get_valid_options();
  mg_get_valid_options();
  
  ;/* Get the List of ports that civetweb is listening on.
  ;   The parameter size is the size of the ports Array in elements.
  ;   The caller is responsibility To allocate the required memory.
  ;   This function returns the number of struct mg_server_ports elements
  ;   filled in, Or <0 in Case of an error. */
  ;-================================================ 
  ;-mg_get_server_ports(context,size.l,*ports);
  mg_get_server_ports(context,size.l,*ports);
  
  ;/* Add, edit Or delete the entry in the passwords file.
  ; *
  ; * This function allows an application To manipulate .htpasswd files on the
  ; * fly by adding, deleting And changing user records. This is one of the
  ; * several ways of implementing authentication on the server side. For another,
  ; * cookie-based way please refer To the examples/chat in the source tree.
  ; *
  ; * Parameter:
  ; *   passwords_file_name: Path And name of a file storing multiple passwords
  ; *   realm: HTTP authentication realm (authentication domain) name
  ; *   user: User name
  ; *   password:
  ; *     If password is Not NULL, entry modified Or added.
  ; *     If password is NULL, entry is deleted.
  ; *
  ; *  Return:
  ; *    1 on success, 0 on error.
  ; */
  ;-================================================ 
  ;-mg_modify_passwords_file(passwords_file_name.s,realm.p-utf8,user.p-utf8,password.p-utf8);
  mg_modify_passwords_file(passwords_file_name.p-utf8,realm.p-utf8,user.p-utf8,password.p-utf8);
  
  ;/* Return information associated With the request.
  ; * Use this function To implement a server And get Data about a request
  ; * from a HTTP/HTTPS client.
  ; * Note: Before CivetWeb 1.10, this function could be used To Read
  ; * a response from a server, when implementing a client, although the
  ; * values were never returned in appropriate mg_request_info elements.
  ; * It is strongly advised To use mg_get_response_info For clients.
  ; */
  ;CIVETWEB_API const struct mg_request_info *
  ;-================================================ 
  ;-mg_get_request_info(connection);
  mg_get_request_info(connection);
  
  ;/* Return information associated With a HTTP/HTTPS response.
  ; * Use this function in a client, To check the response from
  ; * the server. */
  ;CIVETWEB_API const struct mg_response_info *
  ;-================================================ 
  ;-mg_get_response_info(connection);
  mg_get_response_info(connection);
  
  ;/* Send Data To the client.
  ;   Return:
  ;    0   when the connection has been closed
  ;    -1  on error
  ;    >0  number of bytes written on success */
  ;-================================================ 
  ;-mg_write(connection,*buf,len.i);
  mg_write(connection,*buf,len.i);
  
  ;/* Send Data To a websocket client wrapped in a websocket frame.  Uses
  ;   mg_lock_connection To ensure that the transmission is Not interrupted,
  ;   i.e., when the application is proactively communicating And responding To
  ;   a request simultaneously.
  
  ;   Send Data To a websocket client wrapped in a websocket frame.
  ;   This function is available when civetweb is compiled With -DUSE_WEBSOCKET
  
  ;   Return:
  ;    0   when the connection has been closed
  ;    -1  on error
  ;    >0  number of bytes written on success */
  ;-================================================ 
  ;-mg_websocket_write(connection,opcode.l,*Data,len.i);
  mg_websocket_write(connection,opcode.l,*Data,len.i);
  
  ;/* Send Data To a websocket server wrapped in a masked websocket frame.  Uses
  ;   mg_lock_connection To ensure that the transmission is Not interrupted,
  ;   i.e., when the application is proactively communicating And responding To
  ;   a request simultaneously.
  
  ;   Send Data To a websocket server wrapped in a masked websocket frame.
  ;   This function is available when civetweb is compiled With -DUSE_WEBSOCKET
  
  ;   Return:
  ;    0   when the connection has been closed
  ;    -1  on error
  ;    >0  number of bytes written on success */
  ;-================================================ 
  ;-mg_websocket_client_write(connection,opcode.l,*Data.s,len.i);
  mg_websocket_client_write(connection,opcode.l,*Data,len.i);
  
  ;/* Blocks Until unique access is obtained To this connection. Intended For use
  ;   With websockets only.
  ;   Invoke this before mg_write Or mg_printf when communicating With a
  ;   websocket If your code has server-initiated communication As well As
  ;   communication in direct response To a message. */
  ;-================================================ 
  ;-mg_lock_connection(connection);
  
  mg_lock_connection(connection);
  ;-================================================ 
  ;-mg_unlock_connection(connection);
  mg_unlock_connection(connection);
  
  ;/* Lock server context.  This lock may be used To protect resources
  ;   that are Shared between different connection/worker threads. */
  ;-================================================ 
  ;-mg_lock_context(context);
  mg_lock_context(context);
  ;-================================================ 
  ;-mg_unlock_context(context);
  mg_unlock_context(context);
  
  ;/* Send Data To the client using printf() semantics.
  ;   Works exactly like mg_write(), but allows To do message formatting. */
  ;mg_printf(connection, PRINTF_FORMAT_STRING(const char *fmt), ...) PRINTF_ARGS(2, 3);   <----------------fix
  ;/* Send a part of the message body, If chunked transfer encoding is set.
  ; * Only use this function after sending a complete HTTP request Or response
  ; * header With "Transfer-Encoding: chunked" set. */
  ;-================================================ 
  ;-mg_send_chunk(connection,*chunk,chunklen.l);
  mg_send_chunk(connection,*chunk,chunklen.l);
  
  ;/* Send contents of the entire file together With HTTP headers. */
  ;-================================================ 
  ;-mg_send_file(connection,path.s);
  mg_send_file(connection,path.p-utf8);
  
  ;/* Send HTTP error reply. */
  ;-================================================ 
  ;-mg_send_http_error(connection,status_code.l,format.p-utf8,*arg,*arg1=0,*arg2=0,*arg3=0,*arg4=0,*arg5=0,*arg6=0,*arg8=0,*arg9=0);
  mg_send_http_error(connection,status_code.l,format.p-utf8,*arg,*arg1=0,*arg2=0,*arg3=0,*arg4=0,*arg5=0,*arg6=0,*arg8=0,*arg9=0);
    
  ;/* Send HTTP digest access authentication request.
  ; * Browsers will send a user name And password in their Next request, showing
  ; * an authentication dialog If the password is Not stored.
  ; * Parameters:
  ; *   conn: Current connection handle.
  ; *   realm: Authentication realm. If NULL is supplied, the sever domain
  ; *          set in the authentication_domain configuration is used.
  ; * Return:
  ; *   < 0   Error
  ; */
  ;-================================================ 
  ;-mg_send_digest_access_authentication_request(connection,realm.s);
  mg_send_digest_access_authentication_request(connection,realm.p-utf8);
  
  ;/* Check If the current request has a valid authentication token set.
  ; * A file is used To provide a List of valid user names, realms And
  ; * password hashes. The file can be created And modified using the
  ; * mg_modify_passwords_file API function.
  ; * Parameters:
  ; *   conn: Current connection handle.
  ; *   realm: Authentication realm. If NULL is supplied, the sever domain
  ; *          set in the authentication_domain configuration is used.
  ; *   filename: Path And name of a file storing multiple password hashes.
  ; * Return:
  ; *   > 0   Valid authentication
  ; *   0     Invalid authentication
  ; *   < 0   Error (all values < 0 should be considered As invalid
  ; *         authentication, future error codes will have negative
  ; *         numbers)
  ; *   -1    Parameter error
  ; *   -2    File Not found
  ; */
  ;-================================================ 
  ;-mg_check_digest_access_authentication(connection,realm.s,filename.s);
  mg_check_digest_access_authentication(connection,realm.s,filename.p-utf8);
  
  ;/* Send contents of the entire file together With HTTP headers.
  ; * Parameters:
  ; *   conn: Current connection handle.
  ; *   path: Full path To the file To send.
  ; *   mime_type: Content-Type For file.  NULL will cause the type To be
  ; *              looked up by the file extension.
  ;-================================================ 
  ;-mg_send_mime_file(connection,path.s,mime_type.s);
  mg_send_mime_file(connection,path.s,mime_type.p-utf8);
  ;/* Send contents of the entire file together With HTTP headers.
  ;   Parameters:
  ;     conn: Current connection information.
  ;     path: Full path To the file To send.
  ;     mime_type: Content-Type For file.  NULL will cause the type To be
  ;                looked up by the file extension.
  ;     additional_headers: Additional custom header fields appended To the header.
  ;                         Each header should start With an X-, To ensure it is
  ;                         Not included twice.
  ;                         NULL does Not append anything.
  ;-================================================ 
  ;-mg_send_mime_file2(connection,path.s,mime_type.s,additional_headers.s);
  mg_send_mime_file2(connection,path.s,mime_type.p-utf8,additional_headers.p-utf8);
  
  ;/* Store body Data into a file. */
  ;-================================================ 
  ;-mg_store_body.q(connection,path.s);  long long  
  mg_store_body.q(connection,path.p-utf8); 
  
  ;/* Read entire request body And store it in a file "path".
  ;   Return:
  ;     < 0   Error
  ;     >= 0  Number of bytes stored in file "path".
  ;*/
  
  ;/* Read Data from the remote End, Return number of bytes Read.
  ;   Return:
  ;     0     connection has been closed by peer. No more Data could be Read.
  ;     < 0   Read error. No more Data could be Read from the connection.
  ;     > 0   number of bytes Read into the buffer. */
  ;-================================================ 
  ;-mg_read(connection,*buf,len.i);
  mg_read(connection,*buf,len.i);
  
  ;/* Get the value of particular HTTP header.
  
  ;  This is a helper function. It traverses request_info->http_headers Array,
  ;  And If the header is present in the Array, returns its value. If it is
  ;  Not present, NULL is returned. */
  ;-================================================ 
  ;-mg_get_header(connection,name.s);  return string 
  mg_get_header(connection,name.p-utf8);  return string 
  ;/* Get a value of particular form variable.
  ;   Parameters:
  ;     Data: pointer To form-uri-encoded buffer. This could be either POST Data,
  ;           Or request_info.query_string.
  ;     data_len: length of the encoded Data.
  ;     var_name: variable name To decode from the buffer
  ;     dst: destination buffer For the decoded variable
  ;     dst_len: length of the destination buffer
  
  ;   Return:
  ;     On success, length of the decoded variable.
  ;     On error:
  ;        -1 (variable Not found).
  ;        -2 (destination buffer is NULL, zero length Or too small To hold the
  ;            decoded variable).
  
  ;   Destination buffer is guaranteed To be '\0' - terminated If it is Not
  ;   NULL Or zero length. */
  ;-================================================ 
  ;-mg_get_var(sData.s,len.i,var_name.p-utf8,*dst,dst_len.i);
    mg_get_var(sData.s,len.i,var_name.p-utf8,*dst,dst_len.i);
    
  ;/* Get a value of particular form variable.
  ;   Parameters:
  ;     Data: pointer To form-uri-encoded buffer. This could be either POST Data,
  ;           Or request_info.query_string.
  ;     data_len: length of the encoded Data.
  ;     var_name: variable name To decode from the buffer
  ;     dst: destination buffer For the decoded variable
  ;     dst_len: length of the destination buffer
  ;     occurrence: which occurrence of the variable, 0 is the first, 1 the
  ;                 second...
  ;                this makes it possible To parse a query like
  ;                b=x&a=y&a=z which will have occurrence values b:0, a:0 And a:1
  
  ;   Return:
  ;     On success, length of the decoded variable.
  ;     On error:
  ;        -1 (variable Not found).
  ;        -2 (destination buffer is NULL, zero length Or too small To hold the
  ;            decoded variable).
  
  ;   Destination buffer is guaranteed To be '\0' - terminated If it is Not
  ;   NULL Or zero length. */
  ;-================================================ 
  ;-mg_get_var2(*data,data_len.i,var_name.p-utf8,*dst,dst_len.i,occurrence.i);
  mg_get_var2(*data,data_len.i,var_name.p-utf8,*dst,dst_len.i,occurrence.i);
  
  ;/* Fetch value of certain cookie variable into the destination buffer.
  ;   Destination buffer is guaranteed To be '\0' - terminated. In Case of
  ;   failure, dst[0] == '\0'. Note that RFC allows many occurrences of the same
  ;   parameter. This function returns only first occurrence.
  
  ;   Return:
  ;     On success, value length.
  ;     On error:
  ;        -1 (either "Cookie:" header is Not present at all Or the requested
  ;            parameter is Not found).
  ;        -2 (destination buffer is NULL, zero length Or too small To hold the
  ;            value). */
  ;-================================================ 
  ;-mg_get_cookie(cookie.p-utf8,var_name.p-utf8,*buf,buf_len.i);
  mg_get_cookie(cookie.p-utf8,var_name.p-utf8,*buf,buf_len.i);
  
  ;/* Download Data from the remote web server.
  ;     host: host name To connect To, e.g. "foo.com", Or "10.12.40.1".
  ;     port: port number, e.g. 80.
  ;     use_ssl: wether To use SSL connection.
  ;     error_buffer, error_buffer_size: error message placeholder.
  ;     request_fmt,...: HTTP request.
  ;   Return:
  ;     On success, valid pointer To the new connection, suitable For mg_read().
  ;     On error, NULL. error_buffer contains error message.
  ;   Example:
  ;     char ebuf[100];
  ;     struct mg_connection *conn;
  ;     conn = mg_download("google.com", 80, 0, ebuf, SizeOf(ebuf),
  ;    "%s", "GET / HTTP/1.0\r\nHost: google.com\r\n\r\n");
  
  ;-================================================ 
  ;-mg_download(host.p-utf8,port.l,use_ssl.l,*error_buffer,error_buffer_size.i,format.p-utf8,*arg,*arg1=0,*arg2=0,*arg3=0,*arg4=0,*arg5=0,*arg6=0,*arg7=0,*arg8=0,*arg9=0)
  mg_download(host.p-utf8,port.l,use_ssl.l,*error_buffer,error_buffer_size.i,format.p-utf8,*arg,*arg1=0,*arg2=0,*arg3=0,*arg4=0,*arg5=0,*arg6=0,*arg7=0,*arg8=0,*arg9=0)
   
  ;/* Close the connection opened by mg_download(). */
  ;-================================================ 
  ;-mg_close_connection(connection);
  mg_close_connection(connection)                            ;
  
  ;/* Process form Data.
  ;* Returns the number of fields handled, Or < 0 in Case of an error.
  ; * Note: It is possible that several fields are already handled successfully
  ; * (e.g., stored into files), before the request handling is stopped With an
  ; * error. In this Case a number < 0 is returned As well.
  ; * In any Case, it is the duty of the caller To remove files once they are
  ; * no longer required. */
  ;-================================================ 
  ;-mg_handle_form_request(connection,*fdh);  .mg_form_data_handler
  mg_handle_form_request(connection,*fdh) 
  
  ;/* Convenience function -- create detached thread.
  ;   Return: 0 on success, non-0 on error. */
  ;typedef void *(*mg_thread_func_t)(void *);
  ;-================================================ 
  ;-mg_start_thread(*thread_func,*p);
  mg_start_thread(*thread_func,*p)                           ;
  
  ;/* Return builtin mime type For the given file name.
  ;   For unrecognized extensions, "text/plain" is returned. */
  ;-================================================ 
  ;-mg_get_builtin_mime_type(file_name.s);  return string 
  mg_get_builtin_mime_type(file_name.p-utf8);  return string 
  
  ;/* Get text representation of HTTP status code. */
  ;-================================================ 
  ;-mg_get_response_code_text(connection,response_code.l); return string 
  mg_get_response_code_text(connection,response_code.l); return string 
  
  ;/* Return CivetWeb version. */
  ;-================================================ 
  ;-mg_versions(); 
  mg_version(); return string 
  
  ;/* URL-decode input buffer into destination buffer.
  ;   0-terminate the destination buffer.
  ;   form-url-encoded Data differs from URI encoding in a way that it
  ;;   uses '+' As character For space, see RFC 1866 section 8.2.1
  ;   http://ftp.ics.uci.edu/pub/ietf/html/rfc1866.txt
  ;   Return: length of the decoded Data, Or -1 If dst buffer is too small. */
  ;-================================================ 
  ;-mg_url_decode(*src,src_len.l,*dst,dst_len.l,is_form_url_encoded.l);
  mg_url_decode(*src,src_len.l,*dst,dst_len.l,is_form_url_encoded.l);
  
  ;/* URL-encode input buffer into destination buffer.
  ;   returns the length of the resulting buffer Or -1
  ;   is the buffer is too small. */
  ;-================================================ 
  ;-mg_url_encode(*src,*dst,dst_len.i);
  mg_url_encode(*src,*dst,dst_len.i);
  
  ;/* MD5 hash given strings.
  ;   Buffer 'buf' must be 33 bytes long. Varargs is a NULL terminated List of
  ;   ASCIIz strings. When function returns, buf will contain human-readable
  ;   MD5 hash. Example:
  ;     char buf[33];
  ;     mg_md5(buf, "aa", "bb", NULL); */
  ;mg_md5(char buf[33], ...);  <---------------------------------------------------;Reimpliment with PB built in 
  
  ;/* Print error message To the opened error log stream.
  ;   This utilizes the provided logging configuration.
  ;     conn: connection (Not used For sending Data, but To get perameters)
  ;     fmt: format string without the line Return
  ;     ...: variable argument List
  ;   Example:
  ;     mg_cry(conn,"i like %s", "logging"); */
  ;-================================================ 
  ;-mg_cry(connection,format.p-utf8,*args1=0,*args2=0,*args3=0,*args4=0,*args5=0,*args6=0,*args7=0,*args8=0)
  mg_cry(connection,format.p-utf8,*args,*args1=0,*args2=0,*args3=0,*args4=0,*args5=0,*args6=0,*args7=0,*args8=0) ;2,3 
    
  ;/* utility methods To compare two buffers, Case insensitive. */
  ;-================================================ 
  ;-mg_strcasecmp(s1.s,s2.s);
  mg_strcasecmp(s1.p-utf8,s2.p-utf8);
   
  ;-mg_strncasecmp(s1.p-UTF8,s2.p-UTF8,len.i);
  ;-================================================ 
  mg_strncasecmp(s1.s,s2.s,len.i)   ;
  
  ;/* Connect To a websocket As a client
  ;   Parameters:
  ;     host: host To connect To, i.e. "echo.websocket.org" Or "192.168.1.1" Or
  ;   "localhost"
  ;     port: server port
  ;     use_ssl: make a secure connection To server
  ;     error_buffer, error_buffer_size: buffer For an error message
  ;     path: server path you are trying To connect To, i.e. If connection To
  ;   localhost/app, path should be "/app"
  ;     origin: value of the Origin HTTP header
  ;     data_func: callback that should be used when Data is received from the
  ;   server
  ;     user_data: user supplied argument
  
  ;   Return:
  ;     On success, valid mg_connection object.
  ;     On error, NULL. Se error_buffer For details.
  ;*/
  ;-================================================ 
  ;-mg_connect_websocket_client(host.s,port.l,use_ssl.l,*error_buffer,error_buffer_size.i,path.s,origin.s,*mg_websocket_data_handler,*mg_websocket_close_handler,*user_data=0);
  mg_connect_websocket_client(host.p-utf8,port.l,use_ssl.l,*error_buffer,error_buffer_size.i,path.p-UTF8,origin.p-UTF8,*mg_websocket_data_handler,*mg_websocket_close_handler,*user_data=0);
  
  ;/* Connect To a TCP server As a client (can be used To connect To a HTTP server)
  ;   Parameters:
  ;     host: host To connect To, i.e. "www.wikipedia.org" Or "192.168.1.1" Or
  ;   "localhost"
  ;     port: server port
  ;     use_ssl: make a secure connection To server
  ;     error_buffer, error_buffer_size: buffer For an error message;
  
  ;   Return:
  ;     On success, valid mg_connection object.
  ;     On error, NULL. Se error_buffer For details.
  ;*/
  ;-================================================ 
  ;-mg_connect_client(host.s,port.l,use_ssl.l,*error_buffer,error_buffer_size.i);
  mg_connect_client(host.s,port.l,use_ssl.l,*error_buffer,error_buffer_size.i);
  
  ;struct mg_client_options {
  ;	const char *host;
  ;	int port;
  ;	const char *client_cert;
  ;	const char *server_cert;
  ;	/* TO: add more Data */
  ;};
  ;-================================================ 
  ;-mg_connect_client_secure(*client_options,*error_buffer,error_buffer_size.i);
  mg_connect_client_secure(*client_options,*error_buffer,error_buffer_size.i);
  
  ;/* Wait For a response from the server
  ;   Parameters:
  ;     conn: connection
  ;     ebuf, ebuf_len: error message placeholder.
  ;     timeout: time To wait For a response in milliseconds (If < 0 then wait
  ;   ForEver)
  
  ;   Return:
  ;     On success, >= 0
  ;     On error/timeout, < 0
  ;*/
  ;-================================================ 
  ;-mg_get_response(connection,*ebuf,ebuf_len.i,timeout.l);
  mg_get_response(connection,*ebuf,ebuf_len.i,timeout.l);
  
  ;/* Check which features where set when the civetweb library has been compiled.
  ;   The function explicitly addresses compile time defines used when building
  ;   the library - it does Not mean, the feature has been initialized using a
  ;   mg_init_library call.
  ;   mg_check_feature can be called anytime, even before mg_init_library has
  ;   been called.
  
  ;   Parameters:
  ;     feature: specifies which feature should be checked
  ;       The value is a bit mask. The individual bits are defined As:
  
  ;  #MG_FEATURE_SUPPORTS_FILES=1  ;serve files (NO_FILES Not set)
  ;  #MG_FEATURE_SUPPORTS_HTTPS = 2   ;support HTTPS (NO_SSL Not set)
  ;  #MG_FEATURE_SUPPORTS_CGI = 4  ;   4  support CGI (NO_CGI Not set)
  ;  #MG_FEATURE_SUPPORTS_IPV6 = 8 ;         8  support IPv6 (USE_IPV6 set)
  ;  #MG_FEATURE_SUPPORTS_WEBSOCKETS = 16 ;        16  support WebSocket (USE_WEBSOCKET set)
  ;  #MG_FEATURE_SUPPORTS_LUA = 32;        32  support Lua scripts And Lua server pages (USE_LUA is set)
  ;  #MG_FEATURE_SUPPORTS_JAVASCRIPT = 64;        64  support server side JavaScript (USE_DUKTAPE is set)
  ;  #MG_FEATURE_SUPPORT_CACHING = 128;       128  support caching (NO_CACHING Not set)
  ;  #MG_FEATURE_SUPPORT_STATS= 256;       256  support server statistics (USE_SERVER_STATS is set)
  
  ;       The result is undefined, If bits are set that do Not represent a
  ;       defined feature (currently: feature >= 512).
  ;       The result is undefined, If no bit is set (feature == 0).
  
  ;   Return:
  ;     If feature is available, the corresponding bit is set
  ;     If feature is Not available, the bit is 0
  ;*/
  ;-================================================ 
  ;-mg_check_feature(feature.i);
  mg_check_feature(feature.i);
  
  ;/* Get information on the system. Useful For support requests.
  ;   Parameters:
  ;     buffer: Store system information As string here.
  ;     buflen: Length of buffer (including a byte required For a terminating 0).
  ;   Return:
  ;     Available size of system information, exluding a terminating 0.
  ;     The information is complete, If the Return value is smaller than buflen.
  ;     The result is a JSON formatted string, the exact content may vary.
  ;   Note:
  ;     It is possible To determine the required buflen, by first calling this
  ;     function With buffer = NULL And buflen = NULL. The required buflen is
  ;     one byte more than the returned value.
  ;*/
  ;-================================================ 
  ;-mg_get_system_info(*buffer,buflen.l);
  mg_get_system_info(*buffer,buflen.l);
  
  ;/* Get context information. Useful For server diagnosis.
  ;   Parameters:
  ;     ctx: Context handle
  ;     buffer: Store context information here.
  ;     buflen: Length of buffer (including a byte required For a terminating 0).
  ;   Return:
  ;     Available size of system information, exluding a terminating 0.
  ;     The information is complete, If the Return value is smaller than buflen.
  ;     The result is a JSON formatted string, the exact content may vary.
  ;     Note:
  ;     It is possible To determine the required buflen, by first calling this
  ;     function With buffer = NULL And buflen = NULL. The required buflen is
  ;     one byte more than the returned value. However, since the available
  ;     context information changes, you should allocate a few bytes more.
  ;*/
  ;-================================================ 
  ;-mg_get_context_info(context,*buffer,buflen.l);
  mg_get_context_info(context,*buffer,buflen.l);
  
  ;-================================================ 
  ;-mg_printf(ctx,*buf,len)
  ;-================================================ 
EndImport   


#MG_THREAD_TYPE_MASTER = 0
#MG_THREAD_TYPE_WORKER = 1 
#MG_THREAD_TYPE_HELPER = 2 
;-================================================ 
;-Call back Prototypes
;-================================================ 
PrototypeC begin_request(connection) 
PrototypeC end_request(connection,status_code.l) 
PrototypeC log_message(connection,*message.p-utf8)
PrototypeC log_access(connection,*message.p-utf8) 
PrototypeC init_ssl(ssl_context,*userdata) 
PrototypeC connection_close(connection) 
PrototypeC init_lua(connection,lua_context) 
PrototypeC http_error(connection,status_code.l)
PrototypeC init_context(context) 
PrototypeC init_thread(context,thread_type.l)
PrototypeC exit_context(context) 
PrototypeC init_connection(connection,*conn_data) ;**
;-================================================ 
;-Structure mg_callbacks
;-================================================ 
Structure mg_callbacks ;Prototypes 
  *begin_request.begin_request 
  *end_request.end_request 
  *log_message.log_message 
  *log_Access.log_access 
  *inti_ssl.init_ssl
  *connection_close.connection_close 
  *init_LUA.init_lua
  *http_error.http_error 
  *init_context.init_context 
  *init_thread.init_thread  
  *exit_context.exit_context  
  *init_connection.init_connection 
EndStructure   

 PrototypeC mg_websocket_connect_handler(mg_connection,*void);
 PrototypeC mg_websocket_ready_handler(mg_connection,*void);
 PrototypeC mg_websocket_data_handler(mg_connection,bit.l,*data,len.i,*cbdata)
 PrototypeC mg_websocket_close_handler(mg_connection,*void);
 
 Structure mg_websocket_callbacks 
   *connect_handler.mg_websocket_connect_handler 
   *ready_handler.mg_websocket_ready_handler 
   *data_handler.mg_websocket_data_handler
   *close_handler.mg_websocket_close_handler 
 EndStructure 
 
   
;/* Called when civetweb has received new HTTP request.
;	   If the callback returns one, it must process the request
;	   by sending valid HTTP headers And a body. Civetweb will Not do
;	   any further processing. Otherwise it must Return zero.
;	   Note that since V1.7 the "begin_request" function is called
;	   before an authorization check. If an authorization check is
;	   required, use a request_handler instead.
;	   Return value:
;	     0: civetweb will process the request itself. In this Case,
;	        the callback must Not send any Data To the client.
;	     1-999: callback already processed the request. Civetweb will
;	            Not send any Data after the callback returned. The
;	            Return code is stored As a HTTP status code For the
;	            access log. */

;-================================================ 
;-ProcedureC.l cb_begin_request(connection)
ProcedureC.l cb_begin_request(connection) 
  Protected Result=0
  Protected *req.mg_request_info
  *req = mg_get_request_info(connection)
  Debug "Begin request from connection " + Str(connection)  + " HTTP version " + PeekS(@*req\http_version,-1,#PB_UTF8)
  Debug "method " + PeekS(@*req\request_method,-1,#PB_UTF8) + " from " + PeekS(@*req\remote_addr[0],48,#PB_Ascii) + PeekS(@*req\local_uri,-1,#PB_UTF8) 
  ProcedureReturn 0 
EndProcedure   

;/* Called when civetweb has finished processing request. */
;-================================================ 
;-ProcedureC cb_end_request(connection,status.l)  
ProcedureC cb_end_request(connection,status.l)
  Protected Result=0
  Debug "End request from connection " + Str(connection) + "Status " + Str(status) 
EndProcedure   

;/* Called when civetweb is about To log a message. If callback returns
;	   non-zero, civetweb does Not log anything. */
;-================================================ 
;-ProcedureC.l cb_log_message(connection,message.s) 
ProcedureC.l cb_log_message(connection,*message)
  Debug "log message " + PeekS(*message,-1,#PB_UTF8) 
  ProcedureReturn 0  ;1 = no log written 0 = log written 
EndProcedure 

;/* Called when civetweb is about To log access. If callback returns
;	   non-zero, civetweb does Not log anything. */
;-================================================ 
;- ProcedureC.l cb_log_access(connection,message.s)
ProcedureC cb_log_access(connection,*message)
  Debug "log access " + PeekS(*message,-1,#PB_UTF8) 
  ProcedureReturn 0 ;1 = no log written 0 = log written 
EndProcedure 

;/* Called when civetweb initializes SSL library.
;   Parameters:
;	     user_data: parameter user_data passed when starting the server.
;	   Return value:
;	     0: civetweb will set up the SSL certificate.
;	     1: civetweb assumes the callback already set up the certificate.
;	    -1: initializing ssl fails. */
;-================================================ 
;- ProcedureC.l cb_init_ssl(ssl_context,*user_data) 
ProcedureC.l cb_init_ssl(ssl_context,*user_data) 
  ProcedureReturn 0 
EndProcedure   

;/* Called when civetweb is closing a connection.  The per-context mutex is
;	   locked when this is invoked.

;	   Websockets:
;	   Before mg_set_websocket_handler has been added, it was primarily useful
;	   For noting when a websocket is closing, And used To remove it from any
;	   application-maintained List of clients.
;	   Using this callback For websocket connections is deprecated: Use
;	   mg_set_websocket_handler instead.

;	   Connection specific Data:
;	   If memory has been allocated For the connection specific user Data
;	   (mg_request_info->conn_data, mg_get_user_connection_data),
;	   this is the last chance To free it.
;-================================================ 
;-ProcedureC cb_connection_closed(connection) 
ProcedureC cb_connection_closed(connection) 
  Debug "Connection closed " + Str(connection) 
EndProcedure   
;/* Called when civetweb is about To serve Lua server page, If
;   Lua support is enabled.
;   Parameters:
;   lua_context: "lua_State *" pointer. */
;-================================================ 
;-ProcedureC cb_init_Lua(connection,lua_context)  
ProcedureC cb_init_Lua(connection,lua_context) 
EndProcedure 

;/* Called when civetweb is about To send HTTP error To the client.
;	   Implementing this callback allows To create custom error pages.
;	   Parameters:
;	     status: HTTP error status code.
;	   Return value:
;	     1: run civetweb error handler.
;	     0: callback already handled the error. */
;-================================================ 
;- ProcedureC.l cb_http_error(connection,status.l)
ProcedureC.l cb_http_error(connection,status.l)
  Debug "HTTP Error with connection " + Str(connection) + " Status " + Str(status)  
  ProcedureReturn 0   
EndProcedure   

;/* Called after civetweb context has been created, before requests
;	   are processed.
;	   Parameters:
;	   ctx: context handle */
;-================================================ 
;-ProcedureC cb_init_Context(context)  
ProcedureC cb_init_Context(context) 
  Protected *buff,len 
  Debug "Civetweb context " + Str(context)
  *buff = AllocateMemory(4096)
  len = mg_get_system_info(*buff,4096)
  Debug "System Info" 
  Debug PeekS(*buff,-1,#PB_UTF8) 
  FreeMemory(*buff)  
EndProcedure   

;/* Called when a new worker thread is initialized.
;   Parameters:
;     ctx: context handle
;	     thread_type:
;	       0 indicates the master thread
;	       1 indicates a worker thread handling client connections
;	       2 indicates an internal helper thread (timer thread)
;-================================================ 
;-ProcedureC cb_init_Thread(context,thread_type.l)
ProcedureC cb_init_Thread(context,thread_type.l)
  Select thread_type 
    Case #MG_THREAD_TYPE_MASTER
      Debug " Master Thread created on context " + Str(context) 
    Case #MG_THREAD_TYPE_WORKER 
      Debug " Worker Thread created on context " + Str(context) 
    Case #MG_THREAD_TYPE_HELPER 
      Debug " Helper Thread created on context " + Str(context) 
  EndSelect      
EndProcedure

;/* Called when civetweb context is deleted.
;	   Parameters:
;   ctx: context handle */
;-================================================ 
;-ProcedureC cb_exit_context(context)
ProcedureC cb_exit_context(context) 
  Debug "Exiting context " + Str(contex) 
EndProcedure  

; /* Called when initializing a new connection object.
;	 * Can be used To initialize the connection specific user Data
;	 * (mg_request_info->conn_data, mg_get_user_connection_data).
;	 * When the callback is called, it is Not yet known If a
;	 * valid HTTP(S) request will be made.
;	 * Parameters:
;	 *   conn: Not yet fully initialized connection object
;	 *   conn_data: output parameter, set To initialize the
;	 *              connection specific user Data
;	 * Return value:
;	 *   must be 0
;	 *   Otherwise, the result is undefined
;-================================================ 
;-ProcedureC.l cb_init_Connection(connection,*con_data); **con_data
ProcedureC.l cb_init_Connection(connection,*con_data); **con_data   
 
  ProcedureReturn 0  
EndProcedure

;-================================================ 
;-Helper functions 
 Procedure Pb_mg_start(*callbacks,*userdata,Options.s) 
    Protected arsize,ctx 
    ct = CountString(options,",") +1
    Dim ops(ct+1) 
    For a = 1 To ct 
       ops(a) = UTF8(StringField(Options,a,",")) 
       Debug StringField(Options,a,",")
    Next    
    ctx = mg_start(*callbacks,0,@ops(1));
    
    For a = 1 To ct 
      FreeMemory(ops(a)) 
    Next 
    
    ProcedureReturn ctx 
    
  EndProcedure 
   
Procedure SetFeature_Browser_Emulation() 
  Protected lpValueName.s,lpData.l,phkResult,lpsdata.s
  lpValueName.s = GetFilePart(ProgramFilename()) 
  Debug lpValueName
  lpData = 11001  
  If RegCreateKeyEx_(#HKEY_CURRENT_USER, "SOFTWARE\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_BROWSER_EMULATION", 0, #Null, #REG_OPTION_VOLATILE, #KEY_ALL_ACCESS, #Null, @phkResult, @lpdwDisposition) = #ERROR_SUCCESS
    RegSetValueEx_(phkResult, lpValueName, 0, #REG_DWORD, @lpData, SizeOf(LONG))
    RegCloseKey_(phkResult)
  EndIf
    
EndProcedure 

Procedure DelFeature_Browser_Emulation() 
  Protected phkResult,lpValueName.s  
  lpValueName.s = GetFilePart(ProgramFilename()) 
  If RegOpenKeyEx_(#HKEY_CURRENT_USER, "SOFTWARE\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_BROWSER_EMULATION", 0, #KEY_SET_VALUE, @phkResult) = #ERROR_SUCCESS
    RegDeleteValue_(phkResult, lpValueName)
    RegCloseKey_(phkResult)
  EndIf
EndProcedure 

;-================================================  
;-TEST TEST TEST 
  
CompilerIf #PB_Compiler_IsMainFile 
  
 Structure ws_client
	conn.i
	state.l 
 EndStructure 
 
 Global NewList ws_clients.ws_client()
 Global ShutDown,ctx   
  
 ProcedureC WebSocketConnectHandler(conn,*usrdata)
   Protected ctx,reject 
    ctx = mg_get_context(conn);
	  reject = 1;
	  mg_lock_context(ctx);
	    AddElement(ws_clients()) 
	    ws_clients()\conn = conn 
	    ws_clients()\state = 1 
	    mg_set_user_connection_data(ws_clients()\conn,@ws_clients()) 
	    reject=0
	  mg_unlock_context(ctx) 
	  Debug "websocket client connected on connection " + Str(conn) 
	  
	  ProcedureReturn reject    
	    
EndProcedure   
  
ProcedureC WebSocketReadyHandler(conn,*usrdata)

	*text = UTF8("Hello from the websocket ready handler");
	*client.ws_client = mg_get_user_connection_data(conn);
	 mg_websocket_write(conn, #MG_WEBSOCKET_OPCODE_TEXT,*text, MemorySize(*text));
	*client\state= 2;
	
EndProcedure 

ProcedureC WebsocketDataHandler(conn,bits.l,*Data,len.i,*cbdata)
  Protected out.s  
	*client.ws_client = mg_get_user_connection_data(conn);
	Debug "websocket data"
	If conn = *client\conn And *client\state >= 1
	
	out.s = "Websocket got " + Str(len) + " bytes of "
	Select bits ;) & $F)  
	Case #MG_WEBSOCKET_OPCODE_CONTINUATION:
		out +  "continuation";
		
	Case #MG_WEBSOCKET_OPCODE_TEXT:
		out + "text";
		
	Case #MG_WEBSOCKET_OPCODE_BINARY:
		out + "binary";
		
	Case #MG_WEBSOCKET_OPCODE_CONNECTION_CLOSE:
		out + "close";
		
	Case #MG_WEBSOCKET_OPCODE_PING:
		out +  "ping";
		
	Case #MG_WEBSOCKET_OPCODE_PONG:
		out + "pong" ;
		
	Default:
		out + "unknown opcode" 
		
	EndSelect 
	
	Debug out 
	ProcedureReturn 1;
	EndIf 
EndProcedure 

ProcedureC WebSocketCloseHandler(conn,*cbdata)
  Protected ctx,*client.ws_client 
	ctx = mg_get_context(conn);
	*client = mg_get_user_connection_data(conn);
	If (*client\conn = conn And *client\state >=1)
   mg_lock_context(ctx); 
     ChangeCurrentElement(ws_clients(),*client) 
     DeleteElement(ws_clients())
     Debug "Client socket droped from the set of websocket connections " + Str(conn);
  EndIf   
	mg_unlock_context(ctx);

EndProcedure 

Procedure InformWebsockets()
	Static cnt = 0;
	Protected *out
	Protected i;
  *out = UTF8(Str(cnt))
  cnt+1 
	mg_lock_context(ctx);
	ForEach ws_clients() 
		If ws_clients()\state = 2 
			mg_websocket_write(ws_clients()\conn,#MG_WEBSOCKET_OPCODE_TEXT,*out,MemorySize(*out))
		EndIf 
	Next 
	mg_unlock_context(ctx);
	FreeMemory(*out) 
	
EndProcedure 

ProcedureC WebSocketStartHandler(conn,*cbdata)
  Protected out.s,*out  
  
  
  out.s = "HTTP/1.1 200 OK" + #CRLF$ + "Content-Type: text/html" + #CRLF$ + "Connection: close" + #CRLF$ + #CRLF$; 
  out + "<!DOCTYPE html>" + #CRLF$ +  "<html>" + #LF$ + "<head>" + #LF$ + "<meta charset=" +Chr(34) + "UTF-8" + Chr(34) + ">" + #LF$
  out + "<title>Embedded websocket example</title>" + #LF$ 
  out + "<script>" + #LF$ 
  out +  "function load() {" + #LF$ 
  out +  "var wsproto = (location.protocol === 'https:') ? 'wss:' : 'ws:';" +#LF$ 
	out +  "connection = new WebSocket(wsproto + '//' + window.location.host + '/websocket');" + #LF$ 
	out +  "websock_text_field = document.getElementById('websock_text_field');" + #LF$
	out +  "connection.onmessage = function (e) {" + #LF$
	out +  "websock_text_field.innerHTML=e.data;" + #LF$ 
	out +  "}" + #LF$
	out +  "connection.onerror = function (error) {" + #LF$
	out +  "alert('WebSocket error');" + #LF$
	out +  "connection.close();" + #LF$
	out +  "}" + #LF$ 
	out +  "}" + #LF$ 
	out + "</script>" + #LF$ 
	out + "</head>" + #LF$ + " <body onload='load()'>" + #LF$ 
	out + "<div id='websock_text_field'>No websocket connection yet</div>" + #LF$;
  out + "</body>" + #LF$ + "</html>" + #CRLF$ 
  
  ;Debug out 
  
  *out = UTF8(out) 
  mg_lock_context(ctx)
  mg_write(conn,*out,MemorySize(*out)) 
  mg_unlock_context(ctx)
  FreeMemory(*out) 
	ProcedureReturn 200;
EndProcedure 
  
  ProcedureC.l Hello_handler(ctx,*ignored)
    Protected *header,*body,hlen,blen  
    
    *header = UTF8("HTTP/1.1 200 OK" + #CRLF$ + "Content-Type: text/html" + #CRLF$ +"Connection: close" + #CRLF$ + #CRLF$)
    hlen = MemorySize(*header)
    mg_write(ctx,*header,hlen);
    FreeMemory(*header)
    
    *body = UTF8("<html><body><h1>Hello world from PB Civetweb 123</h1></body></html>" +#CRLF$);  
    blen = MemorySize(*body)  
    mg_write(ctx,*body,blen) 
    FreeMemory(*body) 
    
    *body = UTF8("<p>To see a page from the GoodBye handler <a href=/GoodBye> click GoodBye</a></p>" +#CRLF$);  
    blen = MemorySize(*body)  
    mg_write(ctx,*body,blen) 
    FreeMemory(*body) 
    
    ProcedureReturn 200;
  EndProcedure 	
  
  ProcedureC.l GoodBye_Handler(ctx,*ignore) 
    Protected *header,*body,hlen,blen 
    
    *header = UTF8("HTTP/1.1 200 OK" + #CRLF$ + "Content-Type: text/html" + #CRLF$ +"Connection: close" + #CRLF$ + #CRLF$)
    hlen = MemorySize(*header)
    mg_write(ctx,*header,hlen);
    FreeMemory(*header)
    *body = UTF8("<html><body><h1>GoodBye from PB Civetweb</h1></body></html>" +#CRLF$); 
    blen = MemorySize(*body)  
    mg_write(ctx,*body,blen) 
    
    FreeMemory(*body) 
         
    ProcedureReturn 200 
    
  EndProcedure 
  
 
  ProcedureC.l Default_Handler(ctx,*ignore) 
    Debug "Default handler"
    Protected *req.mg_request_info 
    Protected uri.s 
    *req = mg_get_request_info(ctx)
    uri = PeekS(@*req\request_uri,-1,#PB_UTF8) 
    Debug uri
    ProcedureReturn 0 
  EndProcedure   
  
  Global port.s
   
  Procedure cbHelloButton()
    SetGadgetText(2,"http://127.0.0.1:" + port + "/hello")
  EndProcedure 
  
  Procedure cbWebSocket() 
    SetGadgetText(2,"http://127.0.0.1:" + port + "/websocket")
  EndProcedure  
   
  
    ;Initialize the library with features required 
  mg_init_library(#MG_FEATURE_SUPPORTS_WEBSOCKETS ); ;file index server of root dir  
  
  Global callbacks.mg_callbacks
  callbacks\init_context = @cb_init_context() 
  callbacks\log_message = @cb_log_message() 
  callbacks\begin_request = @cb_begin_request()
  callbacks\connection_close = @cb_connection_closed()
  callbacks\end_request = @cb_end_request()
  callbacks\exit_context = @cb_exit_context()
  callbacks\http_error = @cb_http_error() 
  callbacks\init_connection = @cb_init_Connection()
  callbacks\init_thread = @cb_init_Thread() 
  callbacks\log_Access = @cb_log_access() 
  
  port.s = "8080"
  dir.s = GetPathPart(ProgramFilename()) + "www"
  
  Debug dir 
  ;Start the server with the required options comma delimeted */
  ctx = Pb_mg_start(@callbacks,0,"document_root," + dir + "," + "listening_ports," + port + ",access_log_file,access.log,websocket_timeout_ms,10000") 
  
  If ctx          
    ;/* Add some handler */
    mg_set_request_handler(ctx,"/Hello", @hello_handler(), 0);
    mg_set_request_handler(ctx,"/GoodBye", @GoodBye_Handler(), 0);
       
    ;/* Add HTTP site To open a websocket connection */
	  mg_set_request_handler(ctx, "/websocket", @WebSocketStartHandler(), 0);
	  
	  mg_set_websocket_handler(ctx,"/websocket",@WebSocketConnectHandler(),@WebSocketReadyHandler(),@WebsocketDataHandler(),@WebSocketCloseHandler(),0);
	  
	  mg_set_request_handler(ctx,"/",@Default_handler(),0) 
	      
    Global *buff = AllocateMemory(4096)
    len = mg_get_system_info(*buff,4096)
    Debug "System Info" 
    Debug PeekS(*buff,-1,#PB_UTF8) 
    
    SetFeature_Browser_Emulation() 
   
   If OpenWindow(0,0,0,1024,600,"CivetWeb Embedded",#PB_Window_SystemMenu |#PB_Window_SizeGadget) 
          
     ButtonGadget(1,10,0,60,30,"Hello")
     BindGadgetEvent(1, @cbHelloButton())
     
     ButtonGadget(3,70,0,80,30,"WebSocket") 
     BindGadgetEvent(3,@cbWebSocket())
         
     
     WebGadget(2,0,30,1024,650,"http://127.0.0.1:" + port)
     
     AddWindowTimer(0,1,100) 
     BindEvent(#PB_Event_Timer,@InformWebsockets())
     
     Repeat
            
     Until WaitWindowEvent(30) = #PB_Event_CloseWindow
 
   EndIf
   
   DelFeature_Browser_Emulation() 
    
    mg_stop(ctx);
    mg_exit_library(); 
        
  Else 
    Debug "Cant start Civetweb " 
    End
  EndIf   
  
 
CompilerEndIf     


; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 233
; FirstLine = 220
; Folding = ------
; EnableThread
; EnableXP
; Executable = civetweb.exe
; CompileSourceDirectory
; Compiler = PureBasic 5.62 (Windows - x86)