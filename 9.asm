DATA SEGMENT
    TITLE_MSG DB 'The 9mu19 table:', 0DH, 0AH, '$'
    NEWLINE DB 0DH, 0AH, '$'      ; 换行符
    SPACE DB '    $'              ; 4个空格用于对齐
DATA ENDS

STACK SEGMENT STACK
    DW 100 DUP(?)
STACK ENDS

CODE SEGMENT
    ASSUME CS:CODE, DS:DATA, SS:STACK

; 主程序
START:
    MOV AX, DATA
    MOV DS, AX
    
    ; 输出标题
    MOV AH, 09H
    LEA DX, TITLE_MSG
    INT 21H
    
    ; 外层循环：被乘数从9递减到1
    MOV CX, 9                   ; CX = 被乘数
    
OUTER_LOOP:
    PUSH CX                     ; 保存外层循环计数器
    
    ; 内层循环：乘数从1递增到当前被乘数
    MOV BX, 1                   ; BX = 乘数
    
INNER_LOOP:
    ; 调用过程输出一个乘法项
    MOV AL, CL                  ; AL = 被乘数
    MOV AH, BL                  ; AH = 乘数
    CALL PRINT_MULTIPLICATION   ; 调用输出过程
    
    ; 输出空格分隔
    MOV AH, 09H
    LEA DX, SPACE
    INT 21H
    
    INC BX                      ; 乘数加1
    CMP BX, CX                  ; 比较乘数和被乘数
    JLE INNER_LOOP              ; 如果乘数 <= 被乘数，继续内层循环
    
    ; 输出换行
    MOV AH, 09H
    LEA DX, NEWLINE
    INT 21H
    
    POP CX                      ; 恢复外层循环计数器
    LOOP OUTER_LOOP             ; 继续外层循环
    
    ; 程序结束
    MOV AH, 4CH
    INT 21H

; 过程：输出单个乘法项（格式：AxB=C）
; 输入：AL = 被乘数，AH = 乘数
PRINT_MULTIPLICATION PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    
    ; 保存参数到其他寄存器
    MOV BL, AL                  ; BL = 被乘数
    MOV BH, AH                  ; BH = 乘数
    
    ; 输出被乘数
    MOV DL, BL
    ADD DL, '0'                 ; 转换为ASCII
    MOV AH, 02H
    INT 21H
    
    ; 输出'x'
    MOV DL, 'x'
    INT 21H
    
    ; 输出乘数
    MOV DL, BH
    ADD DL, '0'                 ; 转换为ASCII
    INT 21H
    
    ; 输出'='
    MOV DL, '='
    INT 21H
    
    ; 计算乘积
    MOV AL, BL                  ; AL = 被乘数
    MOV AH, 0                   ; 清空AH
    MOV CL, BH                  ; CL = 乘数
    MUL CL                      ; AX = AL * CL
    
    ; 调用数字输出过程
    CALL PRINT_NUMBER
    
    POP DX
    POP CX
    POP BX
    POP AX
    RET
PRINT_MULTIPLICATION ENDP

; 过程：输出数字（处理1位或2位数）
; 输入：AX = 要输出的数字
PRINT_NUMBER PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    
    ; 如果数字为0，直接输出'0'
    CMP AX, 0
    JNE NOT_ZERO
    MOV DL, '0'
    MOV AH, 02H
    INT 21H
    JMP END_PRINT_NUMBER
    
NOT_ZERO:
    ; 处理数字
    MOV CX, 0                   ; 数字位数计数器
    MOV BX, 10                  ; 除数
    
DIVIDE_LOOP:
    MOV DX, 0                   ; 清空DX
    DIV BX                      ; AX / 10，商在AX，余数在DX
    PUSH DX                     ; 保存余数（数字位）
    INC CX                      ; 位数加1
    
    CMP AX, 0                   ; 商是否为0？
    JNE DIVIDE_LOOP             ; 不为0则继续除法
    
    ; 输出数字
OUTPUT_LOOP:
    POP DX                      ; 弹出数字位
    ADD DL, '0'                 ; 转换为ASCII
    MOV AH, 02H
    INT 21H
    LOOP OUTPUT_LOOP
    
END_PRINT_NUMBER:
    POP DX
    POP CX
    POP BX
    POP AX
    RET
PRINT_NUMBER ENDP

CODE ENDS
END START