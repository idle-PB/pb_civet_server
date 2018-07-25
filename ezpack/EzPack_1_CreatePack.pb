 ;-EzPack Test suite 
  ;Create a EzPack Object passing in the address of the call back functions 
  ;Build a source directory listing, you can call this function multiple times to add specific paths to your pack 
  ;Create the pack 
  ;Free the EzPack object 
    
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
  
 ;-Create a Pack
 
    pack.iEzPack = NewEzPack(@cbPackList(),@cbProgress())
    If pack 
       PrintN("EzPack Create pack") 
       PrintN("build recursive source file list of only .pb files")
       PrintN("add a specific file to the build source list") 
       sc = pack\BuildSourceFileList(#PB_Compiler_Home,"*.pb")
       sc = pack\BuildSourceFileList(#PB_Compiler_Home,"purebasic.help") 
       cc.q = pack\CreatePack(PackFile)
       pack\Free()  
       PrintN("EzPack: Create pack Added : "+ Str(sc) + " Files,  PackSize : " + Str(cc)) 
       PrintN("Press enter to end")
       Input() 
     EndIf   
     
 CloseConsole()
 
; IDE Options = PureBasic 5.20 beta 19 LTS (Linux - x64)
; ExecutableFormat = Console
; CursorPosition = 35
; FirstLine = 9
; Folding = -
; EnableUnicode
; EnableThread
; EnableXP