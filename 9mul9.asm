data segment
    table db 7,2,3,4,5,6,7,8,9      ; 第1行 (有错误: 1×1=1, 但这里是7)
          db 2,4,7,8,10,12,14,16,18 ; 第2行 (有错误: 2×3=6, 但这里是7)
          db 3,6,9,12,15,18,21,24,27 ; 第3行 (正确)
          db 4,8,12,16,7,24,28,32,36 ; 第4行 (有错误: 4×5=20, 但这里是7)
          db 5,10,15,20,25,30,35,40,45 ; 第5行 (正确)
          db 6,12,18,24,30,7,42,48,54 ; 第6行 (有错误: 6×6=36, 但这里是7)
          db 7,14,21,28,35,42,49,56,63 ; 第7行 (正确)
          db 8,16,24,32,40,48,56,7,72  ; 第8行 (有错误: 8×8=64, 但这里是7)
          db 9,18,27,36,45,54,63,72,81 ; 第9行 (正确)
    
    msg_x_y db 'x y', 0Dh, 0Ah, '$'  ; 输出标题
    newline db 0Dh, 0Ah, '$'          ; 换行
    space db ' $'                     ; 空格
    error_msg db ' error$'            ; 新增：错误信息
data ends

code segment
    assume cs:code, ds:data

start:
    mov ax, data
    mov ds, ax
    
    ; 输出标题 "x y"
    mov dx, offset msg_x_y
    mov ah, 09h
    int 21h
    
    ; 初始化循环计数器
    mov cx, 0          ; 外层循环计数器 (行号0-8)
    
outer_loop:
    mov dx, 0          ; 内层循环计数器 (列号0-8)
    
inner_loop:
    ; 保存寄存器
    push cx
    push dx
    
    ; 调用检查过程
    call check_cell
    
    ; 恢复寄存器
    pop dx
    pop cx
    
    ; 内层循环控制
    inc dx
    cmp dx, 9
    jl inner_loop
    
    ; 外层循环控制
    inc cx
    cmp cx, 9
    jl outer_loop
    
    ; 程序结束
    mov ah, 4Ch
    int 21h

; 检查单个单元格的过程
; 输入: CX=行号(0-8), DX=列号(0-8)
check_cell proc near
    push ax
    push bx
    push cx
    push dx
    push si
    
    ; 计算表格中的位置: offset = 行号×9 + 列号
    mov ax, cx
    mov bl, 9
    mul bl
    add ax, dx
    mov si, ax
    
    ; 从表格中读取实际值
    mov bl, table[si]
    
    ; 计算期望值: (行号+1) × (列号+1)
    mov al, cl
    inc al          ; 行号+1 (1-9)
    mov ah, dl
    inc ah          ; 列号+1 (1-9)
    mul ah          ; AL = AL × AH
    
    ; 比较实际值和期望值
    cmp al, bl
    je check_done   ; 如果相等，跳过输出
    
    ; 输出错误位置 (行号+1 列号+1) 和 "error"
    call print_position_with_error
    
check_done:
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
check_cell endp

; 输出错误位置的过程 (带error字样)
; 输入: CX=行号, DX=列号
print_position_with_error proc near
    push ax
    push bx
    push dx
    
    ; 保存列号到BX，因为DX会被字符串输出破坏
    mov bx, dx
    
    ; 输出行号 (数字1-9)
    mov al, cl
    add al, '1'      ; 转换为ASCII数字
    mov dl, al
    mov ah, 02h
    int 21h
    
    ; 输出空格
    mov dx, offset space
    mov ah, 09h
    int 21h
    
    ; 输出列号 (数字1-9)
    mov al, bl       ; 从BX恢复列号
    add al, '1'      ; 转换为ASCII数字
    mov dl, al
    mov ah, 02h
    int 21h
    
    ; 输出" error"
    mov dx, offset error_msg
    mov ah, 09h
    int 21h
    
    ; 输出换行
    mov dx, offset newline
    mov ah, 09h
    int 21h
    
    pop dx
    pop bx
    pop ax
    ret
print_position_with_error endp

code ends
end start