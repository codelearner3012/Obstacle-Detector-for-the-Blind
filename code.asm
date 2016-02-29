ORG 00H              		; origin	
MOV P0,#00000000B      	  	; sets P0 as output port
CLR P3.0               		; sets P3.0 as output for sending trigger
SETB P3.1              		; sets P3.1 as input for receiving echo
MOV TMOD,#00100010B        	; sets timer1 as mode 2 auto reload timer
MAIN: 
	MOV A,#38H
	ACALL CMND
	MOV A,#0CH 
	ACALL CMND
	MOV A,#01H 
	ACALL CMND
	MOV A,#06H 
	ACALL CMND
	MOV A,#80H 
	ACALL CMND

	mov dptr,#Mydata
string:	
	clr a
	movc a,@a+dptr
	cjne a,#'$',string1
	sjmp WORK
string1:
	acall disp
	inc dptr 
	sjmp string
	
WORK: setb p1.0
      MOV TL1,#207    		  	; loads the initial value to start counting from
      MOV TH1,#207    		  	; loads the reload value
      MOV A,#00000000B           		; clears accumulator
      SETB P3.0        		  	;starts the trigger pulse
      ACALL DELAY1     	  		; gives 10uS width for the trigger pulse
      CLR P3.0         		  	; ends the trigger pulse
HERE: JNB P3.1,HERE           		; loops here until echo is received
BACK: SETB TR1                    	; starts the timer1
HERE1: JNB TF1,HERE1        		; loops here until timer overflows (ie;48 count)
      CLR TR1          			; stops the timer
      CLR TF1          		   	; clears timer flag 1
      inc A            		  	; increments A for every timer1 overflow
      JB P3.1,BACK     		  	; jumps to BACK if echo is still available
      MOV R4,A         		  	; saves the value of A to R4
       ACALL back1      		  	; calls the buzzer audio function
      acall back2		  	; Calls the function to display on LCD.
      ;acall delaytry			; Insane delay
      SJMP WORK        		  	; jumps to Work

      

DELAY1:   MOV R6,#2     			; 10uS delay
	 DJNZ R6,$
         RET     

back2:	
	mov a,#89H
	acall cmnd
	mov a,r4
	add a,#0H
	da a
	swap a
	anl a,#0FH
	orl a,#30H
	acall disp
	mov a,r4
	add a,#0H
	da a
	anl a,#0FH
	orl a,#30h
	acall disp
	ret

BACK1:   subb a,#10
	jnc down
label:
	clr p1.0
	acall delay 
	setb p1.0
	sjmp out
down:
	mov a,r4
	subb a,#20
	jnc down1
label1:
	clr p1.0
	acall delay
	acall delay
	setb p1.0
	sjmp out
down1:
	mov a,r4
	subb a,#30
	jnc down2
label2:
	clr p1.0
	acall delay
	acall delay
	acall delay
	setb p1.0
	sjmp out
down2:
	mov a,r4
	subb a,#40
	jnc out
label3:
	clr p1.0
	acall delay
	acall delay
	acall delay
	acall delay
	setb p1.0
	sjmp out
out:
	ret
	
delay:   MOV R7,#250        ; 1mS delay
	DJNZ R7,$
        RET

CMND: MOV P2,A
CLR P0.6;this is the rs bit
CLR P0.5;r/w bit
SETB P0.7
CLR P0.7
ACALL DELY
RET

DISP:MOV P2,A
SETB P0.6
CLR P0.5
SETB P0.7
CLR P0.7
ACALL DELY
RET

DELY:
CLR P0.7
CLR P0.6
SETB P0.5
MOV P2,#0ffh
SETB P0.7
MOV A,P2
JB ACC.7,DELY
CLR P0.7
CLR P0.5
RET

delaytry:
wait:
mov r6,#1
mov th0,#0
mov tl0,#0
setb tr0
jnb tf0,$
clr tf0
djnz r6,wait
ret

Mydata:db 'DISTANCE:$'

END