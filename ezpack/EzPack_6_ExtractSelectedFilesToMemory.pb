 ;-Extracting Selected Files to Memory
 
 ;Create a EzPack Object passing in the address of the call back functions 
  ;Open a pack 
  ;Select a file by name from the pack to mark for extraction 
  ;Select a file by index in the pack to mark for extraction
  ;Unpack the slected files to memory by Setting the UnPackAll Flag to #False and the UnPackToMemory to #True 
  ;Open a file by name 
  ;Catch the File 
  ;Print it 
  ;Close the file  
  ;Open a file by Index 
  ;Catch it 
  ;Print it 
  ;Close it 
  ;Free the EzPack Object 
      
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
 Define sc,lc,cc.q,ec.q,output.s,filenum.i,packfile.s,packpath.s
  
  packpath = GetCurrentDirectory() 
  packfile = packpath + "tpak.ezp"
  
  OpenConsole() 
  
       pack.iEzPack = NewEzPack(@cbPackList(),@cbProgress())
       If pack 
          PrintN("EzPack: Extract selected files to memory")
          lc = pack\OpenPackFromDisk(PackFile)
          pack\SelectExtractFile("/purebasic/examples/3d/Demos/Tank.pb") 
          pack\SelectExtractFileIndex(8)
          ec = pack\UnpackSelectedToMemory()  
          filenum = pack\OpenFile("/purebasic/examples/3d/Demos/Tank.pb") 
          If filenum 
            output.s = PeekS(pack\CatchFile(filenum),pack\GetFileSize(filenum)) 
            PrintN(" ")
            Print(output) 
            PrintN(" ")
            pack\CloseFile(filenum) 
            PrintN("Press Enter to continue")
            Input() 
          EndIf 
                  
          filenum = pack\OpenFileIndexed(8) 
          If filenum
            output.s = PeekS(pack\CatchFile(filenum),pack\GetFileSize(filenum)) 
            PrintN(" ")
            Print(output) 
            PrintN(" ")
            pack\CloseFile(filenum) 
          EndIf   
          Pack\Free() 
          PrintN(" Number of Files in Pack : " + Str(lc) + " Extracted  : " + Str(ec) + " Files") 
          PrintN("Press Enter to end")
          Input() 
       EndIf 
       
    CloseConsole()   
    
; IDE Options = PureBasic 5.10 Beta 2 (Linux - x64)
; ExecutableFormat = Console
; CursorPosition = 47
; FirstLine = 35
; Folding = -
; EnableXP
; DisableDebugger