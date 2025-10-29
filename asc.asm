.model small
.stack 100h
.data
.code
main proc
    mov ax, @data
    mov ds, ax
    
    mov bl, 'a'        ; 从字母'a'开始
    mov cx, 26         ; 总共26个字母
    mov dh, 0          ; 当前行字符计数
    
print_loop:
    ; 打印当前字符
    mov dl, bl
    mov ah, 02h
    int 21h
    
    ; 打印空格
    mov dl, ' '
    mov ah, 02h
    int 21h
    
    ; 移动到下一个字符
    inc bl
    inc dh             ; 增加行计数
    
    ; 检查是否需要换行
    cmp dh, 13
    jl no_newline      ; 如果小于13，继续
    
    ; 打印换行
    mov dl, 0Dh        ; 回车
    mov ah, 02h
    int 21h
    mov dl, 0Ah        ; 换行
    mov ah, 02h
    int 21h
    mov dh, 0          ; 重置行计数
    
no_newline:
    loop print_loop    ; 递减CX并循环
    
    ; 如果最后一行有内容但不满，需要换行
    cmp dh, 0
    je exit
    mov dl, 0Dh        ; 回车
    mov ah, 02h
    int 21h
    mov dl, 0Ah        ; 换行
    mov ah, 02h
    int 21h
    
exit:
    mov ah, 4Ch        ; 退出程序
    int 21h
main endp
end main