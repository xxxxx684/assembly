; 求和程序：根据用户输入计算1+2+...+n，并显示结果
.MODEL SMALL
.STACK 100H
.DATA
    PROMPT DB 'Enter a number from 1 to 100 : $'
    RESULT_MSG DB 0DH, 0AH, 'sum : $'
    NEWLINE DB 0DH, 0AH, '$'
    INPUT_BUFFER DB 5, ?, 5 DUP(?)  ; 输入缓冲区
    NUMBER DW 0                     ; 存储输入的数字
    SUM DW 0                        ; 存储求和结果
.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    ; 显示提示信息
    CALL SHOW_PROMPT
    
    ; 获取用户输入
    CALL GET_INPUT
    
    ; 将输入字符串转换为数字
    CALL CONVERT_TO_NUMBER
    
    ; 计算1到n的和
    CALL CALCULATE_SUM
    
    ; 显示结果
    CALL SHOW_RESULT
    
    ; 程序结束
    MOV AH, 4CH
    INT 21H
MAIN ENDP

; 显示提示信息
SHOW_PROMPT PROC
    MOV AH, 09H
    LEA DX, PROMPT
    INT 21H
    RET
SHOW_PROMPT ENDP

; 获取用户输入
GET_INPUT PROC
    MOV AH, 0AH
    LEA DX, INPUT_BUFFER
    INT 21H
    
    ; 显示换行
    MOV AH, 09H
    LEA DX, NEWLINE
    INT 21H
    RET
GET_INPUT ENDP

; 将输入字符串转换为数字
CONVERT_TO_NUMBER PROC
    LEA SI, INPUT_BUFFER + 2  ; 指向输入字符串的开始
    MOV CX, 0                 ; 清零CX用于存储结果
    MOV BL, 10                ; 乘数10
    
CONVERT_LOOP:
    MOV AL, [SI]              ; 获取当前字符
    CMP AL, 0DH               ; 检查是否是回车符
    JE CONVERT_DONE           ; 如果是回车符，转换完成
    
    ; 将ASCII字符转换为数字
    SUB AL, '0'
    MOV AH, 0                 ; 清零AH
    
    ; CX = CX * 10 + AX
    PUSH AX
    MOV AX, CX
    MUL BL                    ; AX = CX * 10
    MOV CX, AX
    POP AX
    ADD CX, AX                ; CX = CX * 10 + 新数字
    
    INC SI                    ; 指向下一个字符
    JMP CONVERT_LOOP
    
CONVERT_DONE:
    MOV NUMBER, CX            ; 保存转换后的数字
    RET
CONVERT_TO_NUMBER ENDP

; 计算1到n的和
CALCULATE_SUM PROC
    MOV AX, 0                 ; 清零累加器
    MOV CX, NUMBER            ; 设置循环次数
    
    CMP CX, 0                 ; 检查输入是否为0
    JLE CALC_DONE             ; 如果<=0，直接结束
    
SUM_LOOP:
    ADD AX, CX                ; AX = AX + CX
    LOOP SUM_LOOP             ; CX减1，如果不为0则继续循环
    
CALC_DONE:
    MOV SUM, AX               ; 保存结果
    RET
CALCULATE_SUM ENDP

; 显示结果
SHOW_RESULT PROC
    ; 显示结果消息
    MOV AH, 09H
    LEA DX, RESULT_MSG
    INT 21H
    
    ; 显示计算结果
    MOV AX, SUM
    CALL DISPLAY_NUMBER
    
    ; 显示换行
    MOV AH, 09H
    LEA DX, NEWLINE
    INT 21H
    RET
SHOW_RESULT ENDP

; 显示AX中的数字（十进制）
DISPLAY_NUMBER PROC
    MOV CX, 0                 ; 计数器，记录数字位数
    MOV BX, 10                ; 除数10
    
    ; 处理特殊情况：如果数字为0，直接显示0
    CMP AX, 0
    JNE CONVERT_LOOP2
    
    PUSH AX
    MOV DL, '0'
    MOV AH, 02H
    INT 21H
    POP AX
    RET
    
CONVERT_LOOP2:
    MOV DX, 0                 ; 清零DX，为除法准备
    DIV BX                    ; AX除以10，商在AX，余数在DX
    PUSH DX                   ; 将余数（数字）压栈
    INC CX                    ; 位数加1
    
    CMP AX, 0                 ; 检查商是否为0
    JNE CONVERT_LOOP2         ; 不为0则继续
    
DISPLAY_LOOP:
    POP DX                    ; 从栈中弹出数字
    ADD DL, '0'               ; 转换为ASCII字符
    MOV AH, 02H               ; DOS显示字符功能
    INT 21H                   ; 显示字符
    LOOP DISPLAY_LOOP
    
    RET
DISPLAY_NUMBER ENDP

END MAIN