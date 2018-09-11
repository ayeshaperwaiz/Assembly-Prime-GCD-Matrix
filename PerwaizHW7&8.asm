; Ayesha Perwaiz 
INCLUDE Irvine32.inc

; used for matrix of words
rows = 5
cols = 5
numVowels = 2
vowelProb = 50

; prototypes for each function 
mainMenu PROTO
InputNumber PROTO
FindPrimes PROTO
DisplayPrimes PROTO
gcdDisplay PROTO
GCD PROTO
matrixRows PROTO
matrixColumns PROTO
matrixDiagonal PROTO direction: SDWORD
is_vowel PROTO
probability PROTO
createMatrix PROTO 
displayMatrix PROTO

.data 
; variable definitions 

divider BYTE "----------------------------------------------", 0

primeArray TYPEDEF DWORD	 ; boolean array
primeNum primeArray 1000 DUP(1)	; array of values initialized to 1 
N DWORD ?	; used to hold user input variable
totalPrimes BYTE 0	; Track number of primes for range 2 through N

GCDinputInt BYTE "Please input a integer: ", 0		 ; prompt user for a integer
GCDinputInt2 BYTE "Please input another integer: ", 0 ; prompt user for another integer
GCDmsg BYTE "The greatest common divisor is: ", 0 ; prompt user before outputting the gcd

;used for matrix of words
vowels BYTE "AEIOU" ;
consonants BYTE "BCDFGHJKLMNPQRSTVWXZ"
matrix BYTE ROWS DUP(COLS DUP(0))
tempstr BYTE 5 DUP(0), 0
vowelcount DWORD 0
msg1 BYTE "The words from the matrix is/are: ",0Ah, 0 


.code 
main PROC 
; clear all registers 
mov eax, 0 
mov ebx, 0 
mov ecx, 0 
mov edx, 0 

Invoke mainMenu 
main ENDP

;--------------------------------------------------------

mainMenu PROC 
.data
; User prompts for main menu
mainMenuDisplay BYTE "		MAIN MENU", 0
SievePrompt BYTE "Find Primes: ", 0 
menuOpt1 BYTE "1. Display all primes between 2 and 1000", 0
menuOpt2 BYTE "2. Display all primes between 2 and n", 0
GCDprompt BYTE "Euclid: ", 0 
menuOpt3 BYTE "3. Find GCD using Euclid's Algorithm ", 0 
matrixPrompt BYTE "Matrix of Words: ", 0 
menuOpt4 BYTE "4. Display matrix", 0 
exitOpt BYTE "5. Exit", 0

.code
top:
call clrscr
mov edx, OFFSET divider			
call WriteString
call crlf
mov edx, OFFSET mainMenuDisplay	; Menu prompt
mov  eax, lightCyan + (black*16) ; set color to light cyan
call SetTextColor
call WriteString
call crlf

mov  eax, white + (black*16) ; set color to white
call SetTextColor
mov edx, OFFSET divider			
call WriteString
call crlf
; display find prime prompt 
mov edx, OFFSET sievePrompt
mov  eax, lightCyan + (black*16) ; set color to light cyan  
call SetTextColor
call WriteString
call crlf 

mov  eax, white + (black*16) ; set color to white 
call SetTextColor

; display menu prompt 1
mov edx, OFFSET menuOpt1
call WriteString
call crlf

; display menu prompt 2
mov edx, OFFSET menuOpt2	
call WriteString
call crlf

; display GCD prompt 
mov edx, OFFSET divider			
call WriteString
call crlf
mov edx, OFFSET GCDprompt 
mov  eax, lightCyan + (black*16) ; set color to green 
call SetTextColor
call WriteString
call crlf 

mov  eax, white + (black*16) ; set color to green 
call SetTextColor

; display menu prompt 3
mov edx, OFFSET menuOpt3
call WriteString 
call crlf

; display matrix of words prompt 
mov edx, OFFSET divider		
call WriteString
call crlf
mov edx, OFFSET matrixPrompt 
mov  eax, lightCyan + (black*16) ; set color to light cyan 
call SetTextColor
call WriteString 
call crlf 

mov  eax, white + (black*16) ; set color to light cyan 
call SetTextColor

; display menu option 4 
mov edx, OFFSET menuOpt4
call WriteString
call crlf 
call crlf 

; display exit prompt
mov edx, OFFSET exitOpt	
mov  eax, lightRed + (black*16) ; set color to light red 
call SetTextColor
call WriteString
call crlf

mov  eax, white + (black*16) ; set color to white 
call SetTextColor

call ReadInt	; read user input

cmp eax, 5	; compare EAX to 3
je exitProg	; If user enters 3 jump to exitProg
ja top	; redisplay prompt if incorrect option is selected 

cmp eax, 4
jne Option3
call clrscr
call Randomize
Invoke createMatrix
Invoke createMatrix
; the next matrix generates a few words
Invoke createMatrix
Invoke displayMatrix

mov	edx, OFFSET msg1
call WriteString

Invoke matrixRows
Invoke matrixColumns
Invoke matrixDiagonal, 1		; left to right
Invoke matrixDiagonal, -1		; right to left
call crlf
call waitMsg
jmp top

Option3: 
cmp eax, 3
jne Option2
call clrscr
Invoke gcdDisplay
jmp top

Option2:
cmp eax, 2
jne Option1 ; jump to userPicks1
call clrscr
Invoke InputNumber	; call InputNumber procedure to get int N for 2 to N where (N >= 1000)
Invoke FindPrimes	; call FindPrimes function
Invoke DisplayPrimes	; call DisplayPrimes function 
jmp top

Option1:
cmp eax, 1
jb top	; redisplay prompt if incorrect option is selected 
mov n, 1000	; Range is 2 through N = 1000
Invoke FindPrimes	; Calculate primes for the range 2 through 1000
Invoke DisplayPrimes	; Display all primes
jmp top	; display menu until option 3 is selected

exitProg:
exit
	
ret 
mainMenu ENDP ; end procedure
	
;--------------------------------------------------------
; Find Prime Procedures
;--------------------------------------------------------

InputNumber PROC
; Procedure that asks user to input a valie N where 
; N is less than or equal to  1000 and is greater than 2

.data
; prompt user for input
InputN_Prompt BYTE "Enter a number between 2 and 1000: ", 0

.code

Nloop:
mov edx, OFFSET InputN_Prompt	; Asks the user to enter a number N 
call WriteString
call ReadInt	; read user input
cmp eax, 1000	; compare integer input 

ja Nloop	; Jump if N is > 1000
cmp eax, 2 ; compare integer input

jb Nloop	; Just if user input is < 2
mov N, eax	; move value of eax to N

ret  

InputNumber ENDP	; end procedure

;--------------------------------------------------------

FindPrimes PROC 
; Determines the prime numbers between the unsigned 
; values of 2 to 1000 using Sieve of Eratosthenes algorithm.
; The algortihm divides each number in the array by 2, 3, 4, etc
; until only prime numbers are left in the array. 
; All non-prime numbers will be represented by 0 

mov ecx, 0	; clear ecx

fillArray:	; Fill the array with all values from 2 to N
mov eax, ecx
add eax, 2	; range starts at 2
mov [primeNum + 4 * ecx], eax	; Put each number into an element of the array
inc ecx	; increment to next element in array
cmp ecx, N	; continue while ecx < N
jb fillArray

mov ecx, 0	; clear ecx

L1:
mov ebx, ecx
inc ebx	; increment ebx which increments array 2, 3, 4...
cmp[primeNum + 4 * ecx], 0	; increments to the next DWORD
jne L2	; If not equal to zero jump to L2

incECX:
inc ecx ; increment ecx for division 
cmp ecx, N	; Only continue while ecx < user input N or 1000
jb L1
jmp bottom	; jump bottom if greater than N

L2:
cmp[primeNum + 4 * ebx], 0	; increment to next DWORD
jne L3

IncEBX:
inc ebx ; increment to next element in the array
cmp ebx, N	; Only increase while ebx < N
jb L2
jmp incECX ; once N is reached, jump to IncreaseECX to check for numbers divisible by element in ecx

; if array element is not equal to 0
L3 :
mov edx, 0	; clear edx
mov eax, 0 ; clear ea
mov eax, [primeNum + 4 * ebx]	; Move current array element from ebx into eax
div [primeNum + 4 * ecx] ; Divide element in eax by number in ecx
cmp edx, 0 ; compare to see if element is equal to 0
je notPrime ; If = 0, number is not a prime
jmp IncEBX							

notPrime:
mov [primeNum + 4 * ebx], 0	; Replace non-prime number with a 0
jmp incEBX ; increase to next element in array

bottom:
ret	

FindPrimes ENDP	; end procedure 

;--------------------------------------------------------

DisplayPrimes PROC 
; Displays how many primes are in the range of 2 to n, 
; where n is less than or equal to 1000.

.data
; display prime message prompts
displayPrime1 BYTE "There are ", 0
displayPrime2 BYTE " primes between 2 and n (n = ", 0
displayPrime3 BYTE ")", 0

; used for row major format
row BYTE 2
column BYTE 0

tempPrime BYTE 0 ; used to keep track of hor many primes are printed per row

.code

sub N, 1
mov ecx, N	; Set loop counter to N-1
mov ebx, 0	; zero register

; determine the total number of primes for any given range of 2 through N
L1:
mov eax, [primeNum + 4 * ebx]	; Move array element into EAX register
cmp eax, 0 ;  Compare to zero
jne numIsPrime	; If the number is not = 0, then it is a prime number
inc ebx	; increment ebx
jmp endL ; Jump to the end of the loop 

numIsPrime:
inc totalPrimes	; If number is prime increase totalPrimes
inc ebx	; Incremenet EBX to next element in the array

endL:
loop L1

call clrscr	; clear screen
; Display prompts for calculated prime numbers
mov edx, OFFSET displayPrime1
call WriteString

mov al, totalPrimes
call WriteDec

mov edx, OFFSET displayPrime2
call WriteString

add N, 1
mov eax, N	; (n = N)
call WriteDec

sub N, 1
mov al, displayPrime3
call WriteChar
call crlf
		
mov edx, OFFSET divider
call WriteString
call crlf

mov ebx, 0 ; clear register 

displayElement: ; displays prime number with at most 5 elements per row and 5 spaces between each column 
mov eax, [primeNum + 4 * EBX]	; Move element into eax
cmp eax, 0	; Check to see if the number is a prime or non-prime number
je elementIsZero	; If element is 0, then not a prime

; if the number is prime 
mov dh, row	; Move cursor location to just below the previous prompt and at column
mov dl, column
call GoToXY
call WriteDec ; Write prime number to output
inc tempPrime	; increment temp 
cmp tempPrime, 5

je equal5 ; temp is < 5
add column, 5	; create 5 spaces between each printed prime number
inc ebx	; move to next array element
jmp bottom

equal5:	; If temp is 5 execute the following
call crlf
sub column, 25	; Move cursor back to col 0
inc row	; move cursor to next row
mov tempPrime, 0	; reset temp variable to 0

mov dh, row	; set cursor location
mov dl, column
call GoToXY

add column, 5	; Add 5 spaces between each col
inc ebx	; Increment to next array element
jmp bottom	

elementIsZero:	; element is zero
inc ebx	; increment to next element is number is non prime 

bottom:
cmp ebx, N	; continue the loop while ebx < 5
jb displayElement
; resets variables
mov column, 0
mov row, 2
mov tempPrime, 0
mov totalPrimes, 0

call crlf
call waitMsg

ret	
DisplayPrimes ENDP ; end procedure

;--------------------------------------------------------
;Greatest Common Divisor Procedures
;--------------------------------------------------------

gcdDisplay PROC 
; procedure that asks user for two inputs, calls a 
; procedure to find the GCD, and displays the output.

mov eax, 0 ; clear eax
mov ebx, 0 ; clear ebx

mov edx, offset GCDinputInt ; prompt user for first value 
call WriteString
call readInt ; read user input
mov bl, al ; move first unser input into bl 

mov edx, offset GCDinputInt2 ; prompt user for second value
call WriteString 
call readInt ; takes user input
mov bh, al ; moves second user input into bh

call GCD ; takes values stored in bl and bh and returns greatest common divisor in al

mov edx, offset GCDmsg ; display GCDmsg to screen 
call WriteString
call WriteInt ; displays greatest common divisor to screen
call Crlf
call Crlf
call waitMsg
ret

; I didn't have enough time to format this as shown 
; in the example and similar to what was done for find primes.

gcdDisplay ENDP 

;--------------------------------------------------------

GCD PROC
; Proceure that finds the greatest common divisor of two numbers
; using Euclid's Algorithm

; psuedocode algorithm from Wikipedia (Euclidean Algorithm)
; int euclid_gcd_recur(int m, int n)
; {
;        if(n == 0)
;                return m;
;       else
;                return euclid_gcd_recur(n, m % n);
; }


mov eax, 0 ; clear eax

cmp bl, 0 ; compares first input to zero
jl L2 ; if value is negative

L1:
cmp bh, 0 ; compares second input to zero
jl L3 ; if value is negative
jmp L4 ; if value is positive

L2:
neg bl ; makes bl positive
jmp L1 ; jump back to L1

L3:
neg bh ; for absolute value

L4:
mov al, bl
div bh ; divides bl by bh
mov bl, bh ; stores bh into bl
mov bh, ah ; stores remainder into bh
mov ax, 0 ; clear ax
cmp bh, 0 ; compares remainder to zero
jg L4 ; jumps back to L4 until remainder from div is less than or equal t0 zero

mov al , bl  ; stores gcd into al 

ret	
GCD ENDP

;--------------------------------------------------------
;Matrix of Words Procedures
;--------------------------------------------------------

matrixRows PROC 
; Generate all sets of letters based on the matrix rows.

mov	esi, 0
mov	ecx, rows ; number of rows
	
; Do one row
next_row:	
push ecx ; save row count
mov	vowelCount, 0
mov	ecx, cols
mov	edi, 0	; points to tempstr

next_char_in_row:
mov	al, matrix[esi]
Invoke is_vowel	; check to see if al contains vowel
jnz	Loop2
inc	vowelcount

Loop2: 
mov tempstr[edi], al
inc	esi	; next matrix index
inc	edi	; next tempstr index
loop next_char_in_row

cmp	vowelcount, numVowels	; two vowels in the row?
jne	L3	; jump if two vowels were not found
mov edx, OFFSET tempstr ; if found display rows
call WriteString
call Crlf

L3:	
pop	ecx	; restore row count
loop next_row
ret

matrixRows ENDP ; end procedure

;--------------------------------------------------------
	
matrixColumns PROC 
; Generate all sets of letters based on the matrix columns.

mov	esi, 0
mov	ecx, cols ; number of columns
	
next_column:	
push ecx ; save column count
mov	vowelcount,0 
mov	ecx, rows ; 5 rows in a column
mov	edi, 0
push esi

next_char_in_column:
mov	al, matrix [esi]
Invoke is_vowel ; check to see if AL contains vowel 
jnz	LoopityLoop ; jump to next loop if no vowel was found
inc	vowelcount ; increment counter

LoopityLoop:	
mov	tempstr[edi], al
add	esi, cols ; point esi to the next row
inc	edi	; next tempstr index
loop next_char_in_column

pop	esi	; restore matrix pointer
inc	esi	; incremenet esi 
cmp	vowelcount, numVowels ; two vowels 
jne	L3 ; if two vowels were not found jump to loop 3
mov edx, OFFSET tempstr	; if found, display the column
call WriteString
call Crlf

L3:	
pop	ecx	; restore column count
loop next_column
	
ret
matrixColumns ENDP

matrixDiagonal PROC ,
	direction: SDWORD

mov	ecx, ROWS
mov	esi, 0 ; row index
mov	edx, 0 ; tempstr index
mov	vowelcount, 0

cmp direction, 0 ; set column index
mov	edi, COLS 
dec	edi
jne loop1

loop1: 
mov	edi, 0 ; clear edi 

L1:	
mov	al, matrix[esi][edi]	
Invoke is_vowel	; call is_vowel procedure to search for vowel 
jnz	L2 ; if no vowel was found
inc	vowelcount ; if vowel was found, increment vowelcount

L2:	mov	tempstr[edx], al
inc	edx	; next tempstr index
add	esi, cols ; next matrix row
add	edi, direction ; next matrix column
loop L1

cmp	vowelcount, numVowels	; check to see if there are two vowels in column
jne	L3 ; jump to L3 if two vowels were not found
mov edx, OFFSET tempstr	; display the column
call WriteString
call Crlf

L3:		
ret

matrixDiagonal ENDP


is_vowel PROC uses ecx edi ; I don't know how to get this procedure to work with using 'USES'
; determines whether letter is vowel

mov	edi, OFFSET vowels
mov	ecx, LENGTHOF vowels
repne scasb	; searches for the first occurence of a byte 
; whose value is equal to that of al 

ret
is_vowel ENDP


createMatrix PROC
; Fills the board with randomly-generated capital letters.
; Vowels must have a 50% probability of being chosen.

mov	esi, OFFSET matrix
mov	ecx, SIZEOF matrix

L1:	
mov	bl, vowelProb; percentage of vowels
call probability ; call probability procedure
jz	L2					
mov	eax, SIZEOF vowels ; choose a vowel
call RandomRange ; generate random integer
movzx edi, al ; use as index
mov	al, vowels [edi] ; get the vowel
jmp	L3 ; jump to loop 3
	
L2:
mov	eax, SIZEOF consonants
call RandomRange ; generate random integer
movzx edi, al ; use as the index
mov	al, consonants[edi] ; get the consonant
	
L3:	
mov	[esi], al ; save character
inc	esi ; increment esi
loop L1

ret
createMatrix ENDP ; end procedure

;--------------------------------------------------------

probability PROC
; Creates a N% probability that ZF = 0.

push eax
mov	eax, 100
call RandomRange ; generate random value
cmp	al, bl ; if al < 40
jb L1	
xor	al, al ; if al is not less than 40
L1:	
pop	eax
ret

probability ENDP ; end procedure

;--------------------------------------------------------

displayMatrix PROC 
; Displays the matrix with a space between each letter.

mov	ecx, rows
mov	esi, OFFSET matrix

L1:	
push ecx
mov	ecx, cols

L2:	
mov	al,[esi]
call WriteChar
mov	al,' '
call WriteChar
inc	esi
loop L2 ; next column


call Crlf
pop	ecx	
loop L1	; next row

call crlf
mov edx, OFFSET divider
call WriteString
call crlf
call crlf 
ret
displayMatrix ENDP

END main
