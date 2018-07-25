DeclareModule CPUInfo
Enumeration 
  #PB_CPU_FPU   ;Onboard x87 FPU   
  #PB_CPU_VME   ;Virtual 8086 mode extensions (such As VIF, VIP, PIV)   
  #PB_CPU_DE     ;Debugging extensions (CR4 bit 3)   
  #PB_CPU_PSE   ;Page Size Extension   
  #PB_CPU_TSC   ;Time Stamp Counter   
  #PB_CPU_MSR   ;Model-specific registers
  #PB_CPU_PAE   ;Physical Address Extension
  #PB_CPU_MCE   ;Machine Check Exception
  #PB_CPU_CX8   ;CMPXCHG8 (compare-And-Swap) instruction   
  #PB_CPU_APIC   ;Onboard Advanced Programmable Interrupt Controller   
  #PB_CPU_res10   ;(reserved)   
  #PB_CPU_SEP   ;SYSENTER And SYSEXIT instructions
  #PB_CPU_MTRR   ;Memory Type Range Registers   
  #PB_CPU_PGE   ;Page Global Enable bit in CR4   
  #PB_CPU_MCA   ;Machine check architecture   
  #PB_CPU_CMOV   ;Conditional move And FCMOV instructions   
  #PB_CPU_PAT   ;Page Attribute Table   (reserved)
  #PB_CPU_PSE36 ;36-bit page size extension   
  #PB_CPU_PSN   ;Processor Serial Number   
  #PB_CPU_CLFSH   ;CLFLUSH instruction (SSE2)
  #PB_CPU_res20   ;(reserved)   
  #PB_CPU_DS   ;Debug store: save trace of executed jumps   
  #PB_CPU_ACPI   ;Onboard thermal control MSRs For ACPI   
  #PB_CPU_MMX   ;MMX instructions   
  #PB_CPU_FXSR   ;FXSAVE, FXRESTOR instructions, CR4 bit 9   
  #PB_CPU_SSE   ;SSE instructions (a.k.a. Katmai New Instructions)   
  #PB_CPU_SSE2   ;SSE2 instructions   
  #PB_CPU_SS   ;CPU cache supports self-snoop   
  #PB_CPU_HTT   ;Hyper-threading   
  #PB_CPU_TM   ;Thermal monitor automatically limits temperature
  #PB_CPU_IA64   ;IA64 processor emulating x86   
  #PB_CPU_PBE   ;Pending Break Enable (PBE#PB_CPU_ pin) wakeup support   
  ;ecx vals
  #PB_CPU_SSE3   ;Prescott New Instructions-SSE3 (PNI)
  #PB_CPU_PCMULQDQ   ;PCLMULQDQ support
  #PB_CPU_DTES64   ;64-bit Debug store (edx bit 21)
  #PB_CPU_MONITOR   ;MONITOR And MWAIT instructions (SSE3)
  #PB_CPU_DSCPL   ;CPL qualified Debug store
  #PB_CPU_VMX   ;Virtual Machine eXtensions
  #PB_CPU_SMX   ;Safer Mode Extensions (LaGrande)
  #PB_CPU_EST   ;Enhanced SpeedStep
  #PB_CPU_TM2   ;Thermal Monitor 2
  #PB_CPU_SSSE3   ;Supplemental SSE3 instructions
  #PB_CPU_CNXTID   ;L1 Context ID
  #PB_CPU_res11
  #PB_CPU_FMA   ;Fused multiply-add (FMA3)
  #PB_CPU_CX16   ;CMPXCHG16B instruction
  #PB_CPU_XTPR   ;Can disable sending task priority messages
  #PB_CPU_PDCM   ;Perfmon & Debug capability
  #PB_CPU_res16
  #PB_CPU_PCID   ;Process context identifiers (CR4 bit 17)
  #PB_CPU_DCA   ;Direct cache access For DMA writes[10][11]
  #PB_CPU_SSE41   ;SSE4.1 instructions
  #PB_CPU_SSE42   ;SSE4.2 instructions
  #PB_CPU_X2APIC   ;x2APIC support
  #PB_CPU_MOVBE   ;MOVBE instruction (big-endian)
  #PB_CPU_POPCNT   ;POPCNT instruction
  #PB_CPU_TSCDEADLINE   ;APIC supports one-shot operation using a TSC deadline value
  #PB_CPU_AES   ;AES instruction set
  #PB_CPU_XSAVE   ;XSAVE, XRESTOR, XSETBV, XGETBV
  #PB_CPU_OSXSAVE   ;XSAVE enabled by OS
  #PB_CPU_AVX   ;Advanced Vector Extensions
  #PB_CPU_F16C   ;F16C (half-precision) FP support
  #PB_CPU_RDRND   ;RDRAND (on-chip random number generator) support
  #PB_CPU_HYPERVISOR   ;Running on a hypervisor (always 0 on a real CPU, but also With some hypervisors)
EndEnumeration 

Declare.s GetVendor()
Declare.s GetName() 
Declare.s GetVendorVM()
Declare   IsCPU(op) 
Declare   CountCores()
Declare   GetActiveCore()
Declare   GetFrequency()  
EndDeclareModule 

Module CPUInfo 

 Procedure.s GetVendor()
  Protected a.l,b.l,c.l
  !mov eax,0
  !cpuid 
  !mov [p.v_a],ebx
  !mov [p.v_b],edx 
  !mov [p.v_c],ecx 
  ProcedureReturn PeekS(@a,4,#PB_Ascii) + PeekS(@b,4,#PB_Ascii) + PeekS(@c,4,#PB_Ascii)
EndProcedure   

Procedure.s GetVendorVM()
  Protected a.l,b.l,c.l
  !mov eax,$40000000
  !cpuid 
  !mov [p.v_a],ebx
  !mov [p.v_b],edx 
  !mov [p.v_c],ecx 
  ProcedureReturn PeekS(@a,4,#PB_Ascii) + PeekS(@b,4,#PB_Ascii) + PeekS(@c,4,#PB_Ascii)
EndProcedure   

 Procedure IsCPU(op)
    !mov eax, 1
    !cpuid
    !xchg eax, ecx
    !mov ecx, [p.v_op]
    !shr edx, cl
    !shr eax, cl
    !sub ecx, 32
    !shr ecx, 31
    !and edx, ecx
    !xor ecx, 1
    !and eax, ecx
    !or eax, edx
    ProcedureReturn   
  EndProcedure

Procedure.s GetName()
  ProcedureReturn CPUName()
EndProcedure 

Procedure CountCores()
  ProcedureReturn CountCPUs(#PB_System_ProcessCPUs)
EndProcedure 

Procedure.i GetActiveCore()
  ! xor ebx, ebx
  ! mov eax, 0x1
  ! cpuid
  ! mov eax,ebx 
  ! shr eax,24
  ProcedureReturn  
EndProcedure

Procedure GetFrequency() 
  EnableASM 
  Protected a.l,b.l,t1.l,t2.l,result 
  Repeat     
  ! xor ebx, ebx
  ! mov eax, 0x1
  ! cpuid
  ! shr ebx, 24
  mov a, ebx
  ! rdtsc 
  mov t1, eax 
  Delay(100) 
  ! xor ebx, ebx
  ! mov eax, 0x1
  ! cpuid
  ! shr ebx, 24
  mov b,ebx 
  ! rdtsc 
  mov t2, eax 
  If a = b  
    result = ((t2-t1) / (100000))  
    result = ((result+5) / 5) * 5  
    If t2 - t1 > 0 
      Break  
    EndIf   
  EndIf    
  ForEver 
  ProcedureReturn result 
  DisableASM
EndProcedure   

EndModule 

;Test code 
CompilerIf #PB_Compiler_IsMainFile 
  
  Prototype.s MyFunction()                
  Global MyFunction.MyFunction 
  
  Procedure.s _MyFunction()
    ProcedureReturn "fall back mode"
  EndProcedure   
  
  Procedure.s _MyFunction_SSE2()
    ProcedureReturn "SSE2 mode" 
  EndProcedure 
  
  Procedure InitDynamic() 
    UseModule CPUInfo
    If IsCPU(#PB_CPU_SSE2)
      MyFunction = @_MyFunction_SSE2()
    Else 
      MyFunction =@_MyFunction() 
    EndIf   
    UnuseModule CPUInfo 
  EndProcedure 
    
  Debug CPUInfo::GetVendor() 
  Debug CPUInfo::GetName()
  Debug Str(CPUInfo::CountCores()) + " cores"
  Debug "Running on core number " + Str(CPUInfo::GetActiveCore()) 
  Debug "Running at " + Str(CPUInfo::GetFrequency()) +  " mhz" 
  
  InitDynamic()
  Debug MyFunction() 
  
CompilerEndIf 
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 178
; FirstLine = 164
; Folding = ---
; EnableXP
; EnableUnicode