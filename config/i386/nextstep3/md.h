/*
 * i386/nextstep3/md.h
 * NEXTSTEP i386 configuration information.
 *
 * Copyright (c) 1996, 1997
 *	Transvirtual Technologies, Inc.  All rights reserved.
 *
 * See the file "license.terms" for information on usage and redistribution 
 * of this file. 
 */

#ifndef __i386_nextstep3_md_h
#define __i386_nextstep3_md_h

#include "i386/common.h"
#include "i386/threads.h"

/*
 * Redefine stack pointer offset.
 */
#undef	SP_OFFSET
#define	SP_OFFSET	9

/* Function prototype for signal handlers */
#define	SIGNAL_ARGS(sig, sc) int sig, int code, struct sigcontext* sc
#define SIGNAL_CONTEXT_POINTER(scp) struct sigcontext* scp
#define GET_SIGNAL_CONTEXT_POINTER(scp) (scp)
#define SIGNAL_PC(scp) ((scp)->sc_eip)

#if defined(TRANSLATOR)
#include "jit-md.h"
#endif

#endif
