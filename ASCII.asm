; 使用条件跳转指令实现ASCII表小写字母打印
.MODEL SMALL
.STACK 100H
.DATA
.CODE
MAIN PROC
    MOV AH, 02H      ; DOS功能号：显示字符
    MOV DL, 'a'      ; 从字母'a'开始
    MOV CX, 26       ; 总共26个小写字母
    MOV BL, 13       ; 每行13个字符计数器

PRINT_LOOP:
    ; 打印当前字符
    INT 21H
    
    ; 打印空格分隔符
    PUSH DX          ; 保存当前字符
    MOV DL, ' '      ; 空格字符
    INT 21H
    POP DX           ; 恢复当前字符
    
    INC DL           ; 指向下一个字符
    DEC CX           ; 总计数器减1
    DEC BL           ; 行计数器减1
    
    ; 检查是否需要换行（BL是否为0）
    CMP BL, 0
    JNE CHECK_END    ; 如果不需要换行，检查是否结束
    
    ; 需要换行的情况
    CALL NEW_LINE    ; 调用换行子程序
    MOV BL, 13       ; 重置行计数器

CHECK_END:
    ; 检查是否还有字符要打印（CX是否为0）
    CMP CX, 0
    JNE PRINT_LOOP   ; 如果还有字符，继续循环
    
    ; 程序结束
    MOV AH, 4CH
    INT 21H
MAIN ENDP

; 换行子程序
NEW_LINE PROC
    PUSH DX
    PUSH AX
    MOV AH, 02H
    MOV DL, 0DH      ; 回车符
    INT 21H
    MOV DL, 0AH      ; 换行符
    INT 21H
    POP AX
    POP DX
    RET
NEW_LINE ENDP

END MAIN