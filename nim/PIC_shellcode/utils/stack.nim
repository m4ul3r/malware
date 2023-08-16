proc allignStack*() {.asmNoStackFrame, inline, nosideeffect.} = 
  asm """
    # xor rax, rax
    pop rax
    and rsp, 0xfffffffffffffff0
    mov rbp, rsp
    sub rsp, 0x100    # allocate stack space, arbitrary size ... depends on payload
    push rax
    ret
  """