;-Open a File on Demand 

 ;Create a EzPack Object passing in the address of the call back functions 
 ;Open a pack 
 ;Open a file by name it will extract it on demand 
 ;Catch the file 
 ;print it 
 ;close the file 

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
 packfile = packpath + "www.ezp"
  
  OpenConsole() 
           
       pack.iEzPack = NewEzPack(@cbPackList(),@cbProgress())
       If pack 
          PrintN("EzPack Open File On Demand")
          lc = pack\OpenPackFromDisk(PackFile)
          pack\
          
          filenum = pack\OpenFile("/purebasic/examples/3d/Demos/Tank.pb") 
          If filenum
            output.s = PeekS(pack\CatchFile(filenum),pack\GetFileSize(filenum)) 
            Print(output)
            PrintN(" ") 
            pack\CloseFile(filenum) 
          EndIf   
          PrintN("Press Enter to continue")
          Input() 
          
          filenum = pack\OpenFileIndexed(10) 
          If filenum
            output.s = PeekS(pack\CatchFile(filenum),pack\GetFileSize(filenum)) 
            PrintN(" ")
            Print(output)
            PrintN(" ") 
            pack\CloseFile(filenum)
         EndIf 
         pack\Free()
         PrintN("Press Enter to end")
         Input() 
       EndIf    
       
    CloseConsole() 
       
; IDE Options = PureBasic 5.62 (Windows - x64)
; ExecutableFormat = Console
; CursorPosition = 33
; Folding = -
; EnableXP
; DisableDebugger