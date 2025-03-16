/*
 * Copyright (C) 2023, Advanced Micro Devices, Inc. All rights reserved.
 * SPDX-License-Identifier: MIT
 */

#include "xparameters.h"
#include "xil_exception.h"
#include "xil_cache.h"
#include "xscugic.h"
#include "xipipsu.h"
#include "xipipsu_hw.h"

#define IPI_MSG_LEN_BYTES 32
#define IPI_MSG_LEN_WORDS (IPI_MSG_LEN_BYTES / sizeof(u32))

XScuGic GicInst;
XIpiPsu IpiInst;

void IpiIntrHandler(void *XIpiPsuPtr)
{
	XIpiPsu *InstancePtr = (XIpiPsu *) XIpiPsuPtr;
	u32 IpiSrcMask = XIpiPsu_GetInterruptStatus(InstancePtr);
	u32 TmpBufPtr[IPI_MSG_LEN_WORDS] = {0};
	u32 SrcIndex;

#ifdef DEBUG
	xil_printf("R5: enter IPI interrupt handler.\r\n");
#endif

	/* Poll for each source */
	for (SrcIndex = 0U; SrcIndex < InstancePtr->Config.TargetCount;   SrcIndex++) {

		if (IpiSrcMask & InstancePtr->Config.TargetList[SrcIndex].Mask) {

			/*  Read Incoming Message Buffer Corresponding to Source CPU */
			XIpiPsu_ReadMessage(InstancePtr, InstancePtr->Config.TargetList[SrcIndex].Mask,
					    TmpBufPtr, IPI_MSG_LEN_WORDS, XIPIPSU_BUF_TYPE_MSG);

#ifdef DEBUG
			xil_printf("R5: message received.\r\n");

			for (int i = 0; i < IPI_MSG_LEN_WORDS; i++) {
				xil_printf("R5: W%d: 0x%08x\r\n", i, TmpBufPtr[i]);
			}
#endif

			/* Send Response (in request buffer) */
			XIpiPsu_WriteMessage(InstancePtr, IpiSrcMask, TmpBufPtr, IPI_MSG_LEN_WORDS, XIPIPSU_BUF_TYPE_MSG);

			/* Trig IPI irq */
			XIpiPsu_TriggerIpi(InstancePtr, IpiSrcMask);

 			/* Clear the Interrupt Status - This clears the OBS bit on the SRC CPU registers */
			XIpiPsu_ClearInterruptStatus(InstancePtr, InstancePtr->Config.TargetList[SrcIndex].Mask);
		}
	}

#ifdef DEBUG
	xil_printf("R5: exit IPI interrupt handler.\r\n");
#endif
}

int main() {
	/* Wait for pretty printing after FSBL */
    	usleep(100);

	/* Initialize the IPI driver */
	XIpiPsu_Config * CfgPtr = XIpiPsu_LookupConfig(XPAR_XIPIPSU_0_DEVICE_ID);
	XIpiPsu_CfgInitialize(&IpiInst, CfgPtr, CfgPtr->BaseAddress);

	/* Initialize the interrupt controller driver */
	XScuGic_Config *IntcConfig = XScuGic_LookupConfig(XPAR_SCUGIC_0_DEVICE_ID);
	XScuGic_CfgInitialize(&GicInst, IntcConfig, IntcConfig->CpuBaseAddress);

	/*
	 * Connect the interrupt controller interrupt handler to the
	 * hardware interrupt handling logic in the processor.
	 */
	Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT, (Xil_ExceptionHandler) XScuGic_InterruptHandler, &GicInst);
	XScuGic_Connect(&GicInst, IpiInst.Config.IntId, (Xil_InterruptHandler) IpiIntrHandler, (void *) &IpiInst);

	/* Enable the interrupt for the device */
	XScuGic_Enable(&GicInst, IpiInst.Config.IntId);

	/* Enable reception of IPIs from all CPUs */
	XIpiPsu_InterruptEnable(&IpiInst, XIPIPSU_ALL_MASK);
	XIpiPsu_ClearInterruptStatus(&IpiInst, XIPIPSU_ALL_MASK);

	/* Enable interrupts */
	Xil_ExceptionEnable();

	xil_printf("R5: echo started.\r\n");

	while(1) {
		/* wait for interrupt */
		__asm("wfi");
	}

	/* Control never reaches here */
    	return 0;
}
