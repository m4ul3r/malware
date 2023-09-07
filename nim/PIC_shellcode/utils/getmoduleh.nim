import winim 

import memcmp, hash

{.passC:"-masm=intel".}
template doWhile(a, b: untyped): untyped =
  b
  while a:
    b

proc getModuleHandle*(lpModuleName: cstring): HMODULE {.inline.} =
  var  
    pPeb: PPEB
  asm """
    mov rax, qword ptr gs:[0x60]
    :"=r"(`pPeb`)
  """
  let
    pLdr: PPEB_LDR_DATA = pPeb.Ldr
    pListHead: LIST_ENTRY = pPeb.Ldr.InMemoryOrderModuleList
  var
    pDte: PLDR_DATA_TABLE_ENTRY = cast[PLDR_DATA_TABLE_ENTRY](pLdr.InMemoryOrderModuleList.Flink)
    pListNode: PLIST_ENTRY = pListHead.Flink
  doWhile cast[int](pListNode) != cast[int](pListHead):
    if pDte.FullDllName.Length != 0:
      if memcmp(cast[uint](lpModuleName), cast[uint](pDte.FullDllName.Buffer), lpModuleName.len, 2) == 0:
        return cast[HMODULE](pDte.Reserved2[0])
    pDte = cast[PLDR_DATA_TABLE_ENTRY](pListNode.Flink)
    pListNode = cast[PLIST_ENTRY](pListNode.Flink)
  return cast[HMODULE](0)

proc locateKernel32*(): HMODULE {.inline.}=
  ## Pure Assembly to locate kernel32.dll on 64-bit windows machines
  ## 
  ## .. code-block:: nim
  ##   var hKernel32 = locateKernel32()
  var hKernel32: HMODULE
  asm """
    #locate_kernel32:
      mov rax, gs:[0x60]           # 0x060 ProcessEnvironmentBlock to RAX.
      mov rax, [rax + 0x18]        # 0x18  ProcessEnvironmentBlock.Ldr Offset
      mov rsi, [rax + 0x20]        # 0x20 Offset = ProcessEnvironmentBlock.Ldr.InMemoryOrderModuleList
      lodsq                        # Load qword at address (R)SI into RAX (ProcessEnvironmentBlock.Ldr.InMemoryOrderModuleList)
      xchg rax, rsi                # Swap RAX,RSI
      lodsq                        # Load qword at address (R)SI into RAX
      mov %0, [rax + 0x20]         # RBX = Kernel32 base address
    :"=r"(`hKernel32`)
    :
    : "rax"
  """
  return hKernel32