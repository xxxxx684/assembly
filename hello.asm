.MODEL SMALL        ; 定义内存模型为小模式
.STACK 64           ; 定义堆栈段大小为64字节

.DATA               ; 数据段开始
msg DB 'Hello, World!$'  ; 定义字符串，以$结尾（DOS字符串结束标志）

.CODE               ; 代码段开始
MAIN PROC FAR       ; 主过程定义为FAR（远调用）
    MOV AX, @DATA   ; 将数据段地址加载到AX寄存器
    MOV DS, AX      ; 将AX的值移动到DS寄存器，设置数据段
    
    MOV AH, 9       ; DOS功能号9：显示字符串
    MOV DX, OFFSET msg  ; 将字符串msg的偏移地址加载到DX寄存器
    INT 21H         ; 调用DOS中断21H，显示字符串
    
    MOV AX, 4C00H   ; DOS功能号4CH：程序退出，返回码00H
    INT 21H         ; 调用DOS中断21H，结束程序
MAIN ENDP           ; 主过程结束

END MAIN            ; 程序结束，指定入口点为MAIN