; Keona Abad
; CS 271 Computer Architecture and Assembly Language - Program 4 
; March 3, 2024
; Description: This program gives an array of random numbers and sorts them and then collectes the median.

INCLUDE Irvine32.inc

.data
minVal DWORD 10
maxVal DWORD 200
loVal DWORD ?
hiVal DWORD ?
arraySize DWORD ?
numbers DWORD 200 DUP(?)
unsortedTitle BYTE "Unsorted List", 0
sortedTitle BYTE "Sorted List", 0
introMsg BYTE "Sorting Random Integers Programmed by Keona Abad",0
promptArraySize BYTE "Enter the number of elements (10-200): ", 0
promptLoVal BYTE "Enter the lower bound (1-999): ", 0
promptHiVal BYTE "Enter the upper bound (1-999): ", 0
errMsg BYTE "Invalid input, please try again.", 0
spacer BYTE " ", 0
medianMsg BYTE "The median is: ", 0
continueMsg BYTE "Would you like to go again (No=0/Yes=1)? ", 0



.code
main PROC
    call Randomize
    call Introduction

    mainLoop:                    ; Beginning of the main loop
        call GetData             ; Calls procedure to get data (array size, range) from user
        call FillArray           ; Fills the array with random numbers within user-defined range
        mov edx, OFFSET unsortedTitle
        call DisplayList         ; Displays the unsorted array of random numbers
        call SortList            ; Sorts the array
        call DisplayMedian       ; Calculates and displays the median value of the array
        mov edx, OFFSET sortedTitle
        call DisplayList         ; Displays the sorted array
        call GoAgain             ; Asks the user if they want to run the program again
        cmp ecx, 0
        jne mainLoop             ; Continues looping if user wants to run again

    call ExitProcess             ; Terminates the program
main ENDP


; Displays the introduction message of the program
Introduction PROC
    ; Loads and displays the introduction message for the program
    mov edx, OFFSET introMsg
    call WriteString            ; Displays the intro message string
    call Crlf                   ; New line for better format
    ret
Introduction ENDP


; Main processing loop of the program
MainLoop PROC
    ; Sets the condition for the while loop and runs the main functionalities
    mov ecx, 1                  ; Initializes loop condition variable
    whileLoop:
        call GetData            ; Retrieves user input for array configuration
        call FillArray          ; Populates the array with random numbers
        call DisplayList        ; Displays the unsorted version of the array
        call SortList           ; Sorts the array
        call DisplayMedian      ; Calculates and displays the median of the array
        call DisplayList        ; Displays the sorted array
        call GoAgain            ; Prompts for rerunning the program
        cmp ecx, 0              ; Checks if user opted to continue
        jne whileLoop           ; Repeats loop if user chose to continue
    ret
MainLoop ENDP


; Procedure to get data (array size, range) from the user
GetData PROC
    ; Makes sure valid user input for array size and value range
    push ecx
    push edx
    mov ecx, FALSE         ; Flag for input validation

    ; Prompt for array size
    getArraySize:
        mov edx, OFFSET promptArraySize
        call WriteString
        call ReadInt
        cmp eax, minVal
        jl invalidInput
        cmp eax, maxVal
        jg invalidInput

        mov arraySize, eax  ; Stores a valid array size
        mov ecx, TRUE       ; Sets valid input flag


    ; Prompt for loVal
    getLoVal:
    ; Prompts and validates user input for lower bound value
        mov edx, OFFSET promptLoVal
        call WriteString
        call ReadInt
        cmp eax, 1
        jl invalidInput
        cmp eax, 999
        jg invalidInput

        mov loVal, eax      ; Store valid loVal


    ; Prompt for hiVal
    getHiVal:
    ; Prompts and validates user input for upper bound value
        mov edx, OFFSET promptHiVal
        call WriteString
        call ReadInt
        cmp eax, loVal
        jl invalidInput
        cmp eax, 999
        jg invalidInput

        mov hiVal, eax      ; Store valid hiVal
        jmp nextInput


    ; Handles invalid input and prompts user to re-enter the data
    invalidInput:
        mov edx, OFFSET errMsg
        call WriteString
        call Crlf
        jmp getArraySize

    nextInput:
    pop edx
    pop ecx
    ret
GetData ENDP


; Procedure to fill the array with random numbers within the user-defined range
FillArray PROC
    pushad
    mov ecx, arraySize          ; Sets loop counter to the size of the array
    mov esi, OFFSET numbers     ; Points to the start of the numbers array


    fillLoop:
        mov eax, hiVal
        sub eax, loVal
        inc eax            ; (hi - lo + 1)
        call RandomRange   ; Get random number in range
        add eax, loVal     ; Adjust range
        mov [esi], eax
        add esi, TYPE numbers
        loop fillLoop

    popad
    ret
FillArray ENDP


SortList PROC
    pushad
    mov ecx, arraySize
    dec ecx
    mov esi, 0           ; Outer loop index

    outerLoop:
        mov edi, esi
        inc edi           ; Inner loop index
        mov ebx, esi      ; Index of max value

        innerLoop:
            mov eax, numbers[edi * TYPE numbers]
            cmp eax, numbers[ebx * TYPE numbers]
            jle noSwap
            mov ebx, edi

            noSwap:
            inc edi
            cmp edi, arraySize
            jl innerLoop

        ; Swap numbers[esi] and numbers[ebx]
        mov eax, numbers[esi * TYPE numbers]
        mov edx, numbers[ebx * TYPE numbers]
        mov numbers[esi * TYPE numbers], edx
        mov numbers[ebx * TYPE numbers], eax

        inc esi
        loop outerLoop

    popad
    ret
SortList ENDP


DisplayList PROC
    pushad
    mov ecx, arraySize   ; Counter
    mov esi, OFFSET numbers
    mov ebx, 10          ; Line counter

    displayLoop:
        mov eax, [esi]
        call WriteDec
        mov edx, OFFSET spacer
        call WriteString
        add esi, TYPE numbers
        dec ebx
        jnz continueLine

        call Crlf
        mov ebx, 10

        continueLine:
        loop displayLoop
    call Crlf

    popad
    ret
DisplayList ENDP


DisplayMedian PROC
    pushad
    mov eax, arraySize
    test eax, eax          ; Check if arraySize is 0
    jz endMedian           ; If 0, skip calculation

    mov esi, OFFSET numbers ; Point to the start of the array

    ; Check if arraySize is odd or even
    test eax, 1            ; Check the least significant bit
    jnz oddArraySize       ; If odd, jump to oddArraySize

evenArraySize:
    ; For even arraySize, median is the average of two middle elements
    shr eax, 1             ; eax = arraySize / 2
    mov ebx, [esi + eax*4 - 4] ; Element before the middle
    add ebx, [esi + eax*4] ; Add the middle element
    shr ebx, 1             ; Average of two middle elements
    jmp printMedian

oddArraySize:
    ; For odd arraySize, median is the middle element
    shr eax, 1             ; eax = arraySize / 2
    mov ebx, [esi + eax*4] ; Middle element

printMedian:
    mov edx, OFFSET medianMsg
    call WriteString
    mov eax, ebx           ; Move median value to eax for WriteDec
    call WriteDec
    call Crlf

endMedian:
    popad
    ret
DisplayMedian ENDP


GoAgain PROC
    pushad
    mov edx, OFFSET continueMsg
    call WriteString
    call ReadInt
    cmp eax, 1
    je continueYes
    jmp continueNo

    continueYes:
    mov ecx, 1          ; Set flag to continue

    continueNo:
    mov ecx, 0          ; Set flag to not continue

    popad
    ret
GoAgain ENDP

END main