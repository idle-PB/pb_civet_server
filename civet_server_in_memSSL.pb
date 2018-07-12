IncludeFile "civetserver.pbi"

Global app.Civet_Server  

Procedure Resize()
  ResizeGadget(2,0,0,WindowWidth(0),WindowHeight(0)) 
EndProcedure 

Procedure cbPost(ctx,*request.Civet_Server_Request) ;callbacks are threaded only use locally scoped resources  
  
  Debug "cbpost request type " +  *request\RequestType 
  Debug *request\Uri 
  
  ForEach *request\mquery()
    Debug *request\mquery()\name + " " + *request\mquery()\value 
  Next
  
  *request\Uri = "/elements.html"  ;redirect 
  
  ProcedureReturn 0 ;to continue processing or 200  
  
EndProcedure  

Procedure cbGet(ctx,*request.Civet_Server_Request)
  
  Debug "cbGet request type " +  *request\RequestType 
  Debug *request\Uri 
  Debug GetFilePart(*request\Uri)
  
  ForEach *request\mquery()
    Debug MapKey(*request\mQuery()) + " " + *request\mquery()\name + " " + *request\mquery()\value 
  Next 
  
  If *request\mQuery("play")\value = "Waponez" 
    RunProgram("Http://127.0.0.1:8080/Waponez.html")
    Civet_Server_Send_Response(ctx,"",0,0,"204 No Content") 
    ProcedureReturn 204
  EndIf     
  
  ProcedureReturn 0
EndProcedure   



app\packAddress =?Index  ;address for ezp pack archive of website in datasection. if unset will load from files. 
app\packsize = ?EndIndex - ?Index ;size of the pack to read in  
app\dirRelitive = "www"           ;required     

app\cbpost = @cbpost()   ;set a call back to process the post tokens 
app\cbget = @cbGet()     ;set a call back to process query strings from a get request 

Debug GetPathPart(ProgramFilename()) + app\dirRelitive

app\Server_Settings\document_root = GetPathPart(ProgramFilename()) + app\dirRelitive ;set a root to be safe
app\Server_Settings\listening_ports = "8080,443s"
app\Server_Settings\error_log_file = GetPathPart(ProgramFilename()) + "error.log"    ;set logs 
app\Server_Settings\access_log_file = GetPathPart(ProgramFilename()) + "access.log"  ;set logs 
app\Server_Settings\static_file_max_age = "0" ;nothing should be cached when debugging                     
app\Server_Settings\ssl_certificate = GetPathPart(ProgramFilename()) + "ssl_cert.pem" 
app\Server_Settings\enable_keep_alive = "yes" 

;app\Server_CallBacks\begin_request = @cb_begin_request() ;these callbacks are usefull for debug info 
;app\Server_CallBacks\end_request = @cb_end_request()     ;or if you want to overide civetweb, declared in civetweb.pbi 
;app\Server_CallBacks\connection_close = @cb_connection_closed() 
;app\Server_CallBacks\log_Access = @cb_log_access() 
;app\Server_CallBacks\log_message = @cb_log_message() 
;app\Server_CallBacks\http_error = @cb_http_error() 
;app\Server_CallBacks\init_connection = @cb_init_Connection() 
;app\Server_CallBacks\init_context = @cb_init_Context() 
;app\Server_CallBacks\exit_context = @cb_exit_context() 

;This can be used to pack your website to ezp so you can include it in the datasection
;it will be named as the folder of the app\dirRelitive setting with an extension of .ezp eg: www.ezp 
;Civet_Server_Create_Pack(app)

If Civet_Server_Start(app) 
  If OpenWindow(0,0,0,1024,600,"PB_Civet_Server_in_memSSL example of in memory embedded PB_Civet_Server " + app\Server_Settings\listening_ports,#PB_Window_SystemMenu |#PB_Window_SizeGadget |#PB_Window_MaximizeGadget) 
    WebGadget(2,0,0,1024,600,"https://127.0.0.1:443")
    BindEvent(#PB_Event_SizeWindow,@Resize()) 
    Repeat
    Until WaitWindowEvent(30) = #PB_Event_CloseWindow
  EndIf
  Civet_Server_Stop(app) 
Else 
  MessageRequester(GetFilePart(ProgramFilename()),"Cant start Server") 
  End
EndIf   

DataSection 
  Index:
  IncludeBinary "www.ezp"
  EndIndex:
EndDataSection 
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 66
; FirstLine = 58
; Folding = -
; EnableThread
; EnableXP
; Executable = civet_server_in_memSSL.exe
; CommandLine = _WIN32_IE=$0600
; CompileSourceDirectory
; Compiler = PureBasic 5.62 (Windows - x86)