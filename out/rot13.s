	.data
	c:

	.long 0
	.data
	offset:

	.long 0
	.text
main:
	#{push:main}
	mov D, SP
	add D, -1
	store BP, D
	mov SP, D
	mov BP, SP
	.file 1 "examples/rot13.c"
	.loc 1 26 0
	# }
	.loc 1 24 0
	#     }
	.L0:
	.loc 1 13 0
	#         if (c == EOF) {
	getc A
	jne .L3, A, 0
	mov A, -1
	.L3:
	mov B, c
	store A, B
	.loc 1 15 0
	#         }
	.loc 1 14 0
	#             break;
	mov B, c
	load A, B
	mov D, SP
	add D, -1
	store A, D
	mov SP, D
	mov A, 0
	mov D, SP
	add D, -1
	store A, D
	mov SP, D
	mov A, 1
	mov B, A
	load A, SP
	add SP, 1
	sub A, B
	mov B, A
	load A, SP
	add SP, 1
	eq A, B
	jeq .L4, A, 0
	.loc 1 15 0
	#         }
	jmp .L2
	.L4:
	.loc 1 18 0
	#         if (('a' <= c && c < 'n') || ('A' <= c && c < 'N')) {
	mov A, 0
	mov B, offset
	store A, B
	.loc 1 22 0
	#         }
	.loc 1 19 0
	#             offset = 13;
	mov A, 97
	mov D, SP
	add D, -1
	store A, D
	mov SP, D
	mov B, c
	load A, B
	mov B, A
	load A, SP
	add SP, 1
	le A, B
	mov B, 0
	jeq .L6, A, 0
	mov B, c
	load A, B
	mov D, SP
	add D, -1
	store A, D
	mov SP, D
	mov A, 110
	mov B, A
	load A, SP
	add SP, 1
	lt A, B
	mov B, A
	ne B, 0
	.L6:
	mov A, B
	mov B, 1
	jne .L5, A, 0
	mov A, 65
	mov D, SP
	add D, -1
	store A, D
	mov SP, D
	mov B, c
	load A, B
	mov B, A
	load A, SP
	add SP, 1
	le A, B
	mov B, 0
	jeq .L7, A, 0
	mov B, c
	load A, B
	mov D, SP
	add D, -1
	store A, D
	mov SP, D
	mov A, 78
	mov B, A
	load A, SP
	add SP, 1
	lt A, B
	mov B, A
	ne B, 0
	.L7:
	mov A, B
	mov B, A
	ne B, 0
	.L5:
	mov A, B
	jeq .L8, A, 0
	.loc 1 20 0
	#         } else if (('n' <= c && c <= 'z') || ('N' <= c && c <= 'Z')) {
	mov A, 13
	mov B, offset
	store A, B
	jmp .L9
	.L8:
	.loc 1 22 0
	#         }
	.loc 1 20 0
	#         } else if (('n' <= c && c <= 'z') || ('N' <= c && c <= 'Z')) {
	mov A, 110
	mov D, SP
	add D, -1
	store A, D
	mov SP, D
	mov B, c
	load A, B
	mov B, A
	load A, SP
	add SP, 1
	le A, B
	mov B, 0
	jeq .L11, A, 0
	mov B, c
	load A, B
	mov D, SP
	add D, -1
	store A, D
	mov SP, D
	mov A, 122
	mov B, A
	load A, SP
	add SP, 1
	le A, B
	mov B, A
	ne B, 0
	.L11:
	mov A, B
	mov B, 1
	jne .L10, A, 0
	mov A, 78
	mov D, SP
	add D, -1
	store A, D
	mov SP, D
	mov B, c
	load A, B
	mov B, A
	load A, SP
	add SP, 1
	le A, B
	mov B, 0
	jeq .L12, A, 0
	mov B, c
	load A, B
	mov D, SP
	add D, -1
	store A, D
	mov SP, D
	mov A, 90
	mov B, A
	load A, SP
	add SP, 1
	le A, B
	mov B, A
	ne B, 0
	.L12:
	mov A, B
	mov B, A
	ne B, 0
	.L10:
	mov A, B
	jeq .L13, A, 0
	.loc 1 22 0
	#         }
	mov A, 0
	mov D, SP
	add D, -1
	store A, D
	mov SP, D
	mov A, 13
	mov B, A
	load A, SP
	add SP, 1
	sub A, B
	mov B, offset
	store A, B
	.L13:
	.L9:
	.loc 1 24 0
	#     }
	mov B, c
	load A, B
	mov D, SP
	add D, -1
	store A, D
	mov SP, D
	mov B, offset
	load A, B
	mov B, A
	load A, SP
	add SP, 1
	add A, B
	mov D, SP
	add D, -1
	store A, D
	mov SP, D
	putc A
	add SP, 1
	.L1:
	jmp .L0
	.L2:
	.loc 1 26 0
	# }
	mov A, 0
	mov B, A
	#{pop:main}
	exit
	#{pop:main}
	exit
