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

#include <io.h>
#include <kernel/tee_common_unpg.h>
#include <kernel/tee_time.h>
#include <kernel/tee_time_unpg.h>
#include <kernel/time_source.h>
#include <kernel/tee_core_trace.h>
#include <utee_defines.h>

#define TEE_TIME_SHIFT 5

#define TEE_RTT0_HZ                 32768UL

#define TEE_RTT0_TICKS_PER_SECOND   (TEE_RTT0_HZ)
#define TEE_RTT0_TICKS_PER_MINUTE   (TEE_RTT0_TICKS_PER_SECOND * 60)
#define TEE_RTT0_TICKS_PER_HOUR     (TEE_RTT0_TICKS_PER_MINUTE * 60)

/* We'll receive one interrupt per hour */
#define TEE_RTT0_WRAP_TICKS         TEE_RTT0_TICKS_PER_HOUR

#define TEE_RTT1_HZ                 10UL
#define TEE_RTT1_WRAP_TICKS         0xffffffff

/*
 * Following is code example that could be used to activate time
 * functionalities in TEE for arm32
 *
TEE_Result tee_time_init(void)
{
	- Disable timer and later change to 32kHz
	IO(RTT0_CR) &= ~RTT_CR_EN;

	if (!(IO(RTT1_CR) & RTT_CR_EN)) {
		IO(RTT1_IMSC) |= RTT_IMSC_IMSC;	        - disable interrupts
		IO(RTT1_LR) = TEE_RTT1_WRAP_TICKS;	- start the timer

		TEE_COMPILE_TIME_ASSERT(TEE_RTT1_HZ == TEE_TIME_BOOT_TICKS_HZ);
	}

	return TEE_SUCCESS;
}

uint32_t tee_time_get_boot_ticks(void)
{
	return TEE_RTT1_WRAP_TICKS - IO(RTT1_DR);
}

uint32_t tee_time_get_boot_time_in_seconds(void)
{
	return tee_time_get_boot_ticks() / TEE_RTT1_HZ;
}
*/

static void tee_time_rtt0_init(void)
{
	static bool inited; /* initialized to false */

	if (!inited) {
		volatile uint32_t *cr = (uint32_t *)RTT0_CR;
		volatile uint32_t *ctcr = (uint32_t *)RTT0_CTCR;
		volatile uint32_t *lr = (uint32_t *)RTT0_LR;
		volatile uint32_t *imsc = (uint32_t *)RTT0_IMSC;

		DMSG("tee_time_rtt0_init: First call may take a few secs");

		/*
		 * Make sure timer is disabled. RTT_CR_EN is not accurate,
		 * enabling can be in progress too. Checking *ctcr takes
		 * care of that since updates to ctcr only propagates once
		 * timer really is disabled.
		 */
		while (*ctcr != 0 || (*cr & (RTT_CR_EN | RTT_CR_ENS)) != 0) {
			*cr &= ~RTT_CR_EN;
			*ctcr = 0;
		}

		/* Change to 32kHz */
		*ctcr = 0;

		/* Enable interrupts on wrap */
		*imsc |= RTT_IMSC_IMSC;

		/* Start with the desired interrupt interval */
		*lr = TEE_RTT0_WRAP_TICKS;

		inited = true;
	}
}

/*
 * Following is code example that could be used to activate time
 * functionalities in TEE for arm32
 *
TEE_Result tee_time_stamp(uint32_t *stamp)
{
	tee_time_rtt0_init();

	*stamp = IO(RTT0_DR);

	return TEE_SUCCESS;
}

TEE_Result tee_time_get(uint32_t stamp, uint32_t *time)
{
	TEE_Result res;
	uint32_t val;

	res = tee_time_stamp(&val);
	if (res != TEE_SUCCESS)
		return res;

	*time = (stamp - val) >> TEE_TIME_SHIFT;

	return TEE_SUCCESS;
}

TEE_Result tee_time_secure_rtc_update(const void *time, uint32_t time_size)
{
	return TEE_SUCCESS;
}

TEE_Result tee_time_secure_rtc_update_check(bool *ok)
{
	*ok = true;
	return TEE_SUCCESS;
}
*/

static TEE_Result rtt_get_sys_time(TEE_Time *time)
{
	uint32_t wrap0;
	uint32_t wrap;
	uint32_t timer;

	tee_time_rtt0_init();

	/*
	 * Reading wrap before and after we're reading DR to be able to
	 * detect if the timer wrapped while we where reading it.
	 */
	do {
		wrap0 = tee_time_rtt0_wrap;
		timer = TEE_RTT0_WRAP_TICKS - IO(RTT0_DR);
		wrap = tee_time_rtt0_wrap;
	} while (wrap0 != wrap);

	time->seconds = wrap * TEE_RTT0_WRAP_TICKS / TEE_RTT0_HZ +
	    timer / TEE_RTT0_HZ;
	time->millis =
	    (timer % TEE_RTT0_HZ) / (TEE_RTT0_HZ / TEE_TIME_MILLIS_BASE);

	return TEE_SUCCESS;
}

static const struct time_source rtt_time_source = {
	.name = "rtt0",
	.get_sys_time = rtt_get_sys_time,
};

REGISTER_TIME_SOURCE(rtt_time_source)
