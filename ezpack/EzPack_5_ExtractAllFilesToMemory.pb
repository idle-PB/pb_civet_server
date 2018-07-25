;-Extracting All Files From Memory to Memory 

;Create a EzPack Object passing in the address of the call back functions 
;Open a pack from memory
;UnPack All Files to Memory by setting the UnpackAll Flag to true and the UnPackToMemory to True 
;Open a File from the Pack by Name
;Catch the memory 
;Print the Output       
;Close the File , it will free the memory 
;Free the EzPack object 

 ;Note you can use the Select and unpack maethods or use OpenFile to do it on demand   

;#####################################################

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
 Define sc,lc,cc.q,ec.q,output.s,filenum.i
  
  
  OpenConsole() 
        
       pack.iEzPack = NewEzPack(@cbPackList(),@cbProgress())
       If pack 
           PrintN("EzPack: Extract all files to memory")
           lc = pack\OpenPackFromMemory(?tpak,?tpake-?tpak)
           ec = pack\UnPackAllToMemory() 
          filenum = pack\OpenFile("/purebasic/Examples/3D/Demos/Tank.pb")  
          If filenum
            output.s = PeekS(pack\CatchFile(filenum),pack\GetFileSize(filenum)) 
            PrintN(" ")
            Print(output) 
            PrintN(" ")
            pack\CloseFile(filenum) 
          EndIf   
          pack\Free() 
          PrintN("Number of Files in Pack : "+ Str(lc) + " Extracted  : " + Str(ec) + " Files")  
          PrintN("Press Enter to end")
          Input() 
       EndIf 
       
    CloseConsole() 
    
     DataSection 
        tpak:
        IncludeBinary "tpak.ezp"  
        tpake: 
    EndDataSection    
     
; IDE Options = PureBasic 5.10 Beta 2 (Linux - x64)
; ExecutableFormat = Console
; CursorPosition = 38
; FirstLine = 18
; Folding = -
; EnableXP
; DisableDebugger