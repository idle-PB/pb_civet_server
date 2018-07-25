 ;-Extract a pack to Disk
  ;Create a EzPack Object passing in the address of the call back functions 
  ;Open a pack from disk 
  ;UnPack All Files in the pack to disk by setting the UnpackAll Flag to true
  ;Free the EzPack Object 
    
  ;#################################################### 
  IncludeFile "EzPack.pbi"
  
 ;callback procedures for file listing or gui lisitng  
  Procedure cbPackList(index,file.s) 
     PrintN(Str(index) + " " + file) 
  EndProcedure    
  
  ;callback for progress percent and progress in bytes 
  Procedure cbProgress(progress.f,position.q) 
     PrintN(StrF(progress,0) + "% : processed " + Str(position) + " bytes") 
  EndProcedure 
     
  Define pack.iEzPack  
  Define sc,lc,cc.q,ec.q,output.s,filenum.i,packfile.s,packpath.s
  
  packpath = GetCurrentDirectory() 
  packfile = packpath + "tpak.ezp"
  
  OpenConsole() 
 
    pack.iEzPack = NewEzPack(@cbPackList(),@cbProgress())
    If pack 
       PrintN("EzPack: Extract pack to disk") 
       lc = pack\OpenPackFromDisk(PackFile)
       ec= pack\UnPackAllToDisk(PackPath) 
       pack\Free() 
       PrintN("Number of Files in Pack : " + Str(lc) + " Extracted  : " + Str(ec) + " Files")  
       PrintN("Press Enter to end")
       Input() 
    EndIf 
    
  CloseConsole()   
 
    
    
  
; IDE Options = PureBasic 5.10 Beta 2 (Linux - x64)
; ExecutableFormat = Console
; CursorPosition = 25
; FirstLine = 6
; Folding = -
; EnableXP
; DisableDebugger