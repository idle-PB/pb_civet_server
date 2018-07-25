;Threaded example needs to be compiled with thread safe option 


IncludeFile "EzPack.pbi"

Global  pack.iEzPack  
Global  Window_0.i,ListView_0, ProgressBar_0, Button_Add,Button_Pack,Button_Clear,Text_Processed,String_FilePattern,Text_FilePattern
Global  Checkbox_Recursive,Checkbox_Selected ,event

   Procedure UpdateList(index,file.s) 
       AddGadgetItem(ListView_0,index,file)
    EndProcedure    
  
  Procedure UpdateProgress(progress.f,position.q) 
     Protected processed.s 
     processed = pack\GetProcessed() 
     SetGadgetState(ProgressBar_0,progress) 
     SetGadgetText(Text_Processed,processed )
    
 EndProcedure 
 
 Procedure BuildFileList() 
    Protected dir.s,pattern.s,recursive   
    pattern = GetGadgetText(String_FilePattern)
    recursive = GetGadgetState(Checkbox_Recursive)
    If  pattern = "" 
       pattern = "*.*" 
    EndIf 
    dir.s = PathRequester("Please choose a directory to add",GetCurrentDirectory())
    pack\BuildSourceFileList(dir,pattern,7,recursive,#True)
  EndProcedure  
  
  Procedure.q Pack() 
     Protected file.s,a
     file.s  = SaveFileRequester("Choose a pack save name","","*.ezp",1) 
     If file <> "" 
        If GetGadgetState(Checkbox_Selected) = 0
       
          pack\CreatePack(file,0) 
        Else 
           For a = 0 To CountGadgetItems(ListView_0)
               If GetGadgetItemState(ListView_0,a) = 1 
                 Pack\SelectCompressFile(a) 
               EndIf    
           Next 
           pack\CreatePackSelected(file,1) 
        EndIf 
     EndIf    
     
  EndProcedure   
  
  Procedure Clear()
      pack\Reset()
      ClearGadgetItems(ListView_0) 
   EndProcedure    
   
   Procedure ProcessEvents(event)
      Protected evt 
      evt = EventType()   
      Select event
          Case #PB_Event_Gadget
            Select EventGadget()
                Case Button_Add 
                  If evt = #PB_EventType_LeftClick
                     BuildFileList()
                  EndIf    
               Case Button_Pack
                   If evt = #PB_EventType_LeftClick
                      Pack()
                   EndIf    
               Case Button_Clear 
                   If evt = #PB_EventType_LeftClick
                      Clear()
                   EndIf    
               EndSelect
        EndSelect
  EndProcedure 
      
  Window_0 = OpenWindow(#PB_Any, 0, 0, 890, 420, "EzPack", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
  pack.iEzPack = NewEzPack(@UpdateList(),@UpdateProgress())
  
  If pack 
    
  ListView_0 = ListViewGadget(#PB_Any, 10, 10, 870, 260, #PB_ListView_MultiSelect | #PB_ListView_ClickSelect)
  ProgressBar_0 = ProgressBarGadget(#PB_Any, 10, 380, 240, 30, 0,100)
  Button_Add = ButtonGadget(#PB_Any, 10, 320, 110, 30, "Add")
  Button_Pack = ButtonGadget(#PB_Any, 130, 320, 120, 30, "Pack")
  Text_Processed = TextGadget(#PB_Any, 260, 380, 90, 30, "")
  String_FilePattern = StringGadget(#PB_Any, 130, 280, 250, 30, "*.*")
  Text_FilePattern = TextGadget(#PB_Any, 10, 280, 110, 30, "FilePattern")
  Checkbox_Selected = CheckBoxGadget(#PB_Any, 10, 350, 100, 30, "selected files")
  Checkbox_Recursive = CheckBoxGadget(#PB_Any, 130, 350, 100, 30, "recursive")
  SetGadgetState(Checkbox_Recursive,1)
  Button_Clear = ButtonGadget(#PB_Any, 270, 320, 110, 30, "Clear")

   Repeat 
     event = WaitWindowEvent(30) 
     ProcessEvents(event)
    Until event = #PB_Event_CloseWindow 
    
    pack\Free()
  
 EndIf   
     
 
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 45
; FirstLine = 27
; Folding = --
; EnableThread
; EnableXP
; Compiler = PureBasic 5.62 (Windows - x86)
; EnableUnicode