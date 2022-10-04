	.text
main:
	#{push:main}
	mov D, SP
	add D, -1
	store BP, D
	mov SP, D
	mov BP, SP
	sub SP, 1
	.file 1 "examples/hello.c"
	.loc 1 7 0
	# }
	.loc 1 5 0
	#     }
	.loc 1 4 0
	#         putchar(*s);
	mov A, 0
	mov B, SP
.data
	.L3:
	.string "Hello, world!\n"
.text
	mov A, .L3
	mov B, BP
	add B, 16777215
	store A, B
	.loc 1 5 0
	#     }
	.L0:
	.loc 1 4 0
	#         putchar(*s);
	mov B, BP
	add B, 16777215
	load A, B
	mov B, A
	load A, B
	jeq .L4, A, 0
	jmp .L5
	.L4:
	.loc 1 5 0
	#     }
	jmp .L2
	.L5:
	.loc 1 4 0
	#         putchar(*s);
	mov B, BP
	add B, 16777215
	load A, B
	mov B, A
	load A, B
	mov D, SP
	add D, -1
	store A, D
	mov SP, D
	putc A
	add SP, 1
	.loc 1 5 0
	#     }
	.L1:
	.loc 1 4 0
	#         putchar(*s);
	mov B, BP
	add B, 16777215
	load A, B
	mov D, SP
	add D, -1
	store A, D
	mov SP, D
	add A, 1
	mov B, BP
	add B, 16777215
	store A, B
	load A, SP
	add SP, 1
	.loc 1 5 0
	#     }
	jmp .L0
	.L2:
	.loc 1 7 0
	# }
	mov A, 0
	mov B, A
	#{pop:main}
	exit
	#{pop:main}
	exit
