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

#include <tee_syscall_numbers.h>

        .section .text
        .balign 4
        .code 32

        .macro UTEE_SYSCALL name, scn, num_args
        .global \name
        .func \name
        \name:

        push    {r5-r7,lr}
        mov     r7, #(\scn)
	.if \num_args > TEE_SVC_MAX_ARGS
	.error "Too many arguments for syscall"
	.endif
        .if \num_args <= 4
        @ No arguments passed on stack
        mov     r6, #0
        .else
        @ Tell number of arguments passed on the stack
        mov     r6, #(\num_args - 4)
        @ Point just before the push (4 registers) above on the first argument
        add     r5, sp, #(4 * 4)
        .endif
        svc #0
        pop     {r5-r7,pc}
        .endfunc
        .endm

        UTEE_SYSCALL utee_return, TEE_SCN_RETURN, 1

        UTEE_SYSCALL utee_log, TEE_SCN_LOG, 2

        UTEE_SYSCALL utee_panic, TEE_SCN_PANIC, 1

        UTEE_SYSCALL utee_dummy, TEE_SCN_DUMMY, 1

        UTEE_SYSCALL utee_dummy_7args, TEE_SCN_DUMMY_7ARGS, 7

        UTEE_SYSCALL utee_nocall, TEE_SCN_MAX + 1, 0

        UTEE_SYSCALL utee_get_property, TEE_SCN_GET_PROPERTY, 3

        UTEE_SYSCALL utee_open_ta_session, TEE_SCN_OPEN_TA_SESSION, 6

        UTEE_SYSCALL utee_close_ta_session, TEE_SCN_CLOSE_TA_SESSION, 1

        UTEE_SYSCALL utee_invoke_ta_command, TEE_SCN_INVOKE_TA_COMMAND, 6
        
        UTEE_SYSCALL utee_get_cancellation_flag, \
                     TEE_SCN_GET_CANCELLATION_FLAG, 0

        UTEE_SYSCALL utee_check_access_rights, TEE_SCN_CHECK_ACCESS_RIGHTS, 3

        UTEE_SYSCALL utee_unmask_cancellation, TEE_SCN_UNMASK_CANCELLATION, 0

        UTEE_SYSCALL utee_mask_cancellation, TEE_SCN_MASK_CANCELLATION, 0

        UTEE_SYSCALL utee_wait, TEE_SCN_WAIT, 1

        UTEE_SYSCALL utee_get_time, TEE_SCN_GET_TIME, 2

        UTEE_SYSCALL utee_set_ta_time, TEE_SCN_SET_TA_TIME, 1

        UTEE_SYSCALL utee_cryp_state_alloc, TEE_SCN_CRYP_STATE_ALLOC, 5

        UTEE_SYSCALL utee_cryp_state_copy, TEE_SCN_CRYP_STATE_COPY, 2

        UTEE_SYSCALL utee_cryp_state_free, TEE_SCN_CRYP_STATE_FREE, 1

        UTEE_SYSCALL utee_hash_init, TEE_SCN_HASH_INIT, 3

        UTEE_SYSCALL utee_hash_update, TEE_SCN_HASH_UPDATE, 3

        UTEE_SYSCALL utee_hash_final, TEE_SCN_HASH_FINAL, 5

        UTEE_SYSCALL utee_cipher_init, TEE_SCN_CIPHER_INIT, 3

        UTEE_SYSCALL utee_cipher_update, TEE_SCN_CIPHER_UPDATE, 5

        UTEE_SYSCALL utee_cipher_final, TEE_SCN_CIPHER_FINAL, 5

        UTEE_SYSCALL utee_cryp_obj_get_info, TEE_SCN_CRYP_OBJ_GET_INFO, 2

        UTEE_SYSCALL utee_cryp_obj_restrict_usage, \
                     TEE_SCN_CRYP_OBJ_RESTRICT_USAGE, 2

        UTEE_SYSCALL utee_cryp_obj_get_attr, TEE_SCN_CRYP_OBJ_GET_ATTR, 4

        UTEE_SYSCALL utee_cryp_obj_alloc, TEE_SCN_CRYP_OBJ_ALLOC, 3

        UTEE_SYSCALL utee_cryp_obj_close, TEE_SCN_CRYP_OBJ_CLOSE, 1

        UTEE_SYSCALL utee_cryp_obj_reset, TEE_SCN_CRYP_OBJ_RESET,  1

        UTEE_SYSCALL utee_cryp_obj_populate, TEE_SCN_CRYP_OBJ_POPULATE, 3

        UTEE_SYSCALL utee_cryp_obj_copy, TEE_SCN_CRYP_OBJ_COPY, 2

        UTEE_SYSCALL utee_cryp_derive_key, TEE_SCN_CRYP_DERIVE_KEY, 4

        UTEE_SYSCALL utee_cryp_random_number_generate, \
                     TEE_SCN_CRYP_RANDOM_NUMBER_GENERATE, 2

        UTEE_SYSCALL utee_authenc_init, TEE_SCN_AUTHENC_INIT, 6

        UTEE_SYSCALL utee_authenc_update_aad, TEE_SCN_AUTHENC_UPDATE_AAD, 3

        UTEE_SYSCALL utee_authenc_update_payload, \
                     TEE_SCN_AUTHENC_UPDATE_PAYLOAD, 5

        UTEE_SYSCALL utee_authenc_enc_final, TEE_SCN_AUTHENC_ENC_FINAL, 7

        UTEE_SYSCALL utee_authenc_dec_final, TEE_SCN_AUTHENC_DEC_FINAL, 7

        UTEE_SYSCALL utee_asymm_operate, TEE_SCN_ASYMM_OPERATE, 7

        UTEE_SYSCALL utee_asymm_verify, TEE_SCN_ASYMM_VERIFY, 7

        UTEE_SYSCALL utee_storage_obj_open, TEE_SCN_STORAGE_OBJ_OPEN, 5

        UTEE_SYSCALL utee_storage_obj_create, TEE_SCN_STORAGE_OBJ_CREATE, 8

        UTEE_SYSCALL utee_storage_obj_del, TEE_SCN_STORAGE_OBJ_DEL, 1

        UTEE_SYSCALL utee_storage_obj_rename, TEE_SCN_STORAGE_OBJ_RENAME, 3

        UTEE_SYSCALL utee_storage_alloc_enum, TEE_SCN_STORAGE_ENUM_ALLOC, 1

        UTEE_SYSCALL utee_storage_free_enum, TEE_SCN_STORAGE_ENUM_FREE, 1

        UTEE_SYSCALL utee_storage_reset_enum, TEE_SCN_STORAGE_ENUM_RESET, 1

        UTEE_SYSCALL utee_storage_start_enum, TEE_SCN_STORAGE_ENUM_START, 2

        UTEE_SYSCALL utee_storage_next_enum, TEE_SCN_STORAGE_ENUM_NEXT, 4

        UTEE_SYSCALL utee_storage_obj_read, TEE_SCN_STORAGE_OBJ_READ, 4

        UTEE_SYSCALL utee_storage_obj_write, TEE_SCN_STORAGE_OBJ_WRITE, 3

        UTEE_SYSCALL utee_storage_obj_trunc, TEE_SCN_STORAGE_OBJ_TRUNC, 2

        UTEE_SYSCALL utee_storage_obj_seek, TEE_SCN_STORAGE_OBJ_SEEK, 3

        UTEE_SYSCALL utee_cryp_obj_generate_key, \
                     TEE_SCN_CRYP_OBJ_GENERATE_KEY, 4
