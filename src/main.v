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
	for t in tokens {
		match t {
			.ptr_right {
				println("subq $4,%rsp")
			}
			.ptr_left {
				println("addq $4,%rsp")
			}
			.inc_cell {
				println("addq $1,(%rsp)")
			}
			.dec_cell {
				println("subq $1,(%rsp)")
			}
			else {}
		}
	}
}

fn main () {
	bytes := os.read_bytes('hello.bf') or {
		panic(err.msg)
	}

	mut toksic := []Token{}
	for b in bytes {
		if t := byte_to_token(b) {
			toksic << t
		}
	}

	compile(toksic)
}
