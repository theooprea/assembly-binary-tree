
section .data
    delim db " ", 0  ; delimitators for strtok
    negativ dd 0     ; variable to check if a nr is negative or not

section .bss
    root resd 1      ; variable in which i keep the pointer to the tree

section .text

extern check_atoi
extern print_tree_inorder
extern print_tree_preorder
extern evaluate_tree
extern printf
extern malloc
extern atoi
extern strtok
extern strlen
extern strcpy

global create_tree
global iocla_atoi
global create_tree_recursiv

create_tree_recursiv:
    push ebp                 ; initializa the function
    mov ebp, esp

    mov eax, [ebp + 8]       ; get the first argument, the node
                             ; where we currently are

    cmp eax, 0               ; check to see if the node is null
    je recursive_done        ; if it is null we exit the func (return)

    mov ebx, [eax]           ; move in eax the data of the current node and
    cmp ebx, 0               ; check to see if it is null
    jne after_data_null      ; if the data isn't null, we skip this step

    push eax                 ; pushing eax in stack to keep it intact after
                             ; using other external functions

    push delim               ; calling strtok on null (the initial input 
    push dword 0             ; string)
    call strtok
    add esp, 8
    push eax

    push eax                 ; find the length of the next word extracted from
    call strlen              ; the initial string
    add esp, 4

    inc eax                  ; increase the lenght (to be able to add string 
                             ; terminator)

    push eax                 ; create a copy of the current string using malloc
    call malloc              ; to add in the current node
    add esp, 4
    pop ebx                  ; pop the pointer to the initial node's data

    push ebx                 ; copy from the extracted string data into the
    push eax                 ; current node's data
    call strcpy
    add esp, 8

    mov ebx, eax             ;use ebx as an auxiliary to keep the copied string

    pop eax                  ; pop the current node
    mov [eax], ebx           ; move the data into current node's data pointer

after_data_null:             ; after the data has been iserted (the root is the
                             ; node initialized in the main function, all other
                             ; nodes' data pointers are initialized in this
                             ; recursive function)

    cmp byte [ebx + 1], 0    ;check to see if the current node's data is a sign
    jne after_sign           ;we have to see if the first (and only) character
    cmp byte [ebx], '+'      ; of the data string is a sign, + or - or * or /
    je sign                  ; we start by checking if the data string has only
    cmp byte [ebx], '-'      ; one character (the second is string terminator)
    je sign                  ; if the data string has just one character we can
    cmp byte [ebx], '/'      ; check whether the character is a number or a
    je sign                  ; sign
    cmp byte [ebx], '*'
    je sign

    jmp after_sign

sign:                        ; if the data is a sign, we add 2 uninitialized
                             ; nodes, the left son and right son into the
                             ; current tree node

    push eax                 ; we save the current node on the stack

    push 12                  ; aloocating a node and initializing it with all
    call malloc              ; pointers as null
    add esp, 4
    
    mov dword [eax], 0       ; nullify all pointers, data, left son node and
    mov dword [eax + 4], 0   ; right son node
    mov dword [eax + 8], 0

    mov ebx, eax             ; save the new node in ebx

    pop eax                  ; pop the current node
    mov [eax + 4], ebx       ; put the new node in the left pointer of the
                             ; current node

    push eax                 ; save the current node on the stack

    push 12                  ; allocate a new node 
    call malloc
    add esp, 4
    
    mov dword [eax], 0       ; initialize everything with 0
    mov dword [eax + 4], 0
    mov dword [eax + 8], 0

    mov ebx, eax             ; save the new node in ebx

    pop eax                  ; pop the current node
    mov [eax + 8], ebx       ; save the new node in the current's right pointer

after_sign:                  ; the non-sign nodes will not allocate new nodes
                             ; and will skip the previous step
                             ; once the function gets to this point, we make 2
                             ; recursive calls, one for the left node and one
                             ; for the right son

    push eax                 ; saving the current son on the stack

    mov ebx, [eax + 4]       ; moving and pushing the left son of the current
    push ebx                 ; node in ebx and immediately on the stack
    call create_tree_recursiv; and call the function to work on that node
    add esp, 4

    pop eax                  ; pop the current node (i saved it on the stack)
                             ; for it not to be uncontrollably modifiend during
                             ; the first recursive call

    mov ebx, [eax + 8]       ; move and push the right son of the current node
    push ebx
    call create_tree_recursiv; and make a recursive call, this time processing
    add esp, 4               ; the right son node

recursive_done:

    leave                    ; leave the function graciously
    ret


iocla_atoi: 
    push ebp                 ; enter the function setting ebp and esp
    mov ebp, esp             ; for atoi i am computing the modulus for the
                             ; input and check at the end whether i need to
                             ; compute the negative of the number or not


    mov ebx, [ebp + 8]       ; move the string argument to ebx
    xor ecx, ecx
    xor eax, eax             ; keeping the sum in eax so i initialize it with 0
    xor edx, edx

    mov dword [negativ], 0   ; variable to check if the input is positive or
                             ; negative

    cmp byte [ebx], '-'      ; check to see if the number is negative or not
    jne while


    inc ecx                  ; if the word is negative, skip the first
    mov dword [negativ], 1   ; character and set the negative variable as true

while:
    xor edx, edx
    mov dl, byte [ebx + ecx] ; take the current character from the input string
    cmp dl, '0'              ; verify that the crrent character is a digit
    jl out                   ; jump to end of function if it isn't a digit
    cmp dl, '9'
    jg out 


    sub edx, 48              ; subtract '0' from it in order to take it's
    imul eax, 10             ; decimal representation to add it to the sum  
    add eax, edx             ; by firstly multiplying the current sum with 10
    
    inc ecx                  ; increment the iterator
    cmp dword [ebx + ecx], 10; compare the current character to newline and
    je out                   ; string terminator, 0
    cmp dword [ebx + ecx], 0 ; if the character is one of these, we move on out
    je out                   ; of the iterating loop
    jmp while                ; if it's a digit we repeat the operation

out:
    mov ebx, [negativ]       ; check to see if the number is negative
    cmp ebx, 0
    je done                  ; if it isn't, we exit the function with eax as
                             ; the answer

    mov ecx, 0               ; if it is negative, we obtain the negative nr
    sub ecx, eax             ; by subtracting the modulus from 0
    mov eax, ecx

done:

    leave                    ; exiting the function graciously with eax as the
    ret                      ; the answer


create_tree:
    push ebp                 ; initialize ebp and esp and save ebx on the
    mov ebp, esp             ; stack for it to be restored at the end of the
    push ebx                 ; function


    mov eax, [ebp + 8]       ; move the input string to eax


    push 12                  ; allocate the initial node, the root with 12
    call malloc              ; bytes, 4 for each pointer
    add esp, 4
    push eax                 ; save the root node on the stack


    mov eax, [ebp + 8]       ; extract the first "word" from the input string
    push delim               ; call strtok with delim as delimitators and the
    push eax                 ; the input string as to process string
    call strtok
    add esp, 8
    
    push eax                 ; save the first "word" on the stack

    push eax                 ; find it's length
    call strlen
    add esp, 4

    inc eax                  ; and increase it for the string terminator, 0
    push eax                 ; allocate space for a dinamically allocated copy
    call malloc              ; of the first node
    add esp, 4
    pop ebx                  ; pop the first "word"

    push ebx                 ; copy into the dinamically allocated string the
    push eax                 ; first "word"
    call strcpy
    add esp, 8
    mov ebx, eax             ; move into ebx the dinamically allocated copy of
                             ; the first "word"

    pop eax                  ; pop the root
    mov dword [eax], ebx     ; move the first word into the root's data
    mov dword [eax + 4], 0   ; initialize the root's left and right son with
    mov dword [eax + 8], 0   ; null
    mov [root], eax          ; save in the root variable the first allocated
                             ; node, the actual pointer to the tree root

    push eax                   ; call the recursive function (the one which
    call create_tree_recursiv  ; build the tree) with the root as the argument
    add esp, 4                 ; reset the stack pointer

    mov eax, [root]          ; move into eax (the return argument of the
                             ; create_tree function) the pointer to the tree's
                             ; root, which is stored in the root variable

    pop ebx                  ; reset the ebx register

    leave                    ; exit the function graciously, with eax as the
    ret                      ; answer, containing the root pointer
