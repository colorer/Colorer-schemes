#if defined(__GNUC__)
    asm("pushfl; \
        popl    %%eax; \
        movl    %%eax,%%ecx; \
        xorl    $0x0200000,%%eax; \
        pushl   %%eax; \
        popfl; \
        pushfl; \
        popl    %%eax; \
        xorl    %%ecx,%%eax; \
        movl    %%eax, %0;"
        :"=m"(temp)
        :
        :"%eax", "%ecx");
#endif
    if(temp == 0)
    {
        return;
    }

#if defined(_WIN32)
    // Save CPU feature flags
    _asm
    {
        push    ebx
        push    edx
        xor     eax, eax
        _emit   0fh
        _emit   0a2h
        cmp     eax, 1
        jb      detect_cpu1
        mov     eax, 1
        _emit   0fh
        _emit   0a2h
        mov     g_icdGlobal.CPU.dwCaps, edx
    detect_cpu1:
#endif
