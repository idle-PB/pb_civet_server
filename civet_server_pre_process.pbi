
IncludeFile "preprocess\FindData.pbi" 
IncludeFile "preprocess\cpuinfo.pbi" 

Prototype cbPreProcesor(*app) 

Prototype FindData(*Haystack, HaystackSize, *Needle, NeedleSize,pos=0, Count = #False)

Structure PreProcessor
  *tag 
  taglen.i
  *output 
  *find.FindData
EndStructure   

Procedure PreProcessInit(*pre.PreProcessor) 
  UseModule CPUInfo
  
  If IsCPU(#PB_CPU_SSE2)
    *pre\find = finddata::@SSE2_Find() 
  Else 
    *pre\find = FindData::@BM() 
  EndIf   
  UnuseModule CPUInfo 
EndProcedure 

Procedure New_PreProcessor() 
  Protected *pre.PreProcessor 
  *pre = AllocateMemory(SizeOf(PreProcessor)) 
  If *pre 
    *pre\tag = UTF8("<?PB")
    *pre\taglen = MemorySize(*pre\tag)-1 
    PreProcessInit(*pre)
    ProcedureReturn *pre 
  EndIf 
EndProcedure 

Procedure PreProcessor_free(*pre.PreProcessor) 
  FreeMemory(*pre\tag) 
  If *pre\output
    FreeMemory(*pre\output) 
  EndIf 
  FreeMemory(*pre) 
EndProcedure 

Procedure Preprocess(*pre.PreProcessor,*input,len,*userdata) 
  Protected pos,t_start,t_end,fnTag.s,p_start,p_end,outlen,outp,osz    
  Protected *cbr.cbPreProcesor,*dat,msz 
  outlen = len 
  *pre\output = AllocateMemory(outlen) 
  
  While (pos > -1 And pos < len) 
    pos = *pre\find(*input,len,*pre\tag,*pre\taglen,pos) 
    If pos <> -1 
      osz = outp+(pos-p_end)
      If osz > outlen 
        *pre\output = ReAllocateMemory(*pre\output,osz,#PB_Memory_NoClear)
        outlen = osz 
      EndIf   
      CopyMemory(*input+p_end,*pre\output+outp,pos-p_end)
      outp + (pos-p_end) 
      p_start = pos 
      pos + *pre\taglen 
      While PeekA(*input+pos) = 32 
        pos + 1
      Wend 
      t_start = pos 
      While (PeekA(*input+pos) <> 32 And PeekA(*input+pos) <> '/')
        pos + 1
      Wend 
      t_end = pos
      While PeekA(*input+pos) <> '>' 
        pos + 1
      Wend 
      p_end = pos+1 
      fnTag = PeekS(*input+t_start,t_end-t_start,#PB_UTF8)
      *cbr.cbPreProcesor = GetRuntimeInteger(fnTag) 
      If *cbr
        *dat = *cbr(*userdata) ;call backs to runtime procedures 
        If *dat 
          msz = MemorySize(*dat)-1
          osz = outp + msz 
          If osz > outlen 
            *pre\output = ReAllocateMemory(*pre\output,osz,#PB_Memory_NoClear)
            outlen = osz 
          EndIf   
          CopyMemory(*dat,*pre\output+outp,msz)
          outp + msz
          FreeMemory(*dat) 
        EndIf 
        pos+1 
      EndIf 
      
    EndIf  
  Wend   
  osz = outp+(len-p_end) 
  If osz > outlen 
    *pre\output = ReAllocateMemory(*pre\output,osz,#PB_Memory_NoClear)
    outlen = osz 
  EndIf   
  
  CopyMemory(*input+p_end,*pre\output+outp,len-p_end)
  
  ProcedureReturn *pre\output 
  
EndProcedure   

CompilerIf #PB_Compiler_IsMainFile 
  
  Runtime Procedure ElementsFillTable(*app) 
    Protected sout.s,sum.f,a  
    sout = "<div><H2>Output from ElementsFillTable() Callback</h2></div>"
    sout + "<div class='table-wrapper'><table><thead><tr><th>Name</th><th>Description</th><th>Price</th></tr></thead>" + #LF$
    sout + "<tbody>" + #LF$ 
    For a = 1 To 20 
      sout + "<tr><td>Item " + Str(a) + "</td><td>Ante turpis integer aliquet porttitor.</td><td>" + StrF(a* 2.99,2) + "</td></tr>" + #LF$
      sum + (a * 2.99)  
    Next 
    sout + "</tbody><tfoot><tr><td colspan='2'></td><td>$" + StrF(sum,2) + "</td></tr></tfoot></table></div>"
    ProcedureReturn UTF8(sout) 
    
  EndProcedure     
  
  Runtime Procedure aFooBar(*app)
    ProcedureReturn UTF8("<li>hello FooBar() " + Str(*app) + " </li>") 
  EndProcedure  
  
  Runtime Procedure BarFoo(*app)
    ProcedureReturn UTF8("<p>hello fffftttttttttfffff BarFoo()</p>") 
  EndProcedure   
  
  Runtime Procedure aFooFoo(*app)
    ProcedureReturn UTF8("<H1>hello FooFoo()</H1>") 
  EndProcedure   
  
  Procedure testPre(*app)
    Protected *buf,*out,*pre
    ;*buf = UTF8("some test <p>1 2 3</p> PB Foobar()/   ><p> more text 3 4 5 </p> <?PB BarFoo()/> <p> da da da 6 7 8 </p> FooFoo() />- <p> 9 10 11 </p>!!!") 
    If ReadFile(0,"www\elements.pbh")
      *buf = AllocateMemory(Lof(0)) 
      ReadData(0,*buf,Lof(0)) 
    EndIf   
    
    *pre = New_PreProcessor() 
    *out = PreProcess(*pre,*buf,MemorySize(*buf),*app) 
    Debug PeekS(*out,-1,#PB_UTF8)
    Debug PeekS(*out,MemorySize(*out),#PB_UTF8)
    PreProcessor_free(*pre) 
  EndProcedure    
  
  testpre(123456) 
CompilerEndIf 
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 143
; FirstLine = 6
; Folding = --
; EnableXP