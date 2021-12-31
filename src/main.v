import os

// > - move the pointer right
// < - move the pointer left
// + - increment the current cell
// - - decrement the current cell

// . - output the value of the current cell
// , - replace the value of the current cell with input
// [ - jump to the matching ] instruction if the current value is zero
// ] - jump to the matching [ instruction if the current value is not zero

// >
// subq $4,%rsp
// <
// addq $4,%rsp

// +
// addq $1,(%rsp)
// -
// addq $1,(%rsp)

// [[]]
// // [
// cmp $0,(%rsp)
// je l1_end
// l1_begin:
// // [
// cmp $0,(%rsp)
// je l2_end
// l2_begin:
// // ]
// cmp $0,(%rsp)
// je l2_begin
// l2_end
// // ]
// cmp $0,(%rsp)
// je l1_begin
// l1_end






enum Token {
    ptr_right
    ptr_left
    inc_cell
	dec_cell
	output_cell
	input_cell
	jump_to_close
	jump_to_open
}

fn byte_to_token(b byte) ?Token {
	return match b {
		byte(`>`) { Token.ptr_right }
		byte(`<`) { Token.ptr_left }
		byte(`+`) { Token.inc_cell }
		byte(`-`) { Token.dec_cell }
		byte(`.`) { Token.output_cell }
		byte(`,`) { Token.input_cell }
		byte(`[`) { Token.jump_to_close }
		byte(`]`) { Token.jump_to_open }
		else { none }
	}
}

fn compile(tokens []Token) {
	mut jump_stack_count := 0
	mut jump_stack_id := 0
	mut jump_stack := []int{}

	for t in tokens {
		match t {
			.jump_to_close {
				println("# Open brace")
				println("cmpq $0,(%rbp)")
				println("je l${jump_stack_id}_end")
				println("l${jump_stack_id}_begin:")

				jump_stack << jump_stack_id

				jump_stack_id += 1
				jump_stack_count += 1
			}
			.jump_to_open {
				matching_id := jump_stack.pop()
				if jump_stack_count < 0 {
					panic("Too many close brackets")
				}
                println("# Close brace")
                println("cmpq $0,(%rbp)")
                println("jne l${matching_id}_begin")
				println("l${matching_id}_end:")
				jump_stack_count -= 1
			}
			.ptr_right {
				println("# ptr right")
				println("subq $8,%rbp")
                println("cmpq %rsp,%rbp")
                println("jl 1f")
                println("movq $0,(%rbp)")
                println("movq %rbp,%rsp")
                println("1:")
			}
			.ptr_left {
				println("# ptr left")
                println("addq $8,%rbp")
				println("cmpq %rbx,%rbp")
				println("jle 1f")
				println("movq $42,%rdi")
				println("movq $60,%rax")
				println("syscall")
				println("1:")
			}
			.inc_cell {
				println("# inc cell")
				println("addq $1,(%rbp)")
			}
			.dec_cell {
				println("# dec cell")
				println("subq $1,(%rbp)")
			}
			.output_cell {
				println("# output cell")
				println("movq $1,%rax")
				println("movq $1,%rdx")
				println("movq $1,%rdi")
				println("leaq (%rbp),%rsi")
				println("syscall")
			}
			else {}
		}
	}
	if jump_stack_count > 0 {
		panic("Missing close brace")
	}
}

fn main () {
	if os.args.len < 2 {
		panic("At the disco")
	}
	bytes := os.read_bytes(os.args[1]) or {
		panic(err.msg)
	}
    println(".text")
    println(".global _start")
    println("_start:")
    println("movq %rsp,%rbp")
    println("movq %rsp,%rbx")
    println("movq $0,(%rsp)")

	mut toksic := []Token{}
	for b in bytes {
		if t := byte_to_token(b) {
			//println("t)
			toksic << t
		}
	}
	compile(toksic)

	println("# exit status")
    println("movq (%rbp),%rdi")
    println("movq $60,%rax")
    println("syscall")
}
