IncludeFile "EzPack.pbi"

Global  pack.iEzPack  
Global  Window_0.i,ListView_0, ProgressBar_0, Button_Open,Button_UnPack,Button_Clear,Text_Processed,String_FilePattern,Text_FilePattern
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
 
 Procedure OpenEzPack() 
    
    Protected file.s    
    file = OpenFileRequester("Open pack",GetCurrentDirectory() + "*.ezp","*.ezp",1)
    If file <> "" 
       ProcedureReturn pack\OpenPackFromDisk(file,#True) 
    EndIf    
    
 EndProcedure  
  
  Procedure UnPack() 
     Protected  dir.s,a
     dir  = PathRequester("Choose extraction path",GetCurrentDirectory()) 
     If dir  <> "" 
        If GetGadgetState(Checkbox_Selected) = 0
           pack\UnPackAllToDisk(dir,#True) 
        Else 
           For a = 0 To CountGadgetItems(ListView_0)
               If GetGadgetItemState(ListView_0,a) = 1 
                 Pack\SelectExtractFileIndex(a) 
               EndIf    
           Next 
           pack\UnPackSelectedToDisk(dir,#True) 
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
                Case Button_Open 
                  If evt = #PB_EventType_LeftClick
                     OpenEzPack()
                  EndIf    
               Case Button_UnPack
                   If evt = #PB_EventType_LeftClick
                      UnPack()
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
  Button_Open = ButtonGadget(#PB_Any, 10, 320, 110, 30, "Open")
  Button_UnPack = ButtonGadget(#PB_Any, 130, 320, 120, 30, "UnPack")
  Text_Processed = TextGadget(#PB_Any, 260, 380, 90, 30, "")
  Checkbox_Selected = CheckBoxGadget(#PB_Any, 10, 350, 100, 30, "selected files")
  Button_Clear = ButtonGadget(#PB_Any, 270, 320, 110, 30, "Clear")

   Repeat 
     event = WaitWindowEvent(30) 
     ProcessEvents(event)
    Until event = #PB_Event_CloseWindow 
    
    pack\Free()
  
 EndIf   
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 67
; FirstLine = 61
; Folding = --
; EnableThread
; EnableXP
; DisableDebugger