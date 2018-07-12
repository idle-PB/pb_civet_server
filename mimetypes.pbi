;some of the mime types built in to civetweb aren't correct 
;so rather than having to rebuild the lib if more types are needed 
;they can be easily added here;
;a full list of mimetypes can be found at iana.org 

Structure mimetype
  extension.s;
	ext_len.i
	mime_type.s
EndStructure 

Structure mimetypes 
  init.i
  count.i 
  types.mimetype[100] 
EndStructure 

Global mimetypes.mimetypes

Macro setmimetype(mext,mlen,mtype) 
  
  mimetypes\types[mimetypes\count]\extension = mext 
  mimetypes\types[mimetypes\count]\ext_len = mlen 
  mimetypes\types[mimetypes\count]\mime_type = mtype
  mimetypes\count+1  
  
EndMacro   

Procedure MimeTypes_Init() 
           
    setmimetype(".doc", 4, "application/msword")
    setmimetype(".eps", 4, "application/postscript")
    setmimetype(".exe", 4, "application/octet-stream")
    setmimetype(".json", 5, "application/json")
    setmimetype(".pdf", 4, "application/pdf")
    setmimetype(".ps", 3, "application/postscript")
    setmimetype(".rtf", 4, "application/rtf")
    setmimetype(".xhtml", 6, "application/xhtml+xml")
    setmimetype(".xsl", 4, "application/xml")
    setmimetype(".xslt", 5, "application/xml")
   
    setmimetype(".ttf", 4, "application/font-sfnt")
    setmimetype(".cff", 4, "application/font-sfnt")
    setmimetype(".otf", 4, "application/font-sfnt")
    setmimetype(".aat", 4, "application/font-sfnt")
    setmimetype(".sil", 4, "application/font-sfnt")
    setmimetype(".pfr", 4, "application/font-tdpfr")
    setmimetype(".woff", 5, "application/font-woff")
    setmimetype(".woff2",6, "application/font-woff2")
    setmimetype(".eot", 4, "application/vnd.ms-fontobject")
       
    
    setmimetype(".mp3", 4, "audio/mpeg")
    setmimetype(".oga", 4, "audio/ogg")
    setmimetype(".ogg", 4, "audio/ogg")
    setmimetype(".wav", 4, "audio/wav")
    
    setmimetype(".gif", 4, "image/gif")
    setmimetype(".ief", 4, "image/ief")
    setmimetype(".jpeg", 5, "image/jpeg")
    setmimetype(".jpg", 4, "image/jpeg")
    setmimetype(".jpm", 4, "image/jpm")
    setmimetype(".jpx", 4, "image/jpx")
    setmimetype(".png", 4, "image/png")
    setmimetype(".svg", 4, "image/svg+xml")
    setmimetype(".tif", 4, "image/tiff")
    setmimetype(".tiff", 5, "image/tiff")
    
    setmimetype(".wrl", 4, "model/vrml")
    
    setmimetype(".js", 3, "text/javascript")
    setmimetype(".css", 4, "text/css")
    setmimetype(".csv", 4, "text/csv")
    setmimetype(".htm", 4, "text/html")
    setmimetype(".html", 5, "text/html")
    setmimetype(".sgm", 4, "text/sgml")
    setmimetype(".shtm", 5, "text/html")
    setmimetype(".shtml", 6, "text/html")
    setmimetype(".txt", 4, "text/plain")
    setmimetype(".xml", 4, "text/xml")
    setmimetype(".sass",5 ,"text/x-sass") 
    setmimetype(".scss",5 ,"text/x-scss") 
        
    setmimetype(".mov", 4, "video/quicktime")
    setmimetype(".mp4", 4, "video/mp4")
    setmimetype(".mpeg", 5, "video/mpeg")
    setmimetype(".mpg", 4, "video/mpeg")
    setmimetype(".ogv", 4, "video/ogg")
    setmimetype(".qt", 3, "video/quicktime")
   
    setmimetype(".arj", 4, "application/x-arj-compressed")
    setmimetype(".gz", 3, "application/x-gunzip")
    setmimetype(".rar", 4, "application/x-arj-compressed")
    setmimetype(".swf", 4, "application/x-shockwave-flash")
    setmimetype(".tar", 4, "application/x-tar")
    setmimetype(".tgz", 4, "application/x-tar-gz")
    setmimetype(".torrent", 8, "application/x-bittorrent")
    setmimetype(".ppt", 4, "application/x-mspowerpoint")
    setmimetype(".xls", 4, "application/x-msexcel")
    setmimetype(".zip", 4, "application/x-zip-compressed")
    setmimetype(".aac", 4, "audio/aac") 
    setmimetype(".aif", 4, "audio/x-aif")
    setmimetype(".m3u", 4, "audio/x-mpegurl")
    setmimetype(".mid", 4, "audio/x-midi")
    setmimetype(".ra", 3, "audio/x-pn-realaudio")
    setmimetype(".ram", 4, "audio/x-pn-realaudio")
    setmimetype(".wav", 4, "audio/x-wav")
    setmimetype(".bmp", 4, "image/bmp")
    setmimetype(".ico", 4, "image/x-icon")
    setmimetype(".pct", 4, "image/x-pct")
    setmimetype(".pict", 5, "image/pict")
    setmimetype(".rgb", 4, "image/x-rgb")
    setmimetype(".webm", 5, "video/webm") 
    setmimetype(".asf", 4, "video/x-ms-asf")
    setmimetype(".avi", 4, "video/x-msvideo")
    setmimetype(".m4v", 4, "video/x-m4v")
    ProcedureReturn 1 
  EndProcedure 
 
Procedure.s MimeTypes_LookUP(uri.s) 
  Protected a,pos  
  
  Repeat  
    pos = FindString(uri,mimetypes\types[a]\extension,Len(uri)-mimetypes\types[a]\ext_len) 
    If pos > 0 
      ProcedureReturn mimetypes\types[a]\mime_type   
    EndIf 
    a+1
  Until a = mimetypes\count
  ProcedureReturn "application/octet-stream"  
EndProcedure   


; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 55
; FirstLine = 42
; Folding = -
; EnableXP
; Compiler = PureBasic 5.62 (Windows - x86)