/*
 * Copyright (c) 2014, STMicroelectronics International N.V.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

#include <asm.S>
#include <arm32.h>
#include <arm32_macros.S>

/* Let platforms override this if needed */
.weak get_core_pos

FUNC get_core_pos , :
	read_mpidr r0
	/* Calculate CorePos = (ClusterId * 4) + CoreId */
	and	r1, r0, #MPIDR_CPU_MASK
	and	r0, r0, #MPIDR_CLUSTER_MASK
	add	r0, r1, r0, LSR #6
	bx	lr
END_FUNC get_core_pos

/* uint32_t read_usr_sp(void) */
FUNC read_usr_sp , :
	mrs	r1, cpsr
	cps     #CPSR_MODE_SYS
	mov     r0, sp
	msr	cpsr, r1
	bx	lr
END_FUNC read_usr_sp

/* uint32_t read_usr_lr(void) */
FUNC read_usr_lr , :
	mrs	r1, cpsr
	cps     #CPSR_MODE_SYS
	mov     r0, lr
	msr	cpsr, r1
	bx	lr
END_FUNC read_usr_lr
