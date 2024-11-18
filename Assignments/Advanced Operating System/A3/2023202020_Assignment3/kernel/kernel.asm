
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	ae813103          	ld	sp,-1304(sp) # 80008ae8 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	076000ef          	jal	ra,8000008c <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000026:	0007859b          	sext.w	a1,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	slliw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873703          	ld	a4,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	9732                	add	a4,a4,a2
    80000046:	e398                	sd	a4,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00259693          	slli	a3,a1,0x2
    8000004c:	96ae                	add	a3,a3,a1
    8000004e:	068e                	slli	a3,a3,0x3
    80000050:	00009717          	auipc	a4,0x9
    80000054:	af070713          	addi	a4,a4,-1296 # 80008b40 <timer_scratch>
    80000058:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005a:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005c:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    8000005e:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000062:	00006797          	auipc	a5,0x6
    80000066:	fce78793          	addi	a5,a5,-50 # 80006030 <timervec>
    8000006a:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000006e:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000072:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000076:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007a:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    8000007e:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000082:	30479073          	csrw	mie,a5
}
    80000086:	6422                	ld	s0,8(sp)
    80000088:	0141                	addi	sp,sp,16
    8000008a:	8082                	ret

000000008000008c <start>:
{
    8000008c:	1141                	addi	sp,sp,-16
    8000008e:	e406                	sd	ra,8(sp)
    80000090:	e022                	sd	s0,0(sp)
    80000092:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000094:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000098:	7779                	lui	a4,0xffffe
    8000009a:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdc04f>
    8000009e:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a0:	6705                	lui	a4,0x1
    800000a2:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a8:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ac:	00001797          	auipc	a5,0x1
    800000b0:	dcc78793          	addi	a5,a5,-564 # 80000e78 <main>
    800000b4:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000b8:	4781                	li	a5,0
    800000ba:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000be:	67c1                	lui	a5,0x10
    800000c0:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    800000c2:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c6:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000ca:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000ce:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d2:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000d6:	57fd                	li	a5,-1
    800000d8:	83a9                	srli	a5,a5,0xa
    800000da:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000de:	47bd                	li	a5,15
    800000e0:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e4:	00000097          	auipc	ra,0x0
    800000e8:	f38080e7          	jalr	-200(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000ec:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000f0:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000f2:	823e                	mv	tp,a5
  asm volatile("mret");
    800000f4:	30200073          	mret
}
    800000f8:	60a2                	ld	ra,8(sp)
    800000fa:	6402                	ld	s0,0(sp)
    800000fc:	0141                	addi	sp,sp,16
    800000fe:	8082                	ret

0000000080000100 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80000100:	715d                	addi	sp,sp,-80
    80000102:	e486                	sd	ra,72(sp)
    80000104:	e0a2                	sd	s0,64(sp)
    80000106:	fc26                	sd	s1,56(sp)
    80000108:	f84a                	sd	s2,48(sp)
    8000010a:	f44e                	sd	s3,40(sp)
    8000010c:	f052                	sd	s4,32(sp)
    8000010e:	ec56                	sd	s5,24(sp)
    80000110:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80000112:	04c05763          	blez	a2,80000160 <consolewrite+0x60>
    80000116:	8a2a                	mv	s4,a0
    80000118:	84ae                	mv	s1,a1
    8000011a:	89b2                	mv	s3,a2
    8000011c:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    8000011e:	5afd                	li	s5,-1
    80000120:	4685                	li	a3,1
    80000122:	8626                	mv	a2,s1
    80000124:	85d2                	mv	a1,s4
    80000126:	fbf40513          	addi	a0,s0,-65
    8000012a:	00002097          	auipc	ra,0x2
    8000012e:	5bc080e7          	jalr	1468(ra) # 800026e6 <either_copyin>
    80000132:	01550d63          	beq	a0,s5,8000014c <consolewrite+0x4c>
      break;
    uartputc(c);
    80000136:	fbf44503          	lbu	a0,-65(s0)
    8000013a:	00000097          	auipc	ra,0x0
    8000013e:	784080e7          	jalr	1924(ra) # 800008be <uartputc>
  for(i = 0; i < n; i++){
    80000142:	2905                	addiw	s2,s2,1
    80000144:	0485                	addi	s1,s1,1
    80000146:	fd299de3          	bne	s3,s2,80000120 <consolewrite+0x20>
    8000014a:	894e                	mv	s2,s3
  }

  return i;
}
    8000014c:	854a                	mv	a0,s2
    8000014e:	60a6                	ld	ra,72(sp)
    80000150:	6406                	ld	s0,64(sp)
    80000152:	74e2                	ld	s1,56(sp)
    80000154:	7942                	ld	s2,48(sp)
    80000156:	79a2                	ld	s3,40(sp)
    80000158:	7a02                	ld	s4,32(sp)
    8000015a:	6ae2                	ld	s5,24(sp)
    8000015c:	6161                	addi	sp,sp,80
    8000015e:	8082                	ret
  for(i = 0; i < n; i++){
    80000160:	4901                	li	s2,0
    80000162:	b7ed                	j	8000014c <consolewrite+0x4c>

0000000080000164 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000164:	7159                	addi	sp,sp,-112
    80000166:	f486                	sd	ra,104(sp)
    80000168:	f0a2                	sd	s0,96(sp)
    8000016a:	eca6                	sd	s1,88(sp)
    8000016c:	e8ca                	sd	s2,80(sp)
    8000016e:	e4ce                	sd	s3,72(sp)
    80000170:	e0d2                	sd	s4,64(sp)
    80000172:	fc56                	sd	s5,56(sp)
    80000174:	f85a                	sd	s6,48(sp)
    80000176:	f45e                	sd	s7,40(sp)
    80000178:	f062                	sd	s8,32(sp)
    8000017a:	ec66                	sd	s9,24(sp)
    8000017c:	e86a                	sd	s10,16(sp)
    8000017e:	1880                	addi	s0,sp,112
    80000180:	8aaa                	mv	s5,a0
    80000182:	8a2e                	mv	s4,a1
    80000184:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000186:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    8000018a:	00011517          	auipc	a0,0x11
    8000018e:	af650513          	addi	a0,a0,-1290 # 80010c80 <cons>
    80000192:	00001097          	auipc	ra,0x1
    80000196:	a44080e7          	jalr	-1468(ra) # 80000bd6 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019a:	00011497          	auipc	s1,0x11
    8000019e:	ae648493          	addi	s1,s1,-1306 # 80010c80 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a2:	00011917          	auipc	s2,0x11
    800001a6:	b7690913          	addi	s2,s2,-1162 # 80010d18 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];

    if(c == C('D')){  // end-of-file
    800001aa:	4b91                	li	s7,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001ac:	5c7d                	li	s8,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    800001ae:	4ca9                	li	s9,10
  while(n > 0){
    800001b0:	07305b63          	blez	s3,80000226 <consoleread+0xc2>
    while(cons.r == cons.w){
    800001b4:	0984a783          	lw	a5,152(s1)
    800001b8:	09c4a703          	lw	a4,156(s1)
    800001bc:	02f71763          	bne	a4,a5,800001ea <consoleread+0x86>
      if(killed(myproc())){
    800001c0:	00001097          	auipc	ra,0x1
    800001c4:	7ec080e7          	jalr	2028(ra) # 800019ac <myproc>
    800001c8:	00002097          	auipc	ra,0x2
    800001cc:	368080e7          	jalr	872(ra) # 80002530 <killed>
    800001d0:	e535                	bnez	a0,8000023c <consoleread+0xd8>
      sleep(&cons.r, &cons.lock);
    800001d2:	85a6                	mv	a1,s1
    800001d4:	854a                	mv	a0,s2
    800001d6:	00002097          	auipc	ra,0x2
    800001da:	f5a080e7          	jalr	-166(ra) # 80002130 <sleep>
    while(cons.r == cons.w){
    800001de:	0984a783          	lw	a5,152(s1)
    800001e2:	09c4a703          	lw	a4,156(s1)
    800001e6:	fcf70de3          	beq	a4,a5,800001c0 <consoleread+0x5c>
    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001ea:	0017871b          	addiw	a4,a5,1
    800001ee:	08e4ac23          	sw	a4,152(s1)
    800001f2:	07f7f713          	andi	a4,a5,127
    800001f6:	9726                	add	a4,a4,s1
    800001f8:	01874703          	lbu	a4,24(a4)
    800001fc:	00070d1b          	sext.w	s10,a4
    if(c == C('D')){  // end-of-file
    80000200:	077d0563          	beq	s10,s7,8000026a <consoleread+0x106>
    cbuf = c;
    80000204:	f8e40fa3          	sb	a4,-97(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000208:	4685                	li	a3,1
    8000020a:	f9f40613          	addi	a2,s0,-97
    8000020e:	85d2                	mv	a1,s4
    80000210:	8556                	mv	a0,s5
    80000212:	00002097          	auipc	ra,0x2
    80000216:	47e080e7          	jalr	1150(ra) # 80002690 <either_copyout>
    8000021a:	01850663          	beq	a0,s8,80000226 <consoleread+0xc2>
    dst++;
    8000021e:	0a05                	addi	s4,s4,1
    --n;
    80000220:	39fd                	addiw	s3,s3,-1
    if(c == '\n'){
    80000222:	f99d17e3          	bne	s10,s9,800001b0 <consoleread+0x4c>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80000226:	00011517          	auipc	a0,0x11
    8000022a:	a5a50513          	addi	a0,a0,-1446 # 80010c80 <cons>
    8000022e:	00001097          	auipc	ra,0x1
    80000232:	a5c080e7          	jalr	-1444(ra) # 80000c8a <release>

  return target - n;
    80000236:	413b053b          	subw	a0,s6,s3
    8000023a:	a811                	j	8000024e <consoleread+0xea>
        release(&cons.lock);
    8000023c:	00011517          	auipc	a0,0x11
    80000240:	a4450513          	addi	a0,a0,-1468 # 80010c80 <cons>
    80000244:	00001097          	auipc	ra,0x1
    80000248:	a46080e7          	jalr	-1466(ra) # 80000c8a <release>
        return -1;
    8000024c:	557d                	li	a0,-1
}
    8000024e:	70a6                	ld	ra,104(sp)
    80000250:	7406                	ld	s0,96(sp)
    80000252:	64e6                	ld	s1,88(sp)
    80000254:	6946                	ld	s2,80(sp)
    80000256:	69a6                	ld	s3,72(sp)
    80000258:	6a06                	ld	s4,64(sp)
    8000025a:	7ae2                	ld	s5,56(sp)
    8000025c:	7b42                	ld	s6,48(sp)
    8000025e:	7ba2                	ld	s7,40(sp)
    80000260:	7c02                	ld	s8,32(sp)
    80000262:	6ce2                	ld	s9,24(sp)
    80000264:	6d42                	ld	s10,16(sp)
    80000266:	6165                	addi	sp,sp,112
    80000268:	8082                	ret
      if(n < target){
    8000026a:	0009871b          	sext.w	a4,s3
    8000026e:	fb677ce3          	bgeu	a4,s6,80000226 <consoleread+0xc2>
        cons.r--;
    80000272:	00011717          	auipc	a4,0x11
    80000276:	aaf72323          	sw	a5,-1370(a4) # 80010d18 <cons+0x98>
    8000027a:	b775                	j	80000226 <consoleread+0xc2>

000000008000027c <consputc>:
{
    8000027c:	1141                	addi	sp,sp,-16
    8000027e:	e406                	sd	ra,8(sp)
    80000280:	e022                	sd	s0,0(sp)
    80000282:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000284:	10000793          	li	a5,256
    80000288:	00f50a63          	beq	a0,a5,8000029c <consputc+0x20>
    uartputc_sync(c);
    8000028c:	00000097          	auipc	ra,0x0
    80000290:	560080e7          	jalr	1376(ra) # 800007ec <uartputc_sync>
}
    80000294:	60a2                	ld	ra,8(sp)
    80000296:	6402                	ld	s0,0(sp)
    80000298:	0141                	addi	sp,sp,16
    8000029a:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    8000029c:	4521                	li	a0,8
    8000029e:	00000097          	auipc	ra,0x0
    800002a2:	54e080e7          	jalr	1358(ra) # 800007ec <uartputc_sync>
    800002a6:	02000513          	li	a0,32
    800002aa:	00000097          	auipc	ra,0x0
    800002ae:	542080e7          	jalr	1346(ra) # 800007ec <uartputc_sync>
    800002b2:	4521                	li	a0,8
    800002b4:	00000097          	auipc	ra,0x0
    800002b8:	538080e7          	jalr	1336(ra) # 800007ec <uartputc_sync>
    800002bc:	bfe1                	j	80000294 <consputc+0x18>

00000000800002be <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002be:	1101                	addi	sp,sp,-32
    800002c0:	ec06                	sd	ra,24(sp)
    800002c2:	e822                	sd	s0,16(sp)
    800002c4:	e426                	sd	s1,8(sp)
    800002c6:	e04a                	sd	s2,0(sp)
    800002c8:	1000                	addi	s0,sp,32
    800002ca:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002cc:	00011517          	auipc	a0,0x11
    800002d0:	9b450513          	addi	a0,a0,-1612 # 80010c80 <cons>
    800002d4:	00001097          	auipc	ra,0x1
    800002d8:	902080e7          	jalr	-1790(ra) # 80000bd6 <acquire>

  switch(c){
    800002dc:	47d5                	li	a5,21
    800002de:	0af48663          	beq	s1,a5,8000038a <consoleintr+0xcc>
    800002e2:	0297ca63          	blt	a5,s1,80000316 <consoleintr+0x58>
    800002e6:	47a1                	li	a5,8
    800002e8:	0ef48763          	beq	s1,a5,800003d6 <consoleintr+0x118>
    800002ec:	47c1                	li	a5,16
    800002ee:	10f49a63          	bne	s1,a5,80000402 <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002f2:	00002097          	auipc	ra,0x2
    800002f6:	44a080e7          	jalr	1098(ra) # 8000273c <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002fa:	00011517          	auipc	a0,0x11
    800002fe:	98650513          	addi	a0,a0,-1658 # 80010c80 <cons>
    80000302:	00001097          	auipc	ra,0x1
    80000306:	988080e7          	jalr	-1656(ra) # 80000c8a <release>
}
    8000030a:	60e2                	ld	ra,24(sp)
    8000030c:	6442                	ld	s0,16(sp)
    8000030e:	64a2                	ld	s1,8(sp)
    80000310:	6902                	ld	s2,0(sp)
    80000312:	6105                	addi	sp,sp,32
    80000314:	8082                	ret
  switch(c){
    80000316:	07f00793          	li	a5,127
    8000031a:	0af48e63          	beq	s1,a5,800003d6 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    8000031e:	00011717          	auipc	a4,0x11
    80000322:	96270713          	addi	a4,a4,-1694 # 80010c80 <cons>
    80000326:	0a072783          	lw	a5,160(a4)
    8000032a:	09872703          	lw	a4,152(a4)
    8000032e:	9f99                	subw	a5,a5,a4
    80000330:	07f00713          	li	a4,127
    80000334:	fcf763e3          	bltu	a4,a5,800002fa <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80000338:	47b5                	li	a5,13
    8000033a:	0cf48763          	beq	s1,a5,80000408 <consoleintr+0x14a>
      consputc(c);
    8000033e:	8526                	mv	a0,s1
    80000340:	00000097          	auipc	ra,0x0
    80000344:	f3c080e7          	jalr	-196(ra) # 8000027c <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000348:	00011797          	auipc	a5,0x11
    8000034c:	93878793          	addi	a5,a5,-1736 # 80010c80 <cons>
    80000350:	0a07a683          	lw	a3,160(a5)
    80000354:	0016871b          	addiw	a4,a3,1
    80000358:	0007061b          	sext.w	a2,a4
    8000035c:	0ae7a023          	sw	a4,160(a5)
    80000360:	07f6f693          	andi	a3,a3,127
    80000364:	97b6                	add	a5,a5,a3
    80000366:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    8000036a:	47a9                	li	a5,10
    8000036c:	0cf48563          	beq	s1,a5,80000436 <consoleintr+0x178>
    80000370:	4791                	li	a5,4
    80000372:	0cf48263          	beq	s1,a5,80000436 <consoleintr+0x178>
    80000376:	00011797          	auipc	a5,0x11
    8000037a:	9a27a783          	lw	a5,-1630(a5) # 80010d18 <cons+0x98>
    8000037e:	9f1d                	subw	a4,a4,a5
    80000380:	08000793          	li	a5,128
    80000384:	f6f71be3          	bne	a4,a5,800002fa <consoleintr+0x3c>
    80000388:	a07d                	j	80000436 <consoleintr+0x178>
    while(cons.e != cons.w &&
    8000038a:	00011717          	auipc	a4,0x11
    8000038e:	8f670713          	addi	a4,a4,-1802 # 80010c80 <cons>
    80000392:	0a072783          	lw	a5,160(a4)
    80000396:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000039a:	00011497          	auipc	s1,0x11
    8000039e:	8e648493          	addi	s1,s1,-1818 # 80010c80 <cons>
    while(cons.e != cons.w &&
    800003a2:	4929                	li	s2,10
    800003a4:	f4f70be3          	beq	a4,a5,800002fa <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003a8:	37fd                	addiw	a5,a5,-1
    800003aa:	07f7f713          	andi	a4,a5,127
    800003ae:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003b0:	01874703          	lbu	a4,24(a4)
    800003b4:	f52703e3          	beq	a4,s2,800002fa <consoleintr+0x3c>
      cons.e--;
    800003b8:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003bc:	10000513          	li	a0,256
    800003c0:	00000097          	auipc	ra,0x0
    800003c4:	ebc080e7          	jalr	-324(ra) # 8000027c <consputc>
    while(cons.e != cons.w &&
    800003c8:	0a04a783          	lw	a5,160(s1)
    800003cc:	09c4a703          	lw	a4,156(s1)
    800003d0:	fcf71ce3          	bne	a4,a5,800003a8 <consoleintr+0xea>
    800003d4:	b71d                	j	800002fa <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003d6:	00011717          	auipc	a4,0x11
    800003da:	8aa70713          	addi	a4,a4,-1878 # 80010c80 <cons>
    800003de:	0a072783          	lw	a5,160(a4)
    800003e2:	09c72703          	lw	a4,156(a4)
    800003e6:	f0f70ae3          	beq	a4,a5,800002fa <consoleintr+0x3c>
      cons.e--;
    800003ea:	37fd                	addiw	a5,a5,-1
    800003ec:	00011717          	auipc	a4,0x11
    800003f0:	92f72a23          	sw	a5,-1740(a4) # 80010d20 <cons+0xa0>
      consputc(BACKSPACE);
    800003f4:	10000513          	li	a0,256
    800003f8:	00000097          	auipc	ra,0x0
    800003fc:	e84080e7          	jalr	-380(ra) # 8000027c <consputc>
    80000400:	bded                	j	800002fa <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80000402:	ee048ce3          	beqz	s1,800002fa <consoleintr+0x3c>
    80000406:	bf21                	j	8000031e <consoleintr+0x60>
      consputc(c);
    80000408:	4529                	li	a0,10
    8000040a:	00000097          	auipc	ra,0x0
    8000040e:	e72080e7          	jalr	-398(ra) # 8000027c <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000412:	00011797          	auipc	a5,0x11
    80000416:	86e78793          	addi	a5,a5,-1938 # 80010c80 <cons>
    8000041a:	0a07a703          	lw	a4,160(a5)
    8000041e:	0017069b          	addiw	a3,a4,1
    80000422:	0006861b          	sext.w	a2,a3
    80000426:	0ad7a023          	sw	a3,160(a5)
    8000042a:	07f77713          	andi	a4,a4,127
    8000042e:	97ba                	add	a5,a5,a4
    80000430:	4729                	li	a4,10
    80000432:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000436:	00011797          	auipc	a5,0x11
    8000043a:	8ec7a323          	sw	a2,-1818(a5) # 80010d1c <cons+0x9c>
        wakeup(&cons.r);
    8000043e:	00011517          	auipc	a0,0x11
    80000442:	8da50513          	addi	a0,a0,-1830 # 80010d18 <cons+0x98>
    80000446:	00002097          	auipc	ra,0x2
    8000044a:	e9a080e7          	jalr	-358(ra) # 800022e0 <wakeup>
    8000044e:	b575                	j	800002fa <consoleintr+0x3c>

0000000080000450 <consoleinit>:

void
consoleinit(void)
{
    80000450:	1141                	addi	sp,sp,-16
    80000452:	e406                	sd	ra,8(sp)
    80000454:	e022                	sd	s0,0(sp)
    80000456:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000458:	00008597          	auipc	a1,0x8
    8000045c:	bb858593          	addi	a1,a1,-1096 # 80008010 <etext+0x10>
    80000460:	00011517          	auipc	a0,0x11
    80000464:	82050513          	addi	a0,a0,-2016 # 80010c80 <cons>
    80000468:	00000097          	auipc	ra,0x0
    8000046c:	6de080e7          	jalr	1758(ra) # 80000b46 <initlock>

  uartinit();
    80000470:	00000097          	auipc	ra,0x0
    80000474:	32c080e7          	jalr	812(ra) # 8000079c <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000478:	00021797          	auipc	a5,0x21
    8000047c:	1a078793          	addi	a5,a5,416 # 80021618 <devsw>
    80000480:	00000717          	auipc	a4,0x0
    80000484:	ce470713          	addi	a4,a4,-796 # 80000164 <consoleread>
    80000488:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    8000048a:	00000717          	auipc	a4,0x0
    8000048e:	c7670713          	addi	a4,a4,-906 # 80000100 <consolewrite>
    80000492:	ef98                	sd	a4,24(a5)
}
    80000494:	60a2                	ld	ra,8(sp)
    80000496:	6402                	ld	s0,0(sp)
    80000498:	0141                	addi	sp,sp,16
    8000049a:	8082                	ret

000000008000049c <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    8000049c:	7179                	addi	sp,sp,-48
    8000049e:	f406                	sd	ra,40(sp)
    800004a0:	f022                	sd	s0,32(sp)
    800004a2:	ec26                	sd	s1,24(sp)
    800004a4:	e84a                	sd	s2,16(sp)
    800004a6:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004a8:	c219                	beqz	a2,800004ae <printint+0x12>
    800004aa:	08054763          	bltz	a0,80000538 <printint+0x9c>
    x = -xx;
  else
    x = xx;
    800004ae:	2501                	sext.w	a0,a0
    800004b0:	4881                	li	a7,0
    800004b2:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004b6:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004b8:	2581                	sext.w	a1,a1
    800004ba:	00008617          	auipc	a2,0x8
    800004be:	b8660613          	addi	a2,a2,-1146 # 80008040 <digits>
    800004c2:	883a                	mv	a6,a4
    800004c4:	2705                	addiw	a4,a4,1
    800004c6:	02b577bb          	remuw	a5,a0,a1
    800004ca:	1782                	slli	a5,a5,0x20
    800004cc:	9381                	srli	a5,a5,0x20
    800004ce:	97b2                	add	a5,a5,a2
    800004d0:	0007c783          	lbu	a5,0(a5)
    800004d4:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004d8:	0005079b          	sext.w	a5,a0
    800004dc:	02b5553b          	divuw	a0,a0,a1
    800004e0:	0685                	addi	a3,a3,1
    800004e2:	feb7f0e3          	bgeu	a5,a1,800004c2 <printint+0x26>

  if(sign)
    800004e6:	00088c63          	beqz	a7,800004fe <printint+0x62>
    buf[i++] = '-';
    800004ea:	fe070793          	addi	a5,a4,-32
    800004ee:	00878733          	add	a4,a5,s0
    800004f2:	02d00793          	li	a5,45
    800004f6:	fef70823          	sb	a5,-16(a4)
    800004fa:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    800004fe:	02e05763          	blez	a4,8000052c <printint+0x90>
    80000502:	fd040793          	addi	a5,s0,-48
    80000506:	00e784b3          	add	s1,a5,a4
    8000050a:	fff78913          	addi	s2,a5,-1
    8000050e:	993a                	add	s2,s2,a4
    80000510:	377d                	addiw	a4,a4,-1
    80000512:	1702                	slli	a4,a4,0x20
    80000514:	9301                	srli	a4,a4,0x20
    80000516:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    8000051a:	fff4c503          	lbu	a0,-1(s1)
    8000051e:	00000097          	auipc	ra,0x0
    80000522:	d5e080e7          	jalr	-674(ra) # 8000027c <consputc>
  while(--i >= 0)
    80000526:	14fd                	addi	s1,s1,-1
    80000528:	ff2499e3          	bne	s1,s2,8000051a <printint+0x7e>
}
    8000052c:	70a2                	ld	ra,40(sp)
    8000052e:	7402                	ld	s0,32(sp)
    80000530:	64e2                	ld	s1,24(sp)
    80000532:	6942                	ld	s2,16(sp)
    80000534:	6145                	addi	sp,sp,48
    80000536:	8082                	ret
    x = -xx;
    80000538:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    8000053c:	4885                	li	a7,1
    x = -xx;
    8000053e:	bf95                	j	800004b2 <printint+0x16>

0000000080000540 <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    80000540:	1101                	addi	sp,sp,-32
    80000542:	ec06                	sd	ra,24(sp)
    80000544:	e822                	sd	s0,16(sp)
    80000546:	e426                	sd	s1,8(sp)
    80000548:	1000                	addi	s0,sp,32
    8000054a:	84aa                	mv	s1,a0
  pr.locking = 0;
    8000054c:	00010797          	auipc	a5,0x10
    80000550:	7e07aa23          	sw	zero,2036(a5) # 80010d40 <pr+0x18>
  printf("panic: ");
    80000554:	00008517          	auipc	a0,0x8
    80000558:	ac450513          	addi	a0,a0,-1340 # 80008018 <etext+0x18>
    8000055c:	00000097          	auipc	ra,0x0
    80000560:	02e080e7          	jalr	46(ra) # 8000058a <printf>
  printf(s);
    80000564:	8526                	mv	a0,s1
    80000566:	00000097          	auipc	ra,0x0
    8000056a:	024080e7          	jalr	36(ra) # 8000058a <printf>
  printf("\n");
    8000056e:	00008517          	auipc	a0,0x8
    80000572:	b5a50513          	addi	a0,a0,-1190 # 800080c8 <digits+0x88>
    80000576:	00000097          	auipc	ra,0x0
    8000057a:	014080e7          	jalr	20(ra) # 8000058a <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000057e:	4785                	li	a5,1
    80000580:	00008717          	auipc	a4,0x8
    80000584:	58f72023          	sw	a5,1408(a4) # 80008b00 <panicked>
  for(;;)
    80000588:	a001                	j	80000588 <panic+0x48>

000000008000058a <printf>:
{
    8000058a:	7131                	addi	sp,sp,-192
    8000058c:	fc86                	sd	ra,120(sp)
    8000058e:	f8a2                	sd	s0,112(sp)
    80000590:	f4a6                	sd	s1,104(sp)
    80000592:	f0ca                	sd	s2,96(sp)
    80000594:	ecce                	sd	s3,88(sp)
    80000596:	e8d2                	sd	s4,80(sp)
    80000598:	e4d6                	sd	s5,72(sp)
    8000059a:	e0da                	sd	s6,64(sp)
    8000059c:	fc5e                	sd	s7,56(sp)
    8000059e:	f862                	sd	s8,48(sp)
    800005a0:	f466                	sd	s9,40(sp)
    800005a2:	f06a                	sd	s10,32(sp)
    800005a4:	ec6e                	sd	s11,24(sp)
    800005a6:	0100                	addi	s0,sp,128
    800005a8:	8a2a                	mv	s4,a0
    800005aa:	e40c                	sd	a1,8(s0)
    800005ac:	e810                	sd	a2,16(s0)
    800005ae:	ec14                	sd	a3,24(s0)
    800005b0:	f018                	sd	a4,32(s0)
    800005b2:	f41c                	sd	a5,40(s0)
    800005b4:	03043823          	sd	a6,48(s0)
    800005b8:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005bc:	00010d97          	auipc	s11,0x10
    800005c0:	784dad83          	lw	s11,1924(s11) # 80010d40 <pr+0x18>
  if(locking)
    800005c4:	020d9b63          	bnez	s11,800005fa <printf+0x70>
  if (fmt == 0)
    800005c8:	040a0263          	beqz	s4,8000060c <printf+0x82>
  va_start(ap, fmt);
    800005cc:	00840793          	addi	a5,s0,8
    800005d0:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005d4:	000a4503          	lbu	a0,0(s4)
    800005d8:	14050f63          	beqz	a0,80000736 <printf+0x1ac>
    800005dc:	4981                	li	s3,0
    if(c != '%'){
    800005de:	02500a93          	li	s5,37
    switch(c){
    800005e2:	07000b93          	li	s7,112
  consputc('x');
    800005e6:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005e8:	00008b17          	auipc	s6,0x8
    800005ec:	a58b0b13          	addi	s6,s6,-1448 # 80008040 <digits>
    switch(c){
    800005f0:	07300c93          	li	s9,115
    800005f4:	06400c13          	li	s8,100
    800005f8:	a82d                	j	80000632 <printf+0xa8>
    acquire(&pr.lock);
    800005fa:	00010517          	auipc	a0,0x10
    800005fe:	72e50513          	addi	a0,a0,1838 # 80010d28 <pr>
    80000602:	00000097          	auipc	ra,0x0
    80000606:	5d4080e7          	jalr	1492(ra) # 80000bd6 <acquire>
    8000060a:	bf7d                	j	800005c8 <printf+0x3e>
    panic("null fmt");
    8000060c:	00008517          	auipc	a0,0x8
    80000610:	a1c50513          	addi	a0,a0,-1508 # 80008028 <etext+0x28>
    80000614:	00000097          	auipc	ra,0x0
    80000618:	f2c080e7          	jalr	-212(ra) # 80000540 <panic>
      consputc(c);
    8000061c:	00000097          	auipc	ra,0x0
    80000620:	c60080e7          	jalr	-928(ra) # 8000027c <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000624:	2985                	addiw	s3,s3,1
    80000626:	013a07b3          	add	a5,s4,s3
    8000062a:	0007c503          	lbu	a0,0(a5)
    8000062e:	10050463          	beqz	a0,80000736 <printf+0x1ac>
    if(c != '%'){
    80000632:	ff5515e3          	bne	a0,s5,8000061c <printf+0x92>
    c = fmt[++i] & 0xff;
    80000636:	2985                	addiw	s3,s3,1
    80000638:	013a07b3          	add	a5,s4,s3
    8000063c:	0007c783          	lbu	a5,0(a5)
    80000640:	0007849b          	sext.w	s1,a5
    if(c == 0)
    80000644:	cbed                	beqz	a5,80000736 <printf+0x1ac>
    switch(c){
    80000646:	05778a63          	beq	a5,s7,8000069a <printf+0x110>
    8000064a:	02fbf663          	bgeu	s7,a5,80000676 <printf+0xec>
    8000064e:	09978863          	beq	a5,s9,800006de <printf+0x154>
    80000652:	07800713          	li	a4,120
    80000656:	0ce79563          	bne	a5,a4,80000720 <printf+0x196>
      printint(va_arg(ap, int), 16, 1);
    8000065a:	f8843783          	ld	a5,-120(s0)
    8000065e:	00878713          	addi	a4,a5,8
    80000662:	f8e43423          	sd	a4,-120(s0)
    80000666:	4605                	li	a2,1
    80000668:	85ea                	mv	a1,s10
    8000066a:	4388                	lw	a0,0(a5)
    8000066c:	00000097          	auipc	ra,0x0
    80000670:	e30080e7          	jalr	-464(ra) # 8000049c <printint>
      break;
    80000674:	bf45                	j	80000624 <printf+0x9a>
    switch(c){
    80000676:	09578f63          	beq	a5,s5,80000714 <printf+0x18a>
    8000067a:	0b879363          	bne	a5,s8,80000720 <printf+0x196>
      printint(va_arg(ap, int), 10, 1);
    8000067e:	f8843783          	ld	a5,-120(s0)
    80000682:	00878713          	addi	a4,a5,8
    80000686:	f8e43423          	sd	a4,-120(s0)
    8000068a:	4605                	li	a2,1
    8000068c:	45a9                	li	a1,10
    8000068e:	4388                	lw	a0,0(a5)
    80000690:	00000097          	auipc	ra,0x0
    80000694:	e0c080e7          	jalr	-500(ra) # 8000049c <printint>
      break;
    80000698:	b771                	j	80000624 <printf+0x9a>
      printptr(va_arg(ap, uint64));
    8000069a:	f8843783          	ld	a5,-120(s0)
    8000069e:	00878713          	addi	a4,a5,8
    800006a2:	f8e43423          	sd	a4,-120(s0)
    800006a6:	0007b903          	ld	s2,0(a5)
  consputc('0');
    800006aa:	03000513          	li	a0,48
    800006ae:	00000097          	auipc	ra,0x0
    800006b2:	bce080e7          	jalr	-1074(ra) # 8000027c <consputc>
  consputc('x');
    800006b6:	07800513          	li	a0,120
    800006ba:	00000097          	auipc	ra,0x0
    800006be:	bc2080e7          	jalr	-1086(ra) # 8000027c <consputc>
    800006c2:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006c4:	03c95793          	srli	a5,s2,0x3c
    800006c8:	97da                	add	a5,a5,s6
    800006ca:	0007c503          	lbu	a0,0(a5)
    800006ce:	00000097          	auipc	ra,0x0
    800006d2:	bae080e7          	jalr	-1106(ra) # 8000027c <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006d6:	0912                	slli	s2,s2,0x4
    800006d8:	34fd                	addiw	s1,s1,-1
    800006da:	f4ed                	bnez	s1,800006c4 <printf+0x13a>
    800006dc:	b7a1                	j	80000624 <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006de:	f8843783          	ld	a5,-120(s0)
    800006e2:	00878713          	addi	a4,a5,8
    800006e6:	f8e43423          	sd	a4,-120(s0)
    800006ea:	6384                	ld	s1,0(a5)
    800006ec:	cc89                	beqz	s1,80000706 <printf+0x17c>
      for(; *s; s++)
    800006ee:	0004c503          	lbu	a0,0(s1)
    800006f2:	d90d                	beqz	a0,80000624 <printf+0x9a>
        consputc(*s);
    800006f4:	00000097          	auipc	ra,0x0
    800006f8:	b88080e7          	jalr	-1144(ra) # 8000027c <consputc>
      for(; *s; s++)
    800006fc:	0485                	addi	s1,s1,1
    800006fe:	0004c503          	lbu	a0,0(s1)
    80000702:	f96d                	bnez	a0,800006f4 <printf+0x16a>
    80000704:	b705                	j	80000624 <printf+0x9a>
        s = "(null)";
    80000706:	00008497          	auipc	s1,0x8
    8000070a:	91a48493          	addi	s1,s1,-1766 # 80008020 <etext+0x20>
      for(; *s; s++)
    8000070e:	02800513          	li	a0,40
    80000712:	b7cd                	j	800006f4 <printf+0x16a>
      consputc('%');
    80000714:	8556                	mv	a0,s5
    80000716:	00000097          	auipc	ra,0x0
    8000071a:	b66080e7          	jalr	-1178(ra) # 8000027c <consputc>
      break;
    8000071e:	b719                	j	80000624 <printf+0x9a>
      consputc('%');
    80000720:	8556                	mv	a0,s5
    80000722:	00000097          	auipc	ra,0x0
    80000726:	b5a080e7          	jalr	-1190(ra) # 8000027c <consputc>
      consputc(c);
    8000072a:	8526                	mv	a0,s1
    8000072c:	00000097          	auipc	ra,0x0
    80000730:	b50080e7          	jalr	-1200(ra) # 8000027c <consputc>
      break;
    80000734:	bdc5                	j	80000624 <printf+0x9a>
  if(locking)
    80000736:	020d9163          	bnez	s11,80000758 <printf+0x1ce>
}
    8000073a:	70e6                	ld	ra,120(sp)
    8000073c:	7446                	ld	s0,112(sp)
    8000073e:	74a6                	ld	s1,104(sp)
    80000740:	7906                	ld	s2,96(sp)
    80000742:	69e6                	ld	s3,88(sp)
    80000744:	6a46                	ld	s4,80(sp)
    80000746:	6aa6                	ld	s5,72(sp)
    80000748:	6b06                	ld	s6,64(sp)
    8000074a:	7be2                	ld	s7,56(sp)
    8000074c:	7c42                	ld	s8,48(sp)
    8000074e:	7ca2                	ld	s9,40(sp)
    80000750:	7d02                	ld	s10,32(sp)
    80000752:	6de2                	ld	s11,24(sp)
    80000754:	6129                	addi	sp,sp,192
    80000756:	8082                	ret
    release(&pr.lock);
    80000758:	00010517          	auipc	a0,0x10
    8000075c:	5d050513          	addi	a0,a0,1488 # 80010d28 <pr>
    80000760:	00000097          	auipc	ra,0x0
    80000764:	52a080e7          	jalr	1322(ra) # 80000c8a <release>
}
    80000768:	bfc9                	j	8000073a <printf+0x1b0>

000000008000076a <printfinit>:
    ;
}

void
printfinit(void)
{
    8000076a:	1101                	addi	sp,sp,-32
    8000076c:	ec06                	sd	ra,24(sp)
    8000076e:	e822                	sd	s0,16(sp)
    80000770:	e426                	sd	s1,8(sp)
    80000772:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    80000774:	00010497          	auipc	s1,0x10
    80000778:	5b448493          	addi	s1,s1,1460 # 80010d28 <pr>
    8000077c:	00008597          	auipc	a1,0x8
    80000780:	8bc58593          	addi	a1,a1,-1860 # 80008038 <etext+0x38>
    80000784:	8526                	mv	a0,s1
    80000786:	00000097          	auipc	ra,0x0
    8000078a:	3c0080e7          	jalr	960(ra) # 80000b46 <initlock>
  pr.locking = 1;
    8000078e:	4785                	li	a5,1
    80000790:	cc9c                	sw	a5,24(s1)
}
    80000792:	60e2                	ld	ra,24(sp)
    80000794:	6442                	ld	s0,16(sp)
    80000796:	64a2                	ld	s1,8(sp)
    80000798:	6105                	addi	sp,sp,32
    8000079a:	8082                	ret

000000008000079c <uartinit>:

void uartstart();

void
uartinit(void)
{
    8000079c:	1141                	addi	sp,sp,-16
    8000079e:	e406                	sd	ra,8(sp)
    800007a0:	e022                	sd	s0,0(sp)
    800007a2:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007a4:	100007b7          	lui	a5,0x10000
    800007a8:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007ac:	f8000713          	li	a4,-128
    800007b0:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007b4:	470d                	li	a4,3
    800007b6:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007ba:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007be:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007c2:	469d                	li	a3,7
    800007c4:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007c8:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007cc:	00008597          	auipc	a1,0x8
    800007d0:	88c58593          	addi	a1,a1,-1908 # 80008058 <digits+0x18>
    800007d4:	00010517          	auipc	a0,0x10
    800007d8:	57450513          	addi	a0,a0,1396 # 80010d48 <uart_tx_lock>
    800007dc:	00000097          	auipc	ra,0x0
    800007e0:	36a080e7          	jalr	874(ra) # 80000b46 <initlock>
}
    800007e4:	60a2                	ld	ra,8(sp)
    800007e6:	6402                	ld	s0,0(sp)
    800007e8:	0141                	addi	sp,sp,16
    800007ea:	8082                	ret

00000000800007ec <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007ec:	1101                	addi	sp,sp,-32
    800007ee:	ec06                	sd	ra,24(sp)
    800007f0:	e822                	sd	s0,16(sp)
    800007f2:	e426                	sd	s1,8(sp)
    800007f4:	1000                	addi	s0,sp,32
    800007f6:	84aa                	mv	s1,a0
  push_off();
    800007f8:	00000097          	auipc	ra,0x0
    800007fc:	392080e7          	jalr	914(ra) # 80000b8a <push_off>

  if(panicked){
    80000800:	00008797          	auipc	a5,0x8
    80000804:	3007a783          	lw	a5,768(a5) # 80008b00 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000808:	10000737          	lui	a4,0x10000
  if(panicked){
    8000080c:	c391                	beqz	a5,80000810 <uartputc_sync+0x24>
    for(;;)
    8000080e:	a001                	j	8000080e <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000810:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000814:	0207f793          	andi	a5,a5,32
    80000818:	dfe5                	beqz	a5,80000810 <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    8000081a:	0ff4f513          	zext.b	a0,s1
    8000081e:	100007b7          	lui	a5,0x10000
    80000822:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80000826:	00000097          	auipc	ra,0x0
    8000082a:	404080e7          	jalr	1028(ra) # 80000c2a <pop_off>
}
    8000082e:	60e2                	ld	ra,24(sp)
    80000830:	6442                	ld	s0,16(sp)
    80000832:	64a2                	ld	s1,8(sp)
    80000834:	6105                	addi	sp,sp,32
    80000836:	8082                	ret

0000000080000838 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80000838:	00008797          	auipc	a5,0x8
    8000083c:	2d07b783          	ld	a5,720(a5) # 80008b08 <uart_tx_r>
    80000840:	00008717          	auipc	a4,0x8
    80000844:	2d073703          	ld	a4,720(a4) # 80008b10 <uart_tx_w>
    80000848:	06f70a63          	beq	a4,a5,800008bc <uartstart+0x84>
{
    8000084c:	7139                	addi	sp,sp,-64
    8000084e:	fc06                	sd	ra,56(sp)
    80000850:	f822                	sd	s0,48(sp)
    80000852:	f426                	sd	s1,40(sp)
    80000854:	f04a                	sd	s2,32(sp)
    80000856:	ec4e                	sd	s3,24(sp)
    80000858:	e852                	sd	s4,16(sp)
    8000085a:	e456                	sd	s5,8(sp)
    8000085c:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000085e:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000862:	00010a17          	auipc	s4,0x10
    80000866:	4e6a0a13          	addi	s4,s4,1254 # 80010d48 <uart_tx_lock>
    uart_tx_r += 1;
    8000086a:	00008497          	auipc	s1,0x8
    8000086e:	29e48493          	addi	s1,s1,670 # 80008b08 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80000872:	00008997          	auipc	s3,0x8
    80000876:	29e98993          	addi	s3,s3,670 # 80008b10 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000087a:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    8000087e:	02077713          	andi	a4,a4,32
    80000882:	c705                	beqz	a4,800008aa <uartstart+0x72>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000884:	01f7f713          	andi	a4,a5,31
    80000888:	9752                	add	a4,a4,s4
    8000088a:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    8000088e:	0785                	addi	a5,a5,1
    80000890:	e09c                	sd	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    80000892:	8526                	mv	a0,s1
    80000894:	00002097          	auipc	ra,0x2
    80000898:	a4c080e7          	jalr	-1460(ra) # 800022e0 <wakeup>
    
    WriteReg(THR, c);
    8000089c:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    800008a0:	609c                	ld	a5,0(s1)
    800008a2:	0009b703          	ld	a4,0(s3)
    800008a6:	fcf71ae3          	bne	a4,a5,8000087a <uartstart+0x42>
  }
}
    800008aa:	70e2                	ld	ra,56(sp)
    800008ac:	7442                	ld	s0,48(sp)
    800008ae:	74a2                	ld	s1,40(sp)
    800008b0:	7902                	ld	s2,32(sp)
    800008b2:	69e2                	ld	s3,24(sp)
    800008b4:	6a42                	ld	s4,16(sp)
    800008b6:	6aa2                	ld	s5,8(sp)
    800008b8:	6121                	addi	sp,sp,64
    800008ba:	8082                	ret
    800008bc:	8082                	ret

00000000800008be <uartputc>:
{
    800008be:	7179                	addi	sp,sp,-48
    800008c0:	f406                	sd	ra,40(sp)
    800008c2:	f022                	sd	s0,32(sp)
    800008c4:	ec26                	sd	s1,24(sp)
    800008c6:	e84a                	sd	s2,16(sp)
    800008c8:	e44e                	sd	s3,8(sp)
    800008ca:	e052                	sd	s4,0(sp)
    800008cc:	1800                	addi	s0,sp,48
    800008ce:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    800008d0:	00010517          	auipc	a0,0x10
    800008d4:	47850513          	addi	a0,a0,1144 # 80010d48 <uart_tx_lock>
    800008d8:	00000097          	auipc	ra,0x0
    800008dc:	2fe080e7          	jalr	766(ra) # 80000bd6 <acquire>
  if(panicked){
    800008e0:	00008797          	auipc	a5,0x8
    800008e4:	2207a783          	lw	a5,544(a5) # 80008b00 <panicked>
    800008e8:	e7c9                	bnez	a5,80000972 <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008ea:	00008717          	auipc	a4,0x8
    800008ee:	22673703          	ld	a4,550(a4) # 80008b10 <uart_tx_w>
    800008f2:	00008797          	auipc	a5,0x8
    800008f6:	2167b783          	ld	a5,534(a5) # 80008b08 <uart_tx_r>
    800008fa:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    800008fe:	00010997          	auipc	s3,0x10
    80000902:	44a98993          	addi	s3,s3,1098 # 80010d48 <uart_tx_lock>
    80000906:	00008497          	auipc	s1,0x8
    8000090a:	20248493          	addi	s1,s1,514 # 80008b08 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000090e:	00008917          	auipc	s2,0x8
    80000912:	20290913          	addi	s2,s2,514 # 80008b10 <uart_tx_w>
    80000916:	00e79f63          	bne	a5,a4,80000934 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    8000091a:	85ce                	mv	a1,s3
    8000091c:	8526                	mv	a0,s1
    8000091e:	00002097          	auipc	ra,0x2
    80000922:	812080e7          	jalr	-2030(ra) # 80002130 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000926:	00093703          	ld	a4,0(s2)
    8000092a:	609c                	ld	a5,0(s1)
    8000092c:	02078793          	addi	a5,a5,32
    80000930:	fee785e3          	beq	a5,a4,8000091a <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000934:	00010497          	auipc	s1,0x10
    80000938:	41448493          	addi	s1,s1,1044 # 80010d48 <uart_tx_lock>
    8000093c:	01f77793          	andi	a5,a4,31
    80000940:	97a6                	add	a5,a5,s1
    80000942:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    80000946:	0705                	addi	a4,a4,1
    80000948:	00008797          	auipc	a5,0x8
    8000094c:	1ce7b423          	sd	a4,456(a5) # 80008b10 <uart_tx_w>
  uartstart();
    80000950:	00000097          	auipc	ra,0x0
    80000954:	ee8080e7          	jalr	-280(ra) # 80000838 <uartstart>
  release(&uart_tx_lock);
    80000958:	8526                	mv	a0,s1
    8000095a:	00000097          	auipc	ra,0x0
    8000095e:	330080e7          	jalr	816(ra) # 80000c8a <release>
}
    80000962:	70a2                	ld	ra,40(sp)
    80000964:	7402                	ld	s0,32(sp)
    80000966:	64e2                	ld	s1,24(sp)
    80000968:	6942                	ld	s2,16(sp)
    8000096a:	69a2                	ld	s3,8(sp)
    8000096c:	6a02                	ld	s4,0(sp)
    8000096e:	6145                	addi	sp,sp,48
    80000970:	8082                	ret
    for(;;)
    80000972:	a001                	j	80000972 <uartputc+0xb4>

0000000080000974 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000974:	1141                	addi	sp,sp,-16
    80000976:	e422                	sd	s0,8(sp)
    80000978:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    8000097a:	100007b7          	lui	a5,0x10000
    8000097e:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80000982:	8b85                	andi	a5,a5,1
    80000984:	cb81                	beqz	a5,80000994 <uartgetc+0x20>
    // input data is ready.
    return ReadReg(RHR);
    80000986:	100007b7          	lui	a5,0x10000
    8000098a:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    8000098e:	6422                	ld	s0,8(sp)
    80000990:	0141                	addi	sp,sp,16
    80000992:	8082                	ret
    return -1;
    80000994:	557d                	li	a0,-1
    80000996:	bfe5                	j	8000098e <uartgetc+0x1a>

0000000080000998 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    80000998:	1101                	addi	sp,sp,-32
    8000099a:	ec06                	sd	ra,24(sp)
    8000099c:	e822                	sd	s0,16(sp)
    8000099e:	e426                	sd	s1,8(sp)
    800009a0:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009a2:	54fd                	li	s1,-1
    800009a4:	a029                	j	800009ae <uartintr+0x16>
      break;
    consoleintr(c);
    800009a6:	00000097          	auipc	ra,0x0
    800009aa:	918080e7          	jalr	-1768(ra) # 800002be <consoleintr>
    int c = uartgetc();
    800009ae:	00000097          	auipc	ra,0x0
    800009b2:	fc6080e7          	jalr	-58(ra) # 80000974 <uartgetc>
    if(c == -1)
    800009b6:	fe9518e3          	bne	a0,s1,800009a6 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009ba:	00010497          	auipc	s1,0x10
    800009be:	38e48493          	addi	s1,s1,910 # 80010d48 <uart_tx_lock>
    800009c2:	8526                	mv	a0,s1
    800009c4:	00000097          	auipc	ra,0x0
    800009c8:	212080e7          	jalr	530(ra) # 80000bd6 <acquire>
  uartstart();
    800009cc:	00000097          	auipc	ra,0x0
    800009d0:	e6c080e7          	jalr	-404(ra) # 80000838 <uartstart>
  release(&uart_tx_lock);
    800009d4:	8526                	mv	a0,s1
    800009d6:	00000097          	auipc	ra,0x0
    800009da:	2b4080e7          	jalr	692(ra) # 80000c8a <release>
}
    800009de:	60e2                	ld	ra,24(sp)
    800009e0:	6442                	ld	s0,16(sp)
    800009e2:	64a2                	ld	s1,8(sp)
    800009e4:	6105                	addi	sp,sp,32
    800009e6:	8082                	ret

00000000800009e8 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009e8:	1101                	addi	sp,sp,-32
    800009ea:	ec06                	sd	ra,24(sp)
    800009ec:	e822                	sd	s0,16(sp)
    800009ee:	e426                	sd	s1,8(sp)
    800009f0:	e04a                	sd	s2,0(sp)
    800009f2:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    800009f4:	03451793          	slli	a5,a0,0x34
    800009f8:	ebb9                	bnez	a5,80000a4e <kfree+0x66>
    800009fa:	84aa                	mv	s1,a0
    800009fc:	00022797          	auipc	a5,0x22
    80000a00:	db478793          	addi	a5,a5,-588 # 800227b0 <end>
    80000a04:	04f56563          	bltu	a0,a5,80000a4e <kfree+0x66>
    80000a08:	47c5                	li	a5,17
    80000a0a:	07ee                	slli	a5,a5,0x1b
    80000a0c:	04f57163          	bgeu	a0,a5,80000a4e <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a10:	6605                	lui	a2,0x1
    80000a12:	4585                	li	a1,1
    80000a14:	00000097          	auipc	ra,0x0
    80000a18:	2be080e7          	jalr	702(ra) # 80000cd2 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a1c:	00010917          	auipc	s2,0x10
    80000a20:	36490913          	addi	s2,s2,868 # 80010d80 <kmem>
    80000a24:	854a                	mv	a0,s2
    80000a26:	00000097          	auipc	ra,0x0
    80000a2a:	1b0080e7          	jalr	432(ra) # 80000bd6 <acquire>
  r->next = kmem.freelist;
    80000a2e:	01893783          	ld	a5,24(s2)
    80000a32:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a34:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a38:	854a                	mv	a0,s2
    80000a3a:	00000097          	auipc	ra,0x0
    80000a3e:	250080e7          	jalr	592(ra) # 80000c8a <release>
}
    80000a42:	60e2                	ld	ra,24(sp)
    80000a44:	6442                	ld	s0,16(sp)
    80000a46:	64a2                	ld	s1,8(sp)
    80000a48:	6902                	ld	s2,0(sp)
    80000a4a:	6105                	addi	sp,sp,32
    80000a4c:	8082                	ret
    panic("kfree");
    80000a4e:	00007517          	auipc	a0,0x7
    80000a52:	61250513          	addi	a0,a0,1554 # 80008060 <digits+0x20>
    80000a56:	00000097          	auipc	ra,0x0
    80000a5a:	aea080e7          	jalr	-1302(ra) # 80000540 <panic>

0000000080000a5e <freerange>:
{
    80000a5e:	7179                	addi	sp,sp,-48
    80000a60:	f406                	sd	ra,40(sp)
    80000a62:	f022                	sd	s0,32(sp)
    80000a64:	ec26                	sd	s1,24(sp)
    80000a66:	e84a                	sd	s2,16(sp)
    80000a68:	e44e                	sd	s3,8(sp)
    80000a6a:	e052                	sd	s4,0(sp)
    80000a6c:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a6e:	6785                	lui	a5,0x1
    80000a70:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000a74:	00e504b3          	add	s1,a0,a4
    80000a78:	777d                	lui	a4,0xfffff
    80000a7a:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a7c:	94be                	add	s1,s1,a5
    80000a7e:	0095ee63          	bltu	a1,s1,80000a9a <freerange+0x3c>
    80000a82:	892e                	mv	s2,a1
    kfree(p);
    80000a84:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a86:	6985                	lui	s3,0x1
    kfree(p);
    80000a88:	01448533          	add	a0,s1,s4
    80000a8c:	00000097          	auipc	ra,0x0
    80000a90:	f5c080e7          	jalr	-164(ra) # 800009e8 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a94:	94ce                	add	s1,s1,s3
    80000a96:	fe9979e3          	bgeu	s2,s1,80000a88 <freerange+0x2a>
}
    80000a9a:	70a2                	ld	ra,40(sp)
    80000a9c:	7402                	ld	s0,32(sp)
    80000a9e:	64e2                	ld	s1,24(sp)
    80000aa0:	6942                	ld	s2,16(sp)
    80000aa2:	69a2                	ld	s3,8(sp)
    80000aa4:	6a02                	ld	s4,0(sp)
    80000aa6:	6145                	addi	sp,sp,48
    80000aa8:	8082                	ret

0000000080000aaa <kinit>:
{
    80000aaa:	1141                	addi	sp,sp,-16
    80000aac:	e406                	sd	ra,8(sp)
    80000aae:	e022                	sd	s0,0(sp)
    80000ab0:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000ab2:	00007597          	auipc	a1,0x7
    80000ab6:	5b658593          	addi	a1,a1,1462 # 80008068 <digits+0x28>
    80000aba:	00010517          	auipc	a0,0x10
    80000abe:	2c650513          	addi	a0,a0,710 # 80010d80 <kmem>
    80000ac2:	00000097          	auipc	ra,0x0
    80000ac6:	084080e7          	jalr	132(ra) # 80000b46 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000aca:	45c5                	li	a1,17
    80000acc:	05ee                	slli	a1,a1,0x1b
    80000ace:	00022517          	auipc	a0,0x22
    80000ad2:	ce250513          	addi	a0,a0,-798 # 800227b0 <end>
    80000ad6:	00000097          	auipc	ra,0x0
    80000ada:	f88080e7          	jalr	-120(ra) # 80000a5e <freerange>
}
    80000ade:	60a2                	ld	ra,8(sp)
    80000ae0:	6402                	ld	s0,0(sp)
    80000ae2:	0141                	addi	sp,sp,16
    80000ae4:	8082                	ret

0000000080000ae6 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000ae6:	1101                	addi	sp,sp,-32
    80000ae8:	ec06                	sd	ra,24(sp)
    80000aea:	e822                	sd	s0,16(sp)
    80000aec:	e426                	sd	s1,8(sp)
    80000aee:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000af0:	00010497          	auipc	s1,0x10
    80000af4:	29048493          	addi	s1,s1,656 # 80010d80 <kmem>
    80000af8:	8526                	mv	a0,s1
    80000afa:	00000097          	auipc	ra,0x0
    80000afe:	0dc080e7          	jalr	220(ra) # 80000bd6 <acquire>
  r = kmem.freelist;
    80000b02:	6c84                	ld	s1,24(s1)
  if(r)
    80000b04:	c885                	beqz	s1,80000b34 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b06:	609c                	ld	a5,0(s1)
    80000b08:	00010517          	auipc	a0,0x10
    80000b0c:	27850513          	addi	a0,a0,632 # 80010d80 <kmem>
    80000b10:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b12:	00000097          	auipc	ra,0x0
    80000b16:	178080e7          	jalr	376(ra) # 80000c8a <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b1a:	6605                	lui	a2,0x1
    80000b1c:	4595                	li	a1,5
    80000b1e:	8526                	mv	a0,s1
    80000b20:	00000097          	auipc	ra,0x0
    80000b24:	1b2080e7          	jalr	434(ra) # 80000cd2 <memset>
  return (void*)r;
}
    80000b28:	8526                	mv	a0,s1
    80000b2a:	60e2                	ld	ra,24(sp)
    80000b2c:	6442                	ld	s0,16(sp)
    80000b2e:	64a2                	ld	s1,8(sp)
    80000b30:	6105                	addi	sp,sp,32
    80000b32:	8082                	ret
  release(&kmem.lock);
    80000b34:	00010517          	auipc	a0,0x10
    80000b38:	24c50513          	addi	a0,a0,588 # 80010d80 <kmem>
    80000b3c:	00000097          	auipc	ra,0x0
    80000b40:	14e080e7          	jalr	334(ra) # 80000c8a <release>
  if(r)
    80000b44:	b7d5                	j	80000b28 <kalloc+0x42>

0000000080000b46 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b46:	1141                	addi	sp,sp,-16
    80000b48:	e422                	sd	s0,8(sp)
    80000b4a:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b4c:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b4e:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b52:	00053823          	sd	zero,16(a0)
}
    80000b56:	6422                	ld	s0,8(sp)
    80000b58:	0141                	addi	sp,sp,16
    80000b5a:	8082                	ret

0000000080000b5c <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b5c:	411c                	lw	a5,0(a0)
    80000b5e:	e399                	bnez	a5,80000b64 <holding+0x8>
    80000b60:	4501                	li	a0,0
  return r;
}
    80000b62:	8082                	ret
{
    80000b64:	1101                	addi	sp,sp,-32
    80000b66:	ec06                	sd	ra,24(sp)
    80000b68:	e822                	sd	s0,16(sp)
    80000b6a:	e426                	sd	s1,8(sp)
    80000b6c:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b6e:	6904                	ld	s1,16(a0)
    80000b70:	00001097          	auipc	ra,0x1
    80000b74:	e20080e7          	jalr	-480(ra) # 80001990 <mycpu>
    80000b78:	40a48533          	sub	a0,s1,a0
    80000b7c:	00153513          	seqz	a0,a0
}
    80000b80:	60e2                	ld	ra,24(sp)
    80000b82:	6442                	ld	s0,16(sp)
    80000b84:	64a2                	ld	s1,8(sp)
    80000b86:	6105                	addi	sp,sp,32
    80000b88:	8082                	ret

0000000080000b8a <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b8a:	1101                	addi	sp,sp,-32
    80000b8c:	ec06                	sd	ra,24(sp)
    80000b8e:	e822                	sd	s0,16(sp)
    80000b90:	e426                	sd	s1,8(sp)
    80000b92:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b94:	100024f3          	csrr	s1,sstatus
    80000b98:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000b9c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000b9e:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000ba2:	00001097          	auipc	ra,0x1
    80000ba6:	dee080e7          	jalr	-530(ra) # 80001990 <mycpu>
    80000baa:	5d3c                	lw	a5,120(a0)
    80000bac:	cf89                	beqz	a5,80000bc6 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bae:	00001097          	auipc	ra,0x1
    80000bb2:	de2080e7          	jalr	-542(ra) # 80001990 <mycpu>
    80000bb6:	5d3c                	lw	a5,120(a0)
    80000bb8:	2785                	addiw	a5,a5,1
    80000bba:	dd3c                	sw	a5,120(a0)
}
    80000bbc:	60e2                	ld	ra,24(sp)
    80000bbe:	6442                	ld	s0,16(sp)
    80000bc0:	64a2                	ld	s1,8(sp)
    80000bc2:	6105                	addi	sp,sp,32
    80000bc4:	8082                	ret
    mycpu()->intena = old;
    80000bc6:	00001097          	auipc	ra,0x1
    80000bca:	dca080e7          	jalr	-566(ra) # 80001990 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bce:	8085                	srli	s1,s1,0x1
    80000bd0:	8885                	andi	s1,s1,1
    80000bd2:	dd64                	sw	s1,124(a0)
    80000bd4:	bfe9                	j	80000bae <push_off+0x24>

0000000080000bd6 <acquire>:
{
    80000bd6:	1101                	addi	sp,sp,-32
    80000bd8:	ec06                	sd	ra,24(sp)
    80000bda:	e822                	sd	s0,16(sp)
    80000bdc:	e426                	sd	s1,8(sp)
    80000bde:	1000                	addi	s0,sp,32
    80000be0:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000be2:	00000097          	auipc	ra,0x0
    80000be6:	fa8080e7          	jalr	-88(ra) # 80000b8a <push_off>
  if(holding(lk))
    80000bea:	8526                	mv	a0,s1
    80000bec:	00000097          	auipc	ra,0x0
    80000bf0:	f70080e7          	jalr	-144(ra) # 80000b5c <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf4:	4705                	li	a4,1
  if(holding(lk))
    80000bf6:	e115                	bnez	a0,80000c1a <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf8:	87ba                	mv	a5,a4
    80000bfa:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000bfe:	2781                	sext.w	a5,a5
    80000c00:	ffe5                	bnez	a5,80000bf8 <acquire+0x22>
  __sync_synchronize();
    80000c02:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c06:	00001097          	auipc	ra,0x1
    80000c0a:	d8a080e7          	jalr	-630(ra) # 80001990 <mycpu>
    80000c0e:	e888                	sd	a0,16(s1)
}
    80000c10:	60e2                	ld	ra,24(sp)
    80000c12:	6442                	ld	s0,16(sp)
    80000c14:	64a2                	ld	s1,8(sp)
    80000c16:	6105                	addi	sp,sp,32
    80000c18:	8082                	ret
    panic("acquire");
    80000c1a:	00007517          	auipc	a0,0x7
    80000c1e:	45650513          	addi	a0,a0,1110 # 80008070 <digits+0x30>
    80000c22:	00000097          	auipc	ra,0x0
    80000c26:	91e080e7          	jalr	-1762(ra) # 80000540 <panic>

0000000080000c2a <pop_off>:

void
pop_off(void)
{
    80000c2a:	1141                	addi	sp,sp,-16
    80000c2c:	e406                	sd	ra,8(sp)
    80000c2e:	e022                	sd	s0,0(sp)
    80000c30:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c32:	00001097          	auipc	ra,0x1
    80000c36:	d5e080e7          	jalr	-674(ra) # 80001990 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c3a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c3e:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c40:	e78d                	bnez	a5,80000c6a <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c42:	5d3c                	lw	a5,120(a0)
    80000c44:	02f05b63          	blez	a5,80000c7a <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c48:	37fd                	addiw	a5,a5,-1
    80000c4a:	0007871b          	sext.w	a4,a5
    80000c4e:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c50:	eb09                	bnez	a4,80000c62 <pop_off+0x38>
    80000c52:	5d7c                	lw	a5,124(a0)
    80000c54:	c799                	beqz	a5,80000c62 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c56:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c5a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c5e:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c62:	60a2                	ld	ra,8(sp)
    80000c64:	6402                	ld	s0,0(sp)
    80000c66:	0141                	addi	sp,sp,16
    80000c68:	8082                	ret
    panic("pop_off - interruptible");
    80000c6a:	00007517          	auipc	a0,0x7
    80000c6e:	40e50513          	addi	a0,a0,1038 # 80008078 <digits+0x38>
    80000c72:	00000097          	auipc	ra,0x0
    80000c76:	8ce080e7          	jalr	-1842(ra) # 80000540 <panic>
    panic("pop_off");
    80000c7a:	00007517          	auipc	a0,0x7
    80000c7e:	41650513          	addi	a0,a0,1046 # 80008090 <digits+0x50>
    80000c82:	00000097          	auipc	ra,0x0
    80000c86:	8be080e7          	jalr	-1858(ra) # 80000540 <panic>

0000000080000c8a <release>:
{
    80000c8a:	1101                	addi	sp,sp,-32
    80000c8c:	ec06                	sd	ra,24(sp)
    80000c8e:	e822                	sd	s0,16(sp)
    80000c90:	e426                	sd	s1,8(sp)
    80000c92:	1000                	addi	s0,sp,32
    80000c94:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c96:	00000097          	auipc	ra,0x0
    80000c9a:	ec6080e7          	jalr	-314(ra) # 80000b5c <holding>
    80000c9e:	c115                	beqz	a0,80000cc2 <release+0x38>
  lk->cpu = 0;
    80000ca0:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000ca4:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000ca8:	0f50000f          	fence	iorw,ow
    80000cac:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000cb0:	00000097          	auipc	ra,0x0
    80000cb4:	f7a080e7          	jalr	-134(ra) # 80000c2a <pop_off>
}
    80000cb8:	60e2                	ld	ra,24(sp)
    80000cba:	6442                	ld	s0,16(sp)
    80000cbc:	64a2                	ld	s1,8(sp)
    80000cbe:	6105                	addi	sp,sp,32
    80000cc0:	8082                	ret
    panic("release");
    80000cc2:	00007517          	auipc	a0,0x7
    80000cc6:	3d650513          	addi	a0,a0,982 # 80008098 <digits+0x58>
    80000cca:	00000097          	auipc	ra,0x0
    80000cce:	876080e7          	jalr	-1930(ra) # 80000540 <panic>

0000000080000cd2 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000cd2:	1141                	addi	sp,sp,-16
    80000cd4:	e422                	sd	s0,8(sp)
    80000cd6:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000cd8:	ca19                	beqz	a2,80000cee <memset+0x1c>
    80000cda:	87aa                	mv	a5,a0
    80000cdc:	1602                	slli	a2,a2,0x20
    80000cde:	9201                	srli	a2,a2,0x20
    80000ce0:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000ce4:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000ce8:	0785                	addi	a5,a5,1
    80000cea:	fee79de3          	bne	a5,a4,80000ce4 <memset+0x12>
  }
  return dst;
}
    80000cee:	6422                	ld	s0,8(sp)
    80000cf0:	0141                	addi	sp,sp,16
    80000cf2:	8082                	ret

0000000080000cf4 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000cf4:	1141                	addi	sp,sp,-16
    80000cf6:	e422                	sd	s0,8(sp)
    80000cf8:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000cfa:	ca05                	beqz	a2,80000d2a <memcmp+0x36>
    80000cfc:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000d00:	1682                	slli	a3,a3,0x20
    80000d02:	9281                	srli	a3,a3,0x20
    80000d04:	0685                	addi	a3,a3,1
    80000d06:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d08:	00054783          	lbu	a5,0(a0)
    80000d0c:	0005c703          	lbu	a4,0(a1)
    80000d10:	00e79863          	bne	a5,a4,80000d20 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d14:	0505                	addi	a0,a0,1
    80000d16:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d18:	fed518e3          	bne	a0,a3,80000d08 <memcmp+0x14>
  }

  return 0;
    80000d1c:	4501                	li	a0,0
    80000d1e:	a019                	j	80000d24 <memcmp+0x30>
      return *s1 - *s2;
    80000d20:	40e7853b          	subw	a0,a5,a4
}
    80000d24:	6422                	ld	s0,8(sp)
    80000d26:	0141                	addi	sp,sp,16
    80000d28:	8082                	ret
  return 0;
    80000d2a:	4501                	li	a0,0
    80000d2c:	bfe5                	j	80000d24 <memcmp+0x30>

0000000080000d2e <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d2e:	1141                	addi	sp,sp,-16
    80000d30:	e422                	sd	s0,8(sp)
    80000d32:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d34:	c205                	beqz	a2,80000d54 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d36:	02a5e263          	bltu	a1,a0,80000d5a <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d3a:	1602                	slli	a2,a2,0x20
    80000d3c:	9201                	srli	a2,a2,0x20
    80000d3e:	00c587b3          	add	a5,a1,a2
{
    80000d42:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d44:	0585                	addi	a1,a1,1
    80000d46:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffdc851>
    80000d48:	fff5c683          	lbu	a3,-1(a1)
    80000d4c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d50:	fef59ae3          	bne	a1,a5,80000d44 <memmove+0x16>

  return dst;
}
    80000d54:	6422                	ld	s0,8(sp)
    80000d56:	0141                	addi	sp,sp,16
    80000d58:	8082                	ret
  if(s < d && s + n > d){
    80000d5a:	02061693          	slli	a3,a2,0x20
    80000d5e:	9281                	srli	a3,a3,0x20
    80000d60:	00d58733          	add	a4,a1,a3
    80000d64:	fce57be3          	bgeu	a0,a4,80000d3a <memmove+0xc>
    d += n;
    80000d68:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d6a:	fff6079b          	addiw	a5,a2,-1
    80000d6e:	1782                	slli	a5,a5,0x20
    80000d70:	9381                	srli	a5,a5,0x20
    80000d72:	fff7c793          	not	a5,a5
    80000d76:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d78:	177d                	addi	a4,a4,-1
    80000d7a:	16fd                	addi	a3,a3,-1
    80000d7c:	00074603          	lbu	a2,0(a4)
    80000d80:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000d84:	fee79ae3          	bne	a5,a4,80000d78 <memmove+0x4a>
    80000d88:	b7f1                	j	80000d54 <memmove+0x26>

0000000080000d8a <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d8a:	1141                	addi	sp,sp,-16
    80000d8c:	e406                	sd	ra,8(sp)
    80000d8e:	e022                	sd	s0,0(sp)
    80000d90:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d92:	00000097          	auipc	ra,0x0
    80000d96:	f9c080e7          	jalr	-100(ra) # 80000d2e <memmove>
}
    80000d9a:	60a2                	ld	ra,8(sp)
    80000d9c:	6402                	ld	s0,0(sp)
    80000d9e:	0141                	addi	sp,sp,16
    80000da0:	8082                	ret

0000000080000da2 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000da2:	1141                	addi	sp,sp,-16
    80000da4:	e422                	sd	s0,8(sp)
    80000da6:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000da8:	ce11                	beqz	a2,80000dc4 <strncmp+0x22>
    80000daa:	00054783          	lbu	a5,0(a0)
    80000dae:	cf89                	beqz	a5,80000dc8 <strncmp+0x26>
    80000db0:	0005c703          	lbu	a4,0(a1)
    80000db4:	00f71a63          	bne	a4,a5,80000dc8 <strncmp+0x26>
    n--, p++, q++;
    80000db8:	367d                	addiw	a2,a2,-1
    80000dba:	0505                	addi	a0,a0,1
    80000dbc:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000dbe:	f675                	bnez	a2,80000daa <strncmp+0x8>
  if(n == 0)
    return 0;
    80000dc0:	4501                	li	a0,0
    80000dc2:	a809                	j	80000dd4 <strncmp+0x32>
    80000dc4:	4501                	li	a0,0
    80000dc6:	a039                	j	80000dd4 <strncmp+0x32>
  if(n == 0)
    80000dc8:	ca09                	beqz	a2,80000dda <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000dca:	00054503          	lbu	a0,0(a0)
    80000dce:	0005c783          	lbu	a5,0(a1)
    80000dd2:	9d1d                	subw	a0,a0,a5
}
    80000dd4:	6422                	ld	s0,8(sp)
    80000dd6:	0141                	addi	sp,sp,16
    80000dd8:	8082                	ret
    return 0;
    80000dda:	4501                	li	a0,0
    80000ddc:	bfe5                	j	80000dd4 <strncmp+0x32>

0000000080000dde <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000dde:	1141                	addi	sp,sp,-16
    80000de0:	e422                	sd	s0,8(sp)
    80000de2:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000de4:	872a                	mv	a4,a0
    80000de6:	8832                	mv	a6,a2
    80000de8:	367d                	addiw	a2,a2,-1
    80000dea:	01005963          	blez	a6,80000dfc <strncpy+0x1e>
    80000dee:	0705                	addi	a4,a4,1
    80000df0:	0005c783          	lbu	a5,0(a1)
    80000df4:	fef70fa3          	sb	a5,-1(a4)
    80000df8:	0585                	addi	a1,a1,1
    80000dfa:	f7f5                	bnez	a5,80000de6 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000dfc:	86ba                	mv	a3,a4
    80000dfe:	00c05c63          	blez	a2,80000e16 <strncpy+0x38>
    *s++ = 0;
    80000e02:	0685                	addi	a3,a3,1
    80000e04:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000e08:	40d707bb          	subw	a5,a4,a3
    80000e0c:	37fd                	addiw	a5,a5,-1
    80000e0e:	010787bb          	addw	a5,a5,a6
    80000e12:	fef048e3          	bgtz	a5,80000e02 <strncpy+0x24>
  return os;
}
    80000e16:	6422                	ld	s0,8(sp)
    80000e18:	0141                	addi	sp,sp,16
    80000e1a:	8082                	ret

0000000080000e1c <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e1c:	1141                	addi	sp,sp,-16
    80000e1e:	e422                	sd	s0,8(sp)
    80000e20:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e22:	02c05363          	blez	a2,80000e48 <safestrcpy+0x2c>
    80000e26:	fff6069b          	addiw	a3,a2,-1
    80000e2a:	1682                	slli	a3,a3,0x20
    80000e2c:	9281                	srli	a3,a3,0x20
    80000e2e:	96ae                	add	a3,a3,a1
    80000e30:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e32:	00d58963          	beq	a1,a3,80000e44 <safestrcpy+0x28>
    80000e36:	0585                	addi	a1,a1,1
    80000e38:	0785                	addi	a5,a5,1
    80000e3a:	fff5c703          	lbu	a4,-1(a1)
    80000e3e:	fee78fa3          	sb	a4,-1(a5)
    80000e42:	fb65                	bnez	a4,80000e32 <safestrcpy+0x16>
    ;
  *s = 0;
    80000e44:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e48:	6422                	ld	s0,8(sp)
    80000e4a:	0141                	addi	sp,sp,16
    80000e4c:	8082                	ret

0000000080000e4e <strlen>:

int
strlen(const char *s)
{
    80000e4e:	1141                	addi	sp,sp,-16
    80000e50:	e422                	sd	s0,8(sp)
    80000e52:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e54:	00054783          	lbu	a5,0(a0)
    80000e58:	cf91                	beqz	a5,80000e74 <strlen+0x26>
    80000e5a:	0505                	addi	a0,a0,1
    80000e5c:	87aa                	mv	a5,a0
    80000e5e:	4685                	li	a3,1
    80000e60:	9e89                	subw	a3,a3,a0
    80000e62:	00f6853b          	addw	a0,a3,a5
    80000e66:	0785                	addi	a5,a5,1
    80000e68:	fff7c703          	lbu	a4,-1(a5)
    80000e6c:	fb7d                	bnez	a4,80000e62 <strlen+0x14>
    ;
  return n;
}
    80000e6e:	6422                	ld	s0,8(sp)
    80000e70:	0141                	addi	sp,sp,16
    80000e72:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e74:	4501                	li	a0,0
    80000e76:	bfe5                	j	80000e6e <strlen+0x20>

0000000080000e78 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e78:	1141                	addi	sp,sp,-16
    80000e7a:	e406                	sd	ra,8(sp)
    80000e7c:	e022                	sd	s0,0(sp)
    80000e7e:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e80:	00001097          	auipc	ra,0x1
    80000e84:	b00080e7          	jalr	-1280(ra) # 80001980 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e88:	00008717          	auipc	a4,0x8
    80000e8c:	c9070713          	addi	a4,a4,-880 # 80008b18 <started>
  if(cpuid() == 0){
    80000e90:	c139                	beqz	a0,80000ed6 <main+0x5e>
    while(started == 0)
    80000e92:	431c                	lw	a5,0(a4)
    80000e94:	2781                	sext.w	a5,a5
    80000e96:	dff5                	beqz	a5,80000e92 <main+0x1a>
      ;
    __sync_synchronize();
    80000e98:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000e9c:	00001097          	auipc	ra,0x1
    80000ea0:	ae4080e7          	jalr	-1308(ra) # 80001980 <cpuid>
    80000ea4:	85aa                	mv	a1,a0
    80000ea6:	00007517          	auipc	a0,0x7
    80000eaa:	21250513          	addi	a0,a0,530 # 800080b8 <digits+0x78>
    80000eae:	fffff097          	auipc	ra,0xfffff
    80000eb2:	6dc080e7          	jalr	1756(ra) # 8000058a <printf>
    kvminithart();    // turn on paging
    80000eb6:	00000097          	auipc	ra,0x0
    80000eba:	0d8080e7          	jalr	216(ra) # 80000f8e <kvminithart>
    trapinithart();   // install kernel trap vector
    80000ebe:	00002097          	auipc	ra,0x2
    80000ec2:	9f2080e7          	jalr	-1550(ra) # 800028b0 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ec6:	00005097          	auipc	ra,0x5
    80000eca:	1aa080e7          	jalr	426(ra) # 80006070 <plicinithart>
  }

  scheduler();        
    80000ece:	00001097          	auipc	ra,0x1
    80000ed2:	0a6080e7          	jalr	166(ra) # 80001f74 <scheduler>
    consoleinit();
    80000ed6:	fffff097          	auipc	ra,0xfffff
    80000eda:	57a080e7          	jalr	1402(ra) # 80000450 <consoleinit>
    printfinit();
    80000ede:	00000097          	auipc	ra,0x0
    80000ee2:	88c080e7          	jalr	-1908(ra) # 8000076a <printfinit>
    printf("\n");
    80000ee6:	00007517          	auipc	a0,0x7
    80000eea:	1e250513          	addi	a0,a0,482 # 800080c8 <digits+0x88>
    80000eee:	fffff097          	auipc	ra,0xfffff
    80000ef2:	69c080e7          	jalr	1692(ra) # 8000058a <printf>
    printf("xv6 kernel is booting\n");
    80000ef6:	00007517          	auipc	a0,0x7
    80000efa:	1aa50513          	addi	a0,a0,426 # 800080a0 <digits+0x60>
    80000efe:	fffff097          	auipc	ra,0xfffff
    80000f02:	68c080e7          	jalr	1676(ra) # 8000058a <printf>
    printf("\n");
    80000f06:	00007517          	auipc	a0,0x7
    80000f0a:	1c250513          	addi	a0,a0,450 # 800080c8 <digits+0x88>
    80000f0e:	fffff097          	auipc	ra,0xfffff
    80000f12:	67c080e7          	jalr	1660(ra) # 8000058a <printf>
    kinit();         // physical page allocator
    80000f16:	00000097          	auipc	ra,0x0
    80000f1a:	b94080e7          	jalr	-1132(ra) # 80000aaa <kinit>
    kvminit();       // create kernel page table
    80000f1e:	00000097          	auipc	ra,0x0
    80000f22:	326080e7          	jalr	806(ra) # 80001244 <kvminit>
    kvminithart();   // turn on paging
    80000f26:	00000097          	auipc	ra,0x0
    80000f2a:	068080e7          	jalr	104(ra) # 80000f8e <kvminithart>
    procinit();      // process table
    80000f2e:	00001097          	auipc	ra,0x1
    80000f32:	99e080e7          	jalr	-1634(ra) # 800018cc <procinit>
    trapinit();      // trap vectors
    80000f36:	00002097          	auipc	ra,0x2
    80000f3a:	952080e7          	jalr	-1710(ra) # 80002888 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f3e:	00002097          	auipc	ra,0x2
    80000f42:	972080e7          	jalr	-1678(ra) # 800028b0 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f46:	00005097          	auipc	ra,0x5
    80000f4a:	114080e7          	jalr	276(ra) # 8000605a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f4e:	00005097          	auipc	ra,0x5
    80000f52:	122080e7          	jalr	290(ra) # 80006070 <plicinithart>
    binit();         // buffer cache
    80000f56:	00002097          	auipc	ra,0x2
    80000f5a:	2be080e7          	jalr	702(ra) # 80003214 <binit>
    iinit();         // inode table
    80000f5e:	00003097          	auipc	ra,0x3
    80000f62:	95e080e7          	jalr	-1698(ra) # 800038bc <iinit>
    fileinit();      // file table
    80000f66:	00004097          	auipc	ra,0x4
    80000f6a:	904080e7          	jalr	-1788(ra) # 8000486a <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f6e:	00005097          	auipc	ra,0x5
    80000f72:	20a080e7          	jalr	522(ra) # 80006178 <virtio_disk_init>
    userinit();      // first user process
    80000f76:	00001097          	auipc	ra,0x1
    80000f7a:	d2a080e7          	jalr	-726(ra) # 80001ca0 <userinit>
    __sync_synchronize();
    80000f7e:	0ff0000f          	fence
    started = 1;
    80000f82:	4785                	li	a5,1
    80000f84:	00008717          	auipc	a4,0x8
    80000f88:	b8f72a23          	sw	a5,-1132(a4) # 80008b18 <started>
    80000f8c:	b789                	j	80000ece <main+0x56>

0000000080000f8e <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000f8e:	1141                	addi	sp,sp,-16
    80000f90:	e422                	sd	s0,8(sp)
    80000f92:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000f94:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000f98:	00008797          	auipc	a5,0x8
    80000f9c:	b887b783          	ld	a5,-1144(a5) # 80008b20 <kernel_pagetable>
    80000fa0:	83b1                	srli	a5,a5,0xc
    80000fa2:	577d                	li	a4,-1
    80000fa4:	177e                	slli	a4,a4,0x3f
    80000fa6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000fa8:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000fac:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000fb0:	6422                	ld	s0,8(sp)
    80000fb2:	0141                	addi	sp,sp,16
    80000fb4:	8082                	ret

0000000080000fb6 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000fb6:	7139                	addi	sp,sp,-64
    80000fb8:	fc06                	sd	ra,56(sp)
    80000fba:	f822                	sd	s0,48(sp)
    80000fbc:	f426                	sd	s1,40(sp)
    80000fbe:	f04a                	sd	s2,32(sp)
    80000fc0:	ec4e                	sd	s3,24(sp)
    80000fc2:	e852                	sd	s4,16(sp)
    80000fc4:	e456                	sd	s5,8(sp)
    80000fc6:	e05a                	sd	s6,0(sp)
    80000fc8:	0080                	addi	s0,sp,64
    80000fca:	84aa                	mv	s1,a0
    80000fcc:	89ae                	mv	s3,a1
    80000fce:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000fd0:	57fd                	li	a5,-1
    80000fd2:	83e9                	srli	a5,a5,0x1a
    80000fd4:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000fd6:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000fd8:	04b7f263          	bgeu	a5,a1,8000101c <walk+0x66>
    panic("walk");
    80000fdc:	00007517          	auipc	a0,0x7
    80000fe0:	0f450513          	addi	a0,a0,244 # 800080d0 <digits+0x90>
    80000fe4:	fffff097          	auipc	ra,0xfffff
    80000fe8:	55c080e7          	jalr	1372(ra) # 80000540 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000fec:	060a8663          	beqz	s5,80001058 <walk+0xa2>
    80000ff0:	00000097          	auipc	ra,0x0
    80000ff4:	af6080e7          	jalr	-1290(ra) # 80000ae6 <kalloc>
    80000ff8:	84aa                	mv	s1,a0
    80000ffa:	c529                	beqz	a0,80001044 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000ffc:	6605                	lui	a2,0x1
    80000ffe:	4581                	li	a1,0
    80001000:	00000097          	auipc	ra,0x0
    80001004:	cd2080e7          	jalr	-814(ra) # 80000cd2 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001008:	00c4d793          	srli	a5,s1,0xc
    8000100c:	07aa                	slli	a5,a5,0xa
    8000100e:	0017e793          	ori	a5,a5,1
    80001012:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001016:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffdc847>
    80001018:	036a0063          	beq	s4,s6,80001038 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    8000101c:	0149d933          	srl	s2,s3,s4
    80001020:	1ff97913          	andi	s2,s2,511
    80001024:	090e                	slli	s2,s2,0x3
    80001026:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001028:	00093483          	ld	s1,0(s2)
    8000102c:	0014f793          	andi	a5,s1,1
    80001030:	dfd5                	beqz	a5,80000fec <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001032:	80a9                	srli	s1,s1,0xa
    80001034:	04b2                	slli	s1,s1,0xc
    80001036:	b7c5                	j	80001016 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001038:	00c9d513          	srli	a0,s3,0xc
    8000103c:	1ff57513          	andi	a0,a0,511
    80001040:	050e                	slli	a0,a0,0x3
    80001042:	9526                	add	a0,a0,s1
}
    80001044:	70e2                	ld	ra,56(sp)
    80001046:	7442                	ld	s0,48(sp)
    80001048:	74a2                	ld	s1,40(sp)
    8000104a:	7902                	ld	s2,32(sp)
    8000104c:	69e2                	ld	s3,24(sp)
    8000104e:	6a42                	ld	s4,16(sp)
    80001050:	6aa2                	ld	s5,8(sp)
    80001052:	6b02                	ld	s6,0(sp)
    80001054:	6121                	addi	sp,sp,64
    80001056:	8082                	ret
        return 0;
    80001058:	4501                	li	a0,0
    8000105a:	b7ed                	j	80001044 <walk+0x8e>

000000008000105c <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    8000105c:	57fd                	li	a5,-1
    8000105e:	83e9                	srli	a5,a5,0x1a
    80001060:	00b7f463          	bgeu	a5,a1,80001068 <walkaddr+0xc>
    return 0;
    80001064:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001066:	8082                	ret
{
    80001068:	1141                	addi	sp,sp,-16
    8000106a:	e406                	sd	ra,8(sp)
    8000106c:	e022                	sd	s0,0(sp)
    8000106e:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001070:	4601                	li	a2,0
    80001072:	00000097          	auipc	ra,0x0
    80001076:	f44080e7          	jalr	-188(ra) # 80000fb6 <walk>
  if(pte == 0)
    8000107a:	c105                	beqz	a0,8000109a <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    8000107c:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    8000107e:	0117f693          	andi	a3,a5,17
    80001082:	4745                	li	a4,17
    return 0;
    80001084:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001086:	00e68663          	beq	a3,a4,80001092 <walkaddr+0x36>
}
    8000108a:	60a2                	ld	ra,8(sp)
    8000108c:	6402                	ld	s0,0(sp)
    8000108e:	0141                	addi	sp,sp,16
    80001090:	8082                	ret
  pa = PTE2PA(*pte);
    80001092:	83a9                	srli	a5,a5,0xa
    80001094:	00c79513          	slli	a0,a5,0xc
  return pa;
    80001098:	bfcd                	j	8000108a <walkaddr+0x2e>
    return 0;
    8000109a:	4501                	li	a0,0
    8000109c:	b7fd                	j	8000108a <walkaddr+0x2e>

000000008000109e <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    8000109e:	715d                	addi	sp,sp,-80
    800010a0:	e486                	sd	ra,72(sp)
    800010a2:	e0a2                	sd	s0,64(sp)
    800010a4:	fc26                	sd	s1,56(sp)
    800010a6:	f84a                	sd	s2,48(sp)
    800010a8:	f44e                	sd	s3,40(sp)
    800010aa:	f052                	sd	s4,32(sp)
    800010ac:	ec56                	sd	s5,24(sp)
    800010ae:	e85a                	sd	s6,16(sp)
    800010b0:	e45e                	sd	s7,8(sp)
    800010b2:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    800010b4:	c639                	beqz	a2,80001102 <mappages+0x64>
    800010b6:	8aaa                	mv	s5,a0
    800010b8:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    800010ba:	777d                	lui	a4,0xfffff
    800010bc:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    800010c0:	fff58993          	addi	s3,a1,-1
    800010c4:	99b2                	add	s3,s3,a2
    800010c6:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    800010ca:	893e                	mv	s2,a5
    800010cc:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800010d0:	6b85                	lui	s7,0x1
    800010d2:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800010d6:	4605                	li	a2,1
    800010d8:	85ca                	mv	a1,s2
    800010da:	8556                	mv	a0,s5
    800010dc:	00000097          	auipc	ra,0x0
    800010e0:	eda080e7          	jalr	-294(ra) # 80000fb6 <walk>
    800010e4:	cd1d                	beqz	a0,80001122 <mappages+0x84>
    if(*pte & PTE_V)
    800010e6:	611c                	ld	a5,0(a0)
    800010e8:	8b85                	andi	a5,a5,1
    800010ea:	e785                	bnez	a5,80001112 <mappages+0x74>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800010ec:	80b1                	srli	s1,s1,0xc
    800010ee:	04aa                	slli	s1,s1,0xa
    800010f0:	0164e4b3          	or	s1,s1,s6
    800010f4:	0014e493          	ori	s1,s1,1
    800010f8:	e104                	sd	s1,0(a0)
    if(a == last)
    800010fa:	05390063          	beq	s2,s3,8000113a <mappages+0x9c>
    a += PGSIZE;
    800010fe:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001100:	bfc9                	j	800010d2 <mappages+0x34>
    panic("mappages: size");
    80001102:	00007517          	auipc	a0,0x7
    80001106:	fd650513          	addi	a0,a0,-42 # 800080d8 <digits+0x98>
    8000110a:	fffff097          	auipc	ra,0xfffff
    8000110e:	436080e7          	jalr	1078(ra) # 80000540 <panic>
      panic("mappages: remap");
    80001112:	00007517          	auipc	a0,0x7
    80001116:	fd650513          	addi	a0,a0,-42 # 800080e8 <digits+0xa8>
    8000111a:	fffff097          	auipc	ra,0xfffff
    8000111e:	426080e7          	jalr	1062(ra) # 80000540 <panic>
      return -1;
    80001122:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001124:	60a6                	ld	ra,72(sp)
    80001126:	6406                	ld	s0,64(sp)
    80001128:	74e2                	ld	s1,56(sp)
    8000112a:	7942                	ld	s2,48(sp)
    8000112c:	79a2                	ld	s3,40(sp)
    8000112e:	7a02                	ld	s4,32(sp)
    80001130:	6ae2                	ld	s5,24(sp)
    80001132:	6b42                	ld	s6,16(sp)
    80001134:	6ba2                	ld	s7,8(sp)
    80001136:	6161                	addi	sp,sp,80
    80001138:	8082                	ret
  return 0;
    8000113a:	4501                	li	a0,0
    8000113c:	b7e5                	j	80001124 <mappages+0x86>

000000008000113e <kvmmap>:
{
    8000113e:	1141                	addi	sp,sp,-16
    80001140:	e406                	sd	ra,8(sp)
    80001142:	e022                	sd	s0,0(sp)
    80001144:	0800                	addi	s0,sp,16
    80001146:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001148:	86b2                	mv	a3,a2
    8000114a:	863e                	mv	a2,a5
    8000114c:	00000097          	auipc	ra,0x0
    80001150:	f52080e7          	jalr	-174(ra) # 8000109e <mappages>
    80001154:	e509                	bnez	a0,8000115e <kvmmap+0x20>
}
    80001156:	60a2                	ld	ra,8(sp)
    80001158:	6402                	ld	s0,0(sp)
    8000115a:	0141                	addi	sp,sp,16
    8000115c:	8082                	ret
    panic("kvmmap");
    8000115e:	00007517          	auipc	a0,0x7
    80001162:	f9a50513          	addi	a0,a0,-102 # 800080f8 <digits+0xb8>
    80001166:	fffff097          	auipc	ra,0xfffff
    8000116a:	3da080e7          	jalr	986(ra) # 80000540 <panic>

000000008000116e <kvmmake>:
{
    8000116e:	1101                	addi	sp,sp,-32
    80001170:	ec06                	sd	ra,24(sp)
    80001172:	e822                	sd	s0,16(sp)
    80001174:	e426                	sd	s1,8(sp)
    80001176:	e04a                	sd	s2,0(sp)
    80001178:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    8000117a:	00000097          	auipc	ra,0x0
    8000117e:	96c080e7          	jalr	-1684(ra) # 80000ae6 <kalloc>
    80001182:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80001184:	6605                	lui	a2,0x1
    80001186:	4581                	li	a1,0
    80001188:	00000097          	auipc	ra,0x0
    8000118c:	b4a080e7          	jalr	-1206(ra) # 80000cd2 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001190:	4719                	li	a4,6
    80001192:	6685                	lui	a3,0x1
    80001194:	10000637          	lui	a2,0x10000
    80001198:	100005b7          	lui	a1,0x10000
    8000119c:	8526                	mv	a0,s1
    8000119e:	00000097          	auipc	ra,0x0
    800011a2:	fa0080e7          	jalr	-96(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800011a6:	4719                	li	a4,6
    800011a8:	6685                	lui	a3,0x1
    800011aa:	10001637          	lui	a2,0x10001
    800011ae:	100015b7          	lui	a1,0x10001
    800011b2:	8526                	mv	a0,s1
    800011b4:	00000097          	auipc	ra,0x0
    800011b8:	f8a080e7          	jalr	-118(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800011bc:	4719                	li	a4,6
    800011be:	004006b7          	lui	a3,0x400
    800011c2:	0c000637          	lui	a2,0xc000
    800011c6:	0c0005b7          	lui	a1,0xc000
    800011ca:	8526                	mv	a0,s1
    800011cc:	00000097          	auipc	ra,0x0
    800011d0:	f72080e7          	jalr	-142(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800011d4:	00007917          	auipc	s2,0x7
    800011d8:	e2c90913          	addi	s2,s2,-468 # 80008000 <etext>
    800011dc:	4729                	li	a4,10
    800011de:	80007697          	auipc	a3,0x80007
    800011e2:	e2268693          	addi	a3,a3,-478 # 8000 <_entry-0x7fff8000>
    800011e6:	4605                	li	a2,1
    800011e8:	067e                	slli	a2,a2,0x1f
    800011ea:	85b2                	mv	a1,a2
    800011ec:	8526                	mv	a0,s1
    800011ee:	00000097          	auipc	ra,0x0
    800011f2:	f50080e7          	jalr	-176(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800011f6:	4719                	li	a4,6
    800011f8:	46c5                	li	a3,17
    800011fa:	06ee                	slli	a3,a3,0x1b
    800011fc:	412686b3          	sub	a3,a3,s2
    80001200:	864a                	mv	a2,s2
    80001202:	85ca                	mv	a1,s2
    80001204:	8526                	mv	a0,s1
    80001206:	00000097          	auipc	ra,0x0
    8000120a:	f38080e7          	jalr	-200(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    8000120e:	4729                	li	a4,10
    80001210:	6685                	lui	a3,0x1
    80001212:	00006617          	auipc	a2,0x6
    80001216:	dee60613          	addi	a2,a2,-530 # 80007000 <_trampoline>
    8000121a:	040005b7          	lui	a1,0x4000
    8000121e:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001220:	05b2                	slli	a1,a1,0xc
    80001222:	8526                	mv	a0,s1
    80001224:	00000097          	auipc	ra,0x0
    80001228:	f1a080e7          	jalr	-230(ra) # 8000113e <kvmmap>
  proc_mapstacks(kpgtbl);
    8000122c:	8526                	mv	a0,s1
    8000122e:	00000097          	auipc	ra,0x0
    80001232:	608080e7          	jalr	1544(ra) # 80001836 <proc_mapstacks>
}
    80001236:	8526                	mv	a0,s1
    80001238:	60e2                	ld	ra,24(sp)
    8000123a:	6442                	ld	s0,16(sp)
    8000123c:	64a2                	ld	s1,8(sp)
    8000123e:	6902                	ld	s2,0(sp)
    80001240:	6105                	addi	sp,sp,32
    80001242:	8082                	ret

0000000080001244 <kvminit>:
{
    80001244:	1141                	addi	sp,sp,-16
    80001246:	e406                	sd	ra,8(sp)
    80001248:	e022                	sd	s0,0(sp)
    8000124a:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    8000124c:	00000097          	auipc	ra,0x0
    80001250:	f22080e7          	jalr	-222(ra) # 8000116e <kvmmake>
    80001254:	00008797          	auipc	a5,0x8
    80001258:	8ca7b623          	sd	a0,-1844(a5) # 80008b20 <kernel_pagetable>
}
    8000125c:	60a2                	ld	ra,8(sp)
    8000125e:	6402                	ld	s0,0(sp)
    80001260:	0141                	addi	sp,sp,16
    80001262:	8082                	ret

0000000080001264 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001264:	715d                	addi	sp,sp,-80
    80001266:	e486                	sd	ra,72(sp)
    80001268:	e0a2                	sd	s0,64(sp)
    8000126a:	fc26                	sd	s1,56(sp)
    8000126c:	f84a                	sd	s2,48(sp)
    8000126e:	f44e                	sd	s3,40(sp)
    80001270:	f052                	sd	s4,32(sp)
    80001272:	ec56                	sd	s5,24(sp)
    80001274:	e85a                	sd	s6,16(sp)
    80001276:	e45e                	sd	s7,8(sp)
    80001278:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000127a:	03459793          	slli	a5,a1,0x34
    8000127e:	e795                	bnez	a5,800012aa <uvmunmap+0x46>
    80001280:	8a2a                	mv	s4,a0
    80001282:	892e                	mv	s2,a1
    80001284:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001286:	0632                	slli	a2,a2,0xc
    80001288:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    8000128c:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000128e:	6b05                	lui	s6,0x1
    80001290:	0735e263          	bltu	a1,s3,800012f4 <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    80001294:	60a6                	ld	ra,72(sp)
    80001296:	6406                	ld	s0,64(sp)
    80001298:	74e2                	ld	s1,56(sp)
    8000129a:	7942                	ld	s2,48(sp)
    8000129c:	79a2                	ld	s3,40(sp)
    8000129e:	7a02                	ld	s4,32(sp)
    800012a0:	6ae2                	ld	s5,24(sp)
    800012a2:	6b42                	ld	s6,16(sp)
    800012a4:	6ba2                	ld	s7,8(sp)
    800012a6:	6161                	addi	sp,sp,80
    800012a8:	8082                	ret
    panic("uvmunmap: not aligned");
    800012aa:	00007517          	auipc	a0,0x7
    800012ae:	e5650513          	addi	a0,a0,-426 # 80008100 <digits+0xc0>
    800012b2:	fffff097          	auipc	ra,0xfffff
    800012b6:	28e080e7          	jalr	654(ra) # 80000540 <panic>
      panic("uvmunmap: walk");
    800012ba:	00007517          	auipc	a0,0x7
    800012be:	e5e50513          	addi	a0,a0,-418 # 80008118 <digits+0xd8>
    800012c2:	fffff097          	auipc	ra,0xfffff
    800012c6:	27e080e7          	jalr	638(ra) # 80000540 <panic>
      panic("uvmunmap: not mapped");
    800012ca:	00007517          	auipc	a0,0x7
    800012ce:	e5e50513          	addi	a0,a0,-418 # 80008128 <digits+0xe8>
    800012d2:	fffff097          	auipc	ra,0xfffff
    800012d6:	26e080e7          	jalr	622(ra) # 80000540 <panic>
      panic("uvmunmap: not a leaf");
    800012da:	00007517          	auipc	a0,0x7
    800012de:	e6650513          	addi	a0,a0,-410 # 80008140 <digits+0x100>
    800012e2:	fffff097          	auipc	ra,0xfffff
    800012e6:	25e080e7          	jalr	606(ra) # 80000540 <panic>
    *pte = 0;
    800012ea:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012ee:	995a                	add	s2,s2,s6
    800012f0:	fb3972e3          	bgeu	s2,s3,80001294 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800012f4:	4601                	li	a2,0
    800012f6:	85ca                	mv	a1,s2
    800012f8:	8552                	mv	a0,s4
    800012fa:	00000097          	auipc	ra,0x0
    800012fe:	cbc080e7          	jalr	-836(ra) # 80000fb6 <walk>
    80001302:	84aa                	mv	s1,a0
    80001304:	d95d                	beqz	a0,800012ba <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    80001306:	6108                	ld	a0,0(a0)
    80001308:	00157793          	andi	a5,a0,1
    8000130c:	dfdd                	beqz	a5,800012ca <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    8000130e:	3ff57793          	andi	a5,a0,1023
    80001312:	fd7784e3          	beq	a5,s7,800012da <uvmunmap+0x76>
    if(do_free){
    80001316:	fc0a8ae3          	beqz	s5,800012ea <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    8000131a:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    8000131c:	0532                	slli	a0,a0,0xc
    8000131e:	fffff097          	auipc	ra,0xfffff
    80001322:	6ca080e7          	jalr	1738(ra) # 800009e8 <kfree>
    80001326:	b7d1                	j	800012ea <uvmunmap+0x86>

0000000080001328 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001328:	1101                	addi	sp,sp,-32
    8000132a:	ec06                	sd	ra,24(sp)
    8000132c:	e822                	sd	s0,16(sp)
    8000132e:	e426                	sd	s1,8(sp)
    80001330:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001332:	fffff097          	auipc	ra,0xfffff
    80001336:	7b4080e7          	jalr	1972(ra) # 80000ae6 <kalloc>
    8000133a:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000133c:	c519                	beqz	a0,8000134a <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000133e:	6605                	lui	a2,0x1
    80001340:	4581                	li	a1,0
    80001342:	00000097          	auipc	ra,0x0
    80001346:	990080e7          	jalr	-1648(ra) # 80000cd2 <memset>
  return pagetable;
}
    8000134a:	8526                	mv	a0,s1
    8000134c:	60e2                	ld	ra,24(sp)
    8000134e:	6442                	ld	s0,16(sp)
    80001350:	64a2                	ld	s1,8(sp)
    80001352:	6105                	addi	sp,sp,32
    80001354:	8082                	ret

0000000080001356 <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    80001356:	7179                	addi	sp,sp,-48
    80001358:	f406                	sd	ra,40(sp)
    8000135a:	f022                	sd	s0,32(sp)
    8000135c:	ec26                	sd	s1,24(sp)
    8000135e:	e84a                	sd	s2,16(sp)
    80001360:	e44e                	sd	s3,8(sp)
    80001362:	e052                	sd	s4,0(sp)
    80001364:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80001366:	6785                	lui	a5,0x1
    80001368:	04f67863          	bgeu	a2,a5,800013b8 <uvmfirst+0x62>
    8000136c:	8a2a                	mv	s4,a0
    8000136e:	89ae                	mv	s3,a1
    80001370:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    80001372:	fffff097          	auipc	ra,0xfffff
    80001376:	774080e7          	jalr	1908(ra) # 80000ae6 <kalloc>
    8000137a:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    8000137c:	6605                	lui	a2,0x1
    8000137e:	4581                	li	a1,0
    80001380:	00000097          	auipc	ra,0x0
    80001384:	952080e7          	jalr	-1710(ra) # 80000cd2 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001388:	4779                	li	a4,30
    8000138a:	86ca                	mv	a3,s2
    8000138c:	6605                	lui	a2,0x1
    8000138e:	4581                	li	a1,0
    80001390:	8552                	mv	a0,s4
    80001392:	00000097          	auipc	ra,0x0
    80001396:	d0c080e7          	jalr	-756(ra) # 8000109e <mappages>
  memmove(mem, src, sz);
    8000139a:	8626                	mv	a2,s1
    8000139c:	85ce                	mv	a1,s3
    8000139e:	854a                	mv	a0,s2
    800013a0:	00000097          	auipc	ra,0x0
    800013a4:	98e080e7          	jalr	-1650(ra) # 80000d2e <memmove>
}
    800013a8:	70a2                	ld	ra,40(sp)
    800013aa:	7402                	ld	s0,32(sp)
    800013ac:	64e2                	ld	s1,24(sp)
    800013ae:	6942                	ld	s2,16(sp)
    800013b0:	69a2                	ld	s3,8(sp)
    800013b2:	6a02                	ld	s4,0(sp)
    800013b4:	6145                	addi	sp,sp,48
    800013b6:	8082                	ret
    panic("uvmfirst: more than a page");
    800013b8:	00007517          	auipc	a0,0x7
    800013bc:	da050513          	addi	a0,a0,-608 # 80008158 <digits+0x118>
    800013c0:	fffff097          	auipc	ra,0xfffff
    800013c4:	180080e7          	jalr	384(ra) # 80000540 <panic>

00000000800013c8 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800013c8:	1101                	addi	sp,sp,-32
    800013ca:	ec06                	sd	ra,24(sp)
    800013cc:	e822                	sd	s0,16(sp)
    800013ce:	e426                	sd	s1,8(sp)
    800013d0:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800013d2:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800013d4:	00b67d63          	bgeu	a2,a1,800013ee <uvmdealloc+0x26>
    800013d8:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800013da:	6785                	lui	a5,0x1
    800013dc:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800013de:	00f60733          	add	a4,a2,a5
    800013e2:	76fd                	lui	a3,0xfffff
    800013e4:	8f75                	and	a4,a4,a3
    800013e6:	97ae                	add	a5,a5,a1
    800013e8:	8ff5                	and	a5,a5,a3
    800013ea:	00f76863          	bltu	a4,a5,800013fa <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800013ee:	8526                	mv	a0,s1
    800013f0:	60e2                	ld	ra,24(sp)
    800013f2:	6442                	ld	s0,16(sp)
    800013f4:	64a2                	ld	s1,8(sp)
    800013f6:	6105                	addi	sp,sp,32
    800013f8:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800013fa:	8f99                	sub	a5,a5,a4
    800013fc:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800013fe:	4685                	li	a3,1
    80001400:	0007861b          	sext.w	a2,a5
    80001404:	85ba                	mv	a1,a4
    80001406:	00000097          	auipc	ra,0x0
    8000140a:	e5e080e7          	jalr	-418(ra) # 80001264 <uvmunmap>
    8000140e:	b7c5                	j	800013ee <uvmdealloc+0x26>

0000000080001410 <uvmalloc>:
  if(newsz < oldsz)
    80001410:	0ab66563          	bltu	a2,a1,800014ba <uvmalloc+0xaa>
{
    80001414:	7139                	addi	sp,sp,-64
    80001416:	fc06                	sd	ra,56(sp)
    80001418:	f822                	sd	s0,48(sp)
    8000141a:	f426                	sd	s1,40(sp)
    8000141c:	f04a                	sd	s2,32(sp)
    8000141e:	ec4e                	sd	s3,24(sp)
    80001420:	e852                	sd	s4,16(sp)
    80001422:	e456                	sd	s5,8(sp)
    80001424:	e05a                	sd	s6,0(sp)
    80001426:	0080                	addi	s0,sp,64
    80001428:	8aaa                	mv	s5,a0
    8000142a:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    8000142c:	6785                	lui	a5,0x1
    8000142e:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001430:	95be                	add	a1,a1,a5
    80001432:	77fd                	lui	a5,0xfffff
    80001434:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001438:	08c9f363          	bgeu	s3,a2,800014be <uvmalloc+0xae>
    8000143c:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000143e:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    80001442:	fffff097          	auipc	ra,0xfffff
    80001446:	6a4080e7          	jalr	1700(ra) # 80000ae6 <kalloc>
    8000144a:	84aa                	mv	s1,a0
    if(mem == 0){
    8000144c:	c51d                	beqz	a0,8000147a <uvmalloc+0x6a>
    memset(mem, 0, PGSIZE);
    8000144e:	6605                	lui	a2,0x1
    80001450:	4581                	li	a1,0
    80001452:	00000097          	auipc	ra,0x0
    80001456:	880080e7          	jalr	-1920(ra) # 80000cd2 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000145a:	875a                	mv	a4,s6
    8000145c:	86a6                	mv	a3,s1
    8000145e:	6605                	lui	a2,0x1
    80001460:	85ca                	mv	a1,s2
    80001462:	8556                	mv	a0,s5
    80001464:	00000097          	auipc	ra,0x0
    80001468:	c3a080e7          	jalr	-966(ra) # 8000109e <mappages>
    8000146c:	e90d                	bnez	a0,8000149e <uvmalloc+0x8e>
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000146e:	6785                	lui	a5,0x1
    80001470:	993e                	add	s2,s2,a5
    80001472:	fd4968e3          	bltu	s2,s4,80001442 <uvmalloc+0x32>
  return newsz;
    80001476:	8552                	mv	a0,s4
    80001478:	a809                	j	8000148a <uvmalloc+0x7a>
      uvmdealloc(pagetable, a, oldsz);
    8000147a:	864e                	mv	a2,s3
    8000147c:	85ca                	mv	a1,s2
    8000147e:	8556                	mv	a0,s5
    80001480:	00000097          	auipc	ra,0x0
    80001484:	f48080e7          	jalr	-184(ra) # 800013c8 <uvmdealloc>
      return 0;
    80001488:	4501                	li	a0,0
}
    8000148a:	70e2                	ld	ra,56(sp)
    8000148c:	7442                	ld	s0,48(sp)
    8000148e:	74a2                	ld	s1,40(sp)
    80001490:	7902                	ld	s2,32(sp)
    80001492:	69e2                	ld	s3,24(sp)
    80001494:	6a42                	ld	s4,16(sp)
    80001496:	6aa2                	ld	s5,8(sp)
    80001498:	6b02                	ld	s6,0(sp)
    8000149a:	6121                	addi	sp,sp,64
    8000149c:	8082                	ret
      kfree(mem);
    8000149e:	8526                	mv	a0,s1
    800014a0:	fffff097          	auipc	ra,0xfffff
    800014a4:	548080e7          	jalr	1352(ra) # 800009e8 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800014a8:	864e                	mv	a2,s3
    800014aa:	85ca                	mv	a1,s2
    800014ac:	8556                	mv	a0,s5
    800014ae:	00000097          	auipc	ra,0x0
    800014b2:	f1a080e7          	jalr	-230(ra) # 800013c8 <uvmdealloc>
      return 0;
    800014b6:	4501                	li	a0,0
    800014b8:	bfc9                	j	8000148a <uvmalloc+0x7a>
    return oldsz;
    800014ba:	852e                	mv	a0,a1
}
    800014bc:	8082                	ret
  return newsz;
    800014be:	8532                	mv	a0,a2
    800014c0:	b7e9                	j	8000148a <uvmalloc+0x7a>

00000000800014c2 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800014c2:	7179                	addi	sp,sp,-48
    800014c4:	f406                	sd	ra,40(sp)
    800014c6:	f022                	sd	s0,32(sp)
    800014c8:	ec26                	sd	s1,24(sp)
    800014ca:	e84a                	sd	s2,16(sp)
    800014cc:	e44e                	sd	s3,8(sp)
    800014ce:	e052                	sd	s4,0(sp)
    800014d0:	1800                	addi	s0,sp,48
    800014d2:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800014d4:	84aa                	mv	s1,a0
    800014d6:	6905                	lui	s2,0x1
    800014d8:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014da:	4985                	li	s3,1
    800014dc:	a829                	j	800014f6 <freewalk+0x34>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800014de:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    800014e0:	00c79513          	slli	a0,a5,0xc
    800014e4:	00000097          	auipc	ra,0x0
    800014e8:	fde080e7          	jalr	-34(ra) # 800014c2 <freewalk>
      pagetable[i] = 0;
    800014ec:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800014f0:	04a1                	addi	s1,s1,8
    800014f2:	03248163          	beq	s1,s2,80001514 <freewalk+0x52>
    pte_t pte = pagetable[i];
    800014f6:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014f8:	00f7f713          	andi	a4,a5,15
    800014fc:	ff3701e3          	beq	a4,s3,800014de <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001500:	8b85                	andi	a5,a5,1
    80001502:	d7fd                	beqz	a5,800014f0 <freewalk+0x2e>
      panic("freewalk: leaf");
    80001504:	00007517          	auipc	a0,0x7
    80001508:	c7450513          	addi	a0,a0,-908 # 80008178 <digits+0x138>
    8000150c:	fffff097          	auipc	ra,0xfffff
    80001510:	034080e7          	jalr	52(ra) # 80000540 <panic>
    }
  }
  kfree((void*)pagetable);
    80001514:	8552                	mv	a0,s4
    80001516:	fffff097          	auipc	ra,0xfffff
    8000151a:	4d2080e7          	jalr	1234(ra) # 800009e8 <kfree>
}
    8000151e:	70a2                	ld	ra,40(sp)
    80001520:	7402                	ld	s0,32(sp)
    80001522:	64e2                	ld	s1,24(sp)
    80001524:	6942                	ld	s2,16(sp)
    80001526:	69a2                	ld	s3,8(sp)
    80001528:	6a02                	ld	s4,0(sp)
    8000152a:	6145                	addi	sp,sp,48
    8000152c:	8082                	ret

000000008000152e <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    8000152e:	1101                	addi	sp,sp,-32
    80001530:	ec06                	sd	ra,24(sp)
    80001532:	e822                	sd	s0,16(sp)
    80001534:	e426                	sd	s1,8(sp)
    80001536:	1000                	addi	s0,sp,32
    80001538:	84aa                	mv	s1,a0
  if(sz > 0)
    8000153a:	e999                	bnez	a1,80001550 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    8000153c:	8526                	mv	a0,s1
    8000153e:	00000097          	auipc	ra,0x0
    80001542:	f84080e7          	jalr	-124(ra) # 800014c2 <freewalk>
}
    80001546:	60e2                	ld	ra,24(sp)
    80001548:	6442                	ld	s0,16(sp)
    8000154a:	64a2                	ld	s1,8(sp)
    8000154c:	6105                	addi	sp,sp,32
    8000154e:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001550:	6785                	lui	a5,0x1
    80001552:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001554:	95be                	add	a1,a1,a5
    80001556:	4685                	li	a3,1
    80001558:	00c5d613          	srli	a2,a1,0xc
    8000155c:	4581                	li	a1,0
    8000155e:	00000097          	auipc	ra,0x0
    80001562:	d06080e7          	jalr	-762(ra) # 80001264 <uvmunmap>
    80001566:	bfd9                	j	8000153c <uvmfree+0xe>

0000000080001568 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001568:	c679                	beqz	a2,80001636 <uvmcopy+0xce>
{
    8000156a:	715d                	addi	sp,sp,-80
    8000156c:	e486                	sd	ra,72(sp)
    8000156e:	e0a2                	sd	s0,64(sp)
    80001570:	fc26                	sd	s1,56(sp)
    80001572:	f84a                	sd	s2,48(sp)
    80001574:	f44e                	sd	s3,40(sp)
    80001576:	f052                	sd	s4,32(sp)
    80001578:	ec56                	sd	s5,24(sp)
    8000157a:	e85a                	sd	s6,16(sp)
    8000157c:	e45e                	sd	s7,8(sp)
    8000157e:	0880                	addi	s0,sp,80
    80001580:	8b2a                	mv	s6,a0
    80001582:	8aae                	mv	s5,a1
    80001584:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001586:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001588:	4601                	li	a2,0
    8000158a:	85ce                	mv	a1,s3
    8000158c:	855a                	mv	a0,s6
    8000158e:	00000097          	auipc	ra,0x0
    80001592:	a28080e7          	jalr	-1496(ra) # 80000fb6 <walk>
    80001596:	c531                	beqz	a0,800015e2 <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80001598:	6118                	ld	a4,0(a0)
    8000159a:	00177793          	andi	a5,a4,1
    8000159e:	cbb1                	beqz	a5,800015f2 <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    800015a0:	00a75593          	srli	a1,a4,0xa
    800015a4:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800015a8:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800015ac:	fffff097          	auipc	ra,0xfffff
    800015b0:	53a080e7          	jalr	1338(ra) # 80000ae6 <kalloc>
    800015b4:	892a                	mv	s2,a0
    800015b6:	c939                	beqz	a0,8000160c <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800015b8:	6605                	lui	a2,0x1
    800015ba:	85de                	mv	a1,s7
    800015bc:	fffff097          	auipc	ra,0xfffff
    800015c0:	772080e7          	jalr	1906(ra) # 80000d2e <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800015c4:	8726                	mv	a4,s1
    800015c6:	86ca                	mv	a3,s2
    800015c8:	6605                	lui	a2,0x1
    800015ca:	85ce                	mv	a1,s3
    800015cc:	8556                	mv	a0,s5
    800015ce:	00000097          	auipc	ra,0x0
    800015d2:	ad0080e7          	jalr	-1328(ra) # 8000109e <mappages>
    800015d6:	e515                	bnez	a0,80001602 <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800015d8:	6785                	lui	a5,0x1
    800015da:	99be                	add	s3,s3,a5
    800015dc:	fb49e6e3          	bltu	s3,s4,80001588 <uvmcopy+0x20>
    800015e0:	a081                	j	80001620 <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800015e2:	00007517          	auipc	a0,0x7
    800015e6:	ba650513          	addi	a0,a0,-1114 # 80008188 <digits+0x148>
    800015ea:	fffff097          	auipc	ra,0xfffff
    800015ee:	f56080e7          	jalr	-170(ra) # 80000540 <panic>
      panic("uvmcopy: page not present");
    800015f2:	00007517          	auipc	a0,0x7
    800015f6:	bb650513          	addi	a0,a0,-1098 # 800081a8 <digits+0x168>
    800015fa:	fffff097          	auipc	ra,0xfffff
    800015fe:	f46080e7          	jalr	-186(ra) # 80000540 <panic>
      kfree(mem);
    80001602:	854a                	mv	a0,s2
    80001604:	fffff097          	auipc	ra,0xfffff
    80001608:	3e4080e7          	jalr	996(ra) # 800009e8 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    8000160c:	4685                	li	a3,1
    8000160e:	00c9d613          	srli	a2,s3,0xc
    80001612:	4581                	li	a1,0
    80001614:	8556                	mv	a0,s5
    80001616:	00000097          	auipc	ra,0x0
    8000161a:	c4e080e7          	jalr	-946(ra) # 80001264 <uvmunmap>
  return -1;
    8000161e:	557d                	li	a0,-1
}
    80001620:	60a6                	ld	ra,72(sp)
    80001622:	6406                	ld	s0,64(sp)
    80001624:	74e2                	ld	s1,56(sp)
    80001626:	7942                	ld	s2,48(sp)
    80001628:	79a2                	ld	s3,40(sp)
    8000162a:	7a02                	ld	s4,32(sp)
    8000162c:	6ae2                	ld	s5,24(sp)
    8000162e:	6b42                	ld	s6,16(sp)
    80001630:	6ba2                	ld	s7,8(sp)
    80001632:	6161                	addi	sp,sp,80
    80001634:	8082                	ret
  return 0;
    80001636:	4501                	li	a0,0
}
    80001638:	8082                	ret

000000008000163a <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    8000163a:	1141                	addi	sp,sp,-16
    8000163c:	e406                	sd	ra,8(sp)
    8000163e:	e022                	sd	s0,0(sp)
    80001640:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001642:	4601                	li	a2,0
    80001644:	00000097          	auipc	ra,0x0
    80001648:	972080e7          	jalr	-1678(ra) # 80000fb6 <walk>
  if(pte == 0)
    8000164c:	c901                	beqz	a0,8000165c <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    8000164e:	611c                	ld	a5,0(a0)
    80001650:	9bbd                	andi	a5,a5,-17
    80001652:	e11c                	sd	a5,0(a0)
}
    80001654:	60a2                	ld	ra,8(sp)
    80001656:	6402                	ld	s0,0(sp)
    80001658:	0141                	addi	sp,sp,16
    8000165a:	8082                	ret
    panic("uvmclear");
    8000165c:	00007517          	auipc	a0,0x7
    80001660:	b6c50513          	addi	a0,a0,-1172 # 800081c8 <digits+0x188>
    80001664:	fffff097          	auipc	ra,0xfffff
    80001668:	edc080e7          	jalr	-292(ra) # 80000540 <panic>

000000008000166c <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    8000166c:	c6bd                	beqz	a3,800016da <copyout+0x6e>
{
    8000166e:	715d                	addi	sp,sp,-80
    80001670:	e486                	sd	ra,72(sp)
    80001672:	e0a2                	sd	s0,64(sp)
    80001674:	fc26                	sd	s1,56(sp)
    80001676:	f84a                	sd	s2,48(sp)
    80001678:	f44e                	sd	s3,40(sp)
    8000167a:	f052                	sd	s4,32(sp)
    8000167c:	ec56                	sd	s5,24(sp)
    8000167e:	e85a                	sd	s6,16(sp)
    80001680:	e45e                	sd	s7,8(sp)
    80001682:	e062                	sd	s8,0(sp)
    80001684:	0880                	addi	s0,sp,80
    80001686:	8b2a                	mv	s6,a0
    80001688:	8c2e                	mv	s8,a1
    8000168a:	8a32                	mv	s4,a2
    8000168c:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    8000168e:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80001690:	6a85                	lui	s5,0x1
    80001692:	a015                	j	800016b6 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001694:	9562                	add	a0,a0,s8
    80001696:	0004861b          	sext.w	a2,s1
    8000169a:	85d2                	mv	a1,s4
    8000169c:	41250533          	sub	a0,a0,s2
    800016a0:	fffff097          	auipc	ra,0xfffff
    800016a4:	68e080e7          	jalr	1678(ra) # 80000d2e <memmove>

    len -= n;
    800016a8:	409989b3          	sub	s3,s3,s1
    src += n;
    800016ac:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    800016ae:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800016b2:	02098263          	beqz	s3,800016d6 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800016b6:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800016ba:	85ca                	mv	a1,s2
    800016bc:	855a                	mv	a0,s6
    800016be:	00000097          	auipc	ra,0x0
    800016c2:	99e080e7          	jalr	-1634(ra) # 8000105c <walkaddr>
    if(pa0 == 0)
    800016c6:	cd01                	beqz	a0,800016de <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800016c8:	418904b3          	sub	s1,s2,s8
    800016cc:	94d6                	add	s1,s1,s5
    800016ce:	fc99f3e3          	bgeu	s3,s1,80001694 <copyout+0x28>
    800016d2:	84ce                	mv	s1,s3
    800016d4:	b7c1                	j	80001694 <copyout+0x28>
  }
  return 0;
    800016d6:	4501                	li	a0,0
    800016d8:	a021                	j	800016e0 <copyout+0x74>
    800016da:	4501                	li	a0,0
}
    800016dc:	8082                	ret
      return -1;
    800016de:	557d                	li	a0,-1
}
    800016e0:	60a6                	ld	ra,72(sp)
    800016e2:	6406                	ld	s0,64(sp)
    800016e4:	74e2                	ld	s1,56(sp)
    800016e6:	7942                	ld	s2,48(sp)
    800016e8:	79a2                	ld	s3,40(sp)
    800016ea:	7a02                	ld	s4,32(sp)
    800016ec:	6ae2                	ld	s5,24(sp)
    800016ee:	6b42                	ld	s6,16(sp)
    800016f0:	6ba2                	ld	s7,8(sp)
    800016f2:	6c02                	ld	s8,0(sp)
    800016f4:	6161                	addi	sp,sp,80
    800016f6:	8082                	ret

00000000800016f8 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800016f8:	caa5                	beqz	a3,80001768 <copyin+0x70>
{
    800016fa:	715d                	addi	sp,sp,-80
    800016fc:	e486                	sd	ra,72(sp)
    800016fe:	e0a2                	sd	s0,64(sp)
    80001700:	fc26                	sd	s1,56(sp)
    80001702:	f84a                	sd	s2,48(sp)
    80001704:	f44e                	sd	s3,40(sp)
    80001706:	f052                	sd	s4,32(sp)
    80001708:	ec56                	sd	s5,24(sp)
    8000170a:	e85a                	sd	s6,16(sp)
    8000170c:	e45e                	sd	s7,8(sp)
    8000170e:	e062                	sd	s8,0(sp)
    80001710:	0880                	addi	s0,sp,80
    80001712:	8b2a                	mv	s6,a0
    80001714:	8a2e                	mv	s4,a1
    80001716:	8c32                	mv	s8,a2
    80001718:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    8000171a:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000171c:	6a85                	lui	s5,0x1
    8000171e:	a01d                	j	80001744 <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001720:	018505b3          	add	a1,a0,s8
    80001724:	0004861b          	sext.w	a2,s1
    80001728:	412585b3          	sub	a1,a1,s2
    8000172c:	8552                	mv	a0,s4
    8000172e:	fffff097          	auipc	ra,0xfffff
    80001732:	600080e7          	jalr	1536(ra) # 80000d2e <memmove>

    len -= n;
    80001736:	409989b3          	sub	s3,s3,s1
    dst += n;
    8000173a:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    8000173c:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001740:	02098263          	beqz	s3,80001764 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    80001744:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001748:	85ca                	mv	a1,s2
    8000174a:	855a                	mv	a0,s6
    8000174c:	00000097          	auipc	ra,0x0
    80001750:	910080e7          	jalr	-1776(ra) # 8000105c <walkaddr>
    if(pa0 == 0)
    80001754:	cd01                	beqz	a0,8000176c <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001756:	418904b3          	sub	s1,s2,s8
    8000175a:	94d6                	add	s1,s1,s5
    8000175c:	fc99f2e3          	bgeu	s3,s1,80001720 <copyin+0x28>
    80001760:	84ce                	mv	s1,s3
    80001762:	bf7d                	j	80001720 <copyin+0x28>
  }
  return 0;
    80001764:	4501                	li	a0,0
    80001766:	a021                	j	8000176e <copyin+0x76>
    80001768:	4501                	li	a0,0
}
    8000176a:	8082                	ret
      return -1;
    8000176c:	557d                	li	a0,-1
}
    8000176e:	60a6                	ld	ra,72(sp)
    80001770:	6406                	ld	s0,64(sp)
    80001772:	74e2                	ld	s1,56(sp)
    80001774:	7942                	ld	s2,48(sp)
    80001776:	79a2                	ld	s3,40(sp)
    80001778:	7a02                	ld	s4,32(sp)
    8000177a:	6ae2                	ld	s5,24(sp)
    8000177c:	6b42                	ld	s6,16(sp)
    8000177e:	6ba2                	ld	s7,8(sp)
    80001780:	6c02                	ld	s8,0(sp)
    80001782:	6161                	addi	sp,sp,80
    80001784:	8082                	ret

0000000080001786 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001786:	c2dd                	beqz	a3,8000182c <copyinstr+0xa6>
{
    80001788:	715d                	addi	sp,sp,-80
    8000178a:	e486                	sd	ra,72(sp)
    8000178c:	e0a2                	sd	s0,64(sp)
    8000178e:	fc26                	sd	s1,56(sp)
    80001790:	f84a                	sd	s2,48(sp)
    80001792:	f44e                	sd	s3,40(sp)
    80001794:	f052                	sd	s4,32(sp)
    80001796:	ec56                	sd	s5,24(sp)
    80001798:	e85a                	sd	s6,16(sp)
    8000179a:	e45e                	sd	s7,8(sp)
    8000179c:	0880                	addi	s0,sp,80
    8000179e:	8a2a                	mv	s4,a0
    800017a0:	8b2e                	mv	s6,a1
    800017a2:	8bb2                	mv	s7,a2
    800017a4:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    800017a6:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017a8:	6985                	lui	s3,0x1
    800017aa:	a02d                	j	800017d4 <copyinstr+0x4e>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800017ac:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800017b0:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800017b2:	37fd                	addiw	a5,a5,-1
    800017b4:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800017b8:	60a6                	ld	ra,72(sp)
    800017ba:	6406                	ld	s0,64(sp)
    800017bc:	74e2                	ld	s1,56(sp)
    800017be:	7942                	ld	s2,48(sp)
    800017c0:	79a2                	ld	s3,40(sp)
    800017c2:	7a02                	ld	s4,32(sp)
    800017c4:	6ae2                	ld	s5,24(sp)
    800017c6:	6b42                	ld	s6,16(sp)
    800017c8:	6ba2                	ld	s7,8(sp)
    800017ca:	6161                	addi	sp,sp,80
    800017cc:	8082                	ret
    srcva = va0 + PGSIZE;
    800017ce:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800017d2:	c8a9                	beqz	s1,80001824 <copyinstr+0x9e>
    va0 = PGROUNDDOWN(srcva);
    800017d4:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800017d8:	85ca                	mv	a1,s2
    800017da:	8552                	mv	a0,s4
    800017dc:	00000097          	auipc	ra,0x0
    800017e0:	880080e7          	jalr	-1920(ra) # 8000105c <walkaddr>
    if(pa0 == 0)
    800017e4:	c131                	beqz	a0,80001828 <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    800017e6:	417906b3          	sub	a3,s2,s7
    800017ea:	96ce                	add	a3,a3,s3
    800017ec:	00d4f363          	bgeu	s1,a3,800017f2 <copyinstr+0x6c>
    800017f0:	86a6                	mv	a3,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800017f2:	955e                	add	a0,a0,s7
    800017f4:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800017f8:	daf9                	beqz	a3,800017ce <copyinstr+0x48>
    800017fa:	87da                	mv	a5,s6
      if(*p == '\0'){
    800017fc:	41650633          	sub	a2,a0,s6
    80001800:	fff48593          	addi	a1,s1,-1
    80001804:	95da                	add	a1,a1,s6
    while(n > 0){
    80001806:	96da                	add	a3,a3,s6
      if(*p == '\0'){
    80001808:	00f60733          	add	a4,a2,a5
    8000180c:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffdc850>
    80001810:	df51                	beqz	a4,800017ac <copyinstr+0x26>
        *dst = *p;
    80001812:	00e78023          	sb	a4,0(a5)
      --max;
    80001816:	40f584b3          	sub	s1,a1,a5
      dst++;
    8000181a:	0785                	addi	a5,a5,1
    while(n > 0){
    8000181c:	fed796e3          	bne	a5,a3,80001808 <copyinstr+0x82>
      dst++;
    80001820:	8b3e                	mv	s6,a5
    80001822:	b775                	j	800017ce <copyinstr+0x48>
    80001824:	4781                	li	a5,0
    80001826:	b771                	j	800017b2 <copyinstr+0x2c>
      return -1;
    80001828:	557d                	li	a0,-1
    8000182a:	b779                	j	800017b8 <copyinstr+0x32>
  int got_null = 0;
    8000182c:	4781                	li	a5,0
  if(got_null){
    8000182e:	37fd                	addiw	a5,a5,-1
    80001830:	0007851b          	sext.w	a0,a5
}
    80001834:	8082                	ret

0000000080001836 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80001836:	7139                	addi	sp,sp,-64
    80001838:	fc06                	sd	ra,56(sp)
    8000183a:	f822                	sd	s0,48(sp)
    8000183c:	f426                	sd	s1,40(sp)
    8000183e:	f04a                	sd	s2,32(sp)
    80001840:	ec4e                	sd	s3,24(sp)
    80001842:	e852                	sd	s4,16(sp)
    80001844:	e456                	sd	s5,8(sp)
    80001846:	e05a                	sd	s6,0(sp)
    80001848:	0080                	addi	s0,sp,64
    8000184a:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    8000184c:	00010497          	auipc	s1,0x10
    80001850:	98448493          	addi	s1,s1,-1660 # 800111d0 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80001854:	8b26                	mv	s6,s1
    80001856:	00006a97          	auipc	s5,0x6
    8000185a:	7aaa8a93          	addi	s5,s5,1962 # 80008000 <etext>
    8000185e:	04000937          	lui	s2,0x4000
    80001862:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80001864:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001866:	00016a17          	auipc	s4,0x16
    8000186a:	b6aa0a13          	addi	s4,s4,-1174 # 800173d0 <tickslock>
    char *pa = kalloc();
    8000186e:	fffff097          	auipc	ra,0xfffff
    80001872:	278080e7          	jalr	632(ra) # 80000ae6 <kalloc>
    80001876:	862a                	mv	a2,a0
    if(pa == 0)
    80001878:	c131                	beqz	a0,800018bc <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    8000187a:	416485b3          	sub	a1,s1,s6
    8000187e:	858d                	srai	a1,a1,0x3
    80001880:	000ab783          	ld	a5,0(s5)
    80001884:	02f585b3          	mul	a1,a1,a5
    80001888:	2585                	addiw	a1,a1,1
    8000188a:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    8000188e:	4719                	li	a4,6
    80001890:	6685                	lui	a3,0x1
    80001892:	40b905b3          	sub	a1,s2,a1
    80001896:	854e                	mv	a0,s3
    80001898:	00000097          	auipc	ra,0x0
    8000189c:	8a6080e7          	jalr	-1882(ra) # 8000113e <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    800018a0:	18848493          	addi	s1,s1,392
    800018a4:	fd4495e3          	bne	s1,s4,8000186e <proc_mapstacks+0x38>
  }
}
    800018a8:	70e2                	ld	ra,56(sp)
    800018aa:	7442                	ld	s0,48(sp)
    800018ac:	74a2                	ld	s1,40(sp)
    800018ae:	7902                	ld	s2,32(sp)
    800018b0:	69e2                	ld	s3,24(sp)
    800018b2:	6a42                	ld	s4,16(sp)
    800018b4:	6aa2                	ld	s5,8(sp)
    800018b6:	6b02                	ld	s6,0(sp)
    800018b8:	6121                	addi	sp,sp,64
    800018ba:	8082                	ret
      panic("kalloc");
    800018bc:	00007517          	auipc	a0,0x7
    800018c0:	91c50513          	addi	a0,a0,-1764 # 800081d8 <digits+0x198>
    800018c4:	fffff097          	auipc	ra,0xfffff
    800018c8:	c7c080e7          	jalr	-900(ra) # 80000540 <panic>

00000000800018cc <procinit>:

// initialize the proc table.
void
procinit(void)
{
    800018cc:	7139                	addi	sp,sp,-64
    800018ce:	fc06                	sd	ra,56(sp)
    800018d0:	f822                	sd	s0,48(sp)
    800018d2:	f426                	sd	s1,40(sp)
    800018d4:	f04a                	sd	s2,32(sp)
    800018d6:	ec4e                	sd	s3,24(sp)
    800018d8:	e852                	sd	s4,16(sp)
    800018da:	e456                	sd	s5,8(sp)
    800018dc:	e05a                	sd	s6,0(sp)
    800018de:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    800018e0:	00007597          	auipc	a1,0x7
    800018e4:	90058593          	addi	a1,a1,-1792 # 800081e0 <digits+0x1a0>
    800018e8:	0000f517          	auipc	a0,0xf
    800018ec:	4b850513          	addi	a0,a0,1208 # 80010da0 <pid_lock>
    800018f0:	fffff097          	auipc	ra,0xfffff
    800018f4:	256080e7          	jalr	598(ra) # 80000b46 <initlock>
  initlock(&wait_lock, "wait_lock");
    800018f8:	00007597          	auipc	a1,0x7
    800018fc:	8f058593          	addi	a1,a1,-1808 # 800081e8 <digits+0x1a8>
    80001900:	0000f517          	auipc	a0,0xf
    80001904:	4b850513          	addi	a0,a0,1208 # 80010db8 <wait_lock>
    80001908:	fffff097          	auipc	ra,0xfffff
    8000190c:	23e080e7          	jalr	574(ra) # 80000b46 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001910:	00010497          	auipc	s1,0x10
    80001914:	8c048493          	addi	s1,s1,-1856 # 800111d0 <proc>
      initlock(&p->lock, "proc");
    80001918:	00007b17          	auipc	s6,0x7
    8000191c:	8e0b0b13          	addi	s6,s6,-1824 # 800081f8 <digits+0x1b8>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    80001920:	8aa6                	mv	s5,s1
    80001922:	00006a17          	auipc	s4,0x6
    80001926:	6dea0a13          	addi	s4,s4,1758 # 80008000 <etext>
    8000192a:	04000937          	lui	s2,0x4000
    8000192e:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80001930:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001932:	00016997          	auipc	s3,0x16
    80001936:	a9e98993          	addi	s3,s3,-1378 # 800173d0 <tickslock>
      initlock(&p->lock, "proc");
    8000193a:	85da                	mv	a1,s6
    8000193c:	8526                	mv	a0,s1
    8000193e:	fffff097          	auipc	ra,0xfffff
    80001942:	208080e7          	jalr	520(ra) # 80000b46 <initlock>
      p->state = UNUSED;
    80001946:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    8000194a:	415487b3          	sub	a5,s1,s5
    8000194e:	878d                	srai	a5,a5,0x3
    80001950:	000a3703          	ld	a4,0(s4)
    80001954:	02e787b3          	mul	a5,a5,a4
    80001958:	2785                	addiw	a5,a5,1
    8000195a:	00d7979b          	slliw	a5,a5,0xd
    8000195e:	40f907b3          	sub	a5,s2,a5
    80001962:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001964:	18848493          	addi	s1,s1,392
    80001968:	fd3499e3          	bne	s1,s3,8000193a <procinit+0x6e>
  }
}
    8000196c:	70e2                	ld	ra,56(sp)
    8000196e:	7442                	ld	s0,48(sp)
    80001970:	74a2                	ld	s1,40(sp)
    80001972:	7902                	ld	s2,32(sp)
    80001974:	69e2                	ld	s3,24(sp)
    80001976:	6a42                	ld	s4,16(sp)
    80001978:	6aa2                	ld	s5,8(sp)
    8000197a:	6b02                	ld	s6,0(sp)
    8000197c:	6121                	addi	sp,sp,64
    8000197e:	8082                	ret

0000000080001980 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001980:	1141                	addi	sp,sp,-16
    80001982:	e422                	sd	s0,8(sp)
    80001984:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001986:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001988:	2501                	sext.w	a0,a0
    8000198a:	6422                	ld	s0,8(sp)
    8000198c:	0141                	addi	sp,sp,16
    8000198e:	8082                	ret

0000000080001990 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    80001990:	1141                	addi	sp,sp,-16
    80001992:	e422                	sd	s0,8(sp)
    80001994:	0800                	addi	s0,sp,16
    80001996:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001998:	2781                	sext.w	a5,a5
    8000199a:	079e                	slli	a5,a5,0x7
  return c;
}
    8000199c:	0000f517          	auipc	a0,0xf
    800019a0:	43450513          	addi	a0,a0,1076 # 80010dd0 <cpus>
    800019a4:	953e                	add	a0,a0,a5
    800019a6:	6422                	ld	s0,8(sp)
    800019a8:	0141                	addi	sp,sp,16
    800019aa:	8082                	ret

00000000800019ac <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    800019ac:	1101                	addi	sp,sp,-32
    800019ae:	ec06                	sd	ra,24(sp)
    800019b0:	e822                	sd	s0,16(sp)
    800019b2:	e426                	sd	s1,8(sp)
    800019b4:	1000                	addi	s0,sp,32
  push_off();
    800019b6:	fffff097          	auipc	ra,0xfffff
    800019ba:	1d4080e7          	jalr	468(ra) # 80000b8a <push_off>
    800019be:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800019c0:	2781                	sext.w	a5,a5
    800019c2:	079e                	slli	a5,a5,0x7
    800019c4:	0000f717          	auipc	a4,0xf
    800019c8:	3dc70713          	addi	a4,a4,988 # 80010da0 <pid_lock>
    800019cc:	97ba                	add	a5,a5,a4
    800019ce:	7b84                	ld	s1,48(a5)
  pop_off();
    800019d0:	fffff097          	auipc	ra,0xfffff
    800019d4:	25a080e7          	jalr	602(ra) # 80000c2a <pop_off>
  return p;
}
    800019d8:	8526                	mv	a0,s1
    800019da:	60e2                	ld	ra,24(sp)
    800019dc:	6442                	ld	s0,16(sp)
    800019de:	64a2                	ld	s1,8(sp)
    800019e0:	6105                	addi	sp,sp,32
    800019e2:	8082                	ret

00000000800019e4 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    800019e4:	1141                	addi	sp,sp,-16
    800019e6:	e406                	sd	ra,8(sp)
    800019e8:	e022                	sd	s0,0(sp)
    800019ea:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    800019ec:	00000097          	auipc	ra,0x0
    800019f0:	fc0080e7          	jalr	-64(ra) # 800019ac <myproc>
    800019f4:	fffff097          	auipc	ra,0xfffff
    800019f8:	296080e7          	jalr	662(ra) # 80000c8a <release>

  if (first) {
    800019fc:	00007797          	auipc	a5,0x7
    80001a00:	0347a783          	lw	a5,52(a5) # 80008a30 <first.1>
    80001a04:	eb89                	bnez	a5,80001a16 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001a06:	00001097          	auipc	ra,0x1
    80001a0a:	ec2080e7          	jalr	-318(ra) # 800028c8 <usertrapret>
}
    80001a0e:	60a2                	ld	ra,8(sp)
    80001a10:	6402                	ld	s0,0(sp)
    80001a12:	0141                	addi	sp,sp,16
    80001a14:	8082                	ret
    first = 0;
    80001a16:	00007797          	auipc	a5,0x7
    80001a1a:	0007ad23          	sw	zero,26(a5) # 80008a30 <first.1>
    fsinit(ROOTDEV);
    80001a1e:	4505                	li	a0,1
    80001a20:	00002097          	auipc	ra,0x2
    80001a24:	e1c080e7          	jalr	-484(ra) # 8000383c <fsinit>
    80001a28:	bff9                	j	80001a06 <forkret+0x22>

0000000080001a2a <allocpid>:
{
    80001a2a:	1101                	addi	sp,sp,-32
    80001a2c:	ec06                	sd	ra,24(sp)
    80001a2e:	e822                	sd	s0,16(sp)
    80001a30:	e426                	sd	s1,8(sp)
    80001a32:	e04a                	sd	s2,0(sp)
    80001a34:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a36:	0000f917          	auipc	s2,0xf
    80001a3a:	36a90913          	addi	s2,s2,874 # 80010da0 <pid_lock>
    80001a3e:	854a                	mv	a0,s2
    80001a40:	fffff097          	auipc	ra,0xfffff
    80001a44:	196080e7          	jalr	406(ra) # 80000bd6 <acquire>
  pid = nextpid;
    80001a48:	00007797          	auipc	a5,0x7
    80001a4c:	fec78793          	addi	a5,a5,-20 # 80008a34 <nextpid>
    80001a50:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a52:	0014871b          	addiw	a4,s1,1
    80001a56:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a58:	854a                	mv	a0,s2
    80001a5a:	fffff097          	auipc	ra,0xfffff
    80001a5e:	230080e7          	jalr	560(ra) # 80000c8a <release>
}
    80001a62:	8526                	mv	a0,s1
    80001a64:	60e2                	ld	ra,24(sp)
    80001a66:	6442                	ld	s0,16(sp)
    80001a68:	64a2                	ld	s1,8(sp)
    80001a6a:	6902                	ld	s2,0(sp)
    80001a6c:	6105                	addi	sp,sp,32
    80001a6e:	8082                	ret

0000000080001a70 <proc_pagetable>:
{
    80001a70:	1101                	addi	sp,sp,-32
    80001a72:	ec06                	sd	ra,24(sp)
    80001a74:	e822                	sd	s0,16(sp)
    80001a76:	e426                	sd	s1,8(sp)
    80001a78:	e04a                	sd	s2,0(sp)
    80001a7a:	1000                	addi	s0,sp,32
    80001a7c:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001a7e:	00000097          	auipc	ra,0x0
    80001a82:	8aa080e7          	jalr	-1878(ra) # 80001328 <uvmcreate>
    80001a86:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001a88:	c121                	beqz	a0,80001ac8 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001a8a:	4729                	li	a4,10
    80001a8c:	00005697          	auipc	a3,0x5
    80001a90:	57468693          	addi	a3,a3,1396 # 80007000 <_trampoline>
    80001a94:	6605                	lui	a2,0x1
    80001a96:	040005b7          	lui	a1,0x4000
    80001a9a:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a9c:	05b2                	slli	a1,a1,0xc
    80001a9e:	fffff097          	auipc	ra,0xfffff
    80001aa2:	600080e7          	jalr	1536(ra) # 8000109e <mappages>
    80001aa6:	02054863          	bltz	a0,80001ad6 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001aaa:	4719                	li	a4,6
    80001aac:	05893683          	ld	a3,88(s2)
    80001ab0:	6605                	lui	a2,0x1
    80001ab2:	020005b7          	lui	a1,0x2000
    80001ab6:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001ab8:	05b6                	slli	a1,a1,0xd
    80001aba:	8526                	mv	a0,s1
    80001abc:	fffff097          	auipc	ra,0xfffff
    80001ac0:	5e2080e7          	jalr	1506(ra) # 8000109e <mappages>
    80001ac4:	02054163          	bltz	a0,80001ae6 <proc_pagetable+0x76>
}
    80001ac8:	8526                	mv	a0,s1
    80001aca:	60e2                	ld	ra,24(sp)
    80001acc:	6442                	ld	s0,16(sp)
    80001ace:	64a2                	ld	s1,8(sp)
    80001ad0:	6902                	ld	s2,0(sp)
    80001ad2:	6105                	addi	sp,sp,32
    80001ad4:	8082                	ret
    uvmfree(pagetable, 0);
    80001ad6:	4581                	li	a1,0
    80001ad8:	8526                	mv	a0,s1
    80001ada:	00000097          	auipc	ra,0x0
    80001ade:	a54080e7          	jalr	-1452(ra) # 8000152e <uvmfree>
    return 0;
    80001ae2:	4481                	li	s1,0
    80001ae4:	b7d5                	j	80001ac8 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001ae6:	4681                	li	a3,0
    80001ae8:	4605                	li	a2,1
    80001aea:	040005b7          	lui	a1,0x4000
    80001aee:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001af0:	05b2                	slli	a1,a1,0xc
    80001af2:	8526                	mv	a0,s1
    80001af4:	fffff097          	auipc	ra,0xfffff
    80001af8:	770080e7          	jalr	1904(ra) # 80001264 <uvmunmap>
    uvmfree(pagetable, 0);
    80001afc:	4581                	li	a1,0
    80001afe:	8526                	mv	a0,s1
    80001b00:	00000097          	auipc	ra,0x0
    80001b04:	a2e080e7          	jalr	-1490(ra) # 8000152e <uvmfree>
    return 0;
    80001b08:	4481                	li	s1,0
    80001b0a:	bf7d                	j	80001ac8 <proc_pagetable+0x58>

0000000080001b0c <proc_freepagetable>:
{
    80001b0c:	1101                	addi	sp,sp,-32
    80001b0e:	ec06                	sd	ra,24(sp)
    80001b10:	e822                	sd	s0,16(sp)
    80001b12:	e426                	sd	s1,8(sp)
    80001b14:	e04a                	sd	s2,0(sp)
    80001b16:	1000                	addi	s0,sp,32
    80001b18:	84aa                	mv	s1,a0
    80001b1a:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b1c:	4681                	li	a3,0
    80001b1e:	4605                	li	a2,1
    80001b20:	040005b7          	lui	a1,0x4000
    80001b24:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b26:	05b2                	slli	a1,a1,0xc
    80001b28:	fffff097          	auipc	ra,0xfffff
    80001b2c:	73c080e7          	jalr	1852(ra) # 80001264 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001b30:	4681                	li	a3,0
    80001b32:	4605                	li	a2,1
    80001b34:	020005b7          	lui	a1,0x2000
    80001b38:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001b3a:	05b6                	slli	a1,a1,0xd
    80001b3c:	8526                	mv	a0,s1
    80001b3e:	fffff097          	auipc	ra,0xfffff
    80001b42:	726080e7          	jalr	1830(ra) # 80001264 <uvmunmap>
  uvmfree(pagetable, sz);
    80001b46:	85ca                	mv	a1,s2
    80001b48:	8526                	mv	a0,s1
    80001b4a:	00000097          	auipc	ra,0x0
    80001b4e:	9e4080e7          	jalr	-1564(ra) # 8000152e <uvmfree>
}
    80001b52:	60e2                	ld	ra,24(sp)
    80001b54:	6442                	ld	s0,16(sp)
    80001b56:	64a2                	ld	s1,8(sp)
    80001b58:	6902                	ld	s2,0(sp)
    80001b5a:	6105                	addi	sp,sp,32
    80001b5c:	8082                	ret

0000000080001b5e <freeproc>:
{
    80001b5e:	1101                	addi	sp,sp,-32
    80001b60:	ec06                	sd	ra,24(sp)
    80001b62:	e822                	sd	s0,16(sp)
    80001b64:	e426                	sd	s1,8(sp)
    80001b66:	1000                	addi	s0,sp,32
    80001b68:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001b6a:	6d28                	ld	a0,88(a0)
    80001b6c:	c509                	beqz	a0,80001b76 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001b6e:	fffff097          	auipc	ra,0xfffff
    80001b72:	e7a080e7          	jalr	-390(ra) # 800009e8 <kfree>
  p->trapframe = 0;
    80001b76:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001b7a:	68a8                	ld	a0,80(s1)
    80001b7c:	c511                	beqz	a0,80001b88 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001b7e:	64ac                	ld	a1,72(s1)
    80001b80:	00000097          	auipc	ra,0x0
    80001b84:	f8c080e7          	jalr	-116(ra) # 80001b0c <proc_freepagetable>
  p->pagetable = 0;
    80001b88:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001b8c:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001b90:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001b94:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001b98:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001b9c:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001ba0:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001ba4:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001ba8:	0004ac23          	sw	zero,24(s1)
}
    80001bac:	60e2                	ld	ra,24(sp)
    80001bae:	6442                	ld	s0,16(sp)
    80001bb0:	64a2                	ld	s1,8(sp)
    80001bb2:	6105                	addi	sp,sp,32
    80001bb4:	8082                	ret

0000000080001bb6 <allocproc>:
{
    80001bb6:	1101                	addi	sp,sp,-32
    80001bb8:	ec06                	sd	ra,24(sp)
    80001bba:	e822                	sd	s0,16(sp)
    80001bbc:	e426                	sd	s1,8(sp)
    80001bbe:	e04a                	sd	s2,0(sp)
    80001bc0:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bc2:	0000f497          	auipc	s1,0xf
    80001bc6:	60e48493          	addi	s1,s1,1550 # 800111d0 <proc>
    80001bca:	00016917          	auipc	s2,0x16
    80001bce:	80690913          	addi	s2,s2,-2042 # 800173d0 <tickslock>
    acquire(&p->lock);
    80001bd2:	8526                	mv	a0,s1
    80001bd4:	fffff097          	auipc	ra,0xfffff
    80001bd8:	002080e7          	jalr	2(ra) # 80000bd6 <acquire>
    if(p->state == UNUSED) {
    80001bdc:	4c9c                	lw	a5,24(s1)
    80001bde:	cf81                	beqz	a5,80001bf6 <allocproc+0x40>
      release(&p->lock);
    80001be0:	8526                	mv	a0,s1
    80001be2:	fffff097          	auipc	ra,0xfffff
    80001be6:	0a8080e7          	jalr	168(ra) # 80000c8a <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bea:	18848493          	addi	s1,s1,392
    80001bee:	ff2492e3          	bne	s1,s2,80001bd2 <allocproc+0x1c>
  return 0;
    80001bf2:	4481                	li	s1,0
    80001bf4:	a0bd                	j	80001c62 <allocproc+0xac>
  p->pid = allocpid();
    80001bf6:	00000097          	auipc	ra,0x0
    80001bfa:	e34080e7          	jalr	-460(ra) # 80001a2a <allocpid>
    80001bfe:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001c00:	4785                	li	a5,1
    80001c02:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001c04:	fffff097          	auipc	ra,0xfffff
    80001c08:	ee2080e7          	jalr	-286(ra) # 80000ae6 <kalloc>
    80001c0c:	892a                	mv	s2,a0
    80001c0e:	eca8                	sd	a0,88(s1)
    80001c10:	c125                	beqz	a0,80001c70 <allocproc+0xba>
  p->pagetable = proc_pagetable(p);
    80001c12:	8526                	mv	a0,s1
    80001c14:	00000097          	auipc	ra,0x0
    80001c18:	e5c080e7          	jalr	-420(ra) # 80001a70 <proc_pagetable>
    80001c1c:	892a                	mv	s2,a0
    80001c1e:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001c20:	c525                	beqz	a0,80001c88 <allocproc+0xd2>
  memset(&p->context, 0, sizeof(p->context));
    80001c22:	07000613          	li	a2,112
    80001c26:	4581                	li	a1,0
    80001c28:	06048513          	addi	a0,s1,96
    80001c2c:	fffff097          	auipc	ra,0xfffff
    80001c30:	0a6080e7          	jalr	166(ra) # 80000cd2 <memset>
  p->context.ra = (uint64)forkret;
    80001c34:	00000797          	auipc	a5,0x0
    80001c38:	db078793          	addi	a5,a5,-592 # 800019e4 <forkret>
    80001c3c:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c3e:	60bc                	ld	a5,64(s1)
    80001c40:	6705                	lui	a4,0x1
    80001c42:	97ba                	add	a5,a5,a4
    80001c44:	f4bc                	sd	a5,104(s1)
  	  p->rtime = 0;	
    80001c46:	1604ac23          	sw	zero,376(s1)
  p->etime = 0;	
    80001c4a:	1804a023          	sw	zero,384(s1)
  p->ctime = ticks;	
    80001c4e:	00007797          	auipc	a5,0x7
    80001c52:	ee27a783          	lw	a5,-286(a5) # 80008b30 <ticks>
    80001c56:	16f4ae23          	sw	a5,380(s1)
  p->mask = 0;	
    80001c5a:	1604a423          	sw	zero,360(s1)
  p->no_of_times_scheduled = 0;	
    80001c5e:	1804a223          	sw	zero,388(s1)
}
    80001c62:	8526                	mv	a0,s1
    80001c64:	60e2                	ld	ra,24(sp)
    80001c66:	6442                	ld	s0,16(sp)
    80001c68:	64a2                	ld	s1,8(sp)
    80001c6a:	6902                	ld	s2,0(sp)
    80001c6c:	6105                	addi	sp,sp,32
    80001c6e:	8082                	ret
    freeproc(p);
    80001c70:	8526                	mv	a0,s1
    80001c72:	00000097          	auipc	ra,0x0
    80001c76:	eec080e7          	jalr	-276(ra) # 80001b5e <freeproc>
    release(&p->lock);
    80001c7a:	8526                	mv	a0,s1
    80001c7c:	fffff097          	auipc	ra,0xfffff
    80001c80:	00e080e7          	jalr	14(ra) # 80000c8a <release>
    return 0;
    80001c84:	84ca                	mv	s1,s2
    80001c86:	bff1                	j	80001c62 <allocproc+0xac>
    freeproc(p);
    80001c88:	8526                	mv	a0,s1
    80001c8a:	00000097          	auipc	ra,0x0
    80001c8e:	ed4080e7          	jalr	-300(ra) # 80001b5e <freeproc>
    release(&p->lock);
    80001c92:	8526                	mv	a0,s1
    80001c94:	fffff097          	auipc	ra,0xfffff
    80001c98:	ff6080e7          	jalr	-10(ra) # 80000c8a <release>
    return 0;
    80001c9c:	84ca                	mv	s1,s2
    80001c9e:	b7d1                	j	80001c62 <allocproc+0xac>

0000000080001ca0 <userinit>:
{
    80001ca0:	1101                	addi	sp,sp,-32
    80001ca2:	ec06                	sd	ra,24(sp)
    80001ca4:	e822                	sd	s0,16(sp)
    80001ca6:	e426                	sd	s1,8(sp)
    80001ca8:	1000                	addi	s0,sp,32
  p = allocproc();
    80001caa:	00000097          	auipc	ra,0x0
    80001cae:	f0c080e7          	jalr	-244(ra) # 80001bb6 <allocproc>
    80001cb2:	84aa                	mv	s1,a0
  initproc = p;
    80001cb4:	00007797          	auipc	a5,0x7
    80001cb8:	e6a7ba23          	sd	a0,-396(a5) # 80008b28 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001cbc:	03400613          	li	a2,52
    80001cc0:	00007597          	auipc	a1,0x7
    80001cc4:	d8058593          	addi	a1,a1,-640 # 80008a40 <initcode>
    80001cc8:	6928                	ld	a0,80(a0)
    80001cca:	fffff097          	auipc	ra,0xfffff
    80001cce:	68c080e7          	jalr	1676(ra) # 80001356 <uvmfirst>
  p->sz = PGSIZE;
    80001cd2:	6785                	lui	a5,0x1
    80001cd4:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001cd6:	6cb8                	ld	a4,88(s1)
    80001cd8:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001cdc:	6cb8                	ld	a4,88(s1)
    80001cde:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001ce0:	4641                	li	a2,16
    80001ce2:	00006597          	auipc	a1,0x6
    80001ce6:	51e58593          	addi	a1,a1,1310 # 80008200 <digits+0x1c0>
    80001cea:	15848513          	addi	a0,s1,344
    80001cee:	fffff097          	auipc	ra,0xfffff
    80001cf2:	12e080e7          	jalr	302(ra) # 80000e1c <safestrcpy>
  p->cwd = namei("/");
    80001cf6:	00006517          	auipc	a0,0x6
    80001cfa:	51a50513          	addi	a0,a0,1306 # 80008210 <digits+0x1d0>
    80001cfe:	00002097          	auipc	ra,0x2
    80001d02:	568080e7          	jalr	1384(ra) # 80004266 <namei>
    80001d06:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001d0a:	478d                	li	a5,3
    80001d0c:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001d0e:	8526                	mv	a0,s1
    80001d10:	fffff097          	auipc	ra,0xfffff
    80001d14:	f7a080e7          	jalr	-134(ra) # 80000c8a <release>
}
    80001d18:	60e2                	ld	ra,24(sp)
    80001d1a:	6442                	ld	s0,16(sp)
    80001d1c:	64a2                	ld	s1,8(sp)
    80001d1e:	6105                	addi	sp,sp,32
    80001d20:	8082                	ret

0000000080001d22 <growproc>:
{
    80001d22:	1101                	addi	sp,sp,-32
    80001d24:	ec06                	sd	ra,24(sp)
    80001d26:	e822                	sd	s0,16(sp)
    80001d28:	e426                	sd	s1,8(sp)
    80001d2a:	e04a                	sd	s2,0(sp)
    80001d2c:	1000                	addi	s0,sp,32
    80001d2e:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001d30:	00000097          	auipc	ra,0x0
    80001d34:	c7c080e7          	jalr	-900(ra) # 800019ac <myproc>
    80001d38:	84aa                	mv	s1,a0
  sz = p->sz;
    80001d3a:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001d3c:	01204c63          	bgtz	s2,80001d54 <growproc+0x32>
  } else if(n < 0){
    80001d40:	02094663          	bltz	s2,80001d6c <growproc+0x4a>
  p->sz = sz;
    80001d44:	e4ac                	sd	a1,72(s1)
  return 0;
    80001d46:	4501                	li	a0,0
}
    80001d48:	60e2                	ld	ra,24(sp)
    80001d4a:	6442                	ld	s0,16(sp)
    80001d4c:	64a2                	ld	s1,8(sp)
    80001d4e:	6902                	ld	s2,0(sp)
    80001d50:	6105                	addi	sp,sp,32
    80001d52:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001d54:	4691                	li	a3,4
    80001d56:	00b90633          	add	a2,s2,a1
    80001d5a:	6928                	ld	a0,80(a0)
    80001d5c:	fffff097          	auipc	ra,0xfffff
    80001d60:	6b4080e7          	jalr	1716(ra) # 80001410 <uvmalloc>
    80001d64:	85aa                	mv	a1,a0
    80001d66:	fd79                	bnez	a0,80001d44 <growproc+0x22>
      return -1;
    80001d68:	557d                	li	a0,-1
    80001d6a:	bff9                	j	80001d48 <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001d6c:	00b90633          	add	a2,s2,a1
    80001d70:	6928                	ld	a0,80(a0)
    80001d72:	fffff097          	auipc	ra,0xfffff
    80001d76:	656080e7          	jalr	1622(ra) # 800013c8 <uvmdealloc>
    80001d7a:	85aa                	mv	a1,a0
    80001d7c:	b7e1                	j	80001d44 <growproc+0x22>

0000000080001d7e <fork>:
{
    80001d7e:	7139                	addi	sp,sp,-64
    80001d80:	fc06                	sd	ra,56(sp)
    80001d82:	f822                	sd	s0,48(sp)
    80001d84:	f426                	sd	s1,40(sp)
    80001d86:	f04a                	sd	s2,32(sp)
    80001d88:	ec4e                	sd	s3,24(sp)
    80001d8a:	e852                	sd	s4,16(sp)
    80001d8c:	e456                	sd	s5,8(sp)
    80001d8e:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001d90:	00000097          	auipc	ra,0x0
    80001d94:	c1c080e7          	jalr	-996(ra) # 800019ac <myproc>
    80001d98:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001d9a:	00000097          	auipc	ra,0x0
    80001d9e:	e1c080e7          	jalr	-484(ra) # 80001bb6 <allocproc>
    80001da2:	12050063          	beqz	a0,80001ec2 <fork+0x144>
    80001da6:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001da8:	048ab603          	ld	a2,72(s5)
    80001dac:	692c                	ld	a1,80(a0)
    80001dae:	050ab503          	ld	a0,80(s5)
    80001db2:	fffff097          	auipc	ra,0xfffff
    80001db6:	7b6080e7          	jalr	1974(ra) # 80001568 <uvmcopy>
    80001dba:	04054c63          	bltz	a0,80001e12 <fork+0x94>
  np->sz = p->sz;
    80001dbe:	048ab783          	ld	a5,72(s5)
    80001dc2:	04f9b423          	sd	a5,72(s3)
  np->mask = p->mask; // strace sys call
    80001dc6:	168aa783          	lw	a5,360(s5)
    80001dca:	16f9a423          	sw	a5,360(s3)
  *(np->trapframe) = *(p->trapframe);
    80001dce:	058ab683          	ld	a3,88(s5)
    80001dd2:	87b6                	mv	a5,a3
    80001dd4:	0589b703          	ld	a4,88(s3)
    80001dd8:	12068693          	addi	a3,a3,288
    80001ddc:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001de0:	6788                	ld	a0,8(a5)
    80001de2:	6b8c                	ld	a1,16(a5)
    80001de4:	6f90                	ld	a2,24(a5)
    80001de6:	01073023          	sd	a6,0(a4)
    80001dea:	e708                	sd	a0,8(a4)
    80001dec:	eb0c                	sd	a1,16(a4)
    80001dee:	ef10                	sd	a2,24(a4)
    80001df0:	02078793          	addi	a5,a5,32
    80001df4:	02070713          	addi	a4,a4,32
    80001df8:	fed792e3          	bne	a5,a3,80001ddc <fork+0x5e>
  np->trapframe->a0 = 0;
    80001dfc:	0589b783          	ld	a5,88(s3)
    80001e00:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001e04:	0d0a8493          	addi	s1,s5,208
    80001e08:	0d098913          	addi	s2,s3,208
    80001e0c:	150a8a13          	addi	s4,s5,336
    80001e10:	a00d                	j	80001e32 <fork+0xb4>
    freeproc(np);
    80001e12:	854e                	mv	a0,s3
    80001e14:	00000097          	auipc	ra,0x0
    80001e18:	d4a080e7          	jalr	-694(ra) # 80001b5e <freeproc>
    release(&np->lock);
    80001e1c:	854e                	mv	a0,s3
    80001e1e:	fffff097          	auipc	ra,0xfffff
    80001e22:	e6c080e7          	jalr	-404(ra) # 80000c8a <release>
    return -1;
    80001e26:	597d                	li	s2,-1
    80001e28:	a059                	j	80001eae <fork+0x130>
  for(i = 0; i < NOFILE; i++)
    80001e2a:	04a1                	addi	s1,s1,8
    80001e2c:	0921                	addi	s2,s2,8
    80001e2e:	01448b63          	beq	s1,s4,80001e44 <fork+0xc6>
    if(p->ofile[i])
    80001e32:	6088                	ld	a0,0(s1)
    80001e34:	d97d                	beqz	a0,80001e2a <fork+0xac>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e36:	00003097          	auipc	ra,0x3
    80001e3a:	ac6080e7          	jalr	-1338(ra) # 800048fc <filedup>
    80001e3e:	00a93023          	sd	a0,0(s2)
    80001e42:	b7e5                	j	80001e2a <fork+0xac>
  np->cwd = idup(p->cwd);
    80001e44:	150ab503          	ld	a0,336(s5)
    80001e48:	00002097          	auipc	ra,0x2
    80001e4c:	c34080e7          	jalr	-972(ra) # 80003a7c <idup>
    80001e50:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001e54:	4641                	li	a2,16
    80001e56:	158a8593          	addi	a1,s5,344
    80001e5a:	15898513          	addi	a0,s3,344
    80001e5e:	fffff097          	auipc	ra,0xfffff
    80001e62:	fbe080e7          	jalr	-66(ra) # 80000e1c <safestrcpy>
  pid = np->pid;
    80001e66:	0309a903          	lw	s2,48(s3)
  release(&np->lock);
    80001e6a:	854e                	mv	a0,s3
    80001e6c:	fffff097          	auipc	ra,0xfffff
    80001e70:	e1e080e7          	jalr	-482(ra) # 80000c8a <release>
  acquire(&wait_lock);
    80001e74:	0000f497          	auipc	s1,0xf
    80001e78:	f4448493          	addi	s1,s1,-188 # 80010db8 <wait_lock>
    80001e7c:	8526                	mv	a0,s1
    80001e7e:	fffff097          	auipc	ra,0xfffff
    80001e82:	d58080e7          	jalr	-680(ra) # 80000bd6 <acquire>
  np->parent = p;
    80001e86:	0359bc23          	sd	s5,56(s3)
  release(&wait_lock);
    80001e8a:	8526                	mv	a0,s1
    80001e8c:	fffff097          	auipc	ra,0xfffff
    80001e90:	dfe080e7          	jalr	-514(ra) # 80000c8a <release>
  acquire(&np->lock);
    80001e94:	854e                	mv	a0,s3
    80001e96:	fffff097          	auipc	ra,0xfffff
    80001e9a:	d40080e7          	jalr	-704(ra) # 80000bd6 <acquire>
  np->state = RUNNABLE;
    80001e9e:	478d                	li	a5,3
    80001ea0:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80001ea4:	854e                	mv	a0,s3
    80001ea6:	fffff097          	auipc	ra,0xfffff
    80001eaa:	de4080e7          	jalr	-540(ra) # 80000c8a <release>
}
    80001eae:	854a                	mv	a0,s2
    80001eb0:	70e2                	ld	ra,56(sp)
    80001eb2:	7442                	ld	s0,48(sp)
    80001eb4:	74a2                	ld	s1,40(sp)
    80001eb6:	7902                	ld	s2,32(sp)
    80001eb8:	69e2                	ld	s3,24(sp)
    80001eba:	6a42                	ld	s4,16(sp)
    80001ebc:	6aa2                	ld	s5,8(sp)
    80001ebe:	6121                	addi	sp,sp,64
    80001ec0:	8082                	ret
    return -1;
    80001ec2:	597d                	li	s2,-1
    80001ec4:	b7ed                	j	80001eae <fork+0x130>

0000000080001ec6 <update_time>:
{	
    80001ec6:	7179                	addi	sp,sp,-48
    80001ec8:	f406                	sd	ra,40(sp)
    80001eca:	f022                	sd	s0,32(sp)
    80001ecc:	ec26                	sd	s1,24(sp)
    80001ece:	e84a                	sd	s2,16(sp)
    80001ed0:	e44e                	sd	s3,8(sp)
    80001ed2:	1800                	addi	s0,sp,48
  for (p = proc; p < &proc[NPROC]; p++) {	
    80001ed4:	0000f497          	auipc	s1,0xf
    80001ed8:	2fc48493          	addi	s1,s1,764 # 800111d0 <proc>
    if (p->state == RUNNING) {	
    80001edc:	4991                	li	s3,4
  for (p = proc; p < &proc[NPROC]; p++) {	
    80001ede:	00015917          	auipc	s2,0x15
    80001ee2:	4f290913          	addi	s2,s2,1266 # 800173d0 <tickslock>
    80001ee6:	a811                	j	80001efa <update_time+0x34>
    release(&p->lock); 	
    80001ee8:	8526                	mv	a0,s1
    80001eea:	fffff097          	auipc	ra,0xfffff
    80001eee:	da0080e7          	jalr	-608(ra) # 80000c8a <release>
  for (p = proc; p < &proc[NPROC]; p++) {	
    80001ef2:	18848493          	addi	s1,s1,392
    80001ef6:	03248063          	beq	s1,s2,80001f16 <update_time+0x50>
    acquire(&p->lock);	
    80001efa:	8526                	mv	a0,s1
    80001efc:	fffff097          	auipc	ra,0xfffff
    80001f00:	cda080e7          	jalr	-806(ra) # 80000bd6 <acquire>
    if (p->state == RUNNING) {	
    80001f04:	4c9c                	lw	a5,24(s1)
    80001f06:	ff3791e3          	bne	a5,s3,80001ee8 <update_time+0x22>
      p->rtime++;	
    80001f0a:	1784a783          	lw	a5,376(s1)
    80001f0e:	2785                	addiw	a5,a5,1
    80001f10:	16f4ac23          	sw	a5,376(s1)
    80001f14:	bfd1                	j	80001ee8 <update_time+0x22>
}	
    80001f16:	70a2                	ld	ra,40(sp)
    80001f18:	7402                	ld	s0,32(sp)
    80001f1a:	64e2                	ld	s1,24(sp)
    80001f1c:	6942                	ld	s2,16(sp)
    80001f1e:	69a2                	ld	s3,8(sp)
    80001f20:	6145                	addi	sp,sp,48
    80001f22:	8082                	ret

0000000080001f24 <trace>:
{	
    80001f24:	1101                	addi	sp,sp,-32
    80001f26:	ec06                	sd	ra,24(sp)
    80001f28:	e822                	sd	s0,16(sp)
    80001f2a:	e426                	sd	s1,8(sp)
    80001f2c:	e04a                	sd	s2,0(sp)
    80001f2e:	1000                	addi	s0,sp,32
    80001f30:	892a                	mv	s2,a0
  struct proc *p = myproc();	
    80001f32:	00000097          	auipc	ra,0x0
    80001f36:	a7a080e7          	jalr	-1414(ra) # 800019ac <myproc>
    80001f3a:	84aa                	mv	s1,a0
  acquire(&p->lock);	
    80001f3c:	fffff097          	auipc	ra,0xfffff
    80001f40:	c9a080e7          	jalr	-870(ra) # 80000bd6 <acquire>
  p->mask = mask;	
    80001f44:	1724a423          	sw	s2,360(s1)
  release(&p->lock);	
    80001f48:	8526                	mv	a0,s1
    80001f4a:	fffff097          	auipc	ra,0xfffff
    80001f4e:	d40080e7          	jalr	-704(ra) # 80000c8a <release>
}	
    80001f52:	60e2                	ld	ra,24(sp)
    80001f54:	6442                	ld	s0,16(sp)
    80001f56:	64a2                	ld	s1,8(sp)
    80001f58:	6902                	ld	s2,0(sp)
    80001f5a:	6105                	addi	sp,sp,32
    80001f5c:	8082                	ret

0000000080001f5e <set_priority>:
{	
    80001f5e:	1141                	addi	sp,sp,-16
    80001f60:	e422                	sd	s0,8(sp)
    80001f62:	0800                	addi	s0,sp,16
    80001f64:	04000793          	li	a5,64
  for (p = proc; p < &proc[NPROC]; p++) {	
    80001f68:	17fd                	addi	a5,a5,-1
    80001f6a:	fffd                	bnez	a5,80001f68 <set_priority+0xa>
}
    80001f6c:	557d                	li	a0,-1
    80001f6e:	6422                	ld	s0,8(sp)
    80001f70:	0141                	addi	sp,sp,16
    80001f72:	8082                	ret

0000000080001f74 <scheduler>:
{
    80001f74:	7139                	addi	sp,sp,-64
    80001f76:	fc06                	sd	ra,56(sp)
    80001f78:	f822                	sd	s0,48(sp)
    80001f7a:	f426                	sd	s1,40(sp)
    80001f7c:	f04a                	sd	s2,32(sp)
    80001f7e:	ec4e                	sd	s3,24(sp)
    80001f80:	e852                	sd	s4,16(sp)
    80001f82:	e456                	sd	s5,8(sp)
    80001f84:	e05a                	sd	s6,0(sp)
    80001f86:	0080                	addi	s0,sp,64
    80001f88:	8792                	mv	a5,tp
  int id = r_tp();
    80001f8a:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001f8c:	00779a93          	slli	s5,a5,0x7
    80001f90:	0000f717          	auipc	a4,0xf
    80001f94:	e1070713          	addi	a4,a4,-496 # 80010da0 <pid_lock>
    80001f98:	9756                	add	a4,a4,s5
    80001f9a:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001f9e:	0000f717          	auipc	a4,0xf
    80001fa2:	e3a70713          	addi	a4,a4,-454 # 80010dd8 <cpus+0x8>
    80001fa6:	9aba                	add	s5,s5,a4
      if(p->state == RUNNABLE) {
    80001fa8:	498d                	li	s3,3
        p->state = RUNNING;
    80001faa:	4b11                	li	s6,4
        c->proc = p;
    80001fac:	079e                	slli	a5,a5,0x7
    80001fae:	0000fa17          	auipc	s4,0xf
    80001fb2:	df2a0a13          	addi	s4,s4,-526 # 80010da0 <pid_lock>
    80001fb6:	9a3e                	add	s4,s4,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80001fb8:	00015917          	auipc	s2,0x15
    80001fbc:	41890913          	addi	s2,s2,1048 # 800173d0 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001fc0:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001fc4:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001fc8:	10079073          	csrw	sstatus,a5
    80001fcc:	0000f497          	auipc	s1,0xf
    80001fd0:	20448493          	addi	s1,s1,516 # 800111d0 <proc>
    80001fd4:	a811                	j	80001fe8 <scheduler+0x74>
      release(&p->lock);
    80001fd6:	8526                	mv	a0,s1
    80001fd8:	fffff097          	auipc	ra,0xfffff
    80001fdc:	cb2080e7          	jalr	-846(ra) # 80000c8a <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001fe0:	18848493          	addi	s1,s1,392
    80001fe4:	fd248ee3          	beq	s1,s2,80001fc0 <scheduler+0x4c>
      acquire(&p->lock);
    80001fe8:	8526                	mv	a0,s1
    80001fea:	fffff097          	auipc	ra,0xfffff
    80001fee:	bec080e7          	jalr	-1044(ra) # 80000bd6 <acquire>
      if(p->state == RUNNABLE) {
    80001ff2:	4c9c                	lw	a5,24(s1)
    80001ff4:	ff3791e3          	bne	a5,s3,80001fd6 <scheduler+0x62>
        p->no_of_times_scheduled++;
    80001ff8:	1844a783          	lw	a5,388(s1)
    80001ffc:	2785                	addiw	a5,a5,1
    80001ffe:	18f4a223          	sw	a5,388(s1)
        p->state = RUNNING;
    80002002:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    80002006:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    8000200a:	06048593          	addi	a1,s1,96
    8000200e:	8556                	mv	a0,s5
    80002010:	00001097          	auipc	ra,0x1
    80002014:	80e080e7          	jalr	-2034(ra) # 8000281e <swtch>
        c->proc = 0;
    80002018:	020a3823          	sd	zero,48(s4)
    8000201c:	bf6d                	j	80001fd6 <scheduler+0x62>

000000008000201e <sched>:
{
    8000201e:	7179                	addi	sp,sp,-48
    80002020:	f406                	sd	ra,40(sp)
    80002022:	f022                	sd	s0,32(sp)
    80002024:	ec26                	sd	s1,24(sp)
    80002026:	e84a                	sd	s2,16(sp)
    80002028:	e44e                	sd	s3,8(sp)
    8000202a:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    8000202c:	00000097          	auipc	ra,0x0
    80002030:	980080e7          	jalr	-1664(ra) # 800019ac <myproc>
    80002034:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80002036:	fffff097          	auipc	ra,0xfffff
    8000203a:	b26080e7          	jalr	-1242(ra) # 80000b5c <holding>
    8000203e:	c93d                	beqz	a0,800020b4 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002040:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80002042:	2781                	sext.w	a5,a5
    80002044:	079e                	slli	a5,a5,0x7
    80002046:	0000f717          	auipc	a4,0xf
    8000204a:	d5a70713          	addi	a4,a4,-678 # 80010da0 <pid_lock>
    8000204e:	97ba                	add	a5,a5,a4
    80002050:	0a87a703          	lw	a4,168(a5)
    80002054:	4785                	li	a5,1
    80002056:	06f71763          	bne	a4,a5,800020c4 <sched+0xa6>
  if(p->state == RUNNING)
    8000205a:	4c98                	lw	a4,24(s1)
    8000205c:	4791                	li	a5,4
    8000205e:	06f70b63          	beq	a4,a5,800020d4 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002062:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002066:	8b89                	andi	a5,a5,2
  if(intr_get())
    80002068:	efb5                	bnez	a5,800020e4 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000206a:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    8000206c:	0000f917          	auipc	s2,0xf
    80002070:	d3490913          	addi	s2,s2,-716 # 80010da0 <pid_lock>
    80002074:	2781                	sext.w	a5,a5
    80002076:	079e                	slli	a5,a5,0x7
    80002078:	97ca                	add	a5,a5,s2
    8000207a:	0ac7a983          	lw	s3,172(a5)
    8000207e:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002080:	2781                	sext.w	a5,a5
    80002082:	079e                	slli	a5,a5,0x7
    80002084:	0000f597          	auipc	a1,0xf
    80002088:	d5458593          	addi	a1,a1,-684 # 80010dd8 <cpus+0x8>
    8000208c:	95be                	add	a1,a1,a5
    8000208e:	06048513          	addi	a0,s1,96
    80002092:	00000097          	auipc	ra,0x0
    80002096:	78c080e7          	jalr	1932(ra) # 8000281e <swtch>
    8000209a:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    8000209c:	2781                	sext.w	a5,a5
    8000209e:	079e                	slli	a5,a5,0x7
    800020a0:	993e                	add	s2,s2,a5
    800020a2:	0b392623          	sw	s3,172(s2)
}
    800020a6:	70a2                	ld	ra,40(sp)
    800020a8:	7402                	ld	s0,32(sp)
    800020aa:	64e2                	ld	s1,24(sp)
    800020ac:	6942                	ld	s2,16(sp)
    800020ae:	69a2                	ld	s3,8(sp)
    800020b0:	6145                	addi	sp,sp,48
    800020b2:	8082                	ret
    panic("sched p->lock");
    800020b4:	00006517          	auipc	a0,0x6
    800020b8:	16450513          	addi	a0,a0,356 # 80008218 <digits+0x1d8>
    800020bc:	ffffe097          	auipc	ra,0xffffe
    800020c0:	484080e7          	jalr	1156(ra) # 80000540 <panic>
    panic("sched locks");
    800020c4:	00006517          	auipc	a0,0x6
    800020c8:	16450513          	addi	a0,a0,356 # 80008228 <digits+0x1e8>
    800020cc:	ffffe097          	auipc	ra,0xffffe
    800020d0:	474080e7          	jalr	1140(ra) # 80000540 <panic>
    panic("sched running");
    800020d4:	00006517          	auipc	a0,0x6
    800020d8:	16450513          	addi	a0,a0,356 # 80008238 <digits+0x1f8>
    800020dc:	ffffe097          	auipc	ra,0xffffe
    800020e0:	464080e7          	jalr	1124(ra) # 80000540 <panic>
    panic("sched interruptible");
    800020e4:	00006517          	auipc	a0,0x6
    800020e8:	16450513          	addi	a0,a0,356 # 80008248 <digits+0x208>
    800020ec:	ffffe097          	auipc	ra,0xffffe
    800020f0:	454080e7          	jalr	1108(ra) # 80000540 <panic>

00000000800020f4 <yield>:
{
    800020f4:	1101                	addi	sp,sp,-32
    800020f6:	ec06                	sd	ra,24(sp)
    800020f8:	e822                	sd	s0,16(sp)
    800020fa:	e426                	sd	s1,8(sp)
    800020fc:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800020fe:	00000097          	auipc	ra,0x0
    80002102:	8ae080e7          	jalr	-1874(ra) # 800019ac <myproc>
    80002106:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002108:	fffff097          	auipc	ra,0xfffff
    8000210c:	ace080e7          	jalr	-1330(ra) # 80000bd6 <acquire>
  p->state = RUNNABLE;
    80002110:	478d                	li	a5,3
    80002112:	cc9c                	sw	a5,24(s1)
  sched();
    80002114:	00000097          	auipc	ra,0x0
    80002118:	f0a080e7          	jalr	-246(ra) # 8000201e <sched>
  release(&p->lock);
    8000211c:	8526                	mv	a0,s1
    8000211e:	fffff097          	auipc	ra,0xfffff
    80002122:	b6c080e7          	jalr	-1172(ra) # 80000c8a <release>
}
    80002126:	60e2                	ld	ra,24(sp)
    80002128:	6442                	ld	s0,16(sp)
    8000212a:	64a2                	ld	s1,8(sp)
    8000212c:	6105                	addi	sp,sp,32
    8000212e:	8082                	ret

0000000080002130 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80002130:	7179                	addi	sp,sp,-48
    80002132:	f406                	sd	ra,40(sp)
    80002134:	f022                	sd	s0,32(sp)
    80002136:	ec26                	sd	s1,24(sp)
    80002138:	e84a                	sd	s2,16(sp)
    8000213a:	e44e                	sd	s3,8(sp)
    8000213c:	1800                	addi	s0,sp,48
    8000213e:	89aa                	mv	s3,a0
    80002140:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002142:	00000097          	auipc	ra,0x0
    80002146:	86a080e7          	jalr	-1942(ra) # 800019ac <myproc>
    8000214a:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    8000214c:	fffff097          	auipc	ra,0xfffff
    80002150:	a8a080e7          	jalr	-1398(ra) # 80000bd6 <acquire>
  release(lk);
    80002154:	854a                	mv	a0,s2
    80002156:	fffff097          	auipc	ra,0xfffff
    8000215a:	b34080e7          	jalr	-1228(ra) # 80000c8a <release>

  // Go to sleep.
  p->chan = chan;
    8000215e:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80002162:	4789                	li	a5,2
    80002164:	cc9c                	sw	a5,24(s1)
  	  #ifdef PBS	
    p->s_start_time = ticks;	
  #endif

  sched();
    80002166:	00000097          	auipc	ra,0x0
    8000216a:	eb8080e7          	jalr	-328(ra) # 8000201e <sched>

  // Tidy up.
  p->chan = 0;
    8000216e:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80002172:	8526                	mv	a0,s1
    80002174:	fffff097          	auipc	ra,0xfffff
    80002178:	b16080e7          	jalr	-1258(ra) # 80000c8a <release>
  acquire(lk);
    8000217c:	854a                	mv	a0,s2
    8000217e:	fffff097          	auipc	ra,0xfffff
    80002182:	a58080e7          	jalr	-1448(ra) # 80000bd6 <acquire>
}
    80002186:	70a2                	ld	ra,40(sp)
    80002188:	7402                	ld	s0,32(sp)
    8000218a:	64e2                	ld	s1,24(sp)
    8000218c:	6942                	ld	s2,16(sp)
    8000218e:	69a2                	ld	s3,8(sp)
    80002190:	6145                	addi	sp,sp,48
    80002192:	8082                	ret

0000000080002194 <waitx>:
{	
    80002194:	711d                	addi	sp,sp,-96
    80002196:	ec86                	sd	ra,88(sp)
    80002198:	e8a2                	sd	s0,80(sp)
    8000219a:	e4a6                	sd	s1,72(sp)
    8000219c:	e0ca                	sd	s2,64(sp)
    8000219e:	fc4e                	sd	s3,56(sp)
    800021a0:	f852                	sd	s4,48(sp)
    800021a2:	f456                	sd	s5,40(sp)
    800021a4:	f05a                	sd	s6,32(sp)
    800021a6:	ec5e                	sd	s7,24(sp)
    800021a8:	e862                	sd	s8,16(sp)
    800021aa:	e466                	sd	s9,8(sp)
    800021ac:	e06a                	sd	s10,0(sp)
    800021ae:	1080                	addi	s0,sp,96
    800021b0:	8b2a                	mv	s6,a0
    800021b2:	8c2e                	mv	s8,a1
    800021b4:	8bb2                	mv	s7,a2
  struct proc *p = myproc();	
    800021b6:	fffff097          	auipc	ra,0xfffff
    800021ba:	7f6080e7          	jalr	2038(ra) # 800019ac <myproc>
    800021be:	892a                	mv	s2,a0
  acquire(&wait_lock);	
    800021c0:	0000f517          	auipc	a0,0xf
    800021c4:	bf850513          	addi	a0,a0,-1032 # 80010db8 <wait_lock>
    800021c8:	fffff097          	auipc	ra,0xfffff
    800021cc:	a0e080e7          	jalr	-1522(ra) # 80000bd6 <acquire>
    havekids = 0;	
    800021d0:	4c81                	li	s9,0
        if(np->state == ZOMBIE){	
    800021d2:	4a15                	li	s4,5
        havekids = 1;	
    800021d4:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){	
    800021d6:	00015997          	auipc	s3,0x15
    800021da:	1fa98993          	addi	s3,s3,506 # 800173d0 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep	
    800021de:	0000fd17          	auipc	s10,0xf
    800021e2:	bdad0d13          	addi	s10,s10,-1062 # 80010db8 <wait_lock>
    havekids = 0;	
    800021e6:	8766                	mv	a4,s9
    for(np = proc; np < &proc[NPROC]; np++){	
    800021e8:	0000f497          	auipc	s1,0xf
    800021ec:	fe848493          	addi	s1,s1,-24 # 800111d0 <proc>
    800021f0:	a059                	j	80002276 <waitx+0xe2>
          pid = np->pid;	
    800021f2:	0304a983          	lw	s3,48(s1)
          *rtime = np->rtime;	
    800021f6:	1784a783          	lw	a5,376(s1)
    800021fa:	00fc2023          	sw	a5,0(s8)
          *wtime = np->etime - np->ctime - np->rtime;	
    800021fe:	17c4a703          	lw	a4,380(s1)
    80002202:	9f3d                	addw	a4,a4,a5
    80002204:	1804a783          	lw	a5,384(s1)
    80002208:	9f99                	subw	a5,a5,a4
    8000220a:	00fba023          	sw	a5,0(s7) # fffffffffffff000 <end+0xffffffff7ffdc850>
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,	
    8000220e:	000b0e63          	beqz	s6,8000222a <waitx+0x96>
    80002212:	4691                	li	a3,4
    80002214:	02c48613          	addi	a2,s1,44
    80002218:	85da                	mv	a1,s6
    8000221a:	05093503          	ld	a0,80(s2)
    8000221e:	fffff097          	auipc	ra,0xfffff
    80002222:	44e080e7          	jalr	1102(ra) # 8000166c <copyout>
    80002226:	02054563          	bltz	a0,80002250 <waitx+0xbc>
          freeproc(np);	
    8000222a:	8526                	mv	a0,s1
    8000222c:	00000097          	auipc	ra,0x0
    80002230:	932080e7          	jalr	-1742(ra) # 80001b5e <freeproc>
          release(&np->lock);	
    80002234:	8526                	mv	a0,s1
    80002236:	fffff097          	auipc	ra,0xfffff
    8000223a:	a54080e7          	jalr	-1452(ra) # 80000c8a <release>
          release(&wait_lock);	
    8000223e:	0000f517          	auipc	a0,0xf
    80002242:	b7a50513          	addi	a0,a0,-1158 # 80010db8 <wait_lock>
    80002246:	fffff097          	auipc	ra,0xfffff
    8000224a:	a44080e7          	jalr	-1468(ra) # 80000c8a <release>
          return pid;	
    8000224e:	a09d                	j	800022b4 <waitx+0x120>
            release(&np->lock);	
    80002250:	8526                	mv	a0,s1
    80002252:	fffff097          	auipc	ra,0xfffff
    80002256:	a38080e7          	jalr	-1480(ra) # 80000c8a <release>
            release(&wait_lock);	
    8000225a:	0000f517          	auipc	a0,0xf
    8000225e:	b5e50513          	addi	a0,a0,-1186 # 80010db8 <wait_lock>
    80002262:	fffff097          	auipc	ra,0xfffff
    80002266:	a28080e7          	jalr	-1496(ra) # 80000c8a <release>
            return -1;	
    8000226a:	59fd                	li	s3,-1
    8000226c:	a0a1                	j	800022b4 <waitx+0x120>
    for(np = proc; np < &proc[NPROC]; np++){	
    8000226e:	18848493          	addi	s1,s1,392
    80002272:	03348463          	beq	s1,s3,8000229a <waitx+0x106>
      if(np->parent == p){	
    80002276:	7c9c                	ld	a5,56(s1)
    80002278:	ff279be3          	bne	a5,s2,8000226e <waitx+0xda>
        acquire(&np->lock);	
    8000227c:	8526                	mv	a0,s1
    8000227e:	fffff097          	auipc	ra,0xfffff
    80002282:	958080e7          	jalr	-1704(ra) # 80000bd6 <acquire>
        if(np->state == ZOMBIE){	
    80002286:	4c9c                	lw	a5,24(s1)
    80002288:	f74785e3          	beq	a5,s4,800021f2 <waitx+0x5e>
        release(&np->lock);	
    8000228c:	8526                	mv	a0,s1
    8000228e:	fffff097          	auipc	ra,0xfffff
    80002292:	9fc080e7          	jalr	-1540(ra) # 80000c8a <release>
        havekids = 1;	
    80002296:	8756                	mv	a4,s5
    80002298:	bfd9                	j	8000226e <waitx+0xda>
    if(!havekids || p->killed){	
    8000229a:	c701                	beqz	a4,800022a2 <waitx+0x10e>
    8000229c:	02892783          	lw	a5,40(s2)
    800022a0:	cb8d                	beqz	a5,800022d2 <waitx+0x13e>
      release(&wait_lock);	
    800022a2:	0000f517          	auipc	a0,0xf
    800022a6:	b1650513          	addi	a0,a0,-1258 # 80010db8 <wait_lock>
    800022aa:	fffff097          	auipc	ra,0xfffff
    800022ae:	9e0080e7          	jalr	-1568(ra) # 80000c8a <release>
      return -1;	
    800022b2:	59fd                	li	s3,-1
}	
    800022b4:	854e                	mv	a0,s3
    800022b6:	60e6                	ld	ra,88(sp)
    800022b8:	6446                	ld	s0,80(sp)
    800022ba:	64a6                	ld	s1,72(sp)
    800022bc:	6906                	ld	s2,64(sp)
    800022be:	79e2                	ld	s3,56(sp)
    800022c0:	7a42                	ld	s4,48(sp)
    800022c2:	7aa2                	ld	s5,40(sp)
    800022c4:	7b02                	ld	s6,32(sp)
    800022c6:	6be2                	ld	s7,24(sp)
    800022c8:	6c42                	ld	s8,16(sp)
    800022ca:	6ca2                	ld	s9,8(sp)
    800022cc:	6d02                	ld	s10,0(sp)
    800022ce:	6125                	addi	sp,sp,96
    800022d0:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep	
    800022d2:	85ea                	mv	a1,s10
    800022d4:	854a                	mv	a0,s2
    800022d6:	00000097          	auipc	ra,0x0
    800022da:	e5a080e7          	jalr	-422(ra) # 80002130 <sleep>
    havekids = 0;	
    800022de:	b721                	j	800021e6 <waitx+0x52>

00000000800022e0 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    800022e0:	7139                	addi	sp,sp,-64
    800022e2:	fc06                	sd	ra,56(sp)
    800022e4:	f822                	sd	s0,48(sp)
    800022e6:	f426                	sd	s1,40(sp)
    800022e8:	f04a                	sd	s2,32(sp)
    800022ea:	ec4e                	sd	s3,24(sp)
    800022ec:	e852                	sd	s4,16(sp)
    800022ee:	e456                	sd	s5,8(sp)
    800022f0:	0080                	addi	s0,sp,64
    800022f2:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    800022f4:	0000f497          	auipc	s1,0xf
    800022f8:	edc48493          	addi	s1,s1,-292 # 800111d0 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    800022fc:	4989                	li	s3,2
        p->state = RUNNABLE;
    800022fe:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80002300:	00015917          	auipc	s2,0x15
    80002304:	0d090913          	addi	s2,s2,208 # 800173d0 <tickslock>
    80002308:	a811                	j	8000231c <wakeup+0x3c>
         #ifdef PBS	
          p->stime = ticks - p->s_start_time;	
        #endif
      }
      release(&p->lock);
    8000230a:	8526                	mv	a0,s1
    8000230c:	fffff097          	auipc	ra,0xfffff
    80002310:	97e080e7          	jalr	-1666(ra) # 80000c8a <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002314:	18848493          	addi	s1,s1,392
    80002318:	03248663          	beq	s1,s2,80002344 <wakeup+0x64>
    if(p != myproc()){
    8000231c:	fffff097          	auipc	ra,0xfffff
    80002320:	690080e7          	jalr	1680(ra) # 800019ac <myproc>
    80002324:	fea488e3          	beq	s1,a0,80002314 <wakeup+0x34>
      acquire(&p->lock);
    80002328:	8526                	mv	a0,s1
    8000232a:	fffff097          	auipc	ra,0xfffff
    8000232e:	8ac080e7          	jalr	-1876(ra) # 80000bd6 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80002332:	4c9c                	lw	a5,24(s1)
    80002334:	fd379be3          	bne	a5,s3,8000230a <wakeup+0x2a>
    80002338:	709c                	ld	a5,32(s1)
    8000233a:	fd4798e3          	bne	a5,s4,8000230a <wakeup+0x2a>
        p->state = RUNNABLE;
    8000233e:	0154ac23          	sw	s5,24(s1)
    80002342:	b7e1                	j	8000230a <wakeup+0x2a>
    }
  }
}
    80002344:	70e2                	ld	ra,56(sp)
    80002346:	7442                	ld	s0,48(sp)
    80002348:	74a2                	ld	s1,40(sp)
    8000234a:	7902                	ld	s2,32(sp)
    8000234c:	69e2                	ld	s3,24(sp)
    8000234e:	6a42                	ld	s4,16(sp)
    80002350:	6aa2                	ld	s5,8(sp)
    80002352:	6121                	addi	sp,sp,64
    80002354:	8082                	ret

0000000080002356 <reparent>:
{
    80002356:	7179                	addi	sp,sp,-48
    80002358:	f406                	sd	ra,40(sp)
    8000235a:	f022                	sd	s0,32(sp)
    8000235c:	ec26                	sd	s1,24(sp)
    8000235e:	e84a                	sd	s2,16(sp)
    80002360:	e44e                	sd	s3,8(sp)
    80002362:	e052                	sd	s4,0(sp)
    80002364:	1800                	addi	s0,sp,48
    80002366:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002368:	0000f497          	auipc	s1,0xf
    8000236c:	e6848493          	addi	s1,s1,-408 # 800111d0 <proc>
      pp->parent = initproc;
    80002370:	00006a17          	auipc	s4,0x6
    80002374:	7b8a0a13          	addi	s4,s4,1976 # 80008b28 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002378:	00015997          	auipc	s3,0x15
    8000237c:	05898993          	addi	s3,s3,88 # 800173d0 <tickslock>
    80002380:	a029                	j	8000238a <reparent+0x34>
    80002382:	18848493          	addi	s1,s1,392
    80002386:	01348d63          	beq	s1,s3,800023a0 <reparent+0x4a>
    if(pp->parent == p){
    8000238a:	7c9c                	ld	a5,56(s1)
    8000238c:	ff279be3          	bne	a5,s2,80002382 <reparent+0x2c>
      pp->parent = initproc;
    80002390:	000a3503          	ld	a0,0(s4)
    80002394:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002396:	00000097          	auipc	ra,0x0
    8000239a:	f4a080e7          	jalr	-182(ra) # 800022e0 <wakeup>
    8000239e:	b7d5                	j	80002382 <reparent+0x2c>
}
    800023a0:	70a2                	ld	ra,40(sp)
    800023a2:	7402                	ld	s0,32(sp)
    800023a4:	64e2                	ld	s1,24(sp)
    800023a6:	6942                	ld	s2,16(sp)
    800023a8:	69a2                	ld	s3,8(sp)
    800023aa:	6a02                	ld	s4,0(sp)
    800023ac:	6145                	addi	sp,sp,48
    800023ae:	8082                	ret

00000000800023b0 <exit>:
{
    800023b0:	7179                	addi	sp,sp,-48
    800023b2:	f406                	sd	ra,40(sp)
    800023b4:	f022                	sd	s0,32(sp)
    800023b6:	ec26                	sd	s1,24(sp)
    800023b8:	e84a                	sd	s2,16(sp)
    800023ba:	e44e                	sd	s3,8(sp)
    800023bc:	e052                	sd	s4,0(sp)
    800023be:	1800                	addi	s0,sp,48
    800023c0:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800023c2:	fffff097          	auipc	ra,0xfffff
    800023c6:	5ea080e7          	jalr	1514(ra) # 800019ac <myproc>
    800023ca:	89aa                	mv	s3,a0
  if(p == initproc)
    800023cc:	00006797          	auipc	a5,0x6
    800023d0:	75c7b783          	ld	a5,1884(a5) # 80008b28 <initproc>
    800023d4:	0d050493          	addi	s1,a0,208
    800023d8:	15050913          	addi	s2,a0,336
    800023dc:	02a79363          	bne	a5,a0,80002402 <exit+0x52>
    panic("init exiting");
    800023e0:	00006517          	auipc	a0,0x6
    800023e4:	e8050513          	addi	a0,a0,-384 # 80008260 <digits+0x220>
    800023e8:	ffffe097          	auipc	ra,0xffffe
    800023ec:	158080e7          	jalr	344(ra) # 80000540 <panic>
      fileclose(f);
    800023f0:	00002097          	auipc	ra,0x2
    800023f4:	55e080e7          	jalr	1374(ra) # 8000494e <fileclose>
      p->ofile[fd] = 0;
    800023f8:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    800023fc:	04a1                	addi	s1,s1,8
    800023fe:	01248563          	beq	s1,s2,80002408 <exit+0x58>
    if(p->ofile[fd]){
    80002402:	6088                	ld	a0,0(s1)
    80002404:	f575                	bnez	a0,800023f0 <exit+0x40>
    80002406:	bfdd                	j	800023fc <exit+0x4c>
  begin_op();
    80002408:	00002097          	auipc	ra,0x2
    8000240c:	07e080e7          	jalr	126(ra) # 80004486 <begin_op>
  iput(p->cwd);
    80002410:	1509b503          	ld	a0,336(s3)
    80002414:	00002097          	auipc	ra,0x2
    80002418:	860080e7          	jalr	-1952(ra) # 80003c74 <iput>
  end_op();
    8000241c:	00002097          	auipc	ra,0x2
    80002420:	0e8080e7          	jalr	232(ra) # 80004504 <end_op>
  p->cwd = 0;
    80002424:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002428:	0000f497          	auipc	s1,0xf
    8000242c:	99048493          	addi	s1,s1,-1648 # 80010db8 <wait_lock>
    80002430:	8526                	mv	a0,s1
    80002432:	ffffe097          	auipc	ra,0xffffe
    80002436:	7a4080e7          	jalr	1956(ra) # 80000bd6 <acquire>
  reparent(p);
    8000243a:	854e                	mv	a0,s3
    8000243c:	00000097          	auipc	ra,0x0
    80002440:	f1a080e7          	jalr	-230(ra) # 80002356 <reparent>
  wakeup(p->parent);
    80002444:	0389b503          	ld	a0,56(s3)
    80002448:	00000097          	auipc	ra,0x0
    8000244c:	e98080e7          	jalr	-360(ra) # 800022e0 <wakeup>
  acquire(&p->lock);
    80002450:	854e                	mv	a0,s3
    80002452:	ffffe097          	auipc	ra,0xffffe
    80002456:	784080e7          	jalr	1924(ra) # 80000bd6 <acquire>
  p->xstate = status;
    8000245a:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    8000245e:	4795                	li	a5,5
    80002460:	00f9ac23          	sw	a5,24(s3)
  p->etime = ticks;
    80002464:	00006797          	auipc	a5,0x6
    80002468:	6cc7a783          	lw	a5,1740(a5) # 80008b30 <ticks>
    8000246c:	18f9a023          	sw	a5,384(s3)
  release(&wait_lock);
    80002470:	8526                	mv	a0,s1
    80002472:	fffff097          	auipc	ra,0xfffff
    80002476:	818080e7          	jalr	-2024(ra) # 80000c8a <release>
  sched();
    8000247a:	00000097          	auipc	ra,0x0
    8000247e:	ba4080e7          	jalr	-1116(ra) # 8000201e <sched>
  panic("zombie exit");
    80002482:	00006517          	auipc	a0,0x6
    80002486:	dee50513          	addi	a0,a0,-530 # 80008270 <digits+0x230>
    8000248a:	ffffe097          	auipc	ra,0xffffe
    8000248e:	0b6080e7          	jalr	182(ra) # 80000540 <panic>

0000000080002492 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002492:	7179                	addi	sp,sp,-48
    80002494:	f406                	sd	ra,40(sp)
    80002496:	f022                	sd	s0,32(sp)
    80002498:	ec26                	sd	s1,24(sp)
    8000249a:	e84a                	sd	s2,16(sp)
    8000249c:	e44e                	sd	s3,8(sp)
    8000249e:	1800                	addi	s0,sp,48
    800024a0:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800024a2:	0000f497          	auipc	s1,0xf
    800024a6:	d2e48493          	addi	s1,s1,-722 # 800111d0 <proc>
    800024aa:	00015997          	auipc	s3,0x15
    800024ae:	f2698993          	addi	s3,s3,-218 # 800173d0 <tickslock>
    acquire(&p->lock);
    800024b2:	8526                	mv	a0,s1
    800024b4:	ffffe097          	auipc	ra,0xffffe
    800024b8:	722080e7          	jalr	1826(ra) # 80000bd6 <acquire>
    if(p->pid == pid){
    800024bc:	589c                	lw	a5,48(s1)
    800024be:	01278d63          	beq	a5,s2,800024d8 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800024c2:	8526                	mv	a0,s1
    800024c4:	ffffe097          	auipc	ra,0xffffe
    800024c8:	7c6080e7          	jalr	1990(ra) # 80000c8a <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800024cc:	18848493          	addi	s1,s1,392
    800024d0:	ff3491e3          	bne	s1,s3,800024b2 <kill+0x20>
  }
  return -1;
    800024d4:	557d                	li	a0,-1
    800024d6:	a829                	j	800024f0 <kill+0x5e>
      p->killed = 1;
    800024d8:	4785                	li	a5,1
    800024da:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800024dc:	4c98                	lw	a4,24(s1)
    800024de:	4789                	li	a5,2
    800024e0:	00f70f63          	beq	a4,a5,800024fe <kill+0x6c>
      release(&p->lock);
    800024e4:	8526                	mv	a0,s1
    800024e6:	ffffe097          	auipc	ra,0xffffe
    800024ea:	7a4080e7          	jalr	1956(ra) # 80000c8a <release>
      return 0;
    800024ee:	4501                	li	a0,0
}
    800024f0:	70a2                	ld	ra,40(sp)
    800024f2:	7402                	ld	s0,32(sp)
    800024f4:	64e2                	ld	s1,24(sp)
    800024f6:	6942                	ld	s2,16(sp)
    800024f8:	69a2                	ld	s3,8(sp)
    800024fa:	6145                	addi	sp,sp,48
    800024fc:	8082                	ret
        p->state = RUNNABLE;
    800024fe:	478d                	li	a5,3
    80002500:	cc9c                	sw	a5,24(s1)
    80002502:	b7cd                	j	800024e4 <kill+0x52>

0000000080002504 <setkilled>:

void
setkilled(struct proc *p)
{
    80002504:	1101                	addi	sp,sp,-32
    80002506:	ec06                	sd	ra,24(sp)
    80002508:	e822                	sd	s0,16(sp)
    8000250a:	e426                	sd	s1,8(sp)
    8000250c:	1000                	addi	s0,sp,32
    8000250e:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002510:	ffffe097          	auipc	ra,0xffffe
    80002514:	6c6080e7          	jalr	1734(ra) # 80000bd6 <acquire>
  p->killed = 1;
    80002518:	4785                	li	a5,1
    8000251a:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    8000251c:	8526                	mv	a0,s1
    8000251e:	ffffe097          	auipc	ra,0xffffe
    80002522:	76c080e7          	jalr	1900(ra) # 80000c8a <release>
}
    80002526:	60e2                	ld	ra,24(sp)
    80002528:	6442                	ld	s0,16(sp)
    8000252a:	64a2                	ld	s1,8(sp)
    8000252c:	6105                	addi	sp,sp,32
    8000252e:	8082                	ret

0000000080002530 <killed>:

int
killed(struct proc *p)
{
    80002530:	1101                	addi	sp,sp,-32
    80002532:	ec06                	sd	ra,24(sp)
    80002534:	e822                	sd	s0,16(sp)
    80002536:	e426                	sd	s1,8(sp)
    80002538:	e04a                	sd	s2,0(sp)
    8000253a:	1000                	addi	s0,sp,32
    8000253c:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    8000253e:	ffffe097          	auipc	ra,0xffffe
    80002542:	698080e7          	jalr	1688(ra) # 80000bd6 <acquire>
  k = p->killed;
    80002546:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    8000254a:	8526                	mv	a0,s1
    8000254c:	ffffe097          	auipc	ra,0xffffe
    80002550:	73e080e7          	jalr	1854(ra) # 80000c8a <release>
  return k;
}
    80002554:	854a                	mv	a0,s2
    80002556:	60e2                	ld	ra,24(sp)
    80002558:	6442                	ld	s0,16(sp)
    8000255a:	64a2                	ld	s1,8(sp)
    8000255c:	6902                	ld	s2,0(sp)
    8000255e:	6105                	addi	sp,sp,32
    80002560:	8082                	ret

0000000080002562 <wait>:
{
    80002562:	715d                	addi	sp,sp,-80
    80002564:	e486                	sd	ra,72(sp)
    80002566:	e0a2                	sd	s0,64(sp)
    80002568:	fc26                	sd	s1,56(sp)
    8000256a:	f84a                	sd	s2,48(sp)
    8000256c:	f44e                	sd	s3,40(sp)
    8000256e:	f052                	sd	s4,32(sp)
    80002570:	ec56                	sd	s5,24(sp)
    80002572:	e85a                	sd	s6,16(sp)
    80002574:	e45e                	sd	s7,8(sp)
    80002576:	e062                	sd	s8,0(sp)
    80002578:	0880                	addi	s0,sp,80
    8000257a:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    8000257c:	fffff097          	auipc	ra,0xfffff
    80002580:	430080e7          	jalr	1072(ra) # 800019ac <myproc>
    80002584:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002586:	0000f517          	auipc	a0,0xf
    8000258a:	83250513          	addi	a0,a0,-1998 # 80010db8 <wait_lock>
    8000258e:	ffffe097          	auipc	ra,0xffffe
    80002592:	648080e7          	jalr	1608(ra) # 80000bd6 <acquire>
    havekids = 0;
    80002596:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    80002598:	4a15                	li	s4,5
        havekids = 1;
    8000259a:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000259c:	00015997          	auipc	s3,0x15
    800025a0:	e3498993          	addi	s3,s3,-460 # 800173d0 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800025a4:	0000fc17          	auipc	s8,0xf
    800025a8:	814c0c13          	addi	s8,s8,-2028 # 80010db8 <wait_lock>
    havekids = 0;
    800025ac:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800025ae:	0000f497          	auipc	s1,0xf
    800025b2:	c2248493          	addi	s1,s1,-990 # 800111d0 <proc>
    800025b6:	a0bd                	j	80002624 <wait+0xc2>
          pid = pp->pid;
    800025b8:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800025bc:	000b0e63          	beqz	s6,800025d8 <wait+0x76>
    800025c0:	4691                	li	a3,4
    800025c2:	02c48613          	addi	a2,s1,44
    800025c6:	85da                	mv	a1,s6
    800025c8:	05093503          	ld	a0,80(s2)
    800025cc:	fffff097          	auipc	ra,0xfffff
    800025d0:	0a0080e7          	jalr	160(ra) # 8000166c <copyout>
    800025d4:	02054563          	bltz	a0,800025fe <wait+0x9c>
          freeproc(pp);
    800025d8:	8526                	mv	a0,s1
    800025da:	fffff097          	auipc	ra,0xfffff
    800025de:	584080e7          	jalr	1412(ra) # 80001b5e <freeproc>
          release(&pp->lock);
    800025e2:	8526                	mv	a0,s1
    800025e4:	ffffe097          	auipc	ra,0xffffe
    800025e8:	6a6080e7          	jalr	1702(ra) # 80000c8a <release>
          release(&wait_lock);
    800025ec:	0000e517          	auipc	a0,0xe
    800025f0:	7cc50513          	addi	a0,a0,1996 # 80010db8 <wait_lock>
    800025f4:	ffffe097          	auipc	ra,0xffffe
    800025f8:	696080e7          	jalr	1686(ra) # 80000c8a <release>
          return pid;
    800025fc:	a0b5                	j	80002668 <wait+0x106>
            release(&pp->lock);
    800025fe:	8526                	mv	a0,s1
    80002600:	ffffe097          	auipc	ra,0xffffe
    80002604:	68a080e7          	jalr	1674(ra) # 80000c8a <release>
            release(&wait_lock);
    80002608:	0000e517          	auipc	a0,0xe
    8000260c:	7b050513          	addi	a0,a0,1968 # 80010db8 <wait_lock>
    80002610:	ffffe097          	auipc	ra,0xffffe
    80002614:	67a080e7          	jalr	1658(ra) # 80000c8a <release>
            return -1;
    80002618:	59fd                	li	s3,-1
    8000261a:	a0b9                	j	80002668 <wait+0x106>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000261c:	18848493          	addi	s1,s1,392
    80002620:	03348463          	beq	s1,s3,80002648 <wait+0xe6>
      if(pp->parent == p){
    80002624:	7c9c                	ld	a5,56(s1)
    80002626:	ff279be3          	bne	a5,s2,8000261c <wait+0xba>
        acquire(&pp->lock);
    8000262a:	8526                	mv	a0,s1
    8000262c:	ffffe097          	auipc	ra,0xffffe
    80002630:	5aa080e7          	jalr	1450(ra) # 80000bd6 <acquire>
        if(pp->state == ZOMBIE){
    80002634:	4c9c                	lw	a5,24(s1)
    80002636:	f94781e3          	beq	a5,s4,800025b8 <wait+0x56>
        release(&pp->lock);
    8000263a:	8526                	mv	a0,s1
    8000263c:	ffffe097          	auipc	ra,0xffffe
    80002640:	64e080e7          	jalr	1614(ra) # 80000c8a <release>
        havekids = 1;
    80002644:	8756                	mv	a4,s5
    80002646:	bfd9                	j	8000261c <wait+0xba>
    if(!havekids || killed(p)){
    80002648:	c719                	beqz	a4,80002656 <wait+0xf4>
    8000264a:	854a                	mv	a0,s2
    8000264c:	00000097          	auipc	ra,0x0
    80002650:	ee4080e7          	jalr	-284(ra) # 80002530 <killed>
    80002654:	c51d                	beqz	a0,80002682 <wait+0x120>
      release(&wait_lock);
    80002656:	0000e517          	auipc	a0,0xe
    8000265a:	76250513          	addi	a0,a0,1890 # 80010db8 <wait_lock>
    8000265e:	ffffe097          	auipc	ra,0xffffe
    80002662:	62c080e7          	jalr	1580(ra) # 80000c8a <release>
      return -1;
    80002666:	59fd                	li	s3,-1
}
    80002668:	854e                	mv	a0,s3
    8000266a:	60a6                	ld	ra,72(sp)
    8000266c:	6406                	ld	s0,64(sp)
    8000266e:	74e2                	ld	s1,56(sp)
    80002670:	7942                	ld	s2,48(sp)
    80002672:	79a2                	ld	s3,40(sp)
    80002674:	7a02                	ld	s4,32(sp)
    80002676:	6ae2                	ld	s5,24(sp)
    80002678:	6b42                	ld	s6,16(sp)
    8000267a:	6ba2                	ld	s7,8(sp)
    8000267c:	6c02                	ld	s8,0(sp)
    8000267e:	6161                	addi	sp,sp,80
    80002680:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002682:	85e2                	mv	a1,s8
    80002684:	854a                	mv	a0,s2
    80002686:	00000097          	auipc	ra,0x0
    8000268a:	aaa080e7          	jalr	-1366(ra) # 80002130 <sleep>
    havekids = 0;
    8000268e:	bf39                	j	800025ac <wait+0x4a>

0000000080002690 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002690:	7179                	addi	sp,sp,-48
    80002692:	f406                	sd	ra,40(sp)
    80002694:	f022                	sd	s0,32(sp)
    80002696:	ec26                	sd	s1,24(sp)
    80002698:	e84a                	sd	s2,16(sp)
    8000269a:	e44e                	sd	s3,8(sp)
    8000269c:	e052                	sd	s4,0(sp)
    8000269e:	1800                	addi	s0,sp,48
    800026a0:	84aa                	mv	s1,a0
    800026a2:	892e                	mv	s2,a1
    800026a4:	89b2                	mv	s3,a2
    800026a6:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800026a8:	fffff097          	auipc	ra,0xfffff
    800026ac:	304080e7          	jalr	772(ra) # 800019ac <myproc>
  if(user_dst){
    800026b0:	c08d                	beqz	s1,800026d2 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    800026b2:	86d2                	mv	a3,s4
    800026b4:	864e                	mv	a2,s3
    800026b6:	85ca                	mv	a1,s2
    800026b8:	6928                	ld	a0,80(a0)
    800026ba:	fffff097          	auipc	ra,0xfffff
    800026be:	fb2080e7          	jalr	-78(ra) # 8000166c <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800026c2:	70a2                	ld	ra,40(sp)
    800026c4:	7402                	ld	s0,32(sp)
    800026c6:	64e2                	ld	s1,24(sp)
    800026c8:	6942                	ld	s2,16(sp)
    800026ca:	69a2                	ld	s3,8(sp)
    800026cc:	6a02                	ld	s4,0(sp)
    800026ce:	6145                	addi	sp,sp,48
    800026d0:	8082                	ret
    memmove((char *)dst, src, len);
    800026d2:	000a061b          	sext.w	a2,s4
    800026d6:	85ce                	mv	a1,s3
    800026d8:	854a                	mv	a0,s2
    800026da:	ffffe097          	auipc	ra,0xffffe
    800026de:	654080e7          	jalr	1620(ra) # 80000d2e <memmove>
    return 0;
    800026e2:	8526                	mv	a0,s1
    800026e4:	bff9                	j	800026c2 <either_copyout+0x32>

00000000800026e6 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800026e6:	7179                	addi	sp,sp,-48
    800026e8:	f406                	sd	ra,40(sp)
    800026ea:	f022                	sd	s0,32(sp)
    800026ec:	ec26                	sd	s1,24(sp)
    800026ee:	e84a                	sd	s2,16(sp)
    800026f0:	e44e                	sd	s3,8(sp)
    800026f2:	e052                	sd	s4,0(sp)
    800026f4:	1800                	addi	s0,sp,48
    800026f6:	892a                	mv	s2,a0
    800026f8:	84ae                	mv	s1,a1
    800026fa:	89b2                	mv	s3,a2
    800026fc:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800026fe:	fffff097          	auipc	ra,0xfffff
    80002702:	2ae080e7          	jalr	686(ra) # 800019ac <myproc>
  if(user_src){
    80002706:	c08d                	beqz	s1,80002728 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80002708:	86d2                	mv	a3,s4
    8000270a:	864e                	mv	a2,s3
    8000270c:	85ca                	mv	a1,s2
    8000270e:	6928                	ld	a0,80(a0)
    80002710:	fffff097          	auipc	ra,0xfffff
    80002714:	fe8080e7          	jalr	-24(ra) # 800016f8 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002718:	70a2                	ld	ra,40(sp)
    8000271a:	7402                	ld	s0,32(sp)
    8000271c:	64e2                	ld	s1,24(sp)
    8000271e:	6942                	ld	s2,16(sp)
    80002720:	69a2                	ld	s3,8(sp)
    80002722:	6a02                	ld	s4,0(sp)
    80002724:	6145                	addi	sp,sp,48
    80002726:	8082                	ret
    memmove(dst, (char*)src, len);
    80002728:	000a061b          	sext.w	a2,s4
    8000272c:	85ce                	mv	a1,s3
    8000272e:	854a                	mv	a0,s2
    80002730:	ffffe097          	auipc	ra,0xffffe
    80002734:	5fe080e7          	jalr	1534(ra) # 80000d2e <memmove>
    return 0;
    80002738:	8526                	mv	a0,s1
    8000273a:	bff9                	j	80002718 <either_copyin+0x32>

000000008000273c <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    8000273c:	715d                	addi	sp,sp,-80
    8000273e:	e486                	sd	ra,72(sp)
    80002740:	e0a2                	sd	s0,64(sp)
    80002742:	fc26                	sd	s1,56(sp)
    80002744:	f84a                	sd	s2,48(sp)
    80002746:	f44e                	sd	s3,40(sp)
    80002748:	f052                	sd	s4,32(sp)
    8000274a:	ec56                	sd	s5,24(sp)
    8000274c:	e85a                	sd	s6,16(sp)
    8000274e:	e45e                	sd	s7,8(sp)
    80002750:	e062                	sd	s8,0(sp)
    80002752:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;
   #ifdef RR	
    printf("\nPID\tState\trtime\twtime\tnrun");	
    80002754:	00006517          	auipc	a0,0x6
    80002758:	b3450513          	addi	a0,a0,-1228 # 80008288 <digits+0x248>
    8000275c:	ffffe097          	auipc	ra,0xffffe
    80002760:	e2e080e7          	jalr	-466(ra) # 8000058a <printf>
  #endif	
  #ifdef MLFQ	
    printf("\nPID\tPrio\tState\trtime\twtime\tnrun\tq0\tq1\tq2\tq3\tq4");	
  #endif

  printf("\n");
    80002764:	00006517          	auipc	a0,0x6
    80002768:	96450513          	addi	a0,a0,-1692 # 800080c8 <digits+0x88>
    8000276c:	ffffe097          	auipc	ra,0xffffe
    80002770:	e1e080e7          	jalr	-482(ra) # 8000058a <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002774:	0000f497          	auipc	s1,0xf
    80002778:	a5c48493          	addi	s1,s1,-1444 # 800111d0 <proc>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000277c:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    8000277e:	00006997          	auipc	s3,0x6
    80002782:	b0298993          	addi	s3,s3,-1278 # 80008280 <digits+0x240>
    	
    #ifdef RR	 
      int end_time = p->etime;	
      if (end_time == 0)	
        end_time = ticks;	
      printf("%d\t%s\t%d\t%d\t%d", p->pid, state, p->rtime, end_time - p->ctime - p->rtime, p->no_of_times_scheduled);	
    80002786:	00006a97          	auipc	s5,0x6
    8000278a:	b22a8a93          	addi	s5,s5,-1246 # 800082a8 <digits+0x268>
      printf("\n");	
    8000278e:	00006a17          	auipc	s4,0x6
    80002792:	93aa0a13          	addi	s4,s4,-1734 # 800080c8 <digits+0x88>
        end_time = ticks;	
    80002796:	00006c17          	auipc	s8,0x6
    8000279a:	39ac0c13          	addi	s8,s8,922 # 80008b30 <ticks>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000279e:	00006b97          	auipc	s7,0x6
    800027a2:	b4ab8b93          	addi	s7,s7,-1206 # 800082e8 <states.0>
  for(p = proc; p < &proc[NPROC]; p++){
    800027a6:	00015917          	auipc	s2,0x15
    800027aa:	c2a90913          	addi	s2,s2,-982 # 800173d0 <tickslock>
    800027ae:	a835                	j	800027ea <procdump+0xae>
      int end_time = p->etime;	
    800027b0:	1804a583          	lw	a1,384(s1)
      if (end_time == 0)	
    800027b4:	e199                	bnez	a1,800027ba <procdump+0x7e>
        end_time = ticks;	
    800027b6:	000c2583          	lw	a1,0(s8)
      printf("%d\t%s\t%d\t%d\t%d", p->pid, state, p->rtime, end_time - p->ctime - p->rtime, p->no_of_times_scheduled);	
    800027ba:	1784a683          	lw	a3,376(s1)
    800027be:	17c4a703          	lw	a4,380(s1)
    800027c2:	9f35                	addw	a4,a4,a3
    800027c4:	1844a783          	lw	a5,388(s1)
    800027c8:	40e5873b          	subw	a4,a1,a4
    800027cc:	588c                	lw	a1,48(s1)
    800027ce:	8556                	mv	a0,s5
    800027d0:	ffffe097          	auipc	ra,0xffffe
    800027d4:	dba080e7          	jalr	-582(ra) # 8000058a <printf>
      printf("\n");	
    800027d8:	8552                	mv	a0,s4
    800027da:	ffffe097          	auipc	ra,0xffffe
    800027de:	db0080e7          	jalr	-592(ra) # 8000058a <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800027e2:	18848493          	addi	s1,s1,392
    800027e6:	03248063          	beq	s1,s2,80002806 <procdump+0xca>
    if(p->state == UNUSED)
    800027ea:	4c9c                	lw	a5,24(s1)
    800027ec:	dbfd                	beqz	a5,800027e2 <procdump+0xa6>
      state = "???";
    800027ee:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800027f0:	fcfb60e3          	bltu	s6,a5,800027b0 <procdump+0x74>
    800027f4:	02079713          	slli	a4,a5,0x20
    800027f8:	01d75793          	srli	a5,a4,0x1d
    800027fc:	97de                	add	a5,a5,s7
    800027fe:	6390                	ld	a2,0(a5)
    80002800:	fa45                	bnez	a2,800027b0 <procdump+0x74>
      state = "???";
    80002802:	864e                	mv	a2,s3
    80002804:	b775                	j	800027b0 <procdump+0x74>
        current_queue = -1;	
      printf("%d\t%d\t%s\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d", p->pid, current_queue, state, p->rtime, end_time - p->ctime - p->rtime, p->no_of_times_scheduled, p->queue_ticks[0], p->queue_ticks[1], p->queue_ticks[2], p->queue_ticks[3], p->queue_ticks[4]);	
      printf("\n");	
    #endif
  }
}
    80002806:	60a6                	ld	ra,72(sp)
    80002808:	6406                	ld	s0,64(sp)
    8000280a:	74e2                	ld	s1,56(sp)
    8000280c:	7942                	ld	s2,48(sp)
    8000280e:	79a2                	ld	s3,40(sp)
    80002810:	7a02                	ld	s4,32(sp)
    80002812:	6ae2                	ld	s5,24(sp)
    80002814:	6b42                	ld	s6,16(sp)
    80002816:	6ba2                	ld	s7,8(sp)
    80002818:	6c02                	ld	s8,0(sp)
    8000281a:	6161                	addi	sp,sp,80
    8000281c:	8082                	ret

000000008000281e <swtch>:
    8000281e:	00153023          	sd	ra,0(a0)
    80002822:	00253423          	sd	sp,8(a0)
    80002826:	e900                	sd	s0,16(a0)
    80002828:	ed04                	sd	s1,24(a0)
    8000282a:	03253023          	sd	s2,32(a0)
    8000282e:	03353423          	sd	s3,40(a0)
    80002832:	03453823          	sd	s4,48(a0)
    80002836:	03553c23          	sd	s5,56(a0)
    8000283a:	05653023          	sd	s6,64(a0)
    8000283e:	05753423          	sd	s7,72(a0)
    80002842:	05853823          	sd	s8,80(a0)
    80002846:	05953c23          	sd	s9,88(a0)
    8000284a:	07a53023          	sd	s10,96(a0)
    8000284e:	07b53423          	sd	s11,104(a0)
    80002852:	0005b083          	ld	ra,0(a1)
    80002856:	0085b103          	ld	sp,8(a1)
    8000285a:	6980                	ld	s0,16(a1)
    8000285c:	6d84                	ld	s1,24(a1)
    8000285e:	0205b903          	ld	s2,32(a1)
    80002862:	0285b983          	ld	s3,40(a1)
    80002866:	0305ba03          	ld	s4,48(a1)
    8000286a:	0385ba83          	ld	s5,56(a1)
    8000286e:	0405bb03          	ld	s6,64(a1)
    80002872:	0485bb83          	ld	s7,72(a1)
    80002876:	0505bc03          	ld	s8,80(a1)
    8000287a:	0585bc83          	ld	s9,88(a1)
    8000287e:	0605bd03          	ld	s10,96(a1)
    80002882:	0685bd83          	ld	s11,104(a1)
    80002886:	8082                	ret

0000000080002888 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002888:	1141                	addi	sp,sp,-16
    8000288a:	e406                	sd	ra,8(sp)
    8000288c:	e022                	sd	s0,0(sp)
    8000288e:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002890:	00006597          	auipc	a1,0x6
    80002894:	a8858593          	addi	a1,a1,-1400 # 80008318 <states.0+0x30>
    80002898:	00015517          	auipc	a0,0x15
    8000289c:	b3850513          	addi	a0,a0,-1224 # 800173d0 <tickslock>
    800028a0:	ffffe097          	auipc	ra,0xffffe
    800028a4:	2a6080e7          	jalr	678(ra) # 80000b46 <initlock>
}
    800028a8:	60a2                	ld	ra,8(sp)
    800028aa:	6402                	ld	s0,0(sp)
    800028ac:	0141                	addi	sp,sp,16
    800028ae:	8082                	ret

00000000800028b0 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800028b0:	1141                	addi	sp,sp,-16
    800028b2:	e422                	sd	s0,8(sp)
    800028b4:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800028b6:	00003797          	auipc	a5,0x3
    800028ba:	6ea78793          	addi	a5,a5,1770 # 80005fa0 <kernelvec>
    800028be:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800028c2:	6422                	ld	s0,8(sp)
    800028c4:	0141                	addi	sp,sp,16
    800028c6:	8082                	ret

00000000800028c8 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    800028c8:	1141                	addi	sp,sp,-16
    800028ca:	e406                	sd	ra,8(sp)
    800028cc:	e022                	sd	s0,0(sp)
    800028ce:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800028d0:	fffff097          	auipc	ra,0xfffff
    800028d4:	0dc080e7          	jalr	220(ra) # 800019ac <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028d8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800028dc:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800028de:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    800028e2:	00004697          	auipc	a3,0x4
    800028e6:	71e68693          	addi	a3,a3,1822 # 80007000 <_trampoline>
    800028ea:	00004717          	auipc	a4,0x4
    800028ee:	71670713          	addi	a4,a4,1814 # 80007000 <_trampoline>
    800028f2:	8f15                	sub	a4,a4,a3
    800028f4:	040007b7          	lui	a5,0x4000
    800028f8:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    800028fa:	07b2                	slli	a5,a5,0xc
    800028fc:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    800028fe:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002902:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002904:	18002673          	csrr	a2,satp
    80002908:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    8000290a:	6d30                	ld	a2,88(a0)
    8000290c:	6138                	ld	a4,64(a0)
    8000290e:	6585                	lui	a1,0x1
    80002910:	972e                	add	a4,a4,a1
    80002912:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002914:	6d38                	ld	a4,88(a0)
    80002916:	00000617          	auipc	a2,0x0
    8000291a:	13e60613          	addi	a2,a2,318 # 80002a54 <usertrap>
    8000291e:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002920:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002922:	8612                	mv	a2,tp
    80002924:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002926:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    8000292a:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    8000292e:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002932:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002936:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002938:	6f18                	ld	a4,24(a4)
    8000293a:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    8000293e:	6928                	ld	a0,80(a0)
    80002940:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002942:	00004717          	auipc	a4,0x4
    80002946:	75a70713          	addi	a4,a4,1882 # 8000709c <userret>
    8000294a:	8f15                	sub	a4,a4,a3
    8000294c:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    8000294e:	577d                	li	a4,-1
    80002950:	177e                	slli	a4,a4,0x3f
    80002952:	8d59                	or	a0,a0,a4
    80002954:	9782                	jalr	a5
}
    80002956:	60a2                	ld	ra,8(sp)
    80002958:	6402                	ld	s0,0(sp)
    8000295a:	0141                	addi	sp,sp,16
    8000295c:	8082                	ret

000000008000295e <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    8000295e:	1101                	addi	sp,sp,-32
    80002960:	ec06                	sd	ra,24(sp)
    80002962:	e822                	sd	s0,16(sp)
    80002964:	e426                	sd	s1,8(sp)
    80002966:	e04a                	sd	s2,0(sp)
    80002968:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    8000296a:	00015917          	auipc	s2,0x15
    8000296e:	a6690913          	addi	s2,s2,-1434 # 800173d0 <tickslock>
    80002972:	854a                	mv	a0,s2
    80002974:	ffffe097          	auipc	ra,0xffffe
    80002978:	262080e7          	jalr	610(ra) # 80000bd6 <acquire>
  ticks++;
    8000297c:	00006497          	auipc	s1,0x6
    80002980:	1b448493          	addi	s1,s1,436 # 80008b30 <ticks>
    80002984:	409c                	lw	a5,0(s1)
    80002986:	2785                	addiw	a5,a5,1
    80002988:	c09c                	sw	a5,0(s1)
   update_time();
    8000298a:	fffff097          	auipc	ra,0xfffff
    8000298e:	53c080e7          	jalr	1340(ra) # 80001ec6 <update_time>
  wakeup(&ticks);
    80002992:	8526                	mv	a0,s1
    80002994:	00000097          	auipc	ra,0x0
    80002998:	94c080e7          	jalr	-1716(ra) # 800022e0 <wakeup>
  release(&tickslock);
    8000299c:	854a                	mv	a0,s2
    8000299e:	ffffe097          	auipc	ra,0xffffe
    800029a2:	2ec080e7          	jalr	748(ra) # 80000c8a <release>
}
    800029a6:	60e2                	ld	ra,24(sp)
    800029a8:	6442                	ld	s0,16(sp)
    800029aa:	64a2                	ld	s1,8(sp)
    800029ac:	6902                	ld	s2,0(sp)
    800029ae:	6105                	addi	sp,sp,32
    800029b0:	8082                	ret

00000000800029b2 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    800029b2:	1101                	addi	sp,sp,-32
    800029b4:	ec06                	sd	ra,24(sp)
    800029b6:	e822                	sd	s0,16(sp)
    800029b8:	e426                	sd	s1,8(sp)
    800029ba:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    800029bc:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    800029c0:	00074d63          	bltz	a4,800029da <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    800029c4:	57fd                	li	a5,-1
    800029c6:	17fe                	slli	a5,a5,0x3f
    800029c8:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    800029ca:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    800029cc:	06f70363          	beq	a4,a5,80002a32 <devintr+0x80>
  }
}
    800029d0:	60e2                	ld	ra,24(sp)
    800029d2:	6442                	ld	s0,16(sp)
    800029d4:	64a2                	ld	s1,8(sp)
    800029d6:	6105                	addi	sp,sp,32
    800029d8:	8082                	ret
     (scause & 0xff) == 9){
    800029da:	0ff77793          	zext.b	a5,a4
  if((scause & 0x8000000000000000L) &&
    800029de:	46a5                	li	a3,9
    800029e0:	fed792e3          	bne	a5,a3,800029c4 <devintr+0x12>
    int irq = plic_claim();
    800029e4:	00003097          	auipc	ra,0x3
    800029e8:	6c4080e7          	jalr	1732(ra) # 800060a8 <plic_claim>
    800029ec:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    800029ee:	47a9                	li	a5,10
    800029f0:	02f50763          	beq	a0,a5,80002a1e <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    800029f4:	4785                	li	a5,1
    800029f6:	02f50963          	beq	a0,a5,80002a28 <devintr+0x76>
    return 1;
    800029fa:	4505                	li	a0,1
    } else if(irq){
    800029fc:	d8f1                	beqz	s1,800029d0 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    800029fe:	85a6                	mv	a1,s1
    80002a00:	00006517          	auipc	a0,0x6
    80002a04:	92050513          	addi	a0,a0,-1760 # 80008320 <states.0+0x38>
    80002a08:	ffffe097          	auipc	ra,0xffffe
    80002a0c:	b82080e7          	jalr	-1150(ra) # 8000058a <printf>
      plic_complete(irq);
    80002a10:	8526                	mv	a0,s1
    80002a12:	00003097          	auipc	ra,0x3
    80002a16:	6ba080e7          	jalr	1722(ra) # 800060cc <plic_complete>
    return 1;
    80002a1a:	4505                	li	a0,1
    80002a1c:	bf55                	j	800029d0 <devintr+0x1e>
      uartintr();
    80002a1e:	ffffe097          	auipc	ra,0xffffe
    80002a22:	f7a080e7          	jalr	-134(ra) # 80000998 <uartintr>
    80002a26:	b7ed                	j	80002a10 <devintr+0x5e>
      virtio_disk_intr();
    80002a28:	00004097          	auipc	ra,0x4
    80002a2c:	b6c080e7          	jalr	-1172(ra) # 80006594 <virtio_disk_intr>
    80002a30:	b7c5                	j	80002a10 <devintr+0x5e>
    if(cpuid() == 0){
    80002a32:	fffff097          	auipc	ra,0xfffff
    80002a36:	f4e080e7          	jalr	-178(ra) # 80001980 <cpuid>
    80002a3a:	c901                	beqz	a0,80002a4a <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002a3c:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002a40:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002a42:	14479073          	csrw	sip,a5
    return 2;
    80002a46:	4509                	li	a0,2
    80002a48:	b761                	j	800029d0 <devintr+0x1e>
      clockintr();
    80002a4a:	00000097          	auipc	ra,0x0
    80002a4e:	f14080e7          	jalr	-236(ra) # 8000295e <clockintr>
    80002a52:	b7ed                	j	80002a3c <devintr+0x8a>

0000000080002a54 <usertrap>:
{
    80002a54:	1101                	addi	sp,sp,-32
    80002a56:	ec06                	sd	ra,24(sp)
    80002a58:	e822                	sd	s0,16(sp)
    80002a5a:	e426                	sd	s1,8(sp)
    80002a5c:	e04a                	sd	s2,0(sp)
    80002a5e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a60:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002a64:	1007f793          	andi	a5,a5,256
    80002a68:	e3b1                	bnez	a5,80002aac <usertrap+0x58>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002a6a:	00003797          	auipc	a5,0x3
    80002a6e:	53678793          	addi	a5,a5,1334 # 80005fa0 <kernelvec>
    80002a72:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002a76:	fffff097          	auipc	ra,0xfffff
    80002a7a:	f36080e7          	jalr	-202(ra) # 800019ac <myproc>
    80002a7e:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002a80:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a82:	14102773          	csrr	a4,sepc
    80002a86:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a88:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002a8c:	47a1                	li	a5,8
    80002a8e:	02f70763          	beq	a4,a5,80002abc <usertrap+0x68>
  } else if((which_dev = devintr()) != 0){
    80002a92:	00000097          	auipc	ra,0x0
    80002a96:	f20080e7          	jalr	-224(ra) # 800029b2 <devintr>
    80002a9a:	892a                	mv	s2,a0
    80002a9c:	c151                	beqz	a0,80002b20 <usertrap+0xcc>
  if(killed(p))
    80002a9e:	8526                	mv	a0,s1
    80002aa0:	00000097          	auipc	ra,0x0
    80002aa4:	a90080e7          	jalr	-1392(ra) # 80002530 <killed>
    80002aa8:	c929                	beqz	a0,80002afa <usertrap+0xa6>
    80002aaa:	a099                	j	80002af0 <usertrap+0x9c>
    panic("usertrap: not from user mode");
    80002aac:	00006517          	auipc	a0,0x6
    80002ab0:	89450513          	addi	a0,a0,-1900 # 80008340 <states.0+0x58>
    80002ab4:	ffffe097          	auipc	ra,0xffffe
    80002ab8:	a8c080e7          	jalr	-1396(ra) # 80000540 <panic>
    if(killed(p))
    80002abc:	00000097          	auipc	ra,0x0
    80002ac0:	a74080e7          	jalr	-1420(ra) # 80002530 <killed>
    80002ac4:	e921                	bnez	a0,80002b14 <usertrap+0xc0>
    p->trapframe->epc += 4;
    80002ac6:	6cb8                	ld	a4,88(s1)
    80002ac8:	6f1c                	ld	a5,24(a4)
    80002aca:	0791                	addi	a5,a5,4
    80002acc:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002ace:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002ad2:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002ad6:	10079073          	csrw	sstatus,a5
    syscall();
    80002ada:	00000097          	auipc	ra,0x0
    80002ade:	2d8080e7          	jalr	728(ra) # 80002db2 <syscall>
  if(killed(p))
    80002ae2:	8526                	mv	a0,s1
    80002ae4:	00000097          	auipc	ra,0x0
    80002ae8:	a4c080e7          	jalr	-1460(ra) # 80002530 <killed>
    80002aec:	c911                	beqz	a0,80002b00 <usertrap+0xac>
    80002aee:	4901                	li	s2,0
    exit(-1);
    80002af0:	557d                	li	a0,-1
    80002af2:	00000097          	auipc	ra,0x0
    80002af6:	8be080e7          	jalr	-1858(ra) # 800023b0 <exit>
    if(which_dev == 2) {
    80002afa:	4789                	li	a5,2
    80002afc:	04f90f63          	beq	s2,a5,80002b5a <usertrap+0x106>
  usertrapret();
    80002b00:	00000097          	auipc	ra,0x0
    80002b04:	dc8080e7          	jalr	-568(ra) # 800028c8 <usertrapret>
}
    80002b08:	60e2                	ld	ra,24(sp)
    80002b0a:	6442                	ld	s0,16(sp)
    80002b0c:	64a2                	ld	s1,8(sp)
    80002b0e:	6902                	ld	s2,0(sp)
    80002b10:	6105                	addi	sp,sp,32
    80002b12:	8082                	ret
      exit(-1);
    80002b14:	557d                	li	a0,-1
    80002b16:	00000097          	auipc	ra,0x0
    80002b1a:	89a080e7          	jalr	-1894(ra) # 800023b0 <exit>
    80002b1e:	b765                	j	80002ac6 <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b20:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002b24:	5890                	lw	a2,48(s1)
    80002b26:	00006517          	auipc	a0,0x6
    80002b2a:	83a50513          	addi	a0,a0,-1990 # 80008360 <states.0+0x78>
    80002b2e:	ffffe097          	auipc	ra,0xffffe
    80002b32:	a5c080e7          	jalr	-1444(ra) # 8000058a <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b36:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002b3a:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002b3e:	00006517          	auipc	a0,0x6
    80002b42:	85250513          	addi	a0,a0,-1966 # 80008390 <states.0+0xa8>
    80002b46:	ffffe097          	auipc	ra,0xffffe
    80002b4a:	a44080e7          	jalr	-1468(ra) # 8000058a <printf>
    setkilled(p);
    80002b4e:	8526                	mv	a0,s1
    80002b50:	00000097          	auipc	ra,0x0
    80002b54:	9b4080e7          	jalr	-1612(ra) # 80002504 <setkilled>
    80002b58:	b769                	j	80002ae2 <usertrap+0x8e>
          yield();
    80002b5a:	fffff097          	auipc	ra,0xfffff
    80002b5e:	59a080e7          	jalr	1434(ra) # 800020f4 <yield>
    80002b62:	bf79                	j	80002b00 <usertrap+0xac>

0000000080002b64 <kerneltrap>:
{
    80002b64:	7179                	addi	sp,sp,-48
    80002b66:	f406                	sd	ra,40(sp)
    80002b68:	f022                	sd	s0,32(sp)
    80002b6a:	ec26                	sd	s1,24(sp)
    80002b6c:	e84a                	sd	s2,16(sp)
    80002b6e:	e44e                	sd	s3,8(sp)
    80002b70:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b72:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b76:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b7a:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002b7e:	1004f793          	andi	a5,s1,256
    80002b82:	cb85                	beqz	a5,80002bb2 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b84:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002b88:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002b8a:	ef85                	bnez	a5,80002bc2 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002b8c:	00000097          	auipc	ra,0x0
    80002b90:	e26080e7          	jalr	-474(ra) # 800029b2 <devintr>
    80002b94:	cd1d                	beqz	a0,80002bd2 <kerneltrap+0x6e>
    if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING) {
    80002b96:	4789                	li	a5,2
    80002b98:	06f50a63          	beq	a0,a5,80002c0c <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002b9c:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002ba0:	10049073          	csrw	sstatus,s1
}
    80002ba4:	70a2                	ld	ra,40(sp)
    80002ba6:	7402                	ld	s0,32(sp)
    80002ba8:	64e2                	ld	s1,24(sp)
    80002baa:	6942                	ld	s2,16(sp)
    80002bac:	69a2                	ld	s3,8(sp)
    80002bae:	6145                	addi	sp,sp,48
    80002bb0:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002bb2:	00005517          	auipc	a0,0x5
    80002bb6:	7fe50513          	addi	a0,a0,2046 # 800083b0 <states.0+0xc8>
    80002bba:	ffffe097          	auipc	ra,0xffffe
    80002bbe:	986080e7          	jalr	-1658(ra) # 80000540 <panic>
    panic("kerneltrap: interrupts enabled");
    80002bc2:	00006517          	auipc	a0,0x6
    80002bc6:	81650513          	addi	a0,a0,-2026 # 800083d8 <states.0+0xf0>
    80002bca:	ffffe097          	auipc	ra,0xffffe
    80002bce:	976080e7          	jalr	-1674(ra) # 80000540 <panic>
    printf("scause %p\n", scause);
    80002bd2:	85ce                	mv	a1,s3
    80002bd4:	00006517          	auipc	a0,0x6
    80002bd8:	82450513          	addi	a0,a0,-2012 # 800083f8 <states.0+0x110>
    80002bdc:	ffffe097          	auipc	ra,0xffffe
    80002be0:	9ae080e7          	jalr	-1618(ra) # 8000058a <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002be4:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002be8:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002bec:	00006517          	auipc	a0,0x6
    80002bf0:	81c50513          	addi	a0,a0,-2020 # 80008408 <states.0+0x120>
    80002bf4:	ffffe097          	auipc	ra,0xffffe
    80002bf8:	996080e7          	jalr	-1642(ra) # 8000058a <printf>
    panic("kerneltrap");
    80002bfc:	00006517          	auipc	a0,0x6
    80002c00:	82450513          	addi	a0,a0,-2012 # 80008420 <states.0+0x138>
    80002c04:	ffffe097          	auipc	ra,0xffffe
    80002c08:	93c080e7          	jalr	-1732(ra) # 80000540 <panic>
    if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING) {
    80002c0c:	fffff097          	auipc	ra,0xfffff
    80002c10:	da0080e7          	jalr	-608(ra) # 800019ac <myproc>
    80002c14:	d541                	beqz	a0,80002b9c <kerneltrap+0x38>
    80002c16:	fffff097          	auipc	ra,0xfffff
    80002c1a:	d96080e7          	jalr	-618(ra) # 800019ac <myproc>
    80002c1e:	4d18                	lw	a4,24(a0)
    80002c20:	4791                	li	a5,4
    80002c22:	f6f71de3          	bne	a4,a5,80002b9c <kerneltrap+0x38>
          yield();
    80002c26:	fffff097          	auipc	ra,0xfffff
    80002c2a:	4ce080e7          	jalr	1230(ra) # 800020f4 <yield>
    80002c2e:	b7bd                	j	80002b9c <kerneltrap+0x38>

0000000080002c30 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002c30:	1101                	addi	sp,sp,-32
    80002c32:	ec06                	sd	ra,24(sp)
    80002c34:	e822                	sd	s0,16(sp)
    80002c36:	e426                	sd	s1,8(sp)
    80002c38:	1000                	addi	s0,sp,32
    80002c3a:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002c3c:	fffff097          	auipc	ra,0xfffff
    80002c40:	d70080e7          	jalr	-656(ra) # 800019ac <myproc>
  switch (n) {
    80002c44:	4795                	li	a5,5
    80002c46:	0497e163          	bltu	a5,s1,80002c88 <argraw+0x58>
    80002c4a:	048a                	slli	s1,s1,0x2
    80002c4c:	00006717          	auipc	a4,0x6
    80002c50:	90470713          	addi	a4,a4,-1788 # 80008550 <states.0+0x268>
    80002c54:	94ba                	add	s1,s1,a4
    80002c56:	409c                	lw	a5,0(s1)
    80002c58:	97ba                	add	a5,a5,a4
    80002c5a:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002c5c:	6d3c                	ld	a5,88(a0)
    80002c5e:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002c60:	60e2                	ld	ra,24(sp)
    80002c62:	6442                	ld	s0,16(sp)
    80002c64:	64a2                	ld	s1,8(sp)
    80002c66:	6105                	addi	sp,sp,32
    80002c68:	8082                	ret
    return p->trapframe->a1;
    80002c6a:	6d3c                	ld	a5,88(a0)
    80002c6c:	7fa8                	ld	a0,120(a5)
    80002c6e:	bfcd                	j	80002c60 <argraw+0x30>
    return p->trapframe->a2;
    80002c70:	6d3c                	ld	a5,88(a0)
    80002c72:	63c8                	ld	a0,128(a5)
    80002c74:	b7f5                	j	80002c60 <argraw+0x30>
    return p->trapframe->a3;
    80002c76:	6d3c                	ld	a5,88(a0)
    80002c78:	67c8                	ld	a0,136(a5)
    80002c7a:	b7dd                	j	80002c60 <argraw+0x30>
    return p->trapframe->a4;
    80002c7c:	6d3c                	ld	a5,88(a0)
    80002c7e:	6bc8                	ld	a0,144(a5)
    80002c80:	b7c5                	j	80002c60 <argraw+0x30>
    return p->trapframe->a5;
    80002c82:	6d3c                	ld	a5,88(a0)
    80002c84:	6fc8                	ld	a0,152(a5)
    80002c86:	bfe9                	j	80002c60 <argraw+0x30>
  panic("argraw");
    80002c88:	00005517          	auipc	a0,0x5
    80002c8c:	7a850513          	addi	a0,a0,1960 # 80008430 <states.0+0x148>
    80002c90:	ffffe097          	auipc	ra,0xffffe
    80002c94:	8b0080e7          	jalr	-1872(ra) # 80000540 <panic>

0000000080002c98 <fetchaddr>:
{
    80002c98:	1101                	addi	sp,sp,-32
    80002c9a:	ec06                	sd	ra,24(sp)
    80002c9c:	e822                	sd	s0,16(sp)
    80002c9e:	e426                	sd	s1,8(sp)
    80002ca0:	e04a                	sd	s2,0(sp)
    80002ca2:	1000                	addi	s0,sp,32
    80002ca4:	84aa                	mv	s1,a0
    80002ca6:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002ca8:	fffff097          	auipc	ra,0xfffff
    80002cac:	d04080e7          	jalr	-764(ra) # 800019ac <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002cb0:	653c                	ld	a5,72(a0)
    80002cb2:	02f4f863          	bgeu	s1,a5,80002ce2 <fetchaddr+0x4a>
    80002cb6:	00848713          	addi	a4,s1,8
    80002cba:	02e7e663          	bltu	a5,a4,80002ce6 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002cbe:	46a1                	li	a3,8
    80002cc0:	8626                	mv	a2,s1
    80002cc2:	85ca                	mv	a1,s2
    80002cc4:	6928                	ld	a0,80(a0)
    80002cc6:	fffff097          	auipc	ra,0xfffff
    80002cca:	a32080e7          	jalr	-1486(ra) # 800016f8 <copyin>
    80002cce:	00a03533          	snez	a0,a0
    80002cd2:	40a00533          	neg	a0,a0
}
    80002cd6:	60e2                	ld	ra,24(sp)
    80002cd8:	6442                	ld	s0,16(sp)
    80002cda:	64a2                	ld	s1,8(sp)
    80002cdc:	6902                	ld	s2,0(sp)
    80002cde:	6105                	addi	sp,sp,32
    80002ce0:	8082                	ret
    return -1;
    80002ce2:	557d                	li	a0,-1
    80002ce4:	bfcd                	j	80002cd6 <fetchaddr+0x3e>
    80002ce6:	557d                	li	a0,-1
    80002ce8:	b7fd                	j	80002cd6 <fetchaddr+0x3e>

0000000080002cea <fetchstr>:
{
    80002cea:	7179                	addi	sp,sp,-48
    80002cec:	f406                	sd	ra,40(sp)
    80002cee:	f022                	sd	s0,32(sp)
    80002cf0:	ec26                	sd	s1,24(sp)
    80002cf2:	e84a                	sd	s2,16(sp)
    80002cf4:	e44e                	sd	s3,8(sp)
    80002cf6:	1800                	addi	s0,sp,48
    80002cf8:	892a                	mv	s2,a0
    80002cfa:	84ae                	mv	s1,a1
    80002cfc:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002cfe:	fffff097          	auipc	ra,0xfffff
    80002d02:	cae080e7          	jalr	-850(ra) # 800019ac <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002d06:	86ce                	mv	a3,s3
    80002d08:	864a                	mv	a2,s2
    80002d0a:	85a6                	mv	a1,s1
    80002d0c:	6928                	ld	a0,80(a0)
    80002d0e:	fffff097          	auipc	ra,0xfffff
    80002d12:	a78080e7          	jalr	-1416(ra) # 80001786 <copyinstr>
    80002d16:	00054e63          	bltz	a0,80002d32 <fetchstr+0x48>
  return strlen(buf);
    80002d1a:	8526                	mv	a0,s1
    80002d1c:	ffffe097          	auipc	ra,0xffffe
    80002d20:	132080e7          	jalr	306(ra) # 80000e4e <strlen>
}
    80002d24:	70a2                	ld	ra,40(sp)
    80002d26:	7402                	ld	s0,32(sp)
    80002d28:	64e2                	ld	s1,24(sp)
    80002d2a:	6942                	ld	s2,16(sp)
    80002d2c:	69a2                	ld	s3,8(sp)
    80002d2e:	6145                	addi	sp,sp,48
    80002d30:	8082                	ret
    return -1;
    80002d32:	557d                	li	a0,-1
    80002d34:	bfc5                	j	80002d24 <fetchstr+0x3a>

0000000080002d36 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002d36:	1101                	addi	sp,sp,-32
    80002d38:	ec06                	sd	ra,24(sp)
    80002d3a:	e822                	sd	s0,16(sp)
    80002d3c:	e426                	sd	s1,8(sp)
    80002d3e:	1000                	addi	s0,sp,32
    80002d40:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002d42:	00000097          	auipc	ra,0x0
    80002d46:	eee080e7          	jalr	-274(ra) # 80002c30 <argraw>
    80002d4a:	c088                	sw	a0,0(s1)
  return 0;
}
    80002d4c:	4501                	li	a0,0
    80002d4e:	60e2                	ld	ra,24(sp)
    80002d50:	6442                	ld	s0,16(sp)
    80002d52:	64a2                	ld	s1,8(sp)
    80002d54:	6105                	addi	sp,sp,32
    80002d56:	8082                	ret

0000000080002d58 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002d58:	1101                	addi	sp,sp,-32
    80002d5a:	ec06                	sd	ra,24(sp)
    80002d5c:	e822                	sd	s0,16(sp)
    80002d5e:	e426                	sd	s1,8(sp)
    80002d60:	1000                	addi	s0,sp,32
    80002d62:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002d64:	00000097          	auipc	ra,0x0
    80002d68:	ecc080e7          	jalr	-308(ra) # 80002c30 <argraw>
    80002d6c:	e088                	sd	a0,0(s1)
  return 0;
}
    80002d6e:	4501                	li	a0,0
    80002d70:	60e2                	ld	ra,24(sp)
    80002d72:	6442                	ld	s0,16(sp)
    80002d74:	64a2                	ld	s1,8(sp)
    80002d76:	6105                	addi	sp,sp,32
    80002d78:	8082                	ret

0000000080002d7a <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002d7a:	7179                	addi	sp,sp,-48
    80002d7c:	f406                	sd	ra,40(sp)
    80002d7e:	f022                	sd	s0,32(sp)
    80002d80:	ec26                	sd	s1,24(sp)
    80002d82:	e84a                	sd	s2,16(sp)
    80002d84:	1800                	addi	s0,sp,48
    80002d86:	84ae                	mv	s1,a1
    80002d88:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002d8a:	fd840593          	addi	a1,s0,-40
    80002d8e:	00000097          	auipc	ra,0x0
    80002d92:	fca080e7          	jalr	-54(ra) # 80002d58 <argaddr>
  return fetchstr(addr, buf, max);
    80002d96:	864a                	mv	a2,s2
    80002d98:	85a6                	mv	a1,s1
    80002d9a:	fd843503          	ld	a0,-40(s0)
    80002d9e:	00000097          	auipc	ra,0x0
    80002da2:	f4c080e7          	jalr	-180(ra) # 80002cea <fetchstr>
}
    80002da6:	70a2                	ld	ra,40(sp)
    80002da8:	7402                	ld	s0,32(sp)
    80002daa:	64e2                	ld	s1,24(sp)
    80002dac:	6942                	ld	s2,16(sp)
    80002dae:	6145                	addi	sp,sp,48
    80002db0:	8082                	ret

0000000080002db2 <syscall>:
	static char *systemCallsNames[]={"","fork","exit","wait","pipe","read","kill","exec","fstat","chdir","dup","getpid","sbrk","sleep","uptime","open","write","mknod","unlink","link","mkdir","close","trace", "waitx", "setpriority"};	
// Stores the number of arguments corresponsing to each system call in the above order of system calls.	
int systemCallArgs[]={0, 0, 1, 1, 1, 3, 1, 2, 2, 1, 1, 0, 1, 1, 0, 2, 3, 3, 1, 2, 1, 1, 1, 3, 2};
void
syscall(void)
{
    80002db2:	7139                	addi	sp,sp,-64
    80002db4:	fc06                	sd	ra,56(sp)
    80002db6:	f822                	sd	s0,48(sp)
    80002db8:	f426                	sd	s1,40(sp)
    80002dba:	f04a                	sd	s2,32(sp)
    80002dbc:	ec4e                	sd	s3,24(sp)
    80002dbe:	e852                	sd	s4,16(sp)
    80002dc0:	e456                	sd	s5,8(sp)
    80002dc2:	e05a                	sd	s6,0(sp)
    80002dc4:	0080                	addi	s0,sp,64
  int num;
  struct proc *p = myproc();
    80002dc6:	fffff097          	auipc	ra,0xfffff
    80002dca:	be6080e7          	jalr	-1050(ra) # 800019ac <myproc>
    80002dce:	892a                	mv	s2,a0

  num = p->trapframe->a7;
    80002dd0:	6d24                	ld	s1,88(a0)
    80002dd2:	74dc                	ld	a5,168(s1)
    80002dd4:	0007899b          	sext.w	s3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002dd8:	37fd                	addiw	a5,a5,-1
    80002dda:	475d                	li	a4,23
    80002ddc:	0ef76763          	bltu	a4,a5,80002eca <syscall+0x118>
    80002de0:	00399713          	slli	a4,s3,0x3
    80002de4:	00005797          	auipc	a5,0x5
    80002de8:	78478793          	addi	a5,a5,1924 # 80008568 <syscalls>
    80002dec:	97ba                	add	a5,a5,a4
    80002dee:	639c                	ld	a5,0(a5)
    80002df0:	cfe9                	beqz	a5,80002eca <syscall+0x118>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002df2:	9782                	jalr	a5
    80002df4:	f8a8                	sd	a0,112(s1)
      if((p->mask>>num)&1){	
    80002df6:	16892483          	lw	s1,360(s2)
    80002dfa:	4134d4bb          	sraw	s1,s1,s3
    80002dfe:	8885                	andi	s1,s1,1
    80002e00:	c4f5                	beqz	s1,80002eec <syscall+0x13a>
      printf("%d: syscall %s (", p->pid, systemCallsNames[num]);	
    80002e02:	00399713          	slli	a4,s3,0x3
    80002e06:	00005797          	auipc	a5,0x5
    80002e0a:	76278793          	addi	a5,a5,1890 # 80008568 <syscalls>
    80002e0e:	97ba                	add	a5,a5,a4
    80002e10:	67f0                	ld	a2,200(a5)
    80002e12:	03092583          	lw	a1,48(s2)
    80002e16:	00005517          	auipc	a0,0x5
    80002e1a:	62250513          	addi	a0,a0,1570 # 80008438 <states.0+0x150>
    80002e1e:	ffffd097          	auipc	ra,0xffffd
    80002e22:	76c080e7          	jalr	1900(ra) # 8000058a <printf>
      int numberOfArguments = systemCallArgs[num];	
    80002e26:	098a                	slli	s3,s3,0x2
    80002e28:	00006797          	auipc	a5,0x6
    80002e2c:	c5078793          	addi	a5,a5,-944 # 80008a78 <systemCallArgs>
    80002e30:	97ce                	add	a5,a5,s3
    80002e32:	0007a983          	lw	s3,0(a5)
      if (numberOfArguments > 1)	
    80002e36:	4785                	li	a5,1
    80002e38:	0337d763          	bge	a5,s3,80002e66 <syscall+0xb4>
        printf("%d ", p->storedVal);	
    80002e3c:	17093583          	ld	a1,368(s2)
    80002e40:	00005517          	auipc	a0,0x5
    80002e44:	61050513          	addi	a0,a0,1552 # 80008450 <states.0+0x168>
    80002e48:	ffffd097          	auipc	ra,0xffffd
    80002e4c:	742080e7          	jalr	1858(ra) # 8000058a <printf>
      else 	
        printf("%d", p->storedVal);	
      for (int i = 1; i < numberOfArguments; i++) {	
        if (i == numberOfArguments - 1) printf("%d", argraw(i));	
    80002e50:	fff98a1b          	addiw	s4,s3,-1
        else printf("%d ", argraw(i));	
    80002e54:	00005a97          	auipc	s5,0x5
    80002e58:	5fca8a93          	addi	s5,s5,1532 # 80008450 <states.0+0x168>
        if (i == numberOfArguments - 1) printf("%d", argraw(i));	
    80002e5c:	00005b17          	auipc	s6,0x5
    80002e60:	5fcb0b13          	addi	s6,s6,1532 # 80008458 <states.0+0x170>
    80002e64:	a0a9                	j	80002eae <syscall+0xfc>
        printf("%d", p->storedVal);	
    80002e66:	17093583          	ld	a1,368(s2)
    80002e6a:	00005517          	auipc	a0,0x5
    80002e6e:	5ee50513          	addi	a0,a0,1518 # 80008458 <states.0+0x170>
    80002e72:	ffffd097          	auipc	ra,0xffffd
    80002e76:	718080e7          	jalr	1816(ra) # 8000058a <printf>
      }	
      printf(") -> %d\n", p->trapframe->a0);	
    80002e7a:	05893783          	ld	a5,88(s2)
    80002e7e:	7bac                	ld	a1,112(a5)
    80002e80:	00005517          	auipc	a0,0x5
    80002e84:	5e050513          	addi	a0,a0,1504 # 80008460 <states.0+0x178>
    80002e88:	ffffd097          	auipc	ra,0xffffd
    80002e8c:	702080e7          	jalr	1794(ra) # 8000058a <printf>
    80002e90:	a8b1                	j	80002eec <syscall+0x13a>
        if (i == numberOfArguments - 1) printf("%d", argraw(i));	
    80002e92:	8526                	mv	a0,s1
    80002e94:	00000097          	auipc	ra,0x0
    80002e98:	d9c080e7          	jalr	-612(ra) # 80002c30 <argraw>
    80002e9c:	85aa                	mv	a1,a0
    80002e9e:	855a                	mv	a0,s6
    80002ea0:	ffffd097          	auipc	ra,0xffffd
    80002ea4:	6ea080e7          	jalr	1770(ra) # 8000058a <printf>
      for (int i = 1; i < numberOfArguments; i++) {	
    80002ea8:	2485                	addiw	s1,s1,1
    80002eaa:	fc9988e3          	beq	s3,s1,80002e7a <syscall+0xc8>
        if (i == numberOfArguments - 1) printf("%d", argraw(i));	
    80002eae:	fe9a02e3          	beq	s4,s1,80002e92 <syscall+0xe0>
        else printf("%d ", argraw(i));	
    80002eb2:	8526                	mv	a0,s1
    80002eb4:	00000097          	auipc	ra,0x0
    80002eb8:	d7c080e7          	jalr	-644(ra) # 80002c30 <argraw>
    80002ebc:	85aa                	mv	a1,a0
    80002ebe:	8556                	mv	a0,s5
    80002ec0:	ffffd097          	auipc	ra,0xffffd
    80002ec4:	6ca080e7          	jalr	1738(ra) # 8000058a <printf>
    80002ec8:	b7c5                	j	80002ea8 <syscall+0xf6>
    }
    
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002eca:	86ce                	mv	a3,s3
    80002ecc:	15890613          	addi	a2,s2,344
    80002ed0:	03092583          	lw	a1,48(s2)
    80002ed4:	00005517          	auipc	a0,0x5
    80002ed8:	59c50513          	addi	a0,a0,1436 # 80008470 <states.0+0x188>
    80002edc:	ffffd097          	auipc	ra,0xffffd
    80002ee0:	6ae080e7          	jalr	1710(ra) # 8000058a <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002ee4:	05893783          	ld	a5,88(s2)
    80002ee8:	577d                	li	a4,-1
    80002eea:	fbb8                	sd	a4,112(a5)
  }
}
    80002eec:	70e2                	ld	ra,56(sp)
    80002eee:	7442                	ld	s0,48(sp)
    80002ef0:	74a2                	ld	s1,40(sp)
    80002ef2:	7902                	ld	s2,32(sp)
    80002ef4:	69e2                	ld	s3,24(sp)
    80002ef6:	6a42                	ld	s4,16(sp)
    80002ef8:	6aa2                	ld	s5,8(sp)
    80002efa:	6b02                	ld	s6,0(sp)
    80002efc:	6121                	addi	sp,sp,64
    80002efe:	8082                	ret

0000000080002f00 <sys_strace>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_strace(void)
{
    80002f00:	1101                	addi	sp,sp,-32
    80002f02:	ec06                	sd	ra,24(sp)
    80002f04:	e822                	sd	s0,16(sp)
    80002f06:	1000                	addi	s0,sp,32
  int trace_mask;

  argint(0, &trace_mask);
    80002f08:	fec40593          	addi	a1,s0,-20
    80002f0c:	4501                	li	a0,0
    80002f0e:	00000097          	auipc	ra,0x0
    80002f12:	e28080e7          	jalr	-472(ra) # 80002d36 <argint>
  if (trace_mask < 0)
    80002f16:	fec42783          	lw	a5,-20(s0)
    return -1;
    80002f1a:	557d                	li	a0,-1
  if (trace_mask < 0)
    80002f1c:	0007cb63          	bltz	a5,80002f32 <sys_strace+0x32>

  struct proc *p = myproc();
    80002f20:	fffff097          	auipc	ra,0xfffff
    80002f24:	a8c080e7          	jalr	-1396(ra) # 800019ac <myproc>
  p->mask = trace_mask;
    80002f28:	fec42783          	lw	a5,-20(s0)
    80002f2c:	16f52423          	sw	a5,360(a0)

  return 0;
    80002f30:	4501                	li	a0,0
}
    80002f32:	60e2                	ld	ra,24(sp)
    80002f34:	6442                	ld	s0,16(sp)
    80002f36:	6105                	addi	sp,sp,32
    80002f38:	8082                	ret

0000000080002f3a <sys_waitx>:
uint64	
sys_waitx(void)	
{	
    80002f3a:	7139                	addi	sp,sp,-64
    80002f3c:	fc06                	sd	ra,56(sp)
    80002f3e:	f822                	sd	s0,48(sp)
    80002f40:	f426                	sd	s1,40(sp)
    80002f42:	f04a                	sd	s2,32(sp)
    80002f44:	0080                	addi	s0,sp,64
  uint64 addr, addr1, addr2;	
  uint wtime, rtime;	
  if(argaddr(0, &addr) < 0)	
    80002f46:	fd840593          	addi	a1,s0,-40
    80002f4a:	4501                	li	a0,0
    80002f4c:	00000097          	auipc	ra,0x0
    80002f50:	e0c080e7          	jalr	-500(ra) # 80002d58 <argaddr>
    return -1;	
    80002f54:	57fd                	li	a5,-1
  if(argaddr(0, &addr) < 0)	
    80002f56:	08054063          	bltz	a0,80002fd6 <sys_waitx+0x9c>
  if(argaddr(1, &addr1) < 0) // user virtual memory	
    80002f5a:	fd040593          	addi	a1,s0,-48
    80002f5e:	4505                	li	a0,1
    80002f60:	00000097          	auipc	ra,0x0
    80002f64:	df8080e7          	jalr	-520(ra) # 80002d58 <argaddr>
    return -1;	
    80002f68:	57fd                	li	a5,-1
  if(argaddr(1, &addr1) < 0) // user virtual memory	
    80002f6a:	06054663          	bltz	a0,80002fd6 <sys_waitx+0x9c>
  if(argaddr(2, &addr2) < 0)	
    80002f6e:	fc840593          	addi	a1,s0,-56
    80002f72:	4509                	li	a0,2
    80002f74:	00000097          	auipc	ra,0x0
    80002f78:	de4080e7          	jalr	-540(ra) # 80002d58 <argaddr>
    return -1;	
    80002f7c:	57fd                	li	a5,-1
  if(argaddr(2, &addr2) < 0)	
    80002f7e:	04054c63          	bltz	a0,80002fd6 <sys_waitx+0x9c>
  int ret = waitx(addr, &wtime, &rtime);	
    80002f82:	fc040613          	addi	a2,s0,-64
    80002f86:	fc440593          	addi	a1,s0,-60
    80002f8a:	fd843503          	ld	a0,-40(s0)
    80002f8e:	fffff097          	auipc	ra,0xfffff
    80002f92:	206080e7          	jalr	518(ra) # 80002194 <waitx>
    80002f96:	892a                	mv	s2,a0
  struct proc* p = myproc();	
    80002f98:	fffff097          	auipc	ra,0xfffff
    80002f9c:	a14080e7          	jalr	-1516(ra) # 800019ac <myproc>
    80002fa0:	84aa                	mv	s1,a0
  if (copyout(p->pagetable, addr1,(char*)&wtime, sizeof(int)) < 0)	
    80002fa2:	4691                	li	a3,4
    80002fa4:	fc440613          	addi	a2,s0,-60
    80002fa8:	fd043583          	ld	a1,-48(s0)
    80002fac:	6928                	ld	a0,80(a0)
    80002fae:	ffffe097          	auipc	ra,0xffffe
    80002fb2:	6be080e7          	jalr	1726(ra) # 8000166c <copyout>
    return -1;	
    80002fb6:	57fd                	li	a5,-1
  if (copyout(p->pagetable, addr1,(char*)&wtime, sizeof(int)) < 0)	
    80002fb8:	00054f63          	bltz	a0,80002fd6 <sys_waitx+0x9c>
  if (copyout(p->pagetable, addr2,(char*)&rtime, sizeof(int)) < 0)	
    80002fbc:	4691                	li	a3,4
    80002fbe:	fc040613          	addi	a2,s0,-64
    80002fc2:	fc843583          	ld	a1,-56(s0)
    80002fc6:	68a8                	ld	a0,80(s1)
    80002fc8:	ffffe097          	auipc	ra,0xffffe
    80002fcc:	6a4080e7          	jalr	1700(ra) # 8000166c <copyout>
    80002fd0:	00054a63          	bltz	a0,80002fe4 <sys_waitx+0xaa>
    return -1;	
  return ret;	
    80002fd4:	87ca                	mv	a5,s2
}	
    80002fd6:	853e                	mv	a0,a5
    80002fd8:	70e2                	ld	ra,56(sp)
    80002fda:	7442                	ld	s0,48(sp)
    80002fdc:	74a2                	ld	s1,40(sp)
    80002fde:	7902                	ld	s2,32(sp)
    80002fe0:	6121                	addi	sp,sp,64
    80002fe2:	8082                	ret
    return -1;	
    80002fe4:	57fd                	li	a5,-1
    80002fe6:	bfc5                	j	80002fd6 <sys_waitx+0x9c>

0000000080002fe8 <sys_set_priority>:
uint64	
sys_set_priority(void)	
{	
    80002fe8:	1101                	addi	sp,sp,-32
    80002fea:	ec06                	sd	ra,24(sp)
    80002fec:	e822                	sd	s0,16(sp)
    80002fee:	1000                	addi	s0,sp,32
  int priority, pid;	
  if (argint(0, &priority) < 0)	
    80002ff0:	fec40593          	addi	a1,s0,-20
    80002ff4:	4501                	li	a0,0
    80002ff6:	00000097          	auipc	ra,0x0
    80002ffa:	d40080e7          	jalr	-704(ra) # 80002d36 <argint>
    return -1;	
    80002ffe:	57fd                	li	a5,-1
  if (argint(0, &priority) < 0)	
    80003000:	02054563          	bltz	a0,8000302a <sys_set_priority+0x42>
  if (argint(1, &pid) < 0)	
    80003004:	fe840593          	addi	a1,s0,-24
    80003008:	4505                	li	a0,1
    8000300a:	00000097          	auipc	ra,0x0
    8000300e:	d2c080e7          	jalr	-724(ra) # 80002d36 <argint>
    return -1;	
    80003012:	57fd                	li	a5,-1
  if (argint(1, &pid) < 0)	
    80003014:	00054b63          	bltz	a0,8000302a <sys_set_priority+0x42>
  return set_priority(priority, pid);	
    80003018:	fe842583          	lw	a1,-24(s0)
    8000301c:	fec42503          	lw	a0,-20(s0)
    80003020:	fffff097          	auipc	ra,0xfffff
    80003024:	f3e080e7          	jalr	-194(ra) # 80001f5e <set_priority>
    80003028:	87aa                	mv	a5,a0
}
    8000302a:	853e                	mv	a0,a5
    8000302c:	60e2                	ld	ra,24(sp)
    8000302e:	6442                	ld	s0,16(sp)
    80003030:	6105                	addi	sp,sp,32
    80003032:	8082                	ret

0000000080003034 <sys_exit>:
uint64
sys_exit(void)
{
    80003034:	1101                	addi	sp,sp,-32
    80003036:	ec06                	sd	ra,24(sp)
    80003038:	e822                	sd	s0,16(sp)
    8000303a:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    8000303c:	fec40593          	addi	a1,s0,-20
    80003040:	4501                	li	a0,0
    80003042:	00000097          	auipc	ra,0x0
    80003046:	cf4080e7          	jalr	-780(ra) # 80002d36 <argint>
  exit(n);
    8000304a:	fec42503          	lw	a0,-20(s0)
    8000304e:	fffff097          	auipc	ra,0xfffff
    80003052:	362080e7          	jalr	866(ra) # 800023b0 <exit>
  return 0;  // not reached
}
    80003056:	4501                	li	a0,0
    80003058:	60e2                	ld	ra,24(sp)
    8000305a:	6442                	ld	s0,16(sp)
    8000305c:	6105                	addi	sp,sp,32
    8000305e:	8082                	ret

0000000080003060 <sys_getpid>:

uint64
sys_getpid(void)
{
    80003060:	1141                	addi	sp,sp,-16
    80003062:	e406                	sd	ra,8(sp)
    80003064:	e022                	sd	s0,0(sp)
    80003066:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80003068:	fffff097          	auipc	ra,0xfffff
    8000306c:	944080e7          	jalr	-1724(ra) # 800019ac <myproc>
}
    80003070:	5908                	lw	a0,48(a0)
    80003072:	60a2                	ld	ra,8(sp)
    80003074:	6402                	ld	s0,0(sp)
    80003076:	0141                	addi	sp,sp,16
    80003078:	8082                	ret

000000008000307a <sys_fork>:

uint64
sys_fork(void)
{
    8000307a:	1141                	addi	sp,sp,-16
    8000307c:	e406                	sd	ra,8(sp)
    8000307e:	e022                	sd	s0,0(sp)
    80003080:	0800                	addi	s0,sp,16
  return fork();
    80003082:	fffff097          	auipc	ra,0xfffff
    80003086:	cfc080e7          	jalr	-772(ra) # 80001d7e <fork>
}
    8000308a:	60a2                	ld	ra,8(sp)
    8000308c:	6402                	ld	s0,0(sp)
    8000308e:	0141                	addi	sp,sp,16
    80003090:	8082                	ret

0000000080003092 <sys_wait>:

uint64
sys_wait(void)
{
    80003092:	1101                	addi	sp,sp,-32
    80003094:	ec06                	sd	ra,24(sp)
    80003096:	e822                	sd	s0,16(sp)
    80003098:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    8000309a:	fe840593          	addi	a1,s0,-24
    8000309e:	4501                	li	a0,0
    800030a0:	00000097          	auipc	ra,0x0
    800030a4:	cb8080e7          	jalr	-840(ra) # 80002d58 <argaddr>
  return wait(p);
    800030a8:	fe843503          	ld	a0,-24(s0)
    800030ac:	fffff097          	auipc	ra,0xfffff
    800030b0:	4b6080e7          	jalr	1206(ra) # 80002562 <wait>
}
    800030b4:	60e2                	ld	ra,24(sp)
    800030b6:	6442                	ld	s0,16(sp)
    800030b8:	6105                	addi	sp,sp,32
    800030ba:	8082                	ret

00000000800030bc <sys_sbrk>:

uint64
sys_sbrk(void)
{
    800030bc:	7179                	addi	sp,sp,-48
    800030be:	f406                	sd	ra,40(sp)
    800030c0:	f022                	sd	s0,32(sp)
    800030c2:	ec26                	sd	s1,24(sp)
    800030c4:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    800030c6:	fdc40593          	addi	a1,s0,-36
    800030ca:	4501                	li	a0,0
    800030cc:	00000097          	auipc	ra,0x0
    800030d0:	c6a080e7          	jalr	-918(ra) # 80002d36 <argint>
  addr = myproc()->sz;
    800030d4:	fffff097          	auipc	ra,0xfffff
    800030d8:	8d8080e7          	jalr	-1832(ra) # 800019ac <myproc>
    800030dc:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    800030de:	fdc42503          	lw	a0,-36(s0)
    800030e2:	fffff097          	auipc	ra,0xfffff
    800030e6:	c40080e7          	jalr	-960(ra) # 80001d22 <growproc>
    800030ea:	00054863          	bltz	a0,800030fa <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    800030ee:	8526                	mv	a0,s1
    800030f0:	70a2                	ld	ra,40(sp)
    800030f2:	7402                	ld	s0,32(sp)
    800030f4:	64e2                	ld	s1,24(sp)
    800030f6:	6145                	addi	sp,sp,48
    800030f8:	8082                	ret
    return -1;
    800030fa:	54fd                	li	s1,-1
    800030fc:	bfcd                	j	800030ee <sys_sbrk+0x32>

00000000800030fe <sys_sleep>:

uint64
sys_sleep(void)
{
    800030fe:	7139                	addi	sp,sp,-64
    80003100:	fc06                	sd	ra,56(sp)
    80003102:	f822                	sd	s0,48(sp)
    80003104:	f426                	sd	s1,40(sp)
    80003106:	f04a                	sd	s2,32(sp)
    80003108:	ec4e                	sd	s3,24(sp)
    8000310a:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    8000310c:	fcc40593          	addi	a1,s0,-52
    80003110:	4501                	li	a0,0
    80003112:	00000097          	auipc	ra,0x0
    80003116:	c24080e7          	jalr	-988(ra) # 80002d36 <argint>
  acquire(&tickslock);
    8000311a:	00014517          	auipc	a0,0x14
    8000311e:	2b650513          	addi	a0,a0,694 # 800173d0 <tickslock>
    80003122:	ffffe097          	auipc	ra,0xffffe
    80003126:	ab4080e7          	jalr	-1356(ra) # 80000bd6 <acquire>
  ticks0 = ticks;
    8000312a:	00006917          	auipc	s2,0x6
    8000312e:	a0692903          	lw	s2,-1530(s2) # 80008b30 <ticks>
  while(ticks - ticks0 < n){
    80003132:	fcc42783          	lw	a5,-52(s0)
    80003136:	cf9d                	beqz	a5,80003174 <sys_sleep+0x76>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80003138:	00014997          	auipc	s3,0x14
    8000313c:	29898993          	addi	s3,s3,664 # 800173d0 <tickslock>
    80003140:	00006497          	auipc	s1,0x6
    80003144:	9f048493          	addi	s1,s1,-1552 # 80008b30 <ticks>
    if(killed(myproc())){
    80003148:	fffff097          	auipc	ra,0xfffff
    8000314c:	864080e7          	jalr	-1948(ra) # 800019ac <myproc>
    80003150:	fffff097          	auipc	ra,0xfffff
    80003154:	3e0080e7          	jalr	992(ra) # 80002530 <killed>
    80003158:	ed15                	bnez	a0,80003194 <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    8000315a:	85ce                	mv	a1,s3
    8000315c:	8526                	mv	a0,s1
    8000315e:	fffff097          	auipc	ra,0xfffff
    80003162:	fd2080e7          	jalr	-46(ra) # 80002130 <sleep>
  while(ticks - ticks0 < n){
    80003166:	409c                	lw	a5,0(s1)
    80003168:	412787bb          	subw	a5,a5,s2
    8000316c:	fcc42703          	lw	a4,-52(s0)
    80003170:	fce7ece3          	bltu	a5,a4,80003148 <sys_sleep+0x4a>
  }
  release(&tickslock);
    80003174:	00014517          	auipc	a0,0x14
    80003178:	25c50513          	addi	a0,a0,604 # 800173d0 <tickslock>
    8000317c:	ffffe097          	auipc	ra,0xffffe
    80003180:	b0e080e7          	jalr	-1266(ra) # 80000c8a <release>
  return 0;
    80003184:	4501                	li	a0,0
}
    80003186:	70e2                	ld	ra,56(sp)
    80003188:	7442                	ld	s0,48(sp)
    8000318a:	74a2                	ld	s1,40(sp)
    8000318c:	7902                	ld	s2,32(sp)
    8000318e:	69e2                	ld	s3,24(sp)
    80003190:	6121                	addi	sp,sp,64
    80003192:	8082                	ret
      release(&tickslock);
    80003194:	00014517          	auipc	a0,0x14
    80003198:	23c50513          	addi	a0,a0,572 # 800173d0 <tickslock>
    8000319c:	ffffe097          	auipc	ra,0xffffe
    800031a0:	aee080e7          	jalr	-1298(ra) # 80000c8a <release>
      return -1;
    800031a4:	557d                	li	a0,-1
    800031a6:	b7c5                	j	80003186 <sys_sleep+0x88>

00000000800031a8 <sys_kill>:

uint64
sys_kill(void)
{
    800031a8:	1101                	addi	sp,sp,-32
    800031aa:	ec06                	sd	ra,24(sp)
    800031ac:	e822                	sd	s0,16(sp)
    800031ae:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    800031b0:	fec40593          	addi	a1,s0,-20
    800031b4:	4501                	li	a0,0
    800031b6:	00000097          	auipc	ra,0x0
    800031ba:	b80080e7          	jalr	-1152(ra) # 80002d36 <argint>
  return kill(pid);
    800031be:	fec42503          	lw	a0,-20(s0)
    800031c2:	fffff097          	auipc	ra,0xfffff
    800031c6:	2d0080e7          	jalr	720(ra) # 80002492 <kill>
}
    800031ca:	60e2                	ld	ra,24(sp)
    800031cc:	6442                	ld	s0,16(sp)
    800031ce:	6105                	addi	sp,sp,32
    800031d0:	8082                	ret

00000000800031d2 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    800031d2:	1101                	addi	sp,sp,-32
    800031d4:	ec06                	sd	ra,24(sp)
    800031d6:	e822                	sd	s0,16(sp)
    800031d8:	e426                	sd	s1,8(sp)
    800031da:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    800031dc:	00014517          	auipc	a0,0x14
    800031e0:	1f450513          	addi	a0,a0,500 # 800173d0 <tickslock>
    800031e4:	ffffe097          	auipc	ra,0xffffe
    800031e8:	9f2080e7          	jalr	-1550(ra) # 80000bd6 <acquire>
  xticks = ticks;
    800031ec:	00006497          	auipc	s1,0x6
    800031f0:	9444a483          	lw	s1,-1724(s1) # 80008b30 <ticks>
  release(&tickslock);
    800031f4:	00014517          	auipc	a0,0x14
    800031f8:	1dc50513          	addi	a0,a0,476 # 800173d0 <tickslock>
    800031fc:	ffffe097          	auipc	ra,0xffffe
    80003200:	a8e080e7          	jalr	-1394(ra) # 80000c8a <release>
  return xticks;
}
    80003204:	02049513          	slli	a0,s1,0x20
    80003208:	9101                	srli	a0,a0,0x20
    8000320a:	60e2                	ld	ra,24(sp)
    8000320c:	6442                	ld	s0,16(sp)
    8000320e:	64a2                	ld	s1,8(sp)
    80003210:	6105                	addi	sp,sp,32
    80003212:	8082                	ret

0000000080003214 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003214:	7179                	addi	sp,sp,-48
    80003216:	f406                	sd	ra,40(sp)
    80003218:	f022                	sd	s0,32(sp)
    8000321a:	ec26                	sd	s1,24(sp)
    8000321c:	e84a                	sd	s2,16(sp)
    8000321e:	e44e                	sd	s3,8(sp)
    80003220:	e052                	sd	s4,0(sp)
    80003222:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003224:	00005597          	auipc	a1,0x5
    80003228:	4d458593          	addi	a1,a1,1236 # 800086f8 <systemCallsNames+0xc8>
    8000322c:	00014517          	auipc	a0,0x14
    80003230:	1bc50513          	addi	a0,a0,444 # 800173e8 <bcache>
    80003234:	ffffe097          	auipc	ra,0xffffe
    80003238:	912080e7          	jalr	-1774(ra) # 80000b46 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    8000323c:	0001c797          	auipc	a5,0x1c
    80003240:	1ac78793          	addi	a5,a5,428 # 8001f3e8 <bcache+0x8000>
    80003244:	0001c717          	auipc	a4,0x1c
    80003248:	40c70713          	addi	a4,a4,1036 # 8001f650 <bcache+0x8268>
    8000324c:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003250:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003254:	00014497          	auipc	s1,0x14
    80003258:	1ac48493          	addi	s1,s1,428 # 80017400 <bcache+0x18>
    b->next = bcache.head.next;
    8000325c:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    8000325e:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003260:	00005a17          	auipc	s4,0x5
    80003264:	4a0a0a13          	addi	s4,s4,1184 # 80008700 <systemCallsNames+0xd0>
    b->next = bcache.head.next;
    80003268:	2b893783          	ld	a5,696(s2)
    8000326c:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    8000326e:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003272:	85d2                	mv	a1,s4
    80003274:	01048513          	addi	a0,s1,16
    80003278:	00001097          	auipc	ra,0x1
    8000327c:	4c8080e7          	jalr	1224(ra) # 80004740 <initsleeplock>
    bcache.head.next->prev = b;
    80003280:	2b893783          	ld	a5,696(s2)
    80003284:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80003286:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000328a:	45848493          	addi	s1,s1,1112
    8000328e:	fd349de3          	bne	s1,s3,80003268 <binit+0x54>
  }
}
    80003292:	70a2                	ld	ra,40(sp)
    80003294:	7402                	ld	s0,32(sp)
    80003296:	64e2                	ld	s1,24(sp)
    80003298:	6942                	ld	s2,16(sp)
    8000329a:	69a2                	ld	s3,8(sp)
    8000329c:	6a02                	ld	s4,0(sp)
    8000329e:	6145                	addi	sp,sp,48
    800032a0:	8082                	ret

00000000800032a2 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800032a2:	7179                	addi	sp,sp,-48
    800032a4:	f406                	sd	ra,40(sp)
    800032a6:	f022                	sd	s0,32(sp)
    800032a8:	ec26                	sd	s1,24(sp)
    800032aa:	e84a                	sd	s2,16(sp)
    800032ac:	e44e                	sd	s3,8(sp)
    800032ae:	1800                	addi	s0,sp,48
    800032b0:	892a                	mv	s2,a0
    800032b2:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    800032b4:	00014517          	auipc	a0,0x14
    800032b8:	13450513          	addi	a0,a0,308 # 800173e8 <bcache>
    800032bc:	ffffe097          	auipc	ra,0xffffe
    800032c0:	91a080e7          	jalr	-1766(ra) # 80000bd6 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800032c4:	0001c497          	auipc	s1,0x1c
    800032c8:	3dc4b483          	ld	s1,988(s1) # 8001f6a0 <bcache+0x82b8>
    800032cc:	0001c797          	auipc	a5,0x1c
    800032d0:	38478793          	addi	a5,a5,900 # 8001f650 <bcache+0x8268>
    800032d4:	02f48f63          	beq	s1,a5,80003312 <bread+0x70>
    800032d8:	873e                	mv	a4,a5
    800032da:	a021                	j	800032e2 <bread+0x40>
    800032dc:	68a4                	ld	s1,80(s1)
    800032de:	02e48a63          	beq	s1,a4,80003312 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    800032e2:	449c                	lw	a5,8(s1)
    800032e4:	ff279ce3          	bne	a5,s2,800032dc <bread+0x3a>
    800032e8:	44dc                	lw	a5,12(s1)
    800032ea:	ff3799e3          	bne	a5,s3,800032dc <bread+0x3a>
      b->refcnt++;
    800032ee:	40bc                	lw	a5,64(s1)
    800032f0:	2785                	addiw	a5,a5,1
    800032f2:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800032f4:	00014517          	auipc	a0,0x14
    800032f8:	0f450513          	addi	a0,a0,244 # 800173e8 <bcache>
    800032fc:	ffffe097          	auipc	ra,0xffffe
    80003300:	98e080e7          	jalr	-1650(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    80003304:	01048513          	addi	a0,s1,16
    80003308:	00001097          	auipc	ra,0x1
    8000330c:	472080e7          	jalr	1138(ra) # 8000477a <acquiresleep>
      return b;
    80003310:	a8b9                	j	8000336e <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003312:	0001c497          	auipc	s1,0x1c
    80003316:	3864b483          	ld	s1,902(s1) # 8001f698 <bcache+0x82b0>
    8000331a:	0001c797          	auipc	a5,0x1c
    8000331e:	33678793          	addi	a5,a5,822 # 8001f650 <bcache+0x8268>
    80003322:	00f48863          	beq	s1,a5,80003332 <bread+0x90>
    80003326:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003328:	40bc                	lw	a5,64(s1)
    8000332a:	cf81                	beqz	a5,80003342 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000332c:	64a4                	ld	s1,72(s1)
    8000332e:	fee49de3          	bne	s1,a4,80003328 <bread+0x86>
  panic("bget: no buffers");
    80003332:	00005517          	auipc	a0,0x5
    80003336:	3d650513          	addi	a0,a0,982 # 80008708 <systemCallsNames+0xd8>
    8000333a:	ffffd097          	auipc	ra,0xffffd
    8000333e:	206080e7          	jalr	518(ra) # 80000540 <panic>
      b->dev = dev;
    80003342:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003346:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    8000334a:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    8000334e:	4785                	li	a5,1
    80003350:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003352:	00014517          	auipc	a0,0x14
    80003356:	09650513          	addi	a0,a0,150 # 800173e8 <bcache>
    8000335a:	ffffe097          	auipc	ra,0xffffe
    8000335e:	930080e7          	jalr	-1744(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    80003362:	01048513          	addi	a0,s1,16
    80003366:	00001097          	auipc	ra,0x1
    8000336a:	414080e7          	jalr	1044(ra) # 8000477a <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    8000336e:	409c                	lw	a5,0(s1)
    80003370:	cb89                	beqz	a5,80003382 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003372:	8526                	mv	a0,s1
    80003374:	70a2                	ld	ra,40(sp)
    80003376:	7402                	ld	s0,32(sp)
    80003378:	64e2                	ld	s1,24(sp)
    8000337a:	6942                	ld	s2,16(sp)
    8000337c:	69a2                	ld	s3,8(sp)
    8000337e:	6145                	addi	sp,sp,48
    80003380:	8082                	ret
    virtio_disk_rw(b, 0);
    80003382:	4581                	li	a1,0
    80003384:	8526                	mv	a0,s1
    80003386:	00003097          	auipc	ra,0x3
    8000338a:	fdc080e7          	jalr	-36(ra) # 80006362 <virtio_disk_rw>
    b->valid = 1;
    8000338e:	4785                	li	a5,1
    80003390:	c09c                	sw	a5,0(s1)
  return b;
    80003392:	b7c5                	j	80003372 <bread+0xd0>

0000000080003394 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003394:	1101                	addi	sp,sp,-32
    80003396:	ec06                	sd	ra,24(sp)
    80003398:	e822                	sd	s0,16(sp)
    8000339a:	e426                	sd	s1,8(sp)
    8000339c:	1000                	addi	s0,sp,32
    8000339e:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800033a0:	0541                	addi	a0,a0,16
    800033a2:	00001097          	auipc	ra,0x1
    800033a6:	472080e7          	jalr	1138(ra) # 80004814 <holdingsleep>
    800033aa:	cd01                	beqz	a0,800033c2 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800033ac:	4585                	li	a1,1
    800033ae:	8526                	mv	a0,s1
    800033b0:	00003097          	auipc	ra,0x3
    800033b4:	fb2080e7          	jalr	-78(ra) # 80006362 <virtio_disk_rw>
}
    800033b8:	60e2                	ld	ra,24(sp)
    800033ba:	6442                	ld	s0,16(sp)
    800033bc:	64a2                	ld	s1,8(sp)
    800033be:	6105                	addi	sp,sp,32
    800033c0:	8082                	ret
    panic("bwrite");
    800033c2:	00005517          	auipc	a0,0x5
    800033c6:	35e50513          	addi	a0,a0,862 # 80008720 <systemCallsNames+0xf0>
    800033ca:	ffffd097          	auipc	ra,0xffffd
    800033ce:	176080e7          	jalr	374(ra) # 80000540 <panic>

00000000800033d2 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800033d2:	1101                	addi	sp,sp,-32
    800033d4:	ec06                	sd	ra,24(sp)
    800033d6:	e822                	sd	s0,16(sp)
    800033d8:	e426                	sd	s1,8(sp)
    800033da:	e04a                	sd	s2,0(sp)
    800033dc:	1000                	addi	s0,sp,32
    800033de:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800033e0:	01050913          	addi	s2,a0,16
    800033e4:	854a                	mv	a0,s2
    800033e6:	00001097          	auipc	ra,0x1
    800033ea:	42e080e7          	jalr	1070(ra) # 80004814 <holdingsleep>
    800033ee:	c92d                	beqz	a0,80003460 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    800033f0:	854a                	mv	a0,s2
    800033f2:	00001097          	auipc	ra,0x1
    800033f6:	3de080e7          	jalr	990(ra) # 800047d0 <releasesleep>

  acquire(&bcache.lock);
    800033fa:	00014517          	auipc	a0,0x14
    800033fe:	fee50513          	addi	a0,a0,-18 # 800173e8 <bcache>
    80003402:	ffffd097          	auipc	ra,0xffffd
    80003406:	7d4080e7          	jalr	2004(ra) # 80000bd6 <acquire>
  b->refcnt--;
    8000340a:	40bc                	lw	a5,64(s1)
    8000340c:	37fd                	addiw	a5,a5,-1
    8000340e:	0007871b          	sext.w	a4,a5
    80003412:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003414:	eb05                	bnez	a4,80003444 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003416:	68bc                	ld	a5,80(s1)
    80003418:	64b8                	ld	a4,72(s1)
    8000341a:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    8000341c:	64bc                	ld	a5,72(s1)
    8000341e:	68b8                	ld	a4,80(s1)
    80003420:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003422:	0001c797          	auipc	a5,0x1c
    80003426:	fc678793          	addi	a5,a5,-58 # 8001f3e8 <bcache+0x8000>
    8000342a:	2b87b703          	ld	a4,696(a5)
    8000342e:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003430:	0001c717          	auipc	a4,0x1c
    80003434:	22070713          	addi	a4,a4,544 # 8001f650 <bcache+0x8268>
    80003438:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    8000343a:	2b87b703          	ld	a4,696(a5)
    8000343e:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003440:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003444:	00014517          	auipc	a0,0x14
    80003448:	fa450513          	addi	a0,a0,-92 # 800173e8 <bcache>
    8000344c:	ffffe097          	auipc	ra,0xffffe
    80003450:	83e080e7          	jalr	-1986(ra) # 80000c8a <release>
}
    80003454:	60e2                	ld	ra,24(sp)
    80003456:	6442                	ld	s0,16(sp)
    80003458:	64a2                	ld	s1,8(sp)
    8000345a:	6902                	ld	s2,0(sp)
    8000345c:	6105                	addi	sp,sp,32
    8000345e:	8082                	ret
    panic("brelse");
    80003460:	00005517          	auipc	a0,0x5
    80003464:	2c850513          	addi	a0,a0,712 # 80008728 <systemCallsNames+0xf8>
    80003468:	ffffd097          	auipc	ra,0xffffd
    8000346c:	0d8080e7          	jalr	216(ra) # 80000540 <panic>

0000000080003470 <bpin>:

void
bpin(struct buf *b) {
    80003470:	1101                	addi	sp,sp,-32
    80003472:	ec06                	sd	ra,24(sp)
    80003474:	e822                	sd	s0,16(sp)
    80003476:	e426                	sd	s1,8(sp)
    80003478:	1000                	addi	s0,sp,32
    8000347a:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000347c:	00014517          	auipc	a0,0x14
    80003480:	f6c50513          	addi	a0,a0,-148 # 800173e8 <bcache>
    80003484:	ffffd097          	auipc	ra,0xffffd
    80003488:	752080e7          	jalr	1874(ra) # 80000bd6 <acquire>
  b->refcnt++;
    8000348c:	40bc                	lw	a5,64(s1)
    8000348e:	2785                	addiw	a5,a5,1
    80003490:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003492:	00014517          	auipc	a0,0x14
    80003496:	f5650513          	addi	a0,a0,-170 # 800173e8 <bcache>
    8000349a:	ffffd097          	auipc	ra,0xffffd
    8000349e:	7f0080e7          	jalr	2032(ra) # 80000c8a <release>
}
    800034a2:	60e2                	ld	ra,24(sp)
    800034a4:	6442                	ld	s0,16(sp)
    800034a6:	64a2                	ld	s1,8(sp)
    800034a8:	6105                	addi	sp,sp,32
    800034aa:	8082                	ret

00000000800034ac <bunpin>:

void
bunpin(struct buf *b) {
    800034ac:	1101                	addi	sp,sp,-32
    800034ae:	ec06                	sd	ra,24(sp)
    800034b0:	e822                	sd	s0,16(sp)
    800034b2:	e426                	sd	s1,8(sp)
    800034b4:	1000                	addi	s0,sp,32
    800034b6:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800034b8:	00014517          	auipc	a0,0x14
    800034bc:	f3050513          	addi	a0,a0,-208 # 800173e8 <bcache>
    800034c0:	ffffd097          	auipc	ra,0xffffd
    800034c4:	716080e7          	jalr	1814(ra) # 80000bd6 <acquire>
  b->refcnt--;
    800034c8:	40bc                	lw	a5,64(s1)
    800034ca:	37fd                	addiw	a5,a5,-1
    800034cc:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800034ce:	00014517          	auipc	a0,0x14
    800034d2:	f1a50513          	addi	a0,a0,-230 # 800173e8 <bcache>
    800034d6:	ffffd097          	auipc	ra,0xffffd
    800034da:	7b4080e7          	jalr	1972(ra) # 80000c8a <release>
}
    800034de:	60e2                	ld	ra,24(sp)
    800034e0:	6442                	ld	s0,16(sp)
    800034e2:	64a2                	ld	s1,8(sp)
    800034e4:	6105                	addi	sp,sp,32
    800034e6:	8082                	ret

00000000800034e8 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800034e8:	1101                	addi	sp,sp,-32
    800034ea:	ec06                	sd	ra,24(sp)
    800034ec:	e822                	sd	s0,16(sp)
    800034ee:	e426                	sd	s1,8(sp)
    800034f0:	e04a                	sd	s2,0(sp)
    800034f2:	1000                	addi	s0,sp,32
    800034f4:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800034f6:	00d5d59b          	srliw	a1,a1,0xd
    800034fa:	0001c797          	auipc	a5,0x1c
    800034fe:	5ca7a783          	lw	a5,1482(a5) # 8001fac4 <sb+0x1c>
    80003502:	9dbd                	addw	a1,a1,a5
    80003504:	00000097          	auipc	ra,0x0
    80003508:	d9e080e7          	jalr	-610(ra) # 800032a2 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    8000350c:	0074f713          	andi	a4,s1,7
    80003510:	4785                	li	a5,1
    80003512:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003516:	14ce                	slli	s1,s1,0x33
    80003518:	90d9                	srli	s1,s1,0x36
    8000351a:	00950733          	add	a4,a0,s1
    8000351e:	05874703          	lbu	a4,88(a4)
    80003522:	00e7f6b3          	and	a3,a5,a4
    80003526:	c69d                	beqz	a3,80003554 <bfree+0x6c>
    80003528:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    8000352a:	94aa                	add	s1,s1,a0
    8000352c:	fff7c793          	not	a5,a5
    80003530:	8f7d                	and	a4,a4,a5
    80003532:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80003536:	00001097          	auipc	ra,0x1
    8000353a:	126080e7          	jalr	294(ra) # 8000465c <log_write>
  brelse(bp);
    8000353e:	854a                	mv	a0,s2
    80003540:	00000097          	auipc	ra,0x0
    80003544:	e92080e7          	jalr	-366(ra) # 800033d2 <brelse>
}
    80003548:	60e2                	ld	ra,24(sp)
    8000354a:	6442                	ld	s0,16(sp)
    8000354c:	64a2                	ld	s1,8(sp)
    8000354e:	6902                	ld	s2,0(sp)
    80003550:	6105                	addi	sp,sp,32
    80003552:	8082                	ret
    panic("freeing free block");
    80003554:	00005517          	auipc	a0,0x5
    80003558:	1dc50513          	addi	a0,a0,476 # 80008730 <systemCallsNames+0x100>
    8000355c:	ffffd097          	auipc	ra,0xffffd
    80003560:	fe4080e7          	jalr	-28(ra) # 80000540 <panic>

0000000080003564 <balloc>:
{
    80003564:	711d                	addi	sp,sp,-96
    80003566:	ec86                	sd	ra,88(sp)
    80003568:	e8a2                	sd	s0,80(sp)
    8000356a:	e4a6                	sd	s1,72(sp)
    8000356c:	e0ca                	sd	s2,64(sp)
    8000356e:	fc4e                	sd	s3,56(sp)
    80003570:	f852                	sd	s4,48(sp)
    80003572:	f456                	sd	s5,40(sp)
    80003574:	f05a                	sd	s6,32(sp)
    80003576:	ec5e                	sd	s7,24(sp)
    80003578:	e862                	sd	s8,16(sp)
    8000357a:	e466                	sd	s9,8(sp)
    8000357c:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    8000357e:	0001c797          	auipc	a5,0x1c
    80003582:	52e7a783          	lw	a5,1326(a5) # 8001faac <sb+0x4>
    80003586:	cff5                	beqz	a5,80003682 <balloc+0x11e>
    80003588:	8baa                	mv	s7,a0
    8000358a:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    8000358c:	0001cb17          	auipc	s6,0x1c
    80003590:	51cb0b13          	addi	s6,s6,1308 # 8001faa8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003594:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003596:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003598:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    8000359a:	6c89                	lui	s9,0x2
    8000359c:	a061                	j	80003624 <balloc+0xc0>
        bp->data[bi/8] |= m;  // Mark block in use.
    8000359e:	97ca                	add	a5,a5,s2
    800035a0:	8e55                	or	a2,a2,a3
    800035a2:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    800035a6:	854a                	mv	a0,s2
    800035a8:	00001097          	auipc	ra,0x1
    800035ac:	0b4080e7          	jalr	180(ra) # 8000465c <log_write>
        brelse(bp);
    800035b0:	854a                	mv	a0,s2
    800035b2:	00000097          	auipc	ra,0x0
    800035b6:	e20080e7          	jalr	-480(ra) # 800033d2 <brelse>
  bp = bread(dev, bno);
    800035ba:	85a6                	mv	a1,s1
    800035bc:	855e                	mv	a0,s7
    800035be:	00000097          	auipc	ra,0x0
    800035c2:	ce4080e7          	jalr	-796(ra) # 800032a2 <bread>
    800035c6:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800035c8:	40000613          	li	a2,1024
    800035cc:	4581                	li	a1,0
    800035ce:	05850513          	addi	a0,a0,88
    800035d2:	ffffd097          	auipc	ra,0xffffd
    800035d6:	700080e7          	jalr	1792(ra) # 80000cd2 <memset>
  log_write(bp);
    800035da:	854a                	mv	a0,s2
    800035dc:	00001097          	auipc	ra,0x1
    800035e0:	080080e7          	jalr	128(ra) # 8000465c <log_write>
  brelse(bp);
    800035e4:	854a                	mv	a0,s2
    800035e6:	00000097          	auipc	ra,0x0
    800035ea:	dec080e7          	jalr	-532(ra) # 800033d2 <brelse>
}
    800035ee:	8526                	mv	a0,s1
    800035f0:	60e6                	ld	ra,88(sp)
    800035f2:	6446                	ld	s0,80(sp)
    800035f4:	64a6                	ld	s1,72(sp)
    800035f6:	6906                	ld	s2,64(sp)
    800035f8:	79e2                	ld	s3,56(sp)
    800035fa:	7a42                	ld	s4,48(sp)
    800035fc:	7aa2                	ld	s5,40(sp)
    800035fe:	7b02                	ld	s6,32(sp)
    80003600:	6be2                	ld	s7,24(sp)
    80003602:	6c42                	ld	s8,16(sp)
    80003604:	6ca2                	ld	s9,8(sp)
    80003606:	6125                	addi	sp,sp,96
    80003608:	8082                	ret
    brelse(bp);
    8000360a:	854a                	mv	a0,s2
    8000360c:	00000097          	auipc	ra,0x0
    80003610:	dc6080e7          	jalr	-570(ra) # 800033d2 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003614:	015c87bb          	addw	a5,s9,s5
    80003618:	00078a9b          	sext.w	s5,a5
    8000361c:	004b2703          	lw	a4,4(s6)
    80003620:	06eaf163          	bgeu	s5,a4,80003682 <balloc+0x11e>
    bp = bread(dev, BBLOCK(b, sb));
    80003624:	41fad79b          	sraiw	a5,s5,0x1f
    80003628:	0137d79b          	srliw	a5,a5,0x13
    8000362c:	015787bb          	addw	a5,a5,s5
    80003630:	40d7d79b          	sraiw	a5,a5,0xd
    80003634:	01cb2583          	lw	a1,28(s6)
    80003638:	9dbd                	addw	a1,a1,a5
    8000363a:	855e                	mv	a0,s7
    8000363c:	00000097          	auipc	ra,0x0
    80003640:	c66080e7          	jalr	-922(ra) # 800032a2 <bread>
    80003644:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003646:	004b2503          	lw	a0,4(s6)
    8000364a:	000a849b          	sext.w	s1,s5
    8000364e:	8762                	mv	a4,s8
    80003650:	faa4fde3          	bgeu	s1,a0,8000360a <balloc+0xa6>
      m = 1 << (bi % 8);
    80003654:	00777693          	andi	a3,a4,7
    80003658:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    8000365c:	41f7579b          	sraiw	a5,a4,0x1f
    80003660:	01d7d79b          	srliw	a5,a5,0x1d
    80003664:	9fb9                	addw	a5,a5,a4
    80003666:	4037d79b          	sraiw	a5,a5,0x3
    8000366a:	00f90633          	add	a2,s2,a5
    8000366e:	05864603          	lbu	a2,88(a2)
    80003672:	00c6f5b3          	and	a1,a3,a2
    80003676:	d585                	beqz	a1,8000359e <balloc+0x3a>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003678:	2705                	addiw	a4,a4,1
    8000367a:	2485                	addiw	s1,s1,1
    8000367c:	fd471ae3          	bne	a4,s4,80003650 <balloc+0xec>
    80003680:	b769                	j	8000360a <balloc+0xa6>
  printf("balloc: out of blocks\n");
    80003682:	00005517          	auipc	a0,0x5
    80003686:	0c650513          	addi	a0,a0,198 # 80008748 <systemCallsNames+0x118>
    8000368a:	ffffd097          	auipc	ra,0xffffd
    8000368e:	f00080e7          	jalr	-256(ra) # 8000058a <printf>
  return 0;
    80003692:	4481                	li	s1,0
    80003694:	bfa9                	j	800035ee <balloc+0x8a>

0000000080003696 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003696:	7179                	addi	sp,sp,-48
    80003698:	f406                	sd	ra,40(sp)
    8000369a:	f022                	sd	s0,32(sp)
    8000369c:	ec26                	sd	s1,24(sp)
    8000369e:	e84a                	sd	s2,16(sp)
    800036a0:	e44e                	sd	s3,8(sp)
    800036a2:	e052                	sd	s4,0(sp)
    800036a4:	1800                	addi	s0,sp,48
    800036a6:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800036a8:	47ad                	li	a5,11
    800036aa:	02b7e863          	bltu	a5,a1,800036da <bmap+0x44>
    if((addr = ip->addrs[bn]) == 0){
    800036ae:	02059793          	slli	a5,a1,0x20
    800036b2:	01e7d593          	srli	a1,a5,0x1e
    800036b6:	00b504b3          	add	s1,a0,a1
    800036ba:	0504a903          	lw	s2,80(s1)
    800036be:	06091e63          	bnez	s2,8000373a <bmap+0xa4>
      addr = balloc(ip->dev);
    800036c2:	4108                	lw	a0,0(a0)
    800036c4:	00000097          	auipc	ra,0x0
    800036c8:	ea0080e7          	jalr	-352(ra) # 80003564 <balloc>
    800036cc:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800036d0:	06090563          	beqz	s2,8000373a <bmap+0xa4>
        return 0;
      ip->addrs[bn] = addr;
    800036d4:	0524a823          	sw	s2,80(s1)
    800036d8:	a08d                	j	8000373a <bmap+0xa4>
    }
    return addr;
  }
  bn -= NDIRECT;
    800036da:	ff45849b          	addiw	s1,a1,-12
    800036de:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800036e2:	0ff00793          	li	a5,255
    800036e6:	08e7e563          	bltu	a5,a4,80003770 <bmap+0xda>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    800036ea:	08052903          	lw	s2,128(a0)
    800036ee:	00091d63          	bnez	s2,80003708 <bmap+0x72>
      addr = balloc(ip->dev);
    800036f2:	4108                	lw	a0,0(a0)
    800036f4:	00000097          	auipc	ra,0x0
    800036f8:	e70080e7          	jalr	-400(ra) # 80003564 <balloc>
    800036fc:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003700:	02090d63          	beqz	s2,8000373a <bmap+0xa4>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003704:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    80003708:	85ca                	mv	a1,s2
    8000370a:	0009a503          	lw	a0,0(s3)
    8000370e:	00000097          	auipc	ra,0x0
    80003712:	b94080e7          	jalr	-1132(ra) # 800032a2 <bread>
    80003716:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003718:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    8000371c:	02049713          	slli	a4,s1,0x20
    80003720:	01e75593          	srli	a1,a4,0x1e
    80003724:	00b784b3          	add	s1,a5,a1
    80003728:	0004a903          	lw	s2,0(s1)
    8000372c:	02090063          	beqz	s2,8000374c <bmap+0xb6>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003730:	8552                	mv	a0,s4
    80003732:	00000097          	auipc	ra,0x0
    80003736:	ca0080e7          	jalr	-864(ra) # 800033d2 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    8000373a:	854a                	mv	a0,s2
    8000373c:	70a2                	ld	ra,40(sp)
    8000373e:	7402                	ld	s0,32(sp)
    80003740:	64e2                	ld	s1,24(sp)
    80003742:	6942                	ld	s2,16(sp)
    80003744:	69a2                	ld	s3,8(sp)
    80003746:	6a02                	ld	s4,0(sp)
    80003748:	6145                	addi	sp,sp,48
    8000374a:	8082                	ret
      addr = balloc(ip->dev);
    8000374c:	0009a503          	lw	a0,0(s3)
    80003750:	00000097          	auipc	ra,0x0
    80003754:	e14080e7          	jalr	-492(ra) # 80003564 <balloc>
    80003758:	0005091b          	sext.w	s2,a0
      if(addr){
    8000375c:	fc090ae3          	beqz	s2,80003730 <bmap+0x9a>
        a[bn] = addr;
    80003760:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003764:	8552                	mv	a0,s4
    80003766:	00001097          	auipc	ra,0x1
    8000376a:	ef6080e7          	jalr	-266(ra) # 8000465c <log_write>
    8000376e:	b7c9                	j	80003730 <bmap+0x9a>
  panic("bmap: out of range");
    80003770:	00005517          	auipc	a0,0x5
    80003774:	ff050513          	addi	a0,a0,-16 # 80008760 <systemCallsNames+0x130>
    80003778:	ffffd097          	auipc	ra,0xffffd
    8000377c:	dc8080e7          	jalr	-568(ra) # 80000540 <panic>

0000000080003780 <iget>:
{
    80003780:	7179                	addi	sp,sp,-48
    80003782:	f406                	sd	ra,40(sp)
    80003784:	f022                	sd	s0,32(sp)
    80003786:	ec26                	sd	s1,24(sp)
    80003788:	e84a                	sd	s2,16(sp)
    8000378a:	e44e                	sd	s3,8(sp)
    8000378c:	e052                	sd	s4,0(sp)
    8000378e:	1800                	addi	s0,sp,48
    80003790:	89aa                	mv	s3,a0
    80003792:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003794:	0001c517          	auipc	a0,0x1c
    80003798:	33450513          	addi	a0,a0,820 # 8001fac8 <itable>
    8000379c:	ffffd097          	auipc	ra,0xffffd
    800037a0:	43a080e7          	jalr	1082(ra) # 80000bd6 <acquire>
  empty = 0;
    800037a4:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800037a6:	0001c497          	auipc	s1,0x1c
    800037aa:	33a48493          	addi	s1,s1,826 # 8001fae0 <itable+0x18>
    800037ae:	0001e697          	auipc	a3,0x1e
    800037b2:	dc268693          	addi	a3,a3,-574 # 80021570 <log>
    800037b6:	a039                	j	800037c4 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800037b8:	02090b63          	beqz	s2,800037ee <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800037bc:	08848493          	addi	s1,s1,136
    800037c0:	02d48a63          	beq	s1,a3,800037f4 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800037c4:	449c                	lw	a5,8(s1)
    800037c6:	fef059e3          	blez	a5,800037b8 <iget+0x38>
    800037ca:	4098                	lw	a4,0(s1)
    800037cc:	ff3716e3          	bne	a4,s3,800037b8 <iget+0x38>
    800037d0:	40d8                	lw	a4,4(s1)
    800037d2:	ff4713e3          	bne	a4,s4,800037b8 <iget+0x38>
      ip->ref++;
    800037d6:	2785                	addiw	a5,a5,1
    800037d8:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800037da:	0001c517          	auipc	a0,0x1c
    800037de:	2ee50513          	addi	a0,a0,750 # 8001fac8 <itable>
    800037e2:	ffffd097          	auipc	ra,0xffffd
    800037e6:	4a8080e7          	jalr	1192(ra) # 80000c8a <release>
      return ip;
    800037ea:	8926                	mv	s2,s1
    800037ec:	a03d                	j	8000381a <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800037ee:	f7f9                	bnez	a5,800037bc <iget+0x3c>
    800037f0:	8926                	mv	s2,s1
    800037f2:	b7e9                	j	800037bc <iget+0x3c>
  if(empty == 0)
    800037f4:	02090c63          	beqz	s2,8000382c <iget+0xac>
  ip->dev = dev;
    800037f8:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800037fc:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003800:	4785                	li	a5,1
    80003802:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003806:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    8000380a:	0001c517          	auipc	a0,0x1c
    8000380e:	2be50513          	addi	a0,a0,702 # 8001fac8 <itable>
    80003812:	ffffd097          	auipc	ra,0xffffd
    80003816:	478080e7          	jalr	1144(ra) # 80000c8a <release>
}
    8000381a:	854a                	mv	a0,s2
    8000381c:	70a2                	ld	ra,40(sp)
    8000381e:	7402                	ld	s0,32(sp)
    80003820:	64e2                	ld	s1,24(sp)
    80003822:	6942                	ld	s2,16(sp)
    80003824:	69a2                	ld	s3,8(sp)
    80003826:	6a02                	ld	s4,0(sp)
    80003828:	6145                	addi	sp,sp,48
    8000382a:	8082                	ret
    panic("iget: no inodes");
    8000382c:	00005517          	auipc	a0,0x5
    80003830:	f4c50513          	addi	a0,a0,-180 # 80008778 <systemCallsNames+0x148>
    80003834:	ffffd097          	auipc	ra,0xffffd
    80003838:	d0c080e7          	jalr	-756(ra) # 80000540 <panic>

000000008000383c <fsinit>:
fsinit(int dev) {
    8000383c:	7179                	addi	sp,sp,-48
    8000383e:	f406                	sd	ra,40(sp)
    80003840:	f022                	sd	s0,32(sp)
    80003842:	ec26                	sd	s1,24(sp)
    80003844:	e84a                	sd	s2,16(sp)
    80003846:	e44e                	sd	s3,8(sp)
    80003848:	1800                	addi	s0,sp,48
    8000384a:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    8000384c:	4585                	li	a1,1
    8000384e:	00000097          	auipc	ra,0x0
    80003852:	a54080e7          	jalr	-1452(ra) # 800032a2 <bread>
    80003856:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003858:	0001c997          	auipc	s3,0x1c
    8000385c:	25098993          	addi	s3,s3,592 # 8001faa8 <sb>
    80003860:	02000613          	li	a2,32
    80003864:	05850593          	addi	a1,a0,88
    80003868:	854e                	mv	a0,s3
    8000386a:	ffffd097          	auipc	ra,0xffffd
    8000386e:	4c4080e7          	jalr	1220(ra) # 80000d2e <memmove>
  brelse(bp);
    80003872:	8526                	mv	a0,s1
    80003874:	00000097          	auipc	ra,0x0
    80003878:	b5e080e7          	jalr	-1186(ra) # 800033d2 <brelse>
  if(sb.magic != FSMAGIC)
    8000387c:	0009a703          	lw	a4,0(s3)
    80003880:	102037b7          	lui	a5,0x10203
    80003884:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003888:	02f71263          	bne	a4,a5,800038ac <fsinit+0x70>
  initlog(dev, &sb);
    8000388c:	0001c597          	auipc	a1,0x1c
    80003890:	21c58593          	addi	a1,a1,540 # 8001faa8 <sb>
    80003894:	854a                	mv	a0,s2
    80003896:	00001097          	auipc	ra,0x1
    8000389a:	b4a080e7          	jalr	-1206(ra) # 800043e0 <initlog>
}
    8000389e:	70a2                	ld	ra,40(sp)
    800038a0:	7402                	ld	s0,32(sp)
    800038a2:	64e2                	ld	s1,24(sp)
    800038a4:	6942                	ld	s2,16(sp)
    800038a6:	69a2                	ld	s3,8(sp)
    800038a8:	6145                	addi	sp,sp,48
    800038aa:	8082                	ret
    panic("invalid file system");
    800038ac:	00005517          	auipc	a0,0x5
    800038b0:	edc50513          	addi	a0,a0,-292 # 80008788 <systemCallsNames+0x158>
    800038b4:	ffffd097          	auipc	ra,0xffffd
    800038b8:	c8c080e7          	jalr	-884(ra) # 80000540 <panic>

00000000800038bc <iinit>:
{
    800038bc:	7179                	addi	sp,sp,-48
    800038be:	f406                	sd	ra,40(sp)
    800038c0:	f022                	sd	s0,32(sp)
    800038c2:	ec26                	sd	s1,24(sp)
    800038c4:	e84a                	sd	s2,16(sp)
    800038c6:	e44e                	sd	s3,8(sp)
    800038c8:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800038ca:	00005597          	auipc	a1,0x5
    800038ce:	ed658593          	addi	a1,a1,-298 # 800087a0 <systemCallsNames+0x170>
    800038d2:	0001c517          	auipc	a0,0x1c
    800038d6:	1f650513          	addi	a0,a0,502 # 8001fac8 <itable>
    800038da:	ffffd097          	auipc	ra,0xffffd
    800038de:	26c080e7          	jalr	620(ra) # 80000b46 <initlock>
  for(i = 0; i < NINODE; i++) {
    800038e2:	0001c497          	auipc	s1,0x1c
    800038e6:	20e48493          	addi	s1,s1,526 # 8001faf0 <itable+0x28>
    800038ea:	0001e997          	auipc	s3,0x1e
    800038ee:	c9698993          	addi	s3,s3,-874 # 80021580 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800038f2:	00005917          	auipc	s2,0x5
    800038f6:	eb690913          	addi	s2,s2,-330 # 800087a8 <systemCallsNames+0x178>
    800038fa:	85ca                	mv	a1,s2
    800038fc:	8526                	mv	a0,s1
    800038fe:	00001097          	auipc	ra,0x1
    80003902:	e42080e7          	jalr	-446(ra) # 80004740 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003906:	08848493          	addi	s1,s1,136
    8000390a:	ff3498e3          	bne	s1,s3,800038fa <iinit+0x3e>
}
    8000390e:	70a2                	ld	ra,40(sp)
    80003910:	7402                	ld	s0,32(sp)
    80003912:	64e2                	ld	s1,24(sp)
    80003914:	6942                	ld	s2,16(sp)
    80003916:	69a2                	ld	s3,8(sp)
    80003918:	6145                	addi	sp,sp,48
    8000391a:	8082                	ret

000000008000391c <ialloc>:
{
    8000391c:	715d                	addi	sp,sp,-80
    8000391e:	e486                	sd	ra,72(sp)
    80003920:	e0a2                	sd	s0,64(sp)
    80003922:	fc26                	sd	s1,56(sp)
    80003924:	f84a                	sd	s2,48(sp)
    80003926:	f44e                	sd	s3,40(sp)
    80003928:	f052                	sd	s4,32(sp)
    8000392a:	ec56                	sd	s5,24(sp)
    8000392c:	e85a                	sd	s6,16(sp)
    8000392e:	e45e                	sd	s7,8(sp)
    80003930:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003932:	0001c717          	auipc	a4,0x1c
    80003936:	18272703          	lw	a4,386(a4) # 8001fab4 <sb+0xc>
    8000393a:	4785                	li	a5,1
    8000393c:	04e7fa63          	bgeu	a5,a4,80003990 <ialloc+0x74>
    80003940:	8aaa                	mv	s5,a0
    80003942:	8bae                	mv	s7,a1
    80003944:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003946:	0001ca17          	auipc	s4,0x1c
    8000394a:	162a0a13          	addi	s4,s4,354 # 8001faa8 <sb>
    8000394e:	00048b1b          	sext.w	s6,s1
    80003952:	0044d593          	srli	a1,s1,0x4
    80003956:	018a2783          	lw	a5,24(s4)
    8000395a:	9dbd                	addw	a1,a1,a5
    8000395c:	8556                	mv	a0,s5
    8000395e:	00000097          	auipc	ra,0x0
    80003962:	944080e7          	jalr	-1724(ra) # 800032a2 <bread>
    80003966:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003968:	05850993          	addi	s3,a0,88
    8000396c:	00f4f793          	andi	a5,s1,15
    80003970:	079a                	slli	a5,a5,0x6
    80003972:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003974:	00099783          	lh	a5,0(s3)
    80003978:	c3a1                	beqz	a5,800039b8 <ialloc+0x9c>
    brelse(bp);
    8000397a:	00000097          	auipc	ra,0x0
    8000397e:	a58080e7          	jalr	-1448(ra) # 800033d2 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003982:	0485                	addi	s1,s1,1
    80003984:	00ca2703          	lw	a4,12(s4)
    80003988:	0004879b          	sext.w	a5,s1
    8000398c:	fce7e1e3          	bltu	a5,a4,8000394e <ialloc+0x32>
  printf("ialloc: no inodes\n");
    80003990:	00005517          	auipc	a0,0x5
    80003994:	e2050513          	addi	a0,a0,-480 # 800087b0 <systemCallsNames+0x180>
    80003998:	ffffd097          	auipc	ra,0xffffd
    8000399c:	bf2080e7          	jalr	-1038(ra) # 8000058a <printf>
  return 0;
    800039a0:	4501                	li	a0,0
}
    800039a2:	60a6                	ld	ra,72(sp)
    800039a4:	6406                	ld	s0,64(sp)
    800039a6:	74e2                	ld	s1,56(sp)
    800039a8:	7942                	ld	s2,48(sp)
    800039aa:	79a2                	ld	s3,40(sp)
    800039ac:	7a02                	ld	s4,32(sp)
    800039ae:	6ae2                	ld	s5,24(sp)
    800039b0:	6b42                	ld	s6,16(sp)
    800039b2:	6ba2                	ld	s7,8(sp)
    800039b4:	6161                	addi	sp,sp,80
    800039b6:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800039b8:	04000613          	li	a2,64
    800039bc:	4581                	li	a1,0
    800039be:	854e                	mv	a0,s3
    800039c0:	ffffd097          	auipc	ra,0xffffd
    800039c4:	312080e7          	jalr	786(ra) # 80000cd2 <memset>
      dip->type = type;
    800039c8:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800039cc:	854a                	mv	a0,s2
    800039ce:	00001097          	auipc	ra,0x1
    800039d2:	c8e080e7          	jalr	-882(ra) # 8000465c <log_write>
      brelse(bp);
    800039d6:	854a                	mv	a0,s2
    800039d8:	00000097          	auipc	ra,0x0
    800039dc:	9fa080e7          	jalr	-1542(ra) # 800033d2 <brelse>
      return iget(dev, inum);
    800039e0:	85da                	mv	a1,s6
    800039e2:	8556                	mv	a0,s5
    800039e4:	00000097          	auipc	ra,0x0
    800039e8:	d9c080e7          	jalr	-612(ra) # 80003780 <iget>
    800039ec:	bf5d                	j	800039a2 <ialloc+0x86>

00000000800039ee <iupdate>:
{
    800039ee:	1101                	addi	sp,sp,-32
    800039f0:	ec06                	sd	ra,24(sp)
    800039f2:	e822                	sd	s0,16(sp)
    800039f4:	e426                	sd	s1,8(sp)
    800039f6:	e04a                	sd	s2,0(sp)
    800039f8:	1000                	addi	s0,sp,32
    800039fa:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800039fc:	415c                	lw	a5,4(a0)
    800039fe:	0047d79b          	srliw	a5,a5,0x4
    80003a02:	0001c597          	auipc	a1,0x1c
    80003a06:	0be5a583          	lw	a1,190(a1) # 8001fac0 <sb+0x18>
    80003a0a:	9dbd                	addw	a1,a1,a5
    80003a0c:	4108                	lw	a0,0(a0)
    80003a0e:	00000097          	auipc	ra,0x0
    80003a12:	894080e7          	jalr	-1900(ra) # 800032a2 <bread>
    80003a16:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003a18:	05850793          	addi	a5,a0,88
    80003a1c:	40d8                	lw	a4,4(s1)
    80003a1e:	8b3d                	andi	a4,a4,15
    80003a20:	071a                	slli	a4,a4,0x6
    80003a22:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003a24:	04449703          	lh	a4,68(s1)
    80003a28:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003a2c:	04649703          	lh	a4,70(s1)
    80003a30:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003a34:	04849703          	lh	a4,72(s1)
    80003a38:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003a3c:	04a49703          	lh	a4,74(s1)
    80003a40:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003a44:	44f8                	lw	a4,76(s1)
    80003a46:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003a48:	03400613          	li	a2,52
    80003a4c:	05048593          	addi	a1,s1,80
    80003a50:	00c78513          	addi	a0,a5,12
    80003a54:	ffffd097          	auipc	ra,0xffffd
    80003a58:	2da080e7          	jalr	730(ra) # 80000d2e <memmove>
  log_write(bp);
    80003a5c:	854a                	mv	a0,s2
    80003a5e:	00001097          	auipc	ra,0x1
    80003a62:	bfe080e7          	jalr	-1026(ra) # 8000465c <log_write>
  brelse(bp);
    80003a66:	854a                	mv	a0,s2
    80003a68:	00000097          	auipc	ra,0x0
    80003a6c:	96a080e7          	jalr	-1686(ra) # 800033d2 <brelse>
}
    80003a70:	60e2                	ld	ra,24(sp)
    80003a72:	6442                	ld	s0,16(sp)
    80003a74:	64a2                	ld	s1,8(sp)
    80003a76:	6902                	ld	s2,0(sp)
    80003a78:	6105                	addi	sp,sp,32
    80003a7a:	8082                	ret

0000000080003a7c <idup>:
{
    80003a7c:	1101                	addi	sp,sp,-32
    80003a7e:	ec06                	sd	ra,24(sp)
    80003a80:	e822                	sd	s0,16(sp)
    80003a82:	e426                	sd	s1,8(sp)
    80003a84:	1000                	addi	s0,sp,32
    80003a86:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003a88:	0001c517          	auipc	a0,0x1c
    80003a8c:	04050513          	addi	a0,a0,64 # 8001fac8 <itable>
    80003a90:	ffffd097          	auipc	ra,0xffffd
    80003a94:	146080e7          	jalr	326(ra) # 80000bd6 <acquire>
  ip->ref++;
    80003a98:	449c                	lw	a5,8(s1)
    80003a9a:	2785                	addiw	a5,a5,1
    80003a9c:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003a9e:	0001c517          	auipc	a0,0x1c
    80003aa2:	02a50513          	addi	a0,a0,42 # 8001fac8 <itable>
    80003aa6:	ffffd097          	auipc	ra,0xffffd
    80003aaa:	1e4080e7          	jalr	484(ra) # 80000c8a <release>
}
    80003aae:	8526                	mv	a0,s1
    80003ab0:	60e2                	ld	ra,24(sp)
    80003ab2:	6442                	ld	s0,16(sp)
    80003ab4:	64a2                	ld	s1,8(sp)
    80003ab6:	6105                	addi	sp,sp,32
    80003ab8:	8082                	ret

0000000080003aba <ilock>:
{
    80003aba:	1101                	addi	sp,sp,-32
    80003abc:	ec06                	sd	ra,24(sp)
    80003abe:	e822                	sd	s0,16(sp)
    80003ac0:	e426                	sd	s1,8(sp)
    80003ac2:	e04a                	sd	s2,0(sp)
    80003ac4:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003ac6:	c115                	beqz	a0,80003aea <ilock+0x30>
    80003ac8:	84aa                	mv	s1,a0
    80003aca:	451c                	lw	a5,8(a0)
    80003acc:	00f05f63          	blez	a5,80003aea <ilock+0x30>
  acquiresleep(&ip->lock);
    80003ad0:	0541                	addi	a0,a0,16
    80003ad2:	00001097          	auipc	ra,0x1
    80003ad6:	ca8080e7          	jalr	-856(ra) # 8000477a <acquiresleep>
  if(ip->valid == 0){
    80003ada:	40bc                	lw	a5,64(s1)
    80003adc:	cf99                	beqz	a5,80003afa <ilock+0x40>
}
    80003ade:	60e2                	ld	ra,24(sp)
    80003ae0:	6442                	ld	s0,16(sp)
    80003ae2:	64a2                	ld	s1,8(sp)
    80003ae4:	6902                	ld	s2,0(sp)
    80003ae6:	6105                	addi	sp,sp,32
    80003ae8:	8082                	ret
    panic("ilock");
    80003aea:	00005517          	auipc	a0,0x5
    80003aee:	cde50513          	addi	a0,a0,-802 # 800087c8 <systemCallsNames+0x198>
    80003af2:	ffffd097          	auipc	ra,0xffffd
    80003af6:	a4e080e7          	jalr	-1458(ra) # 80000540 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003afa:	40dc                	lw	a5,4(s1)
    80003afc:	0047d79b          	srliw	a5,a5,0x4
    80003b00:	0001c597          	auipc	a1,0x1c
    80003b04:	fc05a583          	lw	a1,-64(a1) # 8001fac0 <sb+0x18>
    80003b08:	9dbd                	addw	a1,a1,a5
    80003b0a:	4088                	lw	a0,0(s1)
    80003b0c:	fffff097          	auipc	ra,0xfffff
    80003b10:	796080e7          	jalr	1942(ra) # 800032a2 <bread>
    80003b14:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003b16:	05850593          	addi	a1,a0,88
    80003b1a:	40dc                	lw	a5,4(s1)
    80003b1c:	8bbd                	andi	a5,a5,15
    80003b1e:	079a                	slli	a5,a5,0x6
    80003b20:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003b22:	00059783          	lh	a5,0(a1)
    80003b26:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003b2a:	00259783          	lh	a5,2(a1)
    80003b2e:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003b32:	00459783          	lh	a5,4(a1)
    80003b36:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003b3a:	00659783          	lh	a5,6(a1)
    80003b3e:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003b42:	459c                	lw	a5,8(a1)
    80003b44:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003b46:	03400613          	li	a2,52
    80003b4a:	05b1                	addi	a1,a1,12
    80003b4c:	05048513          	addi	a0,s1,80
    80003b50:	ffffd097          	auipc	ra,0xffffd
    80003b54:	1de080e7          	jalr	478(ra) # 80000d2e <memmove>
    brelse(bp);
    80003b58:	854a                	mv	a0,s2
    80003b5a:	00000097          	auipc	ra,0x0
    80003b5e:	878080e7          	jalr	-1928(ra) # 800033d2 <brelse>
    ip->valid = 1;
    80003b62:	4785                	li	a5,1
    80003b64:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003b66:	04449783          	lh	a5,68(s1)
    80003b6a:	fbb5                	bnez	a5,80003ade <ilock+0x24>
      panic("ilock: no type");
    80003b6c:	00005517          	auipc	a0,0x5
    80003b70:	c6450513          	addi	a0,a0,-924 # 800087d0 <systemCallsNames+0x1a0>
    80003b74:	ffffd097          	auipc	ra,0xffffd
    80003b78:	9cc080e7          	jalr	-1588(ra) # 80000540 <panic>

0000000080003b7c <iunlock>:
{
    80003b7c:	1101                	addi	sp,sp,-32
    80003b7e:	ec06                	sd	ra,24(sp)
    80003b80:	e822                	sd	s0,16(sp)
    80003b82:	e426                	sd	s1,8(sp)
    80003b84:	e04a                	sd	s2,0(sp)
    80003b86:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003b88:	c905                	beqz	a0,80003bb8 <iunlock+0x3c>
    80003b8a:	84aa                	mv	s1,a0
    80003b8c:	01050913          	addi	s2,a0,16
    80003b90:	854a                	mv	a0,s2
    80003b92:	00001097          	auipc	ra,0x1
    80003b96:	c82080e7          	jalr	-894(ra) # 80004814 <holdingsleep>
    80003b9a:	cd19                	beqz	a0,80003bb8 <iunlock+0x3c>
    80003b9c:	449c                	lw	a5,8(s1)
    80003b9e:	00f05d63          	blez	a5,80003bb8 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003ba2:	854a                	mv	a0,s2
    80003ba4:	00001097          	auipc	ra,0x1
    80003ba8:	c2c080e7          	jalr	-980(ra) # 800047d0 <releasesleep>
}
    80003bac:	60e2                	ld	ra,24(sp)
    80003bae:	6442                	ld	s0,16(sp)
    80003bb0:	64a2                	ld	s1,8(sp)
    80003bb2:	6902                	ld	s2,0(sp)
    80003bb4:	6105                	addi	sp,sp,32
    80003bb6:	8082                	ret
    panic("iunlock");
    80003bb8:	00005517          	auipc	a0,0x5
    80003bbc:	c2850513          	addi	a0,a0,-984 # 800087e0 <systemCallsNames+0x1b0>
    80003bc0:	ffffd097          	auipc	ra,0xffffd
    80003bc4:	980080e7          	jalr	-1664(ra) # 80000540 <panic>

0000000080003bc8 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003bc8:	7179                	addi	sp,sp,-48
    80003bca:	f406                	sd	ra,40(sp)
    80003bcc:	f022                	sd	s0,32(sp)
    80003bce:	ec26                	sd	s1,24(sp)
    80003bd0:	e84a                	sd	s2,16(sp)
    80003bd2:	e44e                	sd	s3,8(sp)
    80003bd4:	e052                	sd	s4,0(sp)
    80003bd6:	1800                	addi	s0,sp,48
    80003bd8:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003bda:	05050493          	addi	s1,a0,80
    80003bde:	08050913          	addi	s2,a0,128
    80003be2:	a021                	j	80003bea <itrunc+0x22>
    80003be4:	0491                	addi	s1,s1,4
    80003be6:	01248d63          	beq	s1,s2,80003c00 <itrunc+0x38>
    if(ip->addrs[i]){
    80003bea:	408c                	lw	a1,0(s1)
    80003bec:	dde5                	beqz	a1,80003be4 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003bee:	0009a503          	lw	a0,0(s3)
    80003bf2:	00000097          	auipc	ra,0x0
    80003bf6:	8f6080e7          	jalr	-1802(ra) # 800034e8 <bfree>
      ip->addrs[i] = 0;
    80003bfa:	0004a023          	sw	zero,0(s1)
    80003bfe:	b7dd                	j	80003be4 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003c00:	0809a583          	lw	a1,128(s3)
    80003c04:	e185                	bnez	a1,80003c24 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003c06:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003c0a:	854e                	mv	a0,s3
    80003c0c:	00000097          	auipc	ra,0x0
    80003c10:	de2080e7          	jalr	-542(ra) # 800039ee <iupdate>
}
    80003c14:	70a2                	ld	ra,40(sp)
    80003c16:	7402                	ld	s0,32(sp)
    80003c18:	64e2                	ld	s1,24(sp)
    80003c1a:	6942                	ld	s2,16(sp)
    80003c1c:	69a2                	ld	s3,8(sp)
    80003c1e:	6a02                	ld	s4,0(sp)
    80003c20:	6145                	addi	sp,sp,48
    80003c22:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003c24:	0009a503          	lw	a0,0(s3)
    80003c28:	fffff097          	auipc	ra,0xfffff
    80003c2c:	67a080e7          	jalr	1658(ra) # 800032a2 <bread>
    80003c30:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003c32:	05850493          	addi	s1,a0,88
    80003c36:	45850913          	addi	s2,a0,1112
    80003c3a:	a021                	j	80003c42 <itrunc+0x7a>
    80003c3c:	0491                	addi	s1,s1,4
    80003c3e:	01248b63          	beq	s1,s2,80003c54 <itrunc+0x8c>
      if(a[j])
    80003c42:	408c                	lw	a1,0(s1)
    80003c44:	dde5                	beqz	a1,80003c3c <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003c46:	0009a503          	lw	a0,0(s3)
    80003c4a:	00000097          	auipc	ra,0x0
    80003c4e:	89e080e7          	jalr	-1890(ra) # 800034e8 <bfree>
    80003c52:	b7ed                	j	80003c3c <itrunc+0x74>
    brelse(bp);
    80003c54:	8552                	mv	a0,s4
    80003c56:	fffff097          	auipc	ra,0xfffff
    80003c5a:	77c080e7          	jalr	1916(ra) # 800033d2 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003c5e:	0809a583          	lw	a1,128(s3)
    80003c62:	0009a503          	lw	a0,0(s3)
    80003c66:	00000097          	auipc	ra,0x0
    80003c6a:	882080e7          	jalr	-1918(ra) # 800034e8 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003c6e:	0809a023          	sw	zero,128(s3)
    80003c72:	bf51                	j	80003c06 <itrunc+0x3e>

0000000080003c74 <iput>:
{
    80003c74:	1101                	addi	sp,sp,-32
    80003c76:	ec06                	sd	ra,24(sp)
    80003c78:	e822                	sd	s0,16(sp)
    80003c7a:	e426                	sd	s1,8(sp)
    80003c7c:	e04a                	sd	s2,0(sp)
    80003c7e:	1000                	addi	s0,sp,32
    80003c80:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003c82:	0001c517          	auipc	a0,0x1c
    80003c86:	e4650513          	addi	a0,a0,-442 # 8001fac8 <itable>
    80003c8a:	ffffd097          	auipc	ra,0xffffd
    80003c8e:	f4c080e7          	jalr	-180(ra) # 80000bd6 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003c92:	4498                	lw	a4,8(s1)
    80003c94:	4785                	li	a5,1
    80003c96:	02f70363          	beq	a4,a5,80003cbc <iput+0x48>
  ip->ref--;
    80003c9a:	449c                	lw	a5,8(s1)
    80003c9c:	37fd                	addiw	a5,a5,-1
    80003c9e:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003ca0:	0001c517          	auipc	a0,0x1c
    80003ca4:	e2850513          	addi	a0,a0,-472 # 8001fac8 <itable>
    80003ca8:	ffffd097          	auipc	ra,0xffffd
    80003cac:	fe2080e7          	jalr	-30(ra) # 80000c8a <release>
}
    80003cb0:	60e2                	ld	ra,24(sp)
    80003cb2:	6442                	ld	s0,16(sp)
    80003cb4:	64a2                	ld	s1,8(sp)
    80003cb6:	6902                	ld	s2,0(sp)
    80003cb8:	6105                	addi	sp,sp,32
    80003cba:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003cbc:	40bc                	lw	a5,64(s1)
    80003cbe:	dff1                	beqz	a5,80003c9a <iput+0x26>
    80003cc0:	04a49783          	lh	a5,74(s1)
    80003cc4:	fbf9                	bnez	a5,80003c9a <iput+0x26>
    acquiresleep(&ip->lock);
    80003cc6:	01048913          	addi	s2,s1,16
    80003cca:	854a                	mv	a0,s2
    80003ccc:	00001097          	auipc	ra,0x1
    80003cd0:	aae080e7          	jalr	-1362(ra) # 8000477a <acquiresleep>
    release(&itable.lock);
    80003cd4:	0001c517          	auipc	a0,0x1c
    80003cd8:	df450513          	addi	a0,a0,-524 # 8001fac8 <itable>
    80003cdc:	ffffd097          	auipc	ra,0xffffd
    80003ce0:	fae080e7          	jalr	-82(ra) # 80000c8a <release>
    itrunc(ip);
    80003ce4:	8526                	mv	a0,s1
    80003ce6:	00000097          	auipc	ra,0x0
    80003cea:	ee2080e7          	jalr	-286(ra) # 80003bc8 <itrunc>
    ip->type = 0;
    80003cee:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003cf2:	8526                	mv	a0,s1
    80003cf4:	00000097          	auipc	ra,0x0
    80003cf8:	cfa080e7          	jalr	-774(ra) # 800039ee <iupdate>
    ip->valid = 0;
    80003cfc:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003d00:	854a                	mv	a0,s2
    80003d02:	00001097          	auipc	ra,0x1
    80003d06:	ace080e7          	jalr	-1330(ra) # 800047d0 <releasesleep>
    acquire(&itable.lock);
    80003d0a:	0001c517          	auipc	a0,0x1c
    80003d0e:	dbe50513          	addi	a0,a0,-578 # 8001fac8 <itable>
    80003d12:	ffffd097          	auipc	ra,0xffffd
    80003d16:	ec4080e7          	jalr	-316(ra) # 80000bd6 <acquire>
    80003d1a:	b741                	j	80003c9a <iput+0x26>

0000000080003d1c <iunlockput>:
{
    80003d1c:	1101                	addi	sp,sp,-32
    80003d1e:	ec06                	sd	ra,24(sp)
    80003d20:	e822                	sd	s0,16(sp)
    80003d22:	e426                	sd	s1,8(sp)
    80003d24:	1000                	addi	s0,sp,32
    80003d26:	84aa                	mv	s1,a0
  iunlock(ip);
    80003d28:	00000097          	auipc	ra,0x0
    80003d2c:	e54080e7          	jalr	-428(ra) # 80003b7c <iunlock>
  iput(ip);
    80003d30:	8526                	mv	a0,s1
    80003d32:	00000097          	auipc	ra,0x0
    80003d36:	f42080e7          	jalr	-190(ra) # 80003c74 <iput>
}
    80003d3a:	60e2                	ld	ra,24(sp)
    80003d3c:	6442                	ld	s0,16(sp)
    80003d3e:	64a2                	ld	s1,8(sp)
    80003d40:	6105                	addi	sp,sp,32
    80003d42:	8082                	ret

0000000080003d44 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003d44:	1141                	addi	sp,sp,-16
    80003d46:	e422                	sd	s0,8(sp)
    80003d48:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003d4a:	411c                	lw	a5,0(a0)
    80003d4c:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003d4e:	415c                	lw	a5,4(a0)
    80003d50:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003d52:	04451783          	lh	a5,68(a0)
    80003d56:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003d5a:	04a51783          	lh	a5,74(a0)
    80003d5e:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003d62:	04c56783          	lwu	a5,76(a0)
    80003d66:	e99c                	sd	a5,16(a1)
}
    80003d68:	6422                	ld	s0,8(sp)
    80003d6a:	0141                	addi	sp,sp,16
    80003d6c:	8082                	ret

0000000080003d6e <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003d6e:	457c                	lw	a5,76(a0)
    80003d70:	0ed7e963          	bltu	a5,a3,80003e62 <readi+0xf4>
{
    80003d74:	7159                	addi	sp,sp,-112
    80003d76:	f486                	sd	ra,104(sp)
    80003d78:	f0a2                	sd	s0,96(sp)
    80003d7a:	eca6                	sd	s1,88(sp)
    80003d7c:	e8ca                	sd	s2,80(sp)
    80003d7e:	e4ce                	sd	s3,72(sp)
    80003d80:	e0d2                	sd	s4,64(sp)
    80003d82:	fc56                	sd	s5,56(sp)
    80003d84:	f85a                	sd	s6,48(sp)
    80003d86:	f45e                	sd	s7,40(sp)
    80003d88:	f062                	sd	s8,32(sp)
    80003d8a:	ec66                	sd	s9,24(sp)
    80003d8c:	e86a                	sd	s10,16(sp)
    80003d8e:	e46e                	sd	s11,8(sp)
    80003d90:	1880                	addi	s0,sp,112
    80003d92:	8b2a                	mv	s6,a0
    80003d94:	8bae                	mv	s7,a1
    80003d96:	8a32                	mv	s4,a2
    80003d98:	84b6                	mv	s1,a3
    80003d9a:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003d9c:	9f35                	addw	a4,a4,a3
    return 0;
    80003d9e:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003da0:	0ad76063          	bltu	a4,a3,80003e40 <readi+0xd2>
  if(off + n > ip->size)
    80003da4:	00e7f463          	bgeu	a5,a4,80003dac <readi+0x3e>
    n = ip->size - off;
    80003da8:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003dac:	0a0a8963          	beqz	s5,80003e5e <readi+0xf0>
    80003db0:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003db2:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003db6:	5c7d                	li	s8,-1
    80003db8:	a82d                	j	80003df2 <readi+0x84>
    80003dba:	020d1d93          	slli	s11,s10,0x20
    80003dbe:	020ddd93          	srli	s11,s11,0x20
    80003dc2:	05890613          	addi	a2,s2,88
    80003dc6:	86ee                	mv	a3,s11
    80003dc8:	963a                	add	a2,a2,a4
    80003dca:	85d2                	mv	a1,s4
    80003dcc:	855e                	mv	a0,s7
    80003dce:	fffff097          	auipc	ra,0xfffff
    80003dd2:	8c2080e7          	jalr	-1854(ra) # 80002690 <either_copyout>
    80003dd6:	05850d63          	beq	a0,s8,80003e30 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003dda:	854a                	mv	a0,s2
    80003ddc:	fffff097          	auipc	ra,0xfffff
    80003de0:	5f6080e7          	jalr	1526(ra) # 800033d2 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003de4:	013d09bb          	addw	s3,s10,s3
    80003de8:	009d04bb          	addw	s1,s10,s1
    80003dec:	9a6e                	add	s4,s4,s11
    80003dee:	0559f763          	bgeu	s3,s5,80003e3c <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80003df2:	00a4d59b          	srliw	a1,s1,0xa
    80003df6:	855a                	mv	a0,s6
    80003df8:	00000097          	auipc	ra,0x0
    80003dfc:	89e080e7          	jalr	-1890(ra) # 80003696 <bmap>
    80003e00:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003e04:	cd85                	beqz	a1,80003e3c <readi+0xce>
    bp = bread(ip->dev, addr);
    80003e06:	000b2503          	lw	a0,0(s6)
    80003e0a:	fffff097          	auipc	ra,0xfffff
    80003e0e:	498080e7          	jalr	1176(ra) # 800032a2 <bread>
    80003e12:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003e14:	3ff4f713          	andi	a4,s1,1023
    80003e18:	40ec87bb          	subw	a5,s9,a4
    80003e1c:	413a86bb          	subw	a3,s5,s3
    80003e20:	8d3e                	mv	s10,a5
    80003e22:	2781                	sext.w	a5,a5
    80003e24:	0006861b          	sext.w	a2,a3
    80003e28:	f8f679e3          	bgeu	a2,a5,80003dba <readi+0x4c>
    80003e2c:	8d36                	mv	s10,a3
    80003e2e:	b771                	j	80003dba <readi+0x4c>
      brelse(bp);
    80003e30:	854a                	mv	a0,s2
    80003e32:	fffff097          	auipc	ra,0xfffff
    80003e36:	5a0080e7          	jalr	1440(ra) # 800033d2 <brelse>
      tot = -1;
    80003e3a:	59fd                	li	s3,-1
  }
  return tot;
    80003e3c:	0009851b          	sext.w	a0,s3
}
    80003e40:	70a6                	ld	ra,104(sp)
    80003e42:	7406                	ld	s0,96(sp)
    80003e44:	64e6                	ld	s1,88(sp)
    80003e46:	6946                	ld	s2,80(sp)
    80003e48:	69a6                	ld	s3,72(sp)
    80003e4a:	6a06                	ld	s4,64(sp)
    80003e4c:	7ae2                	ld	s5,56(sp)
    80003e4e:	7b42                	ld	s6,48(sp)
    80003e50:	7ba2                	ld	s7,40(sp)
    80003e52:	7c02                	ld	s8,32(sp)
    80003e54:	6ce2                	ld	s9,24(sp)
    80003e56:	6d42                	ld	s10,16(sp)
    80003e58:	6da2                	ld	s11,8(sp)
    80003e5a:	6165                	addi	sp,sp,112
    80003e5c:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003e5e:	89d6                	mv	s3,s5
    80003e60:	bff1                	j	80003e3c <readi+0xce>
    return 0;
    80003e62:	4501                	li	a0,0
}
    80003e64:	8082                	ret

0000000080003e66 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003e66:	457c                	lw	a5,76(a0)
    80003e68:	10d7e863          	bltu	a5,a3,80003f78 <writei+0x112>
{
    80003e6c:	7159                	addi	sp,sp,-112
    80003e6e:	f486                	sd	ra,104(sp)
    80003e70:	f0a2                	sd	s0,96(sp)
    80003e72:	eca6                	sd	s1,88(sp)
    80003e74:	e8ca                	sd	s2,80(sp)
    80003e76:	e4ce                	sd	s3,72(sp)
    80003e78:	e0d2                	sd	s4,64(sp)
    80003e7a:	fc56                	sd	s5,56(sp)
    80003e7c:	f85a                	sd	s6,48(sp)
    80003e7e:	f45e                	sd	s7,40(sp)
    80003e80:	f062                	sd	s8,32(sp)
    80003e82:	ec66                	sd	s9,24(sp)
    80003e84:	e86a                	sd	s10,16(sp)
    80003e86:	e46e                	sd	s11,8(sp)
    80003e88:	1880                	addi	s0,sp,112
    80003e8a:	8aaa                	mv	s5,a0
    80003e8c:	8bae                	mv	s7,a1
    80003e8e:	8a32                	mv	s4,a2
    80003e90:	8936                	mv	s2,a3
    80003e92:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003e94:	00e687bb          	addw	a5,a3,a4
    80003e98:	0ed7e263          	bltu	a5,a3,80003f7c <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003e9c:	00043737          	lui	a4,0x43
    80003ea0:	0ef76063          	bltu	a4,a5,80003f80 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003ea4:	0c0b0863          	beqz	s6,80003f74 <writei+0x10e>
    80003ea8:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003eaa:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003eae:	5c7d                	li	s8,-1
    80003eb0:	a091                	j	80003ef4 <writei+0x8e>
    80003eb2:	020d1d93          	slli	s11,s10,0x20
    80003eb6:	020ddd93          	srli	s11,s11,0x20
    80003eba:	05848513          	addi	a0,s1,88
    80003ebe:	86ee                	mv	a3,s11
    80003ec0:	8652                	mv	a2,s4
    80003ec2:	85de                	mv	a1,s7
    80003ec4:	953a                	add	a0,a0,a4
    80003ec6:	fffff097          	auipc	ra,0xfffff
    80003eca:	820080e7          	jalr	-2016(ra) # 800026e6 <either_copyin>
    80003ece:	07850263          	beq	a0,s8,80003f32 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003ed2:	8526                	mv	a0,s1
    80003ed4:	00000097          	auipc	ra,0x0
    80003ed8:	788080e7          	jalr	1928(ra) # 8000465c <log_write>
    brelse(bp);
    80003edc:	8526                	mv	a0,s1
    80003ede:	fffff097          	auipc	ra,0xfffff
    80003ee2:	4f4080e7          	jalr	1268(ra) # 800033d2 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003ee6:	013d09bb          	addw	s3,s10,s3
    80003eea:	012d093b          	addw	s2,s10,s2
    80003eee:	9a6e                	add	s4,s4,s11
    80003ef0:	0569f663          	bgeu	s3,s6,80003f3c <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80003ef4:	00a9559b          	srliw	a1,s2,0xa
    80003ef8:	8556                	mv	a0,s5
    80003efa:	fffff097          	auipc	ra,0xfffff
    80003efe:	79c080e7          	jalr	1948(ra) # 80003696 <bmap>
    80003f02:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003f06:	c99d                	beqz	a1,80003f3c <writei+0xd6>
    bp = bread(ip->dev, addr);
    80003f08:	000aa503          	lw	a0,0(s5)
    80003f0c:	fffff097          	auipc	ra,0xfffff
    80003f10:	396080e7          	jalr	918(ra) # 800032a2 <bread>
    80003f14:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003f16:	3ff97713          	andi	a4,s2,1023
    80003f1a:	40ec87bb          	subw	a5,s9,a4
    80003f1e:	413b06bb          	subw	a3,s6,s3
    80003f22:	8d3e                	mv	s10,a5
    80003f24:	2781                	sext.w	a5,a5
    80003f26:	0006861b          	sext.w	a2,a3
    80003f2a:	f8f674e3          	bgeu	a2,a5,80003eb2 <writei+0x4c>
    80003f2e:	8d36                	mv	s10,a3
    80003f30:	b749                	j	80003eb2 <writei+0x4c>
      brelse(bp);
    80003f32:	8526                	mv	a0,s1
    80003f34:	fffff097          	auipc	ra,0xfffff
    80003f38:	49e080e7          	jalr	1182(ra) # 800033d2 <brelse>
  }

  if(off > ip->size)
    80003f3c:	04caa783          	lw	a5,76(s5)
    80003f40:	0127f463          	bgeu	a5,s2,80003f48 <writei+0xe2>
    ip->size = off;
    80003f44:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003f48:	8556                	mv	a0,s5
    80003f4a:	00000097          	auipc	ra,0x0
    80003f4e:	aa4080e7          	jalr	-1372(ra) # 800039ee <iupdate>

  return tot;
    80003f52:	0009851b          	sext.w	a0,s3
}
    80003f56:	70a6                	ld	ra,104(sp)
    80003f58:	7406                	ld	s0,96(sp)
    80003f5a:	64e6                	ld	s1,88(sp)
    80003f5c:	6946                	ld	s2,80(sp)
    80003f5e:	69a6                	ld	s3,72(sp)
    80003f60:	6a06                	ld	s4,64(sp)
    80003f62:	7ae2                	ld	s5,56(sp)
    80003f64:	7b42                	ld	s6,48(sp)
    80003f66:	7ba2                	ld	s7,40(sp)
    80003f68:	7c02                	ld	s8,32(sp)
    80003f6a:	6ce2                	ld	s9,24(sp)
    80003f6c:	6d42                	ld	s10,16(sp)
    80003f6e:	6da2                	ld	s11,8(sp)
    80003f70:	6165                	addi	sp,sp,112
    80003f72:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003f74:	89da                	mv	s3,s6
    80003f76:	bfc9                	j	80003f48 <writei+0xe2>
    return -1;
    80003f78:	557d                	li	a0,-1
}
    80003f7a:	8082                	ret
    return -1;
    80003f7c:	557d                	li	a0,-1
    80003f7e:	bfe1                	j	80003f56 <writei+0xf0>
    return -1;
    80003f80:	557d                	li	a0,-1
    80003f82:	bfd1                	j	80003f56 <writei+0xf0>

0000000080003f84 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003f84:	1141                	addi	sp,sp,-16
    80003f86:	e406                	sd	ra,8(sp)
    80003f88:	e022                	sd	s0,0(sp)
    80003f8a:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003f8c:	4639                	li	a2,14
    80003f8e:	ffffd097          	auipc	ra,0xffffd
    80003f92:	e14080e7          	jalr	-492(ra) # 80000da2 <strncmp>
}
    80003f96:	60a2                	ld	ra,8(sp)
    80003f98:	6402                	ld	s0,0(sp)
    80003f9a:	0141                	addi	sp,sp,16
    80003f9c:	8082                	ret

0000000080003f9e <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003f9e:	7139                	addi	sp,sp,-64
    80003fa0:	fc06                	sd	ra,56(sp)
    80003fa2:	f822                	sd	s0,48(sp)
    80003fa4:	f426                	sd	s1,40(sp)
    80003fa6:	f04a                	sd	s2,32(sp)
    80003fa8:	ec4e                	sd	s3,24(sp)
    80003faa:	e852                	sd	s4,16(sp)
    80003fac:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003fae:	04451703          	lh	a4,68(a0)
    80003fb2:	4785                	li	a5,1
    80003fb4:	00f71a63          	bne	a4,a5,80003fc8 <dirlookup+0x2a>
    80003fb8:	892a                	mv	s2,a0
    80003fba:	89ae                	mv	s3,a1
    80003fbc:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003fbe:	457c                	lw	a5,76(a0)
    80003fc0:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003fc2:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003fc4:	e79d                	bnez	a5,80003ff2 <dirlookup+0x54>
    80003fc6:	a8a5                	j	8000403e <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003fc8:	00005517          	auipc	a0,0x5
    80003fcc:	82050513          	addi	a0,a0,-2016 # 800087e8 <systemCallsNames+0x1b8>
    80003fd0:	ffffc097          	auipc	ra,0xffffc
    80003fd4:	570080e7          	jalr	1392(ra) # 80000540 <panic>
      panic("dirlookup read");
    80003fd8:	00005517          	auipc	a0,0x5
    80003fdc:	82850513          	addi	a0,a0,-2008 # 80008800 <systemCallsNames+0x1d0>
    80003fe0:	ffffc097          	auipc	ra,0xffffc
    80003fe4:	560080e7          	jalr	1376(ra) # 80000540 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003fe8:	24c1                	addiw	s1,s1,16
    80003fea:	04c92783          	lw	a5,76(s2)
    80003fee:	04f4f763          	bgeu	s1,a5,8000403c <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003ff2:	4741                	li	a4,16
    80003ff4:	86a6                	mv	a3,s1
    80003ff6:	fc040613          	addi	a2,s0,-64
    80003ffa:	4581                	li	a1,0
    80003ffc:	854a                	mv	a0,s2
    80003ffe:	00000097          	auipc	ra,0x0
    80004002:	d70080e7          	jalr	-656(ra) # 80003d6e <readi>
    80004006:	47c1                	li	a5,16
    80004008:	fcf518e3          	bne	a0,a5,80003fd8 <dirlookup+0x3a>
    if(de.inum == 0)
    8000400c:	fc045783          	lhu	a5,-64(s0)
    80004010:	dfe1                	beqz	a5,80003fe8 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80004012:	fc240593          	addi	a1,s0,-62
    80004016:	854e                	mv	a0,s3
    80004018:	00000097          	auipc	ra,0x0
    8000401c:	f6c080e7          	jalr	-148(ra) # 80003f84 <namecmp>
    80004020:	f561                	bnez	a0,80003fe8 <dirlookup+0x4a>
      if(poff)
    80004022:	000a0463          	beqz	s4,8000402a <dirlookup+0x8c>
        *poff = off;
    80004026:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    8000402a:	fc045583          	lhu	a1,-64(s0)
    8000402e:	00092503          	lw	a0,0(s2)
    80004032:	fffff097          	auipc	ra,0xfffff
    80004036:	74e080e7          	jalr	1870(ra) # 80003780 <iget>
    8000403a:	a011                	j	8000403e <dirlookup+0xa0>
  return 0;
    8000403c:	4501                	li	a0,0
}
    8000403e:	70e2                	ld	ra,56(sp)
    80004040:	7442                	ld	s0,48(sp)
    80004042:	74a2                	ld	s1,40(sp)
    80004044:	7902                	ld	s2,32(sp)
    80004046:	69e2                	ld	s3,24(sp)
    80004048:	6a42                	ld	s4,16(sp)
    8000404a:	6121                	addi	sp,sp,64
    8000404c:	8082                	ret

000000008000404e <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    8000404e:	711d                	addi	sp,sp,-96
    80004050:	ec86                	sd	ra,88(sp)
    80004052:	e8a2                	sd	s0,80(sp)
    80004054:	e4a6                	sd	s1,72(sp)
    80004056:	e0ca                	sd	s2,64(sp)
    80004058:	fc4e                	sd	s3,56(sp)
    8000405a:	f852                	sd	s4,48(sp)
    8000405c:	f456                	sd	s5,40(sp)
    8000405e:	f05a                	sd	s6,32(sp)
    80004060:	ec5e                	sd	s7,24(sp)
    80004062:	e862                	sd	s8,16(sp)
    80004064:	e466                	sd	s9,8(sp)
    80004066:	e06a                	sd	s10,0(sp)
    80004068:	1080                	addi	s0,sp,96
    8000406a:	84aa                	mv	s1,a0
    8000406c:	8b2e                	mv	s6,a1
    8000406e:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80004070:	00054703          	lbu	a4,0(a0)
    80004074:	02f00793          	li	a5,47
    80004078:	02f70363          	beq	a4,a5,8000409e <namex+0x50>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    8000407c:	ffffe097          	auipc	ra,0xffffe
    80004080:	930080e7          	jalr	-1744(ra) # 800019ac <myproc>
    80004084:	15053503          	ld	a0,336(a0)
    80004088:	00000097          	auipc	ra,0x0
    8000408c:	9f4080e7          	jalr	-1548(ra) # 80003a7c <idup>
    80004090:	8a2a                	mv	s4,a0
  while(*path == '/')
    80004092:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80004096:	4cb5                	li	s9,13
  len = path - s;
    80004098:	4b81                	li	s7,0

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    8000409a:	4c05                	li	s8,1
    8000409c:	a87d                	j	8000415a <namex+0x10c>
    ip = iget(ROOTDEV, ROOTINO);
    8000409e:	4585                	li	a1,1
    800040a0:	4505                	li	a0,1
    800040a2:	fffff097          	auipc	ra,0xfffff
    800040a6:	6de080e7          	jalr	1758(ra) # 80003780 <iget>
    800040aa:	8a2a                	mv	s4,a0
    800040ac:	b7dd                	j	80004092 <namex+0x44>
      iunlockput(ip);
    800040ae:	8552                	mv	a0,s4
    800040b0:	00000097          	auipc	ra,0x0
    800040b4:	c6c080e7          	jalr	-916(ra) # 80003d1c <iunlockput>
      return 0;
    800040b8:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    800040ba:	8552                	mv	a0,s4
    800040bc:	60e6                	ld	ra,88(sp)
    800040be:	6446                	ld	s0,80(sp)
    800040c0:	64a6                	ld	s1,72(sp)
    800040c2:	6906                	ld	s2,64(sp)
    800040c4:	79e2                	ld	s3,56(sp)
    800040c6:	7a42                	ld	s4,48(sp)
    800040c8:	7aa2                	ld	s5,40(sp)
    800040ca:	7b02                	ld	s6,32(sp)
    800040cc:	6be2                	ld	s7,24(sp)
    800040ce:	6c42                	ld	s8,16(sp)
    800040d0:	6ca2                	ld	s9,8(sp)
    800040d2:	6d02                	ld	s10,0(sp)
    800040d4:	6125                	addi	sp,sp,96
    800040d6:	8082                	ret
      iunlock(ip);
    800040d8:	8552                	mv	a0,s4
    800040da:	00000097          	auipc	ra,0x0
    800040de:	aa2080e7          	jalr	-1374(ra) # 80003b7c <iunlock>
      return ip;
    800040e2:	bfe1                	j	800040ba <namex+0x6c>
      iunlockput(ip);
    800040e4:	8552                	mv	a0,s4
    800040e6:	00000097          	auipc	ra,0x0
    800040ea:	c36080e7          	jalr	-970(ra) # 80003d1c <iunlockput>
      return 0;
    800040ee:	8a4e                	mv	s4,s3
    800040f0:	b7e9                	j	800040ba <namex+0x6c>
  len = path - s;
    800040f2:	40998633          	sub	a2,s3,s1
    800040f6:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    800040fa:	09acd863          	bge	s9,s10,8000418a <namex+0x13c>
    memmove(name, s, DIRSIZ);
    800040fe:	4639                	li	a2,14
    80004100:	85a6                	mv	a1,s1
    80004102:	8556                	mv	a0,s5
    80004104:	ffffd097          	auipc	ra,0xffffd
    80004108:	c2a080e7          	jalr	-982(ra) # 80000d2e <memmove>
    8000410c:	84ce                	mv	s1,s3
  while(*path == '/')
    8000410e:	0004c783          	lbu	a5,0(s1)
    80004112:	01279763          	bne	a5,s2,80004120 <namex+0xd2>
    path++;
    80004116:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004118:	0004c783          	lbu	a5,0(s1)
    8000411c:	ff278de3          	beq	a5,s2,80004116 <namex+0xc8>
    ilock(ip);
    80004120:	8552                	mv	a0,s4
    80004122:	00000097          	auipc	ra,0x0
    80004126:	998080e7          	jalr	-1640(ra) # 80003aba <ilock>
    if(ip->type != T_DIR){
    8000412a:	044a1783          	lh	a5,68(s4)
    8000412e:	f98790e3          	bne	a5,s8,800040ae <namex+0x60>
    if(nameiparent && *path == '\0'){
    80004132:	000b0563          	beqz	s6,8000413c <namex+0xee>
    80004136:	0004c783          	lbu	a5,0(s1)
    8000413a:	dfd9                	beqz	a5,800040d8 <namex+0x8a>
    if((next = dirlookup(ip, name, 0)) == 0){
    8000413c:	865e                	mv	a2,s7
    8000413e:	85d6                	mv	a1,s5
    80004140:	8552                	mv	a0,s4
    80004142:	00000097          	auipc	ra,0x0
    80004146:	e5c080e7          	jalr	-420(ra) # 80003f9e <dirlookup>
    8000414a:	89aa                	mv	s3,a0
    8000414c:	dd41                	beqz	a0,800040e4 <namex+0x96>
    iunlockput(ip);
    8000414e:	8552                	mv	a0,s4
    80004150:	00000097          	auipc	ra,0x0
    80004154:	bcc080e7          	jalr	-1076(ra) # 80003d1c <iunlockput>
    ip = next;
    80004158:	8a4e                	mv	s4,s3
  while(*path == '/')
    8000415a:	0004c783          	lbu	a5,0(s1)
    8000415e:	01279763          	bne	a5,s2,8000416c <namex+0x11e>
    path++;
    80004162:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004164:	0004c783          	lbu	a5,0(s1)
    80004168:	ff278de3          	beq	a5,s2,80004162 <namex+0x114>
  if(*path == 0)
    8000416c:	cb9d                	beqz	a5,800041a2 <namex+0x154>
  while(*path != '/' && *path != 0)
    8000416e:	0004c783          	lbu	a5,0(s1)
    80004172:	89a6                	mv	s3,s1
  len = path - s;
    80004174:	8d5e                	mv	s10,s7
    80004176:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80004178:	01278963          	beq	a5,s2,8000418a <namex+0x13c>
    8000417c:	dbbd                	beqz	a5,800040f2 <namex+0xa4>
    path++;
    8000417e:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80004180:	0009c783          	lbu	a5,0(s3)
    80004184:	ff279ce3          	bne	a5,s2,8000417c <namex+0x12e>
    80004188:	b7ad                	j	800040f2 <namex+0xa4>
    memmove(name, s, len);
    8000418a:	2601                	sext.w	a2,a2
    8000418c:	85a6                	mv	a1,s1
    8000418e:	8556                	mv	a0,s5
    80004190:	ffffd097          	auipc	ra,0xffffd
    80004194:	b9e080e7          	jalr	-1122(ra) # 80000d2e <memmove>
    name[len] = 0;
    80004198:	9d56                	add	s10,s10,s5
    8000419a:	000d0023          	sb	zero,0(s10)
    8000419e:	84ce                	mv	s1,s3
    800041a0:	b7bd                	j	8000410e <namex+0xc0>
  if(nameiparent){
    800041a2:	f00b0ce3          	beqz	s6,800040ba <namex+0x6c>
    iput(ip);
    800041a6:	8552                	mv	a0,s4
    800041a8:	00000097          	auipc	ra,0x0
    800041ac:	acc080e7          	jalr	-1332(ra) # 80003c74 <iput>
    return 0;
    800041b0:	4a01                	li	s4,0
    800041b2:	b721                	j	800040ba <namex+0x6c>

00000000800041b4 <dirlink>:
{
    800041b4:	7139                	addi	sp,sp,-64
    800041b6:	fc06                	sd	ra,56(sp)
    800041b8:	f822                	sd	s0,48(sp)
    800041ba:	f426                	sd	s1,40(sp)
    800041bc:	f04a                	sd	s2,32(sp)
    800041be:	ec4e                	sd	s3,24(sp)
    800041c0:	e852                	sd	s4,16(sp)
    800041c2:	0080                	addi	s0,sp,64
    800041c4:	892a                	mv	s2,a0
    800041c6:	8a2e                	mv	s4,a1
    800041c8:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    800041ca:	4601                	li	a2,0
    800041cc:	00000097          	auipc	ra,0x0
    800041d0:	dd2080e7          	jalr	-558(ra) # 80003f9e <dirlookup>
    800041d4:	e93d                	bnez	a0,8000424a <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800041d6:	04c92483          	lw	s1,76(s2)
    800041da:	c49d                	beqz	s1,80004208 <dirlink+0x54>
    800041dc:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800041de:	4741                	li	a4,16
    800041e0:	86a6                	mv	a3,s1
    800041e2:	fc040613          	addi	a2,s0,-64
    800041e6:	4581                	li	a1,0
    800041e8:	854a                	mv	a0,s2
    800041ea:	00000097          	auipc	ra,0x0
    800041ee:	b84080e7          	jalr	-1148(ra) # 80003d6e <readi>
    800041f2:	47c1                	li	a5,16
    800041f4:	06f51163          	bne	a0,a5,80004256 <dirlink+0xa2>
    if(de.inum == 0)
    800041f8:	fc045783          	lhu	a5,-64(s0)
    800041fc:	c791                	beqz	a5,80004208 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800041fe:	24c1                	addiw	s1,s1,16
    80004200:	04c92783          	lw	a5,76(s2)
    80004204:	fcf4ede3          	bltu	s1,a5,800041de <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80004208:	4639                	li	a2,14
    8000420a:	85d2                	mv	a1,s4
    8000420c:	fc240513          	addi	a0,s0,-62
    80004210:	ffffd097          	auipc	ra,0xffffd
    80004214:	bce080e7          	jalr	-1074(ra) # 80000dde <strncpy>
  de.inum = inum;
    80004218:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000421c:	4741                	li	a4,16
    8000421e:	86a6                	mv	a3,s1
    80004220:	fc040613          	addi	a2,s0,-64
    80004224:	4581                	li	a1,0
    80004226:	854a                	mv	a0,s2
    80004228:	00000097          	auipc	ra,0x0
    8000422c:	c3e080e7          	jalr	-962(ra) # 80003e66 <writei>
    80004230:	1541                	addi	a0,a0,-16
    80004232:	00a03533          	snez	a0,a0
    80004236:	40a00533          	neg	a0,a0
}
    8000423a:	70e2                	ld	ra,56(sp)
    8000423c:	7442                	ld	s0,48(sp)
    8000423e:	74a2                	ld	s1,40(sp)
    80004240:	7902                	ld	s2,32(sp)
    80004242:	69e2                	ld	s3,24(sp)
    80004244:	6a42                	ld	s4,16(sp)
    80004246:	6121                	addi	sp,sp,64
    80004248:	8082                	ret
    iput(ip);
    8000424a:	00000097          	auipc	ra,0x0
    8000424e:	a2a080e7          	jalr	-1494(ra) # 80003c74 <iput>
    return -1;
    80004252:	557d                	li	a0,-1
    80004254:	b7dd                	j	8000423a <dirlink+0x86>
      panic("dirlink read");
    80004256:	00004517          	auipc	a0,0x4
    8000425a:	5ba50513          	addi	a0,a0,1466 # 80008810 <systemCallsNames+0x1e0>
    8000425e:	ffffc097          	auipc	ra,0xffffc
    80004262:	2e2080e7          	jalr	738(ra) # 80000540 <panic>

0000000080004266 <namei>:

struct inode*
namei(char *path)
{
    80004266:	1101                	addi	sp,sp,-32
    80004268:	ec06                	sd	ra,24(sp)
    8000426a:	e822                	sd	s0,16(sp)
    8000426c:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    8000426e:	fe040613          	addi	a2,s0,-32
    80004272:	4581                	li	a1,0
    80004274:	00000097          	auipc	ra,0x0
    80004278:	dda080e7          	jalr	-550(ra) # 8000404e <namex>
}
    8000427c:	60e2                	ld	ra,24(sp)
    8000427e:	6442                	ld	s0,16(sp)
    80004280:	6105                	addi	sp,sp,32
    80004282:	8082                	ret

0000000080004284 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80004284:	1141                	addi	sp,sp,-16
    80004286:	e406                	sd	ra,8(sp)
    80004288:	e022                	sd	s0,0(sp)
    8000428a:	0800                	addi	s0,sp,16
    8000428c:	862e                	mv	a2,a1
  return namex(path, 1, name);
    8000428e:	4585                	li	a1,1
    80004290:	00000097          	auipc	ra,0x0
    80004294:	dbe080e7          	jalr	-578(ra) # 8000404e <namex>
}
    80004298:	60a2                	ld	ra,8(sp)
    8000429a:	6402                	ld	s0,0(sp)
    8000429c:	0141                	addi	sp,sp,16
    8000429e:	8082                	ret

00000000800042a0 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800042a0:	1101                	addi	sp,sp,-32
    800042a2:	ec06                	sd	ra,24(sp)
    800042a4:	e822                	sd	s0,16(sp)
    800042a6:	e426                	sd	s1,8(sp)
    800042a8:	e04a                	sd	s2,0(sp)
    800042aa:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800042ac:	0001d917          	auipc	s2,0x1d
    800042b0:	2c490913          	addi	s2,s2,708 # 80021570 <log>
    800042b4:	01892583          	lw	a1,24(s2)
    800042b8:	02892503          	lw	a0,40(s2)
    800042bc:	fffff097          	auipc	ra,0xfffff
    800042c0:	fe6080e7          	jalr	-26(ra) # 800032a2 <bread>
    800042c4:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800042c6:	02c92683          	lw	a3,44(s2)
    800042ca:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800042cc:	02d05863          	blez	a3,800042fc <write_head+0x5c>
    800042d0:	0001d797          	auipc	a5,0x1d
    800042d4:	2d078793          	addi	a5,a5,720 # 800215a0 <log+0x30>
    800042d8:	05c50713          	addi	a4,a0,92
    800042dc:	36fd                	addiw	a3,a3,-1
    800042de:	02069613          	slli	a2,a3,0x20
    800042e2:	01e65693          	srli	a3,a2,0x1e
    800042e6:	0001d617          	auipc	a2,0x1d
    800042ea:	2be60613          	addi	a2,a2,702 # 800215a4 <log+0x34>
    800042ee:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    800042f0:	4390                	lw	a2,0(a5)
    800042f2:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800042f4:	0791                	addi	a5,a5,4
    800042f6:	0711                	addi	a4,a4,4 # 43004 <_entry-0x7ffbcffc>
    800042f8:	fed79ce3          	bne	a5,a3,800042f0 <write_head+0x50>
  }
  bwrite(buf);
    800042fc:	8526                	mv	a0,s1
    800042fe:	fffff097          	auipc	ra,0xfffff
    80004302:	096080e7          	jalr	150(ra) # 80003394 <bwrite>
  brelse(buf);
    80004306:	8526                	mv	a0,s1
    80004308:	fffff097          	auipc	ra,0xfffff
    8000430c:	0ca080e7          	jalr	202(ra) # 800033d2 <brelse>
}
    80004310:	60e2                	ld	ra,24(sp)
    80004312:	6442                	ld	s0,16(sp)
    80004314:	64a2                	ld	s1,8(sp)
    80004316:	6902                	ld	s2,0(sp)
    80004318:	6105                	addi	sp,sp,32
    8000431a:	8082                	ret

000000008000431c <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    8000431c:	0001d797          	auipc	a5,0x1d
    80004320:	2807a783          	lw	a5,640(a5) # 8002159c <log+0x2c>
    80004324:	0af05d63          	blez	a5,800043de <install_trans+0xc2>
{
    80004328:	7139                	addi	sp,sp,-64
    8000432a:	fc06                	sd	ra,56(sp)
    8000432c:	f822                	sd	s0,48(sp)
    8000432e:	f426                	sd	s1,40(sp)
    80004330:	f04a                	sd	s2,32(sp)
    80004332:	ec4e                	sd	s3,24(sp)
    80004334:	e852                	sd	s4,16(sp)
    80004336:	e456                	sd	s5,8(sp)
    80004338:	e05a                	sd	s6,0(sp)
    8000433a:	0080                	addi	s0,sp,64
    8000433c:	8b2a                	mv	s6,a0
    8000433e:	0001da97          	auipc	s5,0x1d
    80004342:	262a8a93          	addi	s5,s5,610 # 800215a0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004346:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004348:	0001d997          	auipc	s3,0x1d
    8000434c:	22898993          	addi	s3,s3,552 # 80021570 <log>
    80004350:	a00d                	j	80004372 <install_trans+0x56>
    brelse(lbuf);
    80004352:	854a                	mv	a0,s2
    80004354:	fffff097          	auipc	ra,0xfffff
    80004358:	07e080e7          	jalr	126(ra) # 800033d2 <brelse>
    brelse(dbuf);
    8000435c:	8526                	mv	a0,s1
    8000435e:	fffff097          	auipc	ra,0xfffff
    80004362:	074080e7          	jalr	116(ra) # 800033d2 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004366:	2a05                	addiw	s4,s4,1
    80004368:	0a91                	addi	s5,s5,4
    8000436a:	02c9a783          	lw	a5,44(s3)
    8000436e:	04fa5e63          	bge	s4,a5,800043ca <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004372:	0189a583          	lw	a1,24(s3)
    80004376:	014585bb          	addw	a1,a1,s4
    8000437a:	2585                	addiw	a1,a1,1
    8000437c:	0289a503          	lw	a0,40(s3)
    80004380:	fffff097          	auipc	ra,0xfffff
    80004384:	f22080e7          	jalr	-222(ra) # 800032a2 <bread>
    80004388:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    8000438a:	000aa583          	lw	a1,0(s5)
    8000438e:	0289a503          	lw	a0,40(s3)
    80004392:	fffff097          	auipc	ra,0xfffff
    80004396:	f10080e7          	jalr	-240(ra) # 800032a2 <bread>
    8000439a:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    8000439c:	40000613          	li	a2,1024
    800043a0:	05890593          	addi	a1,s2,88
    800043a4:	05850513          	addi	a0,a0,88
    800043a8:	ffffd097          	auipc	ra,0xffffd
    800043ac:	986080e7          	jalr	-1658(ra) # 80000d2e <memmove>
    bwrite(dbuf);  // write dst to disk
    800043b0:	8526                	mv	a0,s1
    800043b2:	fffff097          	auipc	ra,0xfffff
    800043b6:	fe2080e7          	jalr	-30(ra) # 80003394 <bwrite>
    if(recovering == 0)
    800043ba:	f80b1ce3          	bnez	s6,80004352 <install_trans+0x36>
      bunpin(dbuf);
    800043be:	8526                	mv	a0,s1
    800043c0:	fffff097          	auipc	ra,0xfffff
    800043c4:	0ec080e7          	jalr	236(ra) # 800034ac <bunpin>
    800043c8:	b769                	j	80004352 <install_trans+0x36>
}
    800043ca:	70e2                	ld	ra,56(sp)
    800043cc:	7442                	ld	s0,48(sp)
    800043ce:	74a2                	ld	s1,40(sp)
    800043d0:	7902                	ld	s2,32(sp)
    800043d2:	69e2                	ld	s3,24(sp)
    800043d4:	6a42                	ld	s4,16(sp)
    800043d6:	6aa2                	ld	s5,8(sp)
    800043d8:	6b02                	ld	s6,0(sp)
    800043da:	6121                	addi	sp,sp,64
    800043dc:	8082                	ret
    800043de:	8082                	ret

00000000800043e0 <initlog>:
{
    800043e0:	7179                	addi	sp,sp,-48
    800043e2:	f406                	sd	ra,40(sp)
    800043e4:	f022                	sd	s0,32(sp)
    800043e6:	ec26                	sd	s1,24(sp)
    800043e8:	e84a                	sd	s2,16(sp)
    800043ea:	e44e                	sd	s3,8(sp)
    800043ec:	1800                	addi	s0,sp,48
    800043ee:	892a                	mv	s2,a0
    800043f0:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800043f2:	0001d497          	auipc	s1,0x1d
    800043f6:	17e48493          	addi	s1,s1,382 # 80021570 <log>
    800043fa:	00004597          	auipc	a1,0x4
    800043fe:	42658593          	addi	a1,a1,1062 # 80008820 <systemCallsNames+0x1f0>
    80004402:	8526                	mv	a0,s1
    80004404:	ffffc097          	auipc	ra,0xffffc
    80004408:	742080e7          	jalr	1858(ra) # 80000b46 <initlock>
  log.start = sb->logstart;
    8000440c:	0149a583          	lw	a1,20(s3)
    80004410:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004412:	0109a783          	lw	a5,16(s3)
    80004416:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004418:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    8000441c:	854a                	mv	a0,s2
    8000441e:	fffff097          	auipc	ra,0xfffff
    80004422:	e84080e7          	jalr	-380(ra) # 800032a2 <bread>
  log.lh.n = lh->n;
    80004426:	4d34                	lw	a3,88(a0)
    80004428:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    8000442a:	02d05663          	blez	a3,80004456 <initlog+0x76>
    8000442e:	05c50793          	addi	a5,a0,92
    80004432:	0001d717          	auipc	a4,0x1d
    80004436:	16e70713          	addi	a4,a4,366 # 800215a0 <log+0x30>
    8000443a:	36fd                	addiw	a3,a3,-1
    8000443c:	02069613          	slli	a2,a3,0x20
    80004440:	01e65693          	srli	a3,a2,0x1e
    80004444:	06050613          	addi	a2,a0,96
    80004448:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    8000444a:	4390                	lw	a2,0(a5)
    8000444c:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000444e:	0791                	addi	a5,a5,4
    80004450:	0711                	addi	a4,a4,4
    80004452:	fed79ce3          	bne	a5,a3,8000444a <initlog+0x6a>
  brelse(buf);
    80004456:	fffff097          	auipc	ra,0xfffff
    8000445a:	f7c080e7          	jalr	-132(ra) # 800033d2 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    8000445e:	4505                	li	a0,1
    80004460:	00000097          	auipc	ra,0x0
    80004464:	ebc080e7          	jalr	-324(ra) # 8000431c <install_trans>
  log.lh.n = 0;
    80004468:	0001d797          	auipc	a5,0x1d
    8000446c:	1207aa23          	sw	zero,308(a5) # 8002159c <log+0x2c>
  write_head(); // clear the log
    80004470:	00000097          	auipc	ra,0x0
    80004474:	e30080e7          	jalr	-464(ra) # 800042a0 <write_head>
}
    80004478:	70a2                	ld	ra,40(sp)
    8000447a:	7402                	ld	s0,32(sp)
    8000447c:	64e2                	ld	s1,24(sp)
    8000447e:	6942                	ld	s2,16(sp)
    80004480:	69a2                	ld	s3,8(sp)
    80004482:	6145                	addi	sp,sp,48
    80004484:	8082                	ret

0000000080004486 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004486:	1101                	addi	sp,sp,-32
    80004488:	ec06                	sd	ra,24(sp)
    8000448a:	e822                	sd	s0,16(sp)
    8000448c:	e426                	sd	s1,8(sp)
    8000448e:	e04a                	sd	s2,0(sp)
    80004490:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004492:	0001d517          	auipc	a0,0x1d
    80004496:	0de50513          	addi	a0,a0,222 # 80021570 <log>
    8000449a:	ffffc097          	auipc	ra,0xffffc
    8000449e:	73c080e7          	jalr	1852(ra) # 80000bd6 <acquire>
  while(1){
    if(log.committing){
    800044a2:	0001d497          	auipc	s1,0x1d
    800044a6:	0ce48493          	addi	s1,s1,206 # 80021570 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800044aa:	4979                	li	s2,30
    800044ac:	a039                	j	800044ba <begin_op+0x34>
      sleep(&log, &log.lock);
    800044ae:	85a6                	mv	a1,s1
    800044b0:	8526                	mv	a0,s1
    800044b2:	ffffe097          	auipc	ra,0xffffe
    800044b6:	c7e080e7          	jalr	-898(ra) # 80002130 <sleep>
    if(log.committing){
    800044ba:	50dc                	lw	a5,36(s1)
    800044bc:	fbed                	bnez	a5,800044ae <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800044be:	5098                	lw	a4,32(s1)
    800044c0:	2705                	addiw	a4,a4,1
    800044c2:	0007069b          	sext.w	a3,a4
    800044c6:	0027179b          	slliw	a5,a4,0x2
    800044ca:	9fb9                	addw	a5,a5,a4
    800044cc:	0017979b          	slliw	a5,a5,0x1
    800044d0:	54d8                	lw	a4,44(s1)
    800044d2:	9fb9                	addw	a5,a5,a4
    800044d4:	00f95963          	bge	s2,a5,800044e6 <begin_op+0x60>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800044d8:	85a6                	mv	a1,s1
    800044da:	8526                	mv	a0,s1
    800044dc:	ffffe097          	auipc	ra,0xffffe
    800044e0:	c54080e7          	jalr	-940(ra) # 80002130 <sleep>
    800044e4:	bfd9                	j	800044ba <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800044e6:	0001d517          	auipc	a0,0x1d
    800044ea:	08a50513          	addi	a0,a0,138 # 80021570 <log>
    800044ee:	d114                	sw	a3,32(a0)
      release(&log.lock);
    800044f0:	ffffc097          	auipc	ra,0xffffc
    800044f4:	79a080e7          	jalr	1946(ra) # 80000c8a <release>
      break;
    }
  }
}
    800044f8:	60e2                	ld	ra,24(sp)
    800044fa:	6442                	ld	s0,16(sp)
    800044fc:	64a2                	ld	s1,8(sp)
    800044fe:	6902                	ld	s2,0(sp)
    80004500:	6105                	addi	sp,sp,32
    80004502:	8082                	ret

0000000080004504 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004504:	7139                	addi	sp,sp,-64
    80004506:	fc06                	sd	ra,56(sp)
    80004508:	f822                	sd	s0,48(sp)
    8000450a:	f426                	sd	s1,40(sp)
    8000450c:	f04a                	sd	s2,32(sp)
    8000450e:	ec4e                	sd	s3,24(sp)
    80004510:	e852                	sd	s4,16(sp)
    80004512:	e456                	sd	s5,8(sp)
    80004514:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004516:	0001d497          	auipc	s1,0x1d
    8000451a:	05a48493          	addi	s1,s1,90 # 80021570 <log>
    8000451e:	8526                	mv	a0,s1
    80004520:	ffffc097          	auipc	ra,0xffffc
    80004524:	6b6080e7          	jalr	1718(ra) # 80000bd6 <acquire>
  log.outstanding -= 1;
    80004528:	509c                	lw	a5,32(s1)
    8000452a:	37fd                	addiw	a5,a5,-1
    8000452c:	0007891b          	sext.w	s2,a5
    80004530:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004532:	50dc                	lw	a5,36(s1)
    80004534:	e7b9                	bnez	a5,80004582 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    80004536:	04091e63          	bnez	s2,80004592 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    8000453a:	0001d497          	auipc	s1,0x1d
    8000453e:	03648493          	addi	s1,s1,54 # 80021570 <log>
    80004542:	4785                	li	a5,1
    80004544:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004546:	8526                	mv	a0,s1
    80004548:	ffffc097          	auipc	ra,0xffffc
    8000454c:	742080e7          	jalr	1858(ra) # 80000c8a <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004550:	54dc                	lw	a5,44(s1)
    80004552:	06f04763          	bgtz	a5,800045c0 <end_op+0xbc>
    acquire(&log.lock);
    80004556:	0001d497          	auipc	s1,0x1d
    8000455a:	01a48493          	addi	s1,s1,26 # 80021570 <log>
    8000455e:	8526                	mv	a0,s1
    80004560:	ffffc097          	auipc	ra,0xffffc
    80004564:	676080e7          	jalr	1654(ra) # 80000bd6 <acquire>
    log.committing = 0;
    80004568:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    8000456c:	8526                	mv	a0,s1
    8000456e:	ffffe097          	auipc	ra,0xffffe
    80004572:	d72080e7          	jalr	-654(ra) # 800022e0 <wakeup>
    release(&log.lock);
    80004576:	8526                	mv	a0,s1
    80004578:	ffffc097          	auipc	ra,0xffffc
    8000457c:	712080e7          	jalr	1810(ra) # 80000c8a <release>
}
    80004580:	a03d                	j	800045ae <end_op+0xaa>
    panic("log.committing");
    80004582:	00004517          	auipc	a0,0x4
    80004586:	2a650513          	addi	a0,a0,678 # 80008828 <systemCallsNames+0x1f8>
    8000458a:	ffffc097          	auipc	ra,0xffffc
    8000458e:	fb6080e7          	jalr	-74(ra) # 80000540 <panic>
    wakeup(&log);
    80004592:	0001d497          	auipc	s1,0x1d
    80004596:	fde48493          	addi	s1,s1,-34 # 80021570 <log>
    8000459a:	8526                	mv	a0,s1
    8000459c:	ffffe097          	auipc	ra,0xffffe
    800045a0:	d44080e7          	jalr	-700(ra) # 800022e0 <wakeup>
  release(&log.lock);
    800045a4:	8526                	mv	a0,s1
    800045a6:	ffffc097          	auipc	ra,0xffffc
    800045aa:	6e4080e7          	jalr	1764(ra) # 80000c8a <release>
}
    800045ae:	70e2                	ld	ra,56(sp)
    800045b0:	7442                	ld	s0,48(sp)
    800045b2:	74a2                	ld	s1,40(sp)
    800045b4:	7902                	ld	s2,32(sp)
    800045b6:	69e2                	ld	s3,24(sp)
    800045b8:	6a42                	ld	s4,16(sp)
    800045ba:	6aa2                	ld	s5,8(sp)
    800045bc:	6121                	addi	sp,sp,64
    800045be:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    800045c0:	0001da97          	auipc	s5,0x1d
    800045c4:	fe0a8a93          	addi	s5,s5,-32 # 800215a0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800045c8:	0001da17          	auipc	s4,0x1d
    800045cc:	fa8a0a13          	addi	s4,s4,-88 # 80021570 <log>
    800045d0:	018a2583          	lw	a1,24(s4)
    800045d4:	012585bb          	addw	a1,a1,s2
    800045d8:	2585                	addiw	a1,a1,1
    800045da:	028a2503          	lw	a0,40(s4)
    800045de:	fffff097          	auipc	ra,0xfffff
    800045e2:	cc4080e7          	jalr	-828(ra) # 800032a2 <bread>
    800045e6:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800045e8:	000aa583          	lw	a1,0(s5)
    800045ec:	028a2503          	lw	a0,40(s4)
    800045f0:	fffff097          	auipc	ra,0xfffff
    800045f4:	cb2080e7          	jalr	-846(ra) # 800032a2 <bread>
    800045f8:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800045fa:	40000613          	li	a2,1024
    800045fe:	05850593          	addi	a1,a0,88
    80004602:	05848513          	addi	a0,s1,88
    80004606:	ffffc097          	auipc	ra,0xffffc
    8000460a:	728080e7          	jalr	1832(ra) # 80000d2e <memmove>
    bwrite(to);  // write the log
    8000460e:	8526                	mv	a0,s1
    80004610:	fffff097          	auipc	ra,0xfffff
    80004614:	d84080e7          	jalr	-636(ra) # 80003394 <bwrite>
    brelse(from);
    80004618:	854e                	mv	a0,s3
    8000461a:	fffff097          	auipc	ra,0xfffff
    8000461e:	db8080e7          	jalr	-584(ra) # 800033d2 <brelse>
    brelse(to);
    80004622:	8526                	mv	a0,s1
    80004624:	fffff097          	auipc	ra,0xfffff
    80004628:	dae080e7          	jalr	-594(ra) # 800033d2 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000462c:	2905                	addiw	s2,s2,1
    8000462e:	0a91                	addi	s5,s5,4
    80004630:	02ca2783          	lw	a5,44(s4)
    80004634:	f8f94ee3          	blt	s2,a5,800045d0 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004638:	00000097          	auipc	ra,0x0
    8000463c:	c68080e7          	jalr	-920(ra) # 800042a0 <write_head>
    install_trans(0); // Now install writes to home locations
    80004640:	4501                	li	a0,0
    80004642:	00000097          	auipc	ra,0x0
    80004646:	cda080e7          	jalr	-806(ra) # 8000431c <install_trans>
    log.lh.n = 0;
    8000464a:	0001d797          	auipc	a5,0x1d
    8000464e:	f407a923          	sw	zero,-174(a5) # 8002159c <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004652:	00000097          	auipc	ra,0x0
    80004656:	c4e080e7          	jalr	-946(ra) # 800042a0 <write_head>
    8000465a:	bdf5                	j	80004556 <end_op+0x52>

000000008000465c <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    8000465c:	1101                	addi	sp,sp,-32
    8000465e:	ec06                	sd	ra,24(sp)
    80004660:	e822                	sd	s0,16(sp)
    80004662:	e426                	sd	s1,8(sp)
    80004664:	e04a                	sd	s2,0(sp)
    80004666:	1000                	addi	s0,sp,32
    80004668:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    8000466a:	0001d917          	auipc	s2,0x1d
    8000466e:	f0690913          	addi	s2,s2,-250 # 80021570 <log>
    80004672:	854a                	mv	a0,s2
    80004674:	ffffc097          	auipc	ra,0xffffc
    80004678:	562080e7          	jalr	1378(ra) # 80000bd6 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    8000467c:	02c92603          	lw	a2,44(s2)
    80004680:	47f5                	li	a5,29
    80004682:	06c7c563          	blt	a5,a2,800046ec <log_write+0x90>
    80004686:	0001d797          	auipc	a5,0x1d
    8000468a:	f067a783          	lw	a5,-250(a5) # 8002158c <log+0x1c>
    8000468e:	37fd                	addiw	a5,a5,-1
    80004690:	04f65e63          	bge	a2,a5,800046ec <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004694:	0001d797          	auipc	a5,0x1d
    80004698:	efc7a783          	lw	a5,-260(a5) # 80021590 <log+0x20>
    8000469c:	06f05063          	blez	a5,800046fc <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800046a0:	4781                	li	a5,0
    800046a2:	06c05563          	blez	a2,8000470c <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    800046a6:	44cc                	lw	a1,12(s1)
    800046a8:	0001d717          	auipc	a4,0x1d
    800046ac:	ef870713          	addi	a4,a4,-264 # 800215a0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800046b0:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    800046b2:	4314                	lw	a3,0(a4)
    800046b4:	04b68c63          	beq	a3,a1,8000470c <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    800046b8:	2785                	addiw	a5,a5,1
    800046ba:	0711                	addi	a4,a4,4
    800046bc:	fef61be3          	bne	a2,a5,800046b2 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    800046c0:	0621                	addi	a2,a2,8
    800046c2:	060a                	slli	a2,a2,0x2
    800046c4:	0001d797          	auipc	a5,0x1d
    800046c8:	eac78793          	addi	a5,a5,-340 # 80021570 <log>
    800046cc:	97b2                	add	a5,a5,a2
    800046ce:	44d8                	lw	a4,12(s1)
    800046d0:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800046d2:	8526                	mv	a0,s1
    800046d4:	fffff097          	auipc	ra,0xfffff
    800046d8:	d9c080e7          	jalr	-612(ra) # 80003470 <bpin>
    log.lh.n++;
    800046dc:	0001d717          	auipc	a4,0x1d
    800046e0:	e9470713          	addi	a4,a4,-364 # 80021570 <log>
    800046e4:	575c                	lw	a5,44(a4)
    800046e6:	2785                	addiw	a5,a5,1
    800046e8:	d75c                	sw	a5,44(a4)
    800046ea:	a82d                	j	80004724 <log_write+0xc8>
    panic("too big a transaction");
    800046ec:	00004517          	auipc	a0,0x4
    800046f0:	14c50513          	addi	a0,a0,332 # 80008838 <systemCallsNames+0x208>
    800046f4:	ffffc097          	auipc	ra,0xffffc
    800046f8:	e4c080e7          	jalr	-436(ra) # 80000540 <panic>
    panic("log_write outside of trans");
    800046fc:	00004517          	auipc	a0,0x4
    80004700:	15450513          	addi	a0,a0,340 # 80008850 <systemCallsNames+0x220>
    80004704:	ffffc097          	auipc	ra,0xffffc
    80004708:	e3c080e7          	jalr	-452(ra) # 80000540 <panic>
  log.lh.block[i] = b->blockno;
    8000470c:	00878693          	addi	a3,a5,8
    80004710:	068a                	slli	a3,a3,0x2
    80004712:	0001d717          	auipc	a4,0x1d
    80004716:	e5e70713          	addi	a4,a4,-418 # 80021570 <log>
    8000471a:	9736                	add	a4,a4,a3
    8000471c:	44d4                	lw	a3,12(s1)
    8000471e:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004720:	faf609e3          	beq	a2,a5,800046d2 <log_write+0x76>
  }
  release(&log.lock);
    80004724:	0001d517          	auipc	a0,0x1d
    80004728:	e4c50513          	addi	a0,a0,-436 # 80021570 <log>
    8000472c:	ffffc097          	auipc	ra,0xffffc
    80004730:	55e080e7          	jalr	1374(ra) # 80000c8a <release>
}
    80004734:	60e2                	ld	ra,24(sp)
    80004736:	6442                	ld	s0,16(sp)
    80004738:	64a2                	ld	s1,8(sp)
    8000473a:	6902                	ld	s2,0(sp)
    8000473c:	6105                	addi	sp,sp,32
    8000473e:	8082                	ret

0000000080004740 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004740:	1101                	addi	sp,sp,-32
    80004742:	ec06                	sd	ra,24(sp)
    80004744:	e822                	sd	s0,16(sp)
    80004746:	e426                	sd	s1,8(sp)
    80004748:	e04a                	sd	s2,0(sp)
    8000474a:	1000                	addi	s0,sp,32
    8000474c:	84aa                	mv	s1,a0
    8000474e:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004750:	00004597          	auipc	a1,0x4
    80004754:	12058593          	addi	a1,a1,288 # 80008870 <systemCallsNames+0x240>
    80004758:	0521                	addi	a0,a0,8
    8000475a:	ffffc097          	auipc	ra,0xffffc
    8000475e:	3ec080e7          	jalr	1004(ra) # 80000b46 <initlock>
  lk->name = name;
    80004762:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004766:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000476a:	0204a423          	sw	zero,40(s1)
}
    8000476e:	60e2                	ld	ra,24(sp)
    80004770:	6442                	ld	s0,16(sp)
    80004772:	64a2                	ld	s1,8(sp)
    80004774:	6902                	ld	s2,0(sp)
    80004776:	6105                	addi	sp,sp,32
    80004778:	8082                	ret

000000008000477a <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    8000477a:	1101                	addi	sp,sp,-32
    8000477c:	ec06                	sd	ra,24(sp)
    8000477e:	e822                	sd	s0,16(sp)
    80004780:	e426                	sd	s1,8(sp)
    80004782:	e04a                	sd	s2,0(sp)
    80004784:	1000                	addi	s0,sp,32
    80004786:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004788:	00850913          	addi	s2,a0,8
    8000478c:	854a                	mv	a0,s2
    8000478e:	ffffc097          	auipc	ra,0xffffc
    80004792:	448080e7          	jalr	1096(ra) # 80000bd6 <acquire>
  while (lk->locked) {
    80004796:	409c                	lw	a5,0(s1)
    80004798:	cb89                	beqz	a5,800047aa <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    8000479a:	85ca                	mv	a1,s2
    8000479c:	8526                	mv	a0,s1
    8000479e:	ffffe097          	auipc	ra,0xffffe
    800047a2:	992080e7          	jalr	-1646(ra) # 80002130 <sleep>
  while (lk->locked) {
    800047a6:	409c                	lw	a5,0(s1)
    800047a8:	fbed                	bnez	a5,8000479a <acquiresleep+0x20>
  }
  lk->locked = 1;
    800047aa:	4785                	li	a5,1
    800047ac:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800047ae:	ffffd097          	auipc	ra,0xffffd
    800047b2:	1fe080e7          	jalr	510(ra) # 800019ac <myproc>
    800047b6:	591c                	lw	a5,48(a0)
    800047b8:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800047ba:	854a                	mv	a0,s2
    800047bc:	ffffc097          	auipc	ra,0xffffc
    800047c0:	4ce080e7          	jalr	1230(ra) # 80000c8a <release>
}
    800047c4:	60e2                	ld	ra,24(sp)
    800047c6:	6442                	ld	s0,16(sp)
    800047c8:	64a2                	ld	s1,8(sp)
    800047ca:	6902                	ld	s2,0(sp)
    800047cc:	6105                	addi	sp,sp,32
    800047ce:	8082                	ret

00000000800047d0 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800047d0:	1101                	addi	sp,sp,-32
    800047d2:	ec06                	sd	ra,24(sp)
    800047d4:	e822                	sd	s0,16(sp)
    800047d6:	e426                	sd	s1,8(sp)
    800047d8:	e04a                	sd	s2,0(sp)
    800047da:	1000                	addi	s0,sp,32
    800047dc:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800047de:	00850913          	addi	s2,a0,8
    800047e2:	854a                	mv	a0,s2
    800047e4:	ffffc097          	auipc	ra,0xffffc
    800047e8:	3f2080e7          	jalr	1010(ra) # 80000bd6 <acquire>
  lk->locked = 0;
    800047ec:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800047f0:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800047f4:	8526                	mv	a0,s1
    800047f6:	ffffe097          	auipc	ra,0xffffe
    800047fa:	aea080e7          	jalr	-1302(ra) # 800022e0 <wakeup>
  release(&lk->lk);
    800047fe:	854a                	mv	a0,s2
    80004800:	ffffc097          	auipc	ra,0xffffc
    80004804:	48a080e7          	jalr	1162(ra) # 80000c8a <release>
}
    80004808:	60e2                	ld	ra,24(sp)
    8000480a:	6442                	ld	s0,16(sp)
    8000480c:	64a2                	ld	s1,8(sp)
    8000480e:	6902                	ld	s2,0(sp)
    80004810:	6105                	addi	sp,sp,32
    80004812:	8082                	ret

0000000080004814 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004814:	7179                	addi	sp,sp,-48
    80004816:	f406                	sd	ra,40(sp)
    80004818:	f022                	sd	s0,32(sp)
    8000481a:	ec26                	sd	s1,24(sp)
    8000481c:	e84a                	sd	s2,16(sp)
    8000481e:	e44e                	sd	s3,8(sp)
    80004820:	1800                	addi	s0,sp,48
    80004822:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004824:	00850913          	addi	s2,a0,8
    80004828:	854a                	mv	a0,s2
    8000482a:	ffffc097          	auipc	ra,0xffffc
    8000482e:	3ac080e7          	jalr	940(ra) # 80000bd6 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004832:	409c                	lw	a5,0(s1)
    80004834:	ef99                	bnez	a5,80004852 <holdingsleep+0x3e>
    80004836:	4481                	li	s1,0
  release(&lk->lk);
    80004838:	854a                	mv	a0,s2
    8000483a:	ffffc097          	auipc	ra,0xffffc
    8000483e:	450080e7          	jalr	1104(ra) # 80000c8a <release>
  return r;
}
    80004842:	8526                	mv	a0,s1
    80004844:	70a2                	ld	ra,40(sp)
    80004846:	7402                	ld	s0,32(sp)
    80004848:	64e2                	ld	s1,24(sp)
    8000484a:	6942                	ld	s2,16(sp)
    8000484c:	69a2                	ld	s3,8(sp)
    8000484e:	6145                	addi	sp,sp,48
    80004850:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004852:	0284a983          	lw	s3,40(s1)
    80004856:	ffffd097          	auipc	ra,0xffffd
    8000485a:	156080e7          	jalr	342(ra) # 800019ac <myproc>
    8000485e:	5904                	lw	s1,48(a0)
    80004860:	413484b3          	sub	s1,s1,s3
    80004864:	0014b493          	seqz	s1,s1
    80004868:	bfc1                	j	80004838 <holdingsleep+0x24>

000000008000486a <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    8000486a:	1141                	addi	sp,sp,-16
    8000486c:	e406                	sd	ra,8(sp)
    8000486e:	e022                	sd	s0,0(sp)
    80004870:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004872:	00004597          	auipc	a1,0x4
    80004876:	00e58593          	addi	a1,a1,14 # 80008880 <systemCallsNames+0x250>
    8000487a:	0001d517          	auipc	a0,0x1d
    8000487e:	e3e50513          	addi	a0,a0,-450 # 800216b8 <ftable>
    80004882:	ffffc097          	auipc	ra,0xffffc
    80004886:	2c4080e7          	jalr	708(ra) # 80000b46 <initlock>
}
    8000488a:	60a2                	ld	ra,8(sp)
    8000488c:	6402                	ld	s0,0(sp)
    8000488e:	0141                	addi	sp,sp,16
    80004890:	8082                	ret

0000000080004892 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004892:	1101                	addi	sp,sp,-32
    80004894:	ec06                	sd	ra,24(sp)
    80004896:	e822                	sd	s0,16(sp)
    80004898:	e426                	sd	s1,8(sp)
    8000489a:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    8000489c:	0001d517          	auipc	a0,0x1d
    800048a0:	e1c50513          	addi	a0,a0,-484 # 800216b8 <ftable>
    800048a4:	ffffc097          	auipc	ra,0xffffc
    800048a8:	332080e7          	jalr	818(ra) # 80000bd6 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800048ac:	0001d497          	auipc	s1,0x1d
    800048b0:	e2448493          	addi	s1,s1,-476 # 800216d0 <ftable+0x18>
    800048b4:	0001e717          	auipc	a4,0x1e
    800048b8:	dbc70713          	addi	a4,a4,-580 # 80022670 <disk>
    if(f->ref == 0){
    800048bc:	40dc                	lw	a5,4(s1)
    800048be:	cf99                	beqz	a5,800048dc <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800048c0:	02848493          	addi	s1,s1,40
    800048c4:	fee49ce3          	bne	s1,a4,800048bc <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800048c8:	0001d517          	auipc	a0,0x1d
    800048cc:	df050513          	addi	a0,a0,-528 # 800216b8 <ftable>
    800048d0:	ffffc097          	auipc	ra,0xffffc
    800048d4:	3ba080e7          	jalr	954(ra) # 80000c8a <release>
  return 0;
    800048d8:	4481                	li	s1,0
    800048da:	a819                	j	800048f0 <filealloc+0x5e>
      f->ref = 1;
    800048dc:	4785                	li	a5,1
    800048de:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800048e0:	0001d517          	auipc	a0,0x1d
    800048e4:	dd850513          	addi	a0,a0,-552 # 800216b8 <ftable>
    800048e8:	ffffc097          	auipc	ra,0xffffc
    800048ec:	3a2080e7          	jalr	930(ra) # 80000c8a <release>
}
    800048f0:	8526                	mv	a0,s1
    800048f2:	60e2                	ld	ra,24(sp)
    800048f4:	6442                	ld	s0,16(sp)
    800048f6:	64a2                	ld	s1,8(sp)
    800048f8:	6105                	addi	sp,sp,32
    800048fa:	8082                	ret

00000000800048fc <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800048fc:	1101                	addi	sp,sp,-32
    800048fe:	ec06                	sd	ra,24(sp)
    80004900:	e822                	sd	s0,16(sp)
    80004902:	e426                	sd	s1,8(sp)
    80004904:	1000                	addi	s0,sp,32
    80004906:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004908:	0001d517          	auipc	a0,0x1d
    8000490c:	db050513          	addi	a0,a0,-592 # 800216b8 <ftable>
    80004910:	ffffc097          	auipc	ra,0xffffc
    80004914:	2c6080e7          	jalr	710(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    80004918:	40dc                	lw	a5,4(s1)
    8000491a:	02f05263          	blez	a5,8000493e <filedup+0x42>
    panic("filedup");
  f->ref++;
    8000491e:	2785                	addiw	a5,a5,1
    80004920:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004922:	0001d517          	auipc	a0,0x1d
    80004926:	d9650513          	addi	a0,a0,-618 # 800216b8 <ftable>
    8000492a:	ffffc097          	auipc	ra,0xffffc
    8000492e:	360080e7          	jalr	864(ra) # 80000c8a <release>
  return f;
}
    80004932:	8526                	mv	a0,s1
    80004934:	60e2                	ld	ra,24(sp)
    80004936:	6442                	ld	s0,16(sp)
    80004938:	64a2                	ld	s1,8(sp)
    8000493a:	6105                	addi	sp,sp,32
    8000493c:	8082                	ret
    panic("filedup");
    8000493e:	00004517          	auipc	a0,0x4
    80004942:	f4a50513          	addi	a0,a0,-182 # 80008888 <systemCallsNames+0x258>
    80004946:	ffffc097          	auipc	ra,0xffffc
    8000494a:	bfa080e7          	jalr	-1030(ra) # 80000540 <panic>

000000008000494e <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    8000494e:	7139                	addi	sp,sp,-64
    80004950:	fc06                	sd	ra,56(sp)
    80004952:	f822                	sd	s0,48(sp)
    80004954:	f426                	sd	s1,40(sp)
    80004956:	f04a                	sd	s2,32(sp)
    80004958:	ec4e                	sd	s3,24(sp)
    8000495a:	e852                	sd	s4,16(sp)
    8000495c:	e456                	sd	s5,8(sp)
    8000495e:	0080                	addi	s0,sp,64
    80004960:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004962:	0001d517          	auipc	a0,0x1d
    80004966:	d5650513          	addi	a0,a0,-682 # 800216b8 <ftable>
    8000496a:	ffffc097          	auipc	ra,0xffffc
    8000496e:	26c080e7          	jalr	620(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    80004972:	40dc                	lw	a5,4(s1)
    80004974:	06f05163          	blez	a5,800049d6 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004978:	37fd                	addiw	a5,a5,-1
    8000497a:	0007871b          	sext.w	a4,a5
    8000497e:	c0dc                	sw	a5,4(s1)
    80004980:	06e04363          	bgtz	a4,800049e6 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004984:	0004a903          	lw	s2,0(s1)
    80004988:	0094ca83          	lbu	s5,9(s1)
    8000498c:	0104ba03          	ld	s4,16(s1)
    80004990:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004994:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004998:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    8000499c:	0001d517          	auipc	a0,0x1d
    800049a0:	d1c50513          	addi	a0,a0,-740 # 800216b8 <ftable>
    800049a4:	ffffc097          	auipc	ra,0xffffc
    800049a8:	2e6080e7          	jalr	742(ra) # 80000c8a <release>

  if(ff.type == FD_PIPE){
    800049ac:	4785                	li	a5,1
    800049ae:	04f90d63          	beq	s2,a5,80004a08 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800049b2:	3979                	addiw	s2,s2,-2
    800049b4:	4785                	li	a5,1
    800049b6:	0527e063          	bltu	a5,s2,800049f6 <fileclose+0xa8>
    begin_op();
    800049ba:	00000097          	auipc	ra,0x0
    800049be:	acc080e7          	jalr	-1332(ra) # 80004486 <begin_op>
    iput(ff.ip);
    800049c2:	854e                	mv	a0,s3
    800049c4:	fffff097          	auipc	ra,0xfffff
    800049c8:	2b0080e7          	jalr	688(ra) # 80003c74 <iput>
    end_op();
    800049cc:	00000097          	auipc	ra,0x0
    800049d0:	b38080e7          	jalr	-1224(ra) # 80004504 <end_op>
    800049d4:	a00d                	j	800049f6 <fileclose+0xa8>
    panic("fileclose");
    800049d6:	00004517          	auipc	a0,0x4
    800049da:	eba50513          	addi	a0,a0,-326 # 80008890 <systemCallsNames+0x260>
    800049de:	ffffc097          	auipc	ra,0xffffc
    800049e2:	b62080e7          	jalr	-1182(ra) # 80000540 <panic>
    release(&ftable.lock);
    800049e6:	0001d517          	auipc	a0,0x1d
    800049ea:	cd250513          	addi	a0,a0,-814 # 800216b8 <ftable>
    800049ee:	ffffc097          	auipc	ra,0xffffc
    800049f2:	29c080e7          	jalr	668(ra) # 80000c8a <release>
  }
}
    800049f6:	70e2                	ld	ra,56(sp)
    800049f8:	7442                	ld	s0,48(sp)
    800049fa:	74a2                	ld	s1,40(sp)
    800049fc:	7902                	ld	s2,32(sp)
    800049fe:	69e2                	ld	s3,24(sp)
    80004a00:	6a42                	ld	s4,16(sp)
    80004a02:	6aa2                	ld	s5,8(sp)
    80004a04:	6121                	addi	sp,sp,64
    80004a06:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004a08:	85d6                	mv	a1,s5
    80004a0a:	8552                	mv	a0,s4
    80004a0c:	00000097          	auipc	ra,0x0
    80004a10:	34c080e7          	jalr	844(ra) # 80004d58 <pipeclose>
    80004a14:	b7cd                	j	800049f6 <fileclose+0xa8>

0000000080004a16 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004a16:	715d                	addi	sp,sp,-80
    80004a18:	e486                	sd	ra,72(sp)
    80004a1a:	e0a2                	sd	s0,64(sp)
    80004a1c:	fc26                	sd	s1,56(sp)
    80004a1e:	f84a                	sd	s2,48(sp)
    80004a20:	f44e                	sd	s3,40(sp)
    80004a22:	0880                	addi	s0,sp,80
    80004a24:	84aa                	mv	s1,a0
    80004a26:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004a28:	ffffd097          	auipc	ra,0xffffd
    80004a2c:	f84080e7          	jalr	-124(ra) # 800019ac <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004a30:	409c                	lw	a5,0(s1)
    80004a32:	37f9                	addiw	a5,a5,-2
    80004a34:	4705                	li	a4,1
    80004a36:	04f76763          	bltu	a4,a5,80004a84 <filestat+0x6e>
    80004a3a:	892a                	mv	s2,a0
    ilock(f->ip);
    80004a3c:	6c88                	ld	a0,24(s1)
    80004a3e:	fffff097          	auipc	ra,0xfffff
    80004a42:	07c080e7          	jalr	124(ra) # 80003aba <ilock>
    stati(f->ip, &st);
    80004a46:	fb840593          	addi	a1,s0,-72
    80004a4a:	6c88                	ld	a0,24(s1)
    80004a4c:	fffff097          	auipc	ra,0xfffff
    80004a50:	2f8080e7          	jalr	760(ra) # 80003d44 <stati>
    iunlock(f->ip);
    80004a54:	6c88                	ld	a0,24(s1)
    80004a56:	fffff097          	auipc	ra,0xfffff
    80004a5a:	126080e7          	jalr	294(ra) # 80003b7c <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004a5e:	46e1                	li	a3,24
    80004a60:	fb840613          	addi	a2,s0,-72
    80004a64:	85ce                	mv	a1,s3
    80004a66:	05093503          	ld	a0,80(s2)
    80004a6a:	ffffd097          	auipc	ra,0xffffd
    80004a6e:	c02080e7          	jalr	-1022(ra) # 8000166c <copyout>
    80004a72:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004a76:	60a6                	ld	ra,72(sp)
    80004a78:	6406                	ld	s0,64(sp)
    80004a7a:	74e2                	ld	s1,56(sp)
    80004a7c:	7942                	ld	s2,48(sp)
    80004a7e:	79a2                	ld	s3,40(sp)
    80004a80:	6161                	addi	sp,sp,80
    80004a82:	8082                	ret
  return -1;
    80004a84:	557d                	li	a0,-1
    80004a86:	bfc5                	j	80004a76 <filestat+0x60>

0000000080004a88 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004a88:	7179                	addi	sp,sp,-48
    80004a8a:	f406                	sd	ra,40(sp)
    80004a8c:	f022                	sd	s0,32(sp)
    80004a8e:	ec26                	sd	s1,24(sp)
    80004a90:	e84a                	sd	s2,16(sp)
    80004a92:	e44e                	sd	s3,8(sp)
    80004a94:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004a96:	00854783          	lbu	a5,8(a0)
    80004a9a:	c3d5                	beqz	a5,80004b3e <fileread+0xb6>
    80004a9c:	84aa                	mv	s1,a0
    80004a9e:	89ae                	mv	s3,a1
    80004aa0:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004aa2:	411c                	lw	a5,0(a0)
    80004aa4:	4705                	li	a4,1
    80004aa6:	04e78963          	beq	a5,a4,80004af8 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004aaa:	470d                	li	a4,3
    80004aac:	04e78d63          	beq	a5,a4,80004b06 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004ab0:	4709                	li	a4,2
    80004ab2:	06e79e63          	bne	a5,a4,80004b2e <fileread+0xa6>
    ilock(f->ip);
    80004ab6:	6d08                	ld	a0,24(a0)
    80004ab8:	fffff097          	auipc	ra,0xfffff
    80004abc:	002080e7          	jalr	2(ra) # 80003aba <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004ac0:	874a                	mv	a4,s2
    80004ac2:	5094                	lw	a3,32(s1)
    80004ac4:	864e                	mv	a2,s3
    80004ac6:	4585                	li	a1,1
    80004ac8:	6c88                	ld	a0,24(s1)
    80004aca:	fffff097          	auipc	ra,0xfffff
    80004ace:	2a4080e7          	jalr	676(ra) # 80003d6e <readi>
    80004ad2:	892a                	mv	s2,a0
    80004ad4:	00a05563          	blez	a0,80004ade <fileread+0x56>
      f->off += r;
    80004ad8:	509c                	lw	a5,32(s1)
    80004ada:	9fa9                	addw	a5,a5,a0
    80004adc:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004ade:	6c88                	ld	a0,24(s1)
    80004ae0:	fffff097          	auipc	ra,0xfffff
    80004ae4:	09c080e7          	jalr	156(ra) # 80003b7c <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004ae8:	854a                	mv	a0,s2
    80004aea:	70a2                	ld	ra,40(sp)
    80004aec:	7402                	ld	s0,32(sp)
    80004aee:	64e2                	ld	s1,24(sp)
    80004af0:	6942                	ld	s2,16(sp)
    80004af2:	69a2                	ld	s3,8(sp)
    80004af4:	6145                	addi	sp,sp,48
    80004af6:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004af8:	6908                	ld	a0,16(a0)
    80004afa:	00000097          	auipc	ra,0x0
    80004afe:	3c6080e7          	jalr	966(ra) # 80004ec0 <piperead>
    80004b02:	892a                	mv	s2,a0
    80004b04:	b7d5                	j	80004ae8 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004b06:	02451783          	lh	a5,36(a0)
    80004b0a:	03079693          	slli	a3,a5,0x30
    80004b0e:	92c1                	srli	a3,a3,0x30
    80004b10:	4725                	li	a4,9
    80004b12:	02d76863          	bltu	a4,a3,80004b42 <fileread+0xba>
    80004b16:	0792                	slli	a5,a5,0x4
    80004b18:	0001d717          	auipc	a4,0x1d
    80004b1c:	b0070713          	addi	a4,a4,-1280 # 80021618 <devsw>
    80004b20:	97ba                	add	a5,a5,a4
    80004b22:	639c                	ld	a5,0(a5)
    80004b24:	c38d                	beqz	a5,80004b46 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004b26:	4505                	li	a0,1
    80004b28:	9782                	jalr	a5
    80004b2a:	892a                	mv	s2,a0
    80004b2c:	bf75                	j	80004ae8 <fileread+0x60>
    panic("fileread");
    80004b2e:	00004517          	auipc	a0,0x4
    80004b32:	d7250513          	addi	a0,a0,-654 # 800088a0 <systemCallsNames+0x270>
    80004b36:	ffffc097          	auipc	ra,0xffffc
    80004b3a:	a0a080e7          	jalr	-1526(ra) # 80000540 <panic>
    return -1;
    80004b3e:	597d                	li	s2,-1
    80004b40:	b765                	j	80004ae8 <fileread+0x60>
      return -1;
    80004b42:	597d                	li	s2,-1
    80004b44:	b755                	j	80004ae8 <fileread+0x60>
    80004b46:	597d                	li	s2,-1
    80004b48:	b745                	j	80004ae8 <fileread+0x60>

0000000080004b4a <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004b4a:	715d                	addi	sp,sp,-80
    80004b4c:	e486                	sd	ra,72(sp)
    80004b4e:	e0a2                	sd	s0,64(sp)
    80004b50:	fc26                	sd	s1,56(sp)
    80004b52:	f84a                	sd	s2,48(sp)
    80004b54:	f44e                	sd	s3,40(sp)
    80004b56:	f052                	sd	s4,32(sp)
    80004b58:	ec56                	sd	s5,24(sp)
    80004b5a:	e85a                	sd	s6,16(sp)
    80004b5c:	e45e                	sd	s7,8(sp)
    80004b5e:	e062                	sd	s8,0(sp)
    80004b60:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004b62:	00954783          	lbu	a5,9(a0)
    80004b66:	10078663          	beqz	a5,80004c72 <filewrite+0x128>
    80004b6a:	892a                	mv	s2,a0
    80004b6c:	8b2e                	mv	s6,a1
    80004b6e:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004b70:	411c                	lw	a5,0(a0)
    80004b72:	4705                	li	a4,1
    80004b74:	02e78263          	beq	a5,a4,80004b98 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004b78:	470d                	li	a4,3
    80004b7a:	02e78663          	beq	a5,a4,80004ba6 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004b7e:	4709                	li	a4,2
    80004b80:	0ee79163          	bne	a5,a4,80004c62 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004b84:	0ac05d63          	blez	a2,80004c3e <filewrite+0xf4>
    int i = 0;
    80004b88:	4981                	li	s3,0
    80004b8a:	6b85                	lui	s7,0x1
    80004b8c:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004b90:	6c05                	lui	s8,0x1
    80004b92:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80004b96:	a861                	j	80004c2e <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004b98:	6908                	ld	a0,16(a0)
    80004b9a:	00000097          	auipc	ra,0x0
    80004b9e:	22e080e7          	jalr	558(ra) # 80004dc8 <pipewrite>
    80004ba2:	8a2a                	mv	s4,a0
    80004ba4:	a045                	j	80004c44 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004ba6:	02451783          	lh	a5,36(a0)
    80004baa:	03079693          	slli	a3,a5,0x30
    80004bae:	92c1                	srli	a3,a3,0x30
    80004bb0:	4725                	li	a4,9
    80004bb2:	0cd76263          	bltu	a4,a3,80004c76 <filewrite+0x12c>
    80004bb6:	0792                	slli	a5,a5,0x4
    80004bb8:	0001d717          	auipc	a4,0x1d
    80004bbc:	a6070713          	addi	a4,a4,-1440 # 80021618 <devsw>
    80004bc0:	97ba                	add	a5,a5,a4
    80004bc2:	679c                	ld	a5,8(a5)
    80004bc4:	cbdd                	beqz	a5,80004c7a <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004bc6:	4505                	li	a0,1
    80004bc8:	9782                	jalr	a5
    80004bca:	8a2a                	mv	s4,a0
    80004bcc:	a8a5                	j	80004c44 <filewrite+0xfa>
    80004bce:	00048a9b          	sext.w	s5,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004bd2:	00000097          	auipc	ra,0x0
    80004bd6:	8b4080e7          	jalr	-1868(ra) # 80004486 <begin_op>
      ilock(f->ip);
    80004bda:	01893503          	ld	a0,24(s2)
    80004bde:	fffff097          	auipc	ra,0xfffff
    80004be2:	edc080e7          	jalr	-292(ra) # 80003aba <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004be6:	8756                	mv	a4,s5
    80004be8:	02092683          	lw	a3,32(s2)
    80004bec:	01698633          	add	a2,s3,s6
    80004bf0:	4585                	li	a1,1
    80004bf2:	01893503          	ld	a0,24(s2)
    80004bf6:	fffff097          	auipc	ra,0xfffff
    80004bfa:	270080e7          	jalr	624(ra) # 80003e66 <writei>
    80004bfe:	84aa                	mv	s1,a0
    80004c00:	00a05763          	blez	a0,80004c0e <filewrite+0xc4>
        f->off += r;
    80004c04:	02092783          	lw	a5,32(s2)
    80004c08:	9fa9                	addw	a5,a5,a0
    80004c0a:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004c0e:	01893503          	ld	a0,24(s2)
    80004c12:	fffff097          	auipc	ra,0xfffff
    80004c16:	f6a080e7          	jalr	-150(ra) # 80003b7c <iunlock>
      end_op();
    80004c1a:	00000097          	auipc	ra,0x0
    80004c1e:	8ea080e7          	jalr	-1814(ra) # 80004504 <end_op>

      if(r != n1){
    80004c22:	009a9f63          	bne	s5,s1,80004c40 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004c26:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004c2a:	0149db63          	bge	s3,s4,80004c40 <filewrite+0xf6>
      int n1 = n - i;
    80004c2e:	413a04bb          	subw	s1,s4,s3
    80004c32:	0004879b          	sext.w	a5,s1
    80004c36:	f8fbdce3          	bge	s7,a5,80004bce <filewrite+0x84>
    80004c3a:	84e2                	mv	s1,s8
    80004c3c:	bf49                	j	80004bce <filewrite+0x84>
    int i = 0;
    80004c3e:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004c40:	013a1f63          	bne	s4,s3,80004c5e <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004c44:	8552                	mv	a0,s4
    80004c46:	60a6                	ld	ra,72(sp)
    80004c48:	6406                	ld	s0,64(sp)
    80004c4a:	74e2                	ld	s1,56(sp)
    80004c4c:	7942                	ld	s2,48(sp)
    80004c4e:	79a2                	ld	s3,40(sp)
    80004c50:	7a02                	ld	s4,32(sp)
    80004c52:	6ae2                	ld	s5,24(sp)
    80004c54:	6b42                	ld	s6,16(sp)
    80004c56:	6ba2                	ld	s7,8(sp)
    80004c58:	6c02                	ld	s8,0(sp)
    80004c5a:	6161                	addi	sp,sp,80
    80004c5c:	8082                	ret
    ret = (i == n ? n : -1);
    80004c5e:	5a7d                	li	s4,-1
    80004c60:	b7d5                	j	80004c44 <filewrite+0xfa>
    panic("filewrite");
    80004c62:	00004517          	auipc	a0,0x4
    80004c66:	c4e50513          	addi	a0,a0,-946 # 800088b0 <systemCallsNames+0x280>
    80004c6a:	ffffc097          	auipc	ra,0xffffc
    80004c6e:	8d6080e7          	jalr	-1834(ra) # 80000540 <panic>
    return -1;
    80004c72:	5a7d                	li	s4,-1
    80004c74:	bfc1                	j	80004c44 <filewrite+0xfa>
      return -1;
    80004c76:	5a7d                	li	s4,-1
    80004c78:	b7f1                	j	80004c44 <filewrite+0xfa>
    80004c7a:	5a7d                	li	s4,-1
    80004c7c:	b7e1                	j	80004c44 <filewrite+0xfa>

0000000080004c7e <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004c7e:	7179                	addi	sp,sp,-48
    80004c80:	f406                	sd	ra,40(sp)
    80004c82:	f022                	sd	s0,32(sp)
    80004c84:	ec26                	sd	s1,24(sp)
    80004c86:	e84a                	sd	s2,16(sp)
    80004c88:	e44e                	sd	s3,8(sp)
    80004c8a:	e052                	sd	s4,0(sp)
    80004c8c:	1800                	addi	s0,sp,48
    80004c8e:	84aa                	mv	s1,a0
    80004c90:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004c92:	0005b023          	sd	zero,0(a1)
    80004c96:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004c9a:	00000097          	auipc	ra,0x0
    80004c9e:	bf8080e7          	jalr	-1032(ra) # 80004892 <filealloc>
    80004ca2:	e088                	sd	a0,0(s1)
    80004ca4:	c551                	beqz	a0,80004d30 <pipealloc+0xb2>
    80004ca6:	00000097          	auipc	ra,0x0
    80004caa:	bec080e7          	jalr	-1044(ra) # 80004892 <filealloc>
    80004cae:	00aa3023          	sd	a0,0(s4)
    80004cb2:	c92d                	beqz	a0,80004d24 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004cb4:	ffffc097          	auipc	ra,0xffffc
    80004cb8:	e32080e7          	jalr	-462(ra) # 80000ae6 <kalloc>
    80004cbc:	892a                	mv	s2,a0
    80004cbe:	c125                	beqz	a0,80004d1e <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004cc0:	4985                	li	s3,1
    80004cc2:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004cc6:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004cca:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004cce:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004cd2:	00003597          	auipc	a1,0x3
    80004cd6:	7d658593          	addi	a1,a1,2006 # 800084a8 <states.0+0x1c0>
    80004cda:	ffffc097          	auipc	ra,0xffffc
    80004cde:	e6c080e7          	jalr	-404(ra) # 80000b46 <initlock>
  (*f0)->type = FD_PIPE;
    80004ce2:	609c                	ld	a5,0(s1)
    80004ce4:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004ce8:	609c                	ld	a5,0(s1)
    80004cea:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004cee:	609c                	ld	a5,0(s1)
    80004cf0:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004cf4:	609c                	ld	a5,0(s1)
    80004cf6:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004cfa:	000a3783          	ld	a5,0(s4)
    80004cfe:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004d02:	000a3783          	ld	a5,0(s4)
    80004d06:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004d0a:	000a3783          	ld	a5,0(s4)
    80004d0e:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004d12:	000a3783          	ld	a5,0(s4)
    80004d16:	0127b823          	sd	s2,16(a5)
  return 0;
    80004d1a:	4501                	li	a0,0
    80004d1c:	a025                	j	80004d44 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004d1e:	6088                	ld	a0,0(s1)
    80004d20:	e501                	bnez	a0,80004d28 <pipealloc+0xaa>
    80004d22:	a039                	j	80004d30 <pipealloc+0xb2>
    80004d24:	6088                	ld	a0,0(s1)
    80004d26:	c51d                	beqz	a0,80004d54 <pipealloc+0xd6>
    fileclose(*f0);
    80004d28:	00000097          	auipc	ra,0x0
    80004d2c:	c26080e7          	jalr	-986(ra) # 8000494e <fileclose>
  if(*f1)
    80004d30:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004d34:	557d                	li	a0,-1
  if(*f1)
    80004d36:	c799                	beqz	a5,80004d44 <pipealloc+0xc6>
    fileclose(*f1);
    80004d38:	853e                	mv	a0,a5
    80004d3a:	00000097          	auipc	ra,0x0
    80004d3e:	c14080e7          	jalr	-1004(ra) # 8000494e <fileclose>
  return -1;
    80004d42:	557d                	li	a0,-1
}
    80004d44:	70a2                	ld	ra,40(sp)
    80004d46:	7402                	ld	s0,32(sp)
    80004d48:	64e2                	ld	s1,24(sp)
    80004d4a:	6942                	ld	s2,16(sp)
    80004d4c:	69a2                	ld	s3,8(sp)
    80004d4e:	6a02                	ld	s4,0(sp)
    80004d50:	6145                	addi	sp,sp,48
    80004d52:	8082                	ret
  return -1;
    80004d54:	557d                	li	a0,-1
    80004d56:	b7fd                	j	80004d44 <pipealloc+0xc6>

0000000080004d58 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004d58:	1101                	addi	sp,sp,-32
    80004d5a:	ec06                	sd	ra,24(sp)
    80004d5c:	e822                	sd	s0,16(sp)
    80004d5e:	e426                	sd	s1,8(sp)
    80004d60:	e04a                	sd	s2,0(sp)
    80004d62:	1000                	addi	s0,sp,32
    80004d64:	84aa                	mv	s1,a0
    80004d66:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004d68:	ffffc097          	auipc	ra,0xffffc
    80004d6c:	e6e080e7          	jalr	-402(ra) # 80000bd6 <acquire>
  if(writable){
    80004d70:	02090d63          	beqz	s2,80004daa <pipeclose+0x52>
    pi->writeopen = 0;
    80004d74:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004d78:	21848513          	addi	a0,s1,536
    80004d7c:	ffffd097          	auipc	ra,0xffffd
    80004d80:	564080e7          	jalr	1380(ra) # 800022e0 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004d84:	2204b783          	ld	a5,544(s1)
    80004d88:	eb95                	bnez	a5,80004dbc <pipeclose+0x64>
    release(&pi->lock);
    80004d8a:	8526                	mv	a0,s1
    80004d8c:	ffffc097          	auipc	ra,0xffffc
    80004d90:	efe080e7          	jalr	-258(ra) # 80000c8a <release>
    kfree((char*)pi);
    80004d94:	8526                	mv	a0,s1
    80004d96:	ffffc097          	auipc	ra,0xffffc
    80004d9a:	c52080e7          	jalr	-942(ra) # 800009e8 <kfree>
  } else
    release(&pi->lock);
}
    80004d9e:	60e2                	ld	ra,24(sp)
    80004da0:	6442                	ld	s0,16(sp)
    80004da2:	64a2                	ld	s1,8(sp)
    80004da4:	6902                	ld	s2,0(sp)
    80004da6:	6105                	addi	sp,sp,32
    80004da8:	8082                	ret
    pi->readopen = 0;
    80004daa:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004dae:	21c48513          	addi	a0,s1,540
    80004db2:	ffffd097          	auipc	ra,0xffffd
    80004db6:	52e080e7          	jalr	1326(ra) # 800022e0 <wakeup>
    80004dba:	b7e9                	j	80004d84 <pipeclose+0x2c>
    release(&pi->lock);
    80004dbc:	8526                	mv	a0,s1
    80004dbe:	ffffc097          	auipc	ra,0xffffc
    80004dc2:	ecc080e7          	jalr	-308(ra) # 80000c8a <release>
}
    80004dc6:	bfe1                	j	80004d9e <pipeclose+0x46>

0000000080004dc8 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004dc8:	711d                	addi	sp,sp,-96
    80004dca:	ec86                	sd	ra,88(sp)
    80004dcc:	e8a2                	sd	s0,80(sp)
    80004dce:	e4a6                	sd	s1,72(sp)
    80004dd0:	e0ca                	sd	s2,64(sp)
    80004dd2:	fc4e                	sd	s3,56(sp)
    80004dd4:	f852                	sd	s4,48(sp)
    80004dd6:	f456                	sd	s5,40(sp)
    80004dd8:	f05a                	sd	s6,32(sp)
    80004dda:	ec5e                	sd	s7,24(sp)
    80004ddc:	e862                	sd	s8,16(sp)
    80004dde:	1080                	addi	s0,sp,96
    80004de0:	84aa                	mv	s1,a0
    80004de2:	8aae                	mv	s5,a1
    80004de4:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004de6:	ffffd097          	auipc	ra,0xffffd
    80004dea:	bc6080e7          	jalr	-1082(ra) # 800019ac <myproc>
    80004dee:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004df0:	8526                	mv	a0,s1
    80004df2:	ffffc097          	auipc	ra,0xffffc
    80004df6:	de4080e7          	jalr	-540(ra) # 80000bd6 <acquire>
  while(i < n){
    80004dfa:	0b405663          	blez	s4,80004ea6 <pipewrite+0xde>
  int i = 0;
    80004dfe:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004e00:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004e02:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004e06:	21c48b93          	addi	s7,s1,540
    80004e0a:	a089                	j	80004e4c <pipewrite+0x84>
      release(&pi->lock);
    80004e0c:	8526                	mv	a0,s1
    80004e0e:	ffffc097          	auipc	ra,0xffffc
    80004e12:	e7c080e7          	jalr	-388(ra) # 80000c8a <release>
      return -1;
    80004e16:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004e18:	854a                	mv	a0,s2
    80004e1a:	60e6                	ld	ra,88(sp)
    80004e1c:	6446                	ld	s0,80(sp)
    80004e1e:	64a6                	ld	s1,72(sp)
    80004e20:	6906                	ld	s2,64(sp)
    80004e22:	79e2                	ld	s3,56(sp)
    80004e24:	7a42                	ld	s4,48(sp)
    80004e26:	7aa2                	ld	s5,40(sp)
    80004e28:	7b02                	ld	s6,32(sp)
    80004e2a:	6be2                	ld	s7,24(sp)
    80004e2c:	6c42                	ld	s8,16(sp)
    80004e2e:	6125                	addi	sp,sp,96
    80004e30:	8082                	ret
      wakeup(&pi->nread);
    80004e32:	8562                	mv	a0,s8
    80004e34:	ffffd097          	auipc	ra,0xffffd
    80004e38:	4ac080e7          	jalr	1196(ra) # 800022e0 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004e3c:	85a6                	mv	a1,s1
    80004e3e:	855e                	mv	a0,s7
    80004e40:	ffffd097          	auipc	ra,0xffffd
    80004e44:	2f0080e7          	jalr	752(ra) # 80002130 <sleep>
  while(i < n){
    80004e48:	07495063          	bge	s2,s4,80004ea8 <pipewrite+0xe0>
    if(pi->readopen == 0 || killed(pr)){
    80004e4c:	2204a783          	lw	a5,544(s1)
    80004e50:	dfd5                	beqz	a5,80004e0c <pipewrite+0x44>
    80004e52:	854e                	mv	a0,s3
    80004e54:	ffffd097          	auipc	ra,0xffffd
    80004e58:	6dc080e7          	jalr	1756(ra) # 80002530 <killed>
    80004e5c:	f945                	bnez	a0,80004e0c <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004e5e:	2184a783          	lw	a5,536(s1)
    80004e62:	21c4a703          	lw	a4,540(s1)
    80004e66:	2007879b          	addiw	a5,a5,512
    80004e6a:	fcf704e3          	beq	a4,a5,80004e32 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004e6e:	4685                	li	a3,1
    80004e70:	01590633          	add	a2,s2,s5
    80004e74:	faf40593          	addi	a1,s0,-81
    80004e78:	0509b503          	ld	a0,80(s3)
    80004e7c:	ffffd097          	auipc	ra,0xffffd
    80004e80:	87c080e7          	jalr	-1924(ra) # 800016f8 <copyin>
    80004e84:	03650263          	beq	a0,s6,80004ea8 <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004e88:	21c4a783          	lw	a5,540(s1)
    80004e8c:	0017871b          	addiw	a4,a5,1
    80004e90:	20e4ae23          	sw	a4,540(s1)
    80004e94:	1ff7f793          	andi	a5,a5,511
    80004e98:	97a6                	add	a5,a5,s1
    80004e9a:	faf44703          	lbu	a4,-81(s0)
    80004e9e:	00e78c23          	sb	a4,24(a5)
      i++;
    80004ea2:	2905                	addiw	s2,s2,1
    80004ea4:	b755                	j	80004e48 <pipewrite+0x80>
  int i = 0;
    80004ea6:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004ea8:	21848513          	addi	a0,s1,536
    80004eac:	ffffd097          	auipc	ra,0xffffd
    80004eb0:	434080e7          	jalr	1076(ra) # 800022e0 <wakeup>
  release(&pi->lock);
    80004eb4:	8526                	mv	a0,s1
    80004eb6:	ffffc097          	auipc	ra,0xffffc
    80004eba:	dd4080e7          	jalr	-556(ra) # 80000c8a <release>
  return i;
    80004ebe:	bfa9                	j	80004e18 <pipewrite+0x50>

0000000080004ec0 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004ec0:	715d                	addi	sp,sp,-80
    80004ec2:	e486                	sd	ra,72(sp)
    80004ec4:	e0a2                	sd	s0,64(sp)
    80004ec6:	fc26                	sd	s1,56(sp)
    80004ec8:	f84a                	sd	s2,48(sp)
    80004eca:	f44e                	sd	s3,40(sp)
    80004ecc:	f052                	sd	s4,32(sp)
    80004ece:	ec56                	sd	s5,24(sp)
    80004ed0:	e85a                	sd	s6,16(sp)
    80004ed2:	0880                	addi	s0,sp,80
    80004ed4:	84aa                	mv	s1,a0
    80004ed6:	892e                	mv	s2,a1
    80004ed8:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004eda:	ffffd097          	auipc	ra,0xffffd
    80004ede:	ad2080e7          	jalr	-1326(ra) # 800019ac <myproc>
    80004ee2:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004ee4:	8526                	mv	a0,s1
    80004ee6:	ffffc097          	auipc	ra,0xffffc
    80004eea:	cf0080e7          	jalr	-784(ra) # 80000bd6 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004eee:	2184a703          	lw	a4,536(s1)
    80004ef2:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004ef6:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004efa:	02f71763          	bne	a4,a5,80004f28 <piperead+0x68>
    80004efe:	2244a783          	lw	a5,548(s1)
    80004f02:	c39d                	beqz	a5,80004f28 <piperead+0x68>
    if(killed(pr)){
    80004f04:	8552                	mv	a0,s4
    80004f06:	ffffd097          	auipc	ra,0xffffd
    80004f0a:	62a080e7          	jalr	1578(ra) # 80002530 <killed>
    80004f0e:	e949                	bnez	a0,80004fa0 <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004f10:	85a6                	mv	a1,s1
    80004f12:	854e                	mv	a0,s3
    80004f14:	ffffd097          	auipc	ra,0xffffd
    80004f18:	21c080e7          	jalr	540(ra) # 80002130 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004f1c:	2184a703          	lw	a4,536(s1)
    80004f20:	21c4a783          	lw	a5,540(s1)
    80004f24:	fcf70de3          	beq	a4,a5,80004efe <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004f28:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004f2a:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004f2c:	05505463          	blez	s5,80004f74 <piperead+0xb4>
    if(pi->nread == pi->nwrite)
    80004f30:	2184a783          	lw	a5,536(s1)
    80004f34:	21c4a703          	lw	a4,540(s1)
    80004f38:	02f70e63          	beq	a4,a5,80004f74 <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004f3c:	0017871b          	addiw	a4,a5,1
    80004f40:	20e4ac23          	sw	a4,536(s1)
    80004f44:	1ff7f793          	andi	a5,a5,511
    80004f48:	97a6                	add	a5,a5,s1
    80004f4a:	0187c783          	lbu	a5,24(a5)
    80004f4e:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004f52:	4685                	li	a3,1
    80004f54:	fbf40613          	addi	a2,s0,-65
    80004f58:	85ca                	mv	a1,s2
    80004f5a:	050a3503          	ld	a0,80(s4)
    80004f5e:	ffffc097          	auipc	ra,0xffffc
    80004f62:	70e080e7          	jalr	1806(ra) # 8000166c <copyout>
    80004f66:	01650763          	beq	a0,s6,80004f74 <piperead+0xb4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004f6a:	2985                	addiw	s3,s3,1
    80004f6c:	0905                	addi	s2,s2,1
    80004f6e:	fd3a91e3          	bne	s5,s3,80004f30 <piperead+0x70>
    80004f72:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004f74:	21c48513          	addi	a0,s1,540
    80004f78:	ffffd097          	auipc	ra,0xffffd
    80004f7c:	368080e7          	jalr	872(ra) # 800022e0 <wakeup>
  release(&pi->lock);
    80004f80:	8526                	mv	a0,s1
    80004f82:	ffffc097          	auipc	ra,0xffffc
    80004f86:	d08080e7          	jalr	-760(ra) # 80000c8a <release>
  return i;
}
    80004f8a:	854e                	mv	a0,s3
    80004f8c:	60a6                	ld	ra,72(sp)
    80004f8e:	6406                	ld	s0,64(sp)
    80004f90:	74e2                	ld	s1,56(sp)
    80004f92:	7942                	ld	s2,48(sp)
    80004f94:	79a2                	ld	s3,40(sp)
    80004f96:	7a02                	ld	s4,32(sp)
    80004f98:	6ae2                	ld	s5,24(sp)
    80004f9a:	6b42                	ld	s6,16(sp)
    80004f9c:	6161                	addi	sp,sp,80
    80004f9e:	8082                	ret
      release(&pi->lock);
    80004fa0:	8526                	mv	a0,s1
    80004fa2:	ffffc097          	auipc	ra,0xffffc
    80004fa6:	ce8080e7          	jalr	-792(ra) # 80000c8a <release>
      return -1;
    80004faa:	59fd                	li	s3,-1
    80004fac:	bff9                	j	80004f8a <piperead+0xca>

0000000080004fae <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004fae:	1141                	addi	sp,sp,-16
    80004fb0:	e422                	sd	s0,8(sp)
    80004fb2:	0800                	addi	s0,sp,16
    80004fb4:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004fb6:	8905                	andi	a0,a0,1
    80004fb8:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80004fba:	8b89                	andi	a5,a5,2
    80004fbc:	c399                	beqz	a5,80004fc2 <flags2perm+0x14>
      perm |= PTE_W;
    80004fbe:	00456513          	ori	a0,a0,4
    return perm;
}
    80004fc2:	6422                	ld	s0,8(sp)
    80004fc4:	0141                	addi	sp,sp,16
    80004fc6:	8082                	ret

0000000080004fc8 <exec>:

int
exec(char *path, char **argv)
{
    80004fc8:	de010113          	addi	sp,sp,-544
    80004fcc:	20113c23          	sd	ra,536(sp)
    80004fd0:	20813823          	sd	s0,528(sp)
    80004fd4:	20913423          	sd	s1,520(sp)
    80004fd8:	21213023          	sd	s2,512(sp)
    80004fdc:	ffce                	sd	s3,504(sp)
    80004fde:	fbd2                	sd	s4,496(sp)
    80004fe0:	f7d6                	sd	s5,488(sp)
    80004fe2:	f3da                	sd	s6,480(sp)
    80004fe4:	efde                	sd	s7,472(sp)
    80004fe6:	ebe2                	sd	s8,464(sp)
    80004fe8:	e7e6                	sd	s9,456(sp)
    80004fea:	e3ea                	sd	s10,448(sp)
    80004fec:	ff6e                	sd	s11,440(sp)
    80004fee:	1400                	addi	s0,sp,544
    80004ff0:	892a                	mv	s2,a0
    80004ff2:	dea43423          	sd	a0,-536(s0)
    80004ff6:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004ffa:	ffffd097          	auipc	ra,0xffffd
    80004ffe:	9b2080e7          	jalr	-1614(ra) # 800019ac <myproc>
    80005002:	84aa                	mv	s1,a0

  begin_op();
    80005004:	fffff097          	auipc	ra,0xfffff
    80005008:	482080e7          	jalr	1154(ra) # 80004486 <begin_op>

  if((ip = namei(path)) == 0){
    8000500c:	854a                	mv	a0,s2
    8000500e:	fffff097          	auipc	ra,0xfffff
    80005012:	258080e7          	jalr	600(ra) # 80004266 <namei>
    80005016:	c93d                	beqz	a0,8000508c <exec+0xc4>
    80005018:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    8000501a:	fffff097          	auipc	ra,0xfffff
    8000501e:	aa0080e7          	jalr	-1376(ra) # 80003aba <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80005022:	04000713          	li	a4,64
    80005026:	4681                	li	a3,0
    80005028:	e5040613          	addi	a2,s0,-432
    8000502c:	4581                	li	a1,0
    8000502e:	8556                	mv	a0,s5
    80005030:	fffff097          	auipc	ra,0xfffff
    80005034:	d3e080e7          	jalr	-706(ra) # 80003d6e <readi>
    80005038:	04000793          	li	a5,64
    8000503c:	00f51a63          	bne	a0,a5,80005050 <exec+0x88>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80005040:	e5042703          	lw	a4,-432(s0)
    80005044:	464c47b7          	lui	a5,0x464c4
    80005048:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    8000504c:	04f70663          	beq	a4,a5,80005098 <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80005050:	8556                	mv	a0,s5
    80005052:	fffff097          	auipc	ra,0xfffff
    80005056:	cca080e7          	jalr	-822(ra) # 80003d1c <iunlockput>
    end_op();
    8000505a:	fffff097          	auipc	ra,0xfffff
    8000505e:	4aa080e7          	jalr	1194(ra) # 80004504 <end_op>
  }
  return -1;
    80005062:	557d                	li	a0,-1
}
    80005064:	21813083          	ld	ra,536(sp)
    80005068:	21013403          	ld	s0,528(sp)
    8000506c:	20813483          	ld	s1,520(sp)
    80005070:	20013903          	ld	s2,512(sp)
    80005074:	79fe                	ld	s3,504(sp)
    80005076:	7a5e                	ld	s4,496(sp)
    80005078:	7abe                	ld	s5,488(sp)
    8000507a:	7b1e                	ld	s6,480(sp)
    8000507c:	6bfe                	ld	s7,472(sp)
    8000507e:	6c5e                	ld	s8,464(sp)
    80005080:	6cbe                	ld	s9,456(sp)
    80005082:	6d1e                	ld	s10,448(sp)
    80005084:	7dfa                	ld	s11,440(sp)
    80005086:	22010113          	addi	sp,sp,544
    8000508a:	8082                	ret
    end_op();
    8000508c:	fffff097          	auipc	ra,0xfffff
    80005090:	478080e7          	jalr	1144(ra) # 80004504 <end_op>
    return -1;
    80005094:	557d                	li	a0,-1
    80005096:	b7f9                	j	80005064 <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    80005098:	8526                	mv	a0,s1
    8000509a:	ffffd097          	auipc	ra,0xffffd
    8000509e:	9d6080e7          	jalr	-1578(ra) # 80001a70 <proc_pagetable>
    800050a2:	8b2a                	mv	s6,a0
    800050a4:	d555                	beqz	a0,80005050 <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800050a6:	e7042783          	lw	a5,-400(s0)
    800050aa:	e8845703          	lhu	a4,-376(s0)
    800050ae:	c735                	beqz	a4,8000511a <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800050b0:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800050b2:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    800050b6:	6a05                	lui	s4,0x1
    800050b8:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    800050bc:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    800050c0:	6d85                	lui	s11,0x1
    800050c2:	7d7d                	lui	s10,0xfffff
    800050c4:	ac3d                	j	80005302 <exec+0x33a>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    800050c6:	00003517          	auipc	a0,0x3
    800050ca:	7fa50513          	addi	a0,a0,2042 # 800088c0 <systemCallsNames+0x290>
    800050ce:	ffffb097          	auipc	ra,0xffffb
    800050d2:	472080e7          	jalr	1138(ra) # 80000540 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    800050d6:	874a                	mv	a4,s2
    800050d8:	009c86bb          	addw	a3,s9,s1
    800050dc:	4581                	li	a1,0
    800050de:	8556                	mv	a0,s5
    800050e0:	fffff097          	auipc	ra,0xfffff
    800050e4:	c8e080e7          	jalr	-882(ra) # 80003d6e <readi>
    800050e8:	2501                	sext.w	a0,a0
    800050ea:	1aa91963          	bne	s2,a0,8000529c <exec+0x2d4>
  for(i = 0; i < sz; i += PGSIZE){
    800050ee:	009d84bb          	addw	s1,s11,s1
    800050f2:	013d09bb          	addw	s3,s10,s3
    800050f6:	1f74f663          	bgeu	s1,s7,800052e2 <exec+0x31a>
    pa = walkaddr(pagetable, va + i);
    800050fa:	02049593          	slli	a1,s1,0x20
    800050fe:	9181                	srli	a1,a1,0x20
    80005100:	95e2                	add	a1,a1,s8
    80005102:	855a                	mv	a0,s6
    80005104:	ffffc097          	auipc	ra,0xffffc
    80005108:	f58080e7          	jalr	-168(ra) # 8000105c <walkaddr>
    8000510c:	862a                	mv	a2,a0
    if(pa == 0)
    8000510e:	dd45                	beqz	a0,800050c6 <exec+0xfe>
      n = PGSIZE;
    80005110:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80005112:	fd49f2e3          	bgeu	s3,s4,800050d6 <exec+0x10e>
      n = sz - i;
    80005116:	894e                	mv	s2,s3
    80005118:	bf7d                	j	800050d6 <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    8000511a:	4901                	li	s2,0
  iunlockput(ip);
    8000511c:	8556                	mv	a0,s5
    8000511e:	fffff097          	auipc	ra,0xfffff
    80005122:	bfe080e7          	jalr	-1026(ra) # 80003d1c <iunlockput>
  end_op();
    80005126:	fffff097          	auipc	ra,0xfffff
    8000512a:	3de080e7          	jalr	990(ra) # 80004504 <end_op>
  p = myproc();
    8000512e:	ffffd097          	auipc	ra,0xffffd
    80005132:	87e080e7          	jalr	-1922(ra) # 800019ac <myproc>
    80005136:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80005138:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    8000513c:	6785                	lui	a5,0x1
    8000513e:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80005140:	97ca                	add	a5,a5,s2
    80005142:	777d                	lui	a4,0xfffff
    80005144:	8ff9                	and	a5,a5,a4
    80005146:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    8000514a:	4691                	li	a3,4
    8000514c:	6609                	lui	a2,0x2
    8000514e:	963e                	add	a2,a2,a5
    80005150:	85be                	mv	a1,a5
    80005152:	855a                	mv	a0,s6
    80005154:	ffffc097          	auipc	ra,0xffffc
    80005158:	2bc080e7          	jalr	700(ra) # 80001410 <uvmalloc>
    8000515c:	8c2a                	mv	s8,a0
  ip = 0;
    8000515e:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80005160:	12050e63          	beqz	a0,8000529c <exec+0x2d4>
  uvmclear(pagetable, sz-2*PGSIZE);
    80005164:	75f9                	lui	a1,0xffffe
    80005166:	95aa                	add	a1,a1,a0
    80005168:	855a                	mv	a0,s6
    8000516a:	ffffc097          	auipc	ra,0xffffc
    8000516e:	4d0080e7          	jalr	1232(ra) # 8000163a <uvmclear>
  stackbase = sp - PGSIZE;
    80005172:	7afd                	lui	s5,0xfffff
    80005174:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    80005176:	df043783          	ld	a5,-528(s0)
    8000517a:	6388                	ld	a0,0(a5)
    8000517c:	c925                	beqz	a0,800051ec <exec+0x224>
    8000517e:	e9040993          	addi	s3,s0,-368
    80005182:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    80005186:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80005188:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    8000518a:	ffffc097          	auipc	ra,0xffffc
    8000518e:	cc4080e7          	jalr	-828(ra) # 80000e4e <strlen>
    80005192:	0015079b          	addiw	a5,a0,1
    80005196:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    8000519a:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    8000519e:	13596663          	bltu	s2,s5,800052ca <exec+0x302>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800051a2:	df043d83          	ld	s11,-528(s0)
    800051a6:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    800051aa:	8552                	mv	a0,s4
    800051ac:	ffffc097          	auipc	ra,0xffffc
    800051b0:	ca2080e7          	jalr	-862(ra) # 80000e4e <strlen>
    800051b4:	0015069b          	addiw	a3,a0,1
    800051b8:	8652                	mv	a2,s4
    800051ba:	85ca                	mv	a1,s2
    800051bc:	855a                	mv	a0,s6
    800051be:	ffffc097          	auipc	ra,0xffffc
    800051c2:	4ae080e7          	jalr	1198(ra) # 8000166c <copyout>
    800051c6:	10054663          	bltz	a0,800052d2 <exec+0x30a>
    ustack[argc] = sp;
    800051ca:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800051ce:	0485                	addi	s1,s1,1
    800051d0:	008d8793          	addi	a5,s11,8
    800051d4:	def43823          	sd	a5,-528(s0)
    800051d8:	008db503          	ld	a0,8(s11)
    800051dc:	c911                	beqz	a0,800051f0 <exec+0x228>
    if(argc >= MAXARG)
    800051de:	09a1                	addi	s3,s3,8
    800051e0:	fb3c95e3          	bne	s9,s3,8000518a <exec+0x1c2>
  sz = sz1;
    800051e4:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800051e8:	4a81                	li	s5,0
    800051ea:	a84d                	j	8000529c <exec+0x2d4>
  sp = sz;
    800051ec:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    800051ee:	4481                	li	s1,0
  ustack[argc] = 0;
    800051f0:	00349793          	slli	a5,s1,0x3
    800051f4:	f9078793          	addi	a5,a5,-112
    800051f8:	97a2                	add	a5,a5,s0
    800051fa:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    800051fe:	00148693          	addi	a3,s1,1
    80005202:	068e                	slli	a3,a3,0x3
    80005204:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005208:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    8000520c:	01597663          	bgeu	s2,s5,80005218 <exec+0x250>
  sz = sz1;
    80005210:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005214:	4a81                	li	s5,0
    80005216:	a059                	j	8000529c <exec+0x2d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005218:	e9040613          	addi	a2,s0,-368
    8000521c:	85ca                	mv	a1,s2
    8000521e:	855a                	mv	a0,s6
    80005220:	ffffc097          	auipc	ra,0xffffc
    80005224:	44c080e7          	jalr	1100(ra) # 8000166c <copyout>
    80005228:	0a054963          	bltz	a0,800052da <exec+0x312>
  p->trapframe->a1 = sp;
    8000522c:	058bb783          	ld	a5,88(s7)
    80005230:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005234:	de843783          	ld	a5,-536(s0)
    80005238:	0007c703          	lbu	a4,0(a5)
    8000523c:	cf11                	beqz	a4,80005258 <exec+0x290>
    8000523e:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005240:	02f00693          	li	a3,47
    80005244:	a039                	j	80005252 <exec+0x28a>
      last = s+1;
    80005246:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    8000524a:	0785                	addi	a5,a5,1
    8000524c:	fff7c703          	lbu	a4,-1(a5)
    80005250:	c701                	beqz	a4,80005258 <exec+0x290>
    if(*s == '/')
    80005252:	fed71ce3          	bne	a4,a3,8000524a <exec+0x282>
    80005256:	bfc5                	j	80005246 <exec+0x27e>
  safestrcpy(p->name, last, sizeof(p->name));
    80005258:	4641                	li	a2,16
    8000525a:	de843583          	ld	a1,-536(s0)
    8000525e:	158b8513          	addi	a0,s7,344
    80005262:	ffffc097          	auipc	ra,0xffffc
    80005266:	bba080e7          	jalr	-1094(ra) # 80000e1c <safestrcpy>
  oldpagetable = p->pagetable;
    8000526a:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    8000526e:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    80005272:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80005276:	058bb783          	ld	a5,88(s7)
    8000527a:	e6843703          	ld	a4,-408(s0)
    8000527e:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80005280:	058bb783          	ld	a5,88(s7)
    80005284:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80005288:	85ea                	mv	a1,s10
    8000528a:	ffffd097          	auipc	ra,0xffffd
    8000528e:	882080e7          	jalr	-1918(ra) # 80001b0c <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005292:	0004851b          	sext.w	a0,s1
    80005296:	b3f9                	j	80005064 <exec+0x9c>
    80005298:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    8000529c:	df843583          	ld	a1,-520(s0)
    800052a0:	855a                	mv	a0,s6
    800052a2:	ffffd097          	auipc	ra,0xffffd
    800052a6:	86a080e7          	jalr	-1942(ra) # 80001b0c <proc_freepagetable>
  if(ip){
    800052aa:	da0a93e3          	bnez	s5,80005050 <exec+0x88>
  return -1;
    800052ae:	557d                	li	a0,-1
    800052b0:	bb55                	j	80005064 <exec+0x9c>
    800052b2:	df243c23          	sd	s2,-520(s0)
    800052b6:	b7dd                	j	8000529c <exec+0x2d4>
    800052b8:	df243c23          	sd	s2,-520(s0)
    800052bc:	b7c5                	j	8000529c <exec+0x2d4>
    800052be:	df243c23          	sd	s2,-520(s0)
    800052c2:	bfe9                	j	8000529c <exec+0x2d4>
    800052c4:	df243c23          	sd	s2,-520(s0)
    800052c8:	bfd1                	j	8000529c <exec+0x2d4>
  sz = sz1;
    800052ca:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800052ce:	4a81                	li	s5,0
    800052d0:	b7f1                	j	8000529c <exec+0x2d4>
  sz = sz1;
    800052d2:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800052d6:	4a81                	li	s5,0
    800052d8:	b7d1                	j	8000529c <exec+0x2d4>
  sz = sz1;
    800052da:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800052de:	4a81                	li	s5,0
    800052e0:	bf75                	j	8000529c <exec+0x2d4>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800052e2:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800052e6:	e0843783          	ld	a5,-504(s0)
    800052ea:	0017869b          	addiw	a3,a5,1
    800052ee:	e0d43423          	sd	a3,-504(s0)
    800052f2:	e0043783          	ld	a5,-512(s0)
    800052f6:	0387879b          	addiw	a5,a5,56
    800052fa:	e8845703          	lhu	a4,-376(s0)
    800052fe:	e0e6dfe3          	bge	a3,a4,8000511c <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005302:	2781                	sext.w	a5,a5
    80005304:	e0f43023          	sd	a5,-512(s0)
    80005308:	03800713          	li	a4,56
    8000530c:	86be                	mv	a3,a5
    8000530e:	e1840613          	addi	a2,s0,-488
    80005312:	4581                	li	a1,0
    80005314:	8556                	mv	a0,s5
    80005316:	fffff097          	auipc	ra,0xfffff
    8000531a:	a58080e7          	jalr	-1448(ra) # 80003d6e <readi>
    8000531e:	03800793          	li	a5,56
    80005322:	f6f51be3          	bne	a0,a5,80005298 <exec+0x2d0>
    if(ph.type != ELF_PROG_LOAD)
    80005326:	e1842783          	lw	a5,-488(s0)
    8000532a:	4705                	li	a4,1
    8000532c:	fae79de3          	bne	a5,a4,800052e6 <exec+0x31e>
    if(ph.memsz < ph.filesz)
    80005330:	e4043483          	ld	s1,-448(s0)
    80005334:	e3843783          	ld	a5,-456(s0)
    80005338:	f6f4ede3          	bltu	s1,a5,800052b2 <exec+0x2ea>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    8000533c:	e2843783          	ld	a5,-472(s0)
    80005340:	94be                	add	s1,s1,a5
    80005342:	f6f4ebe3          	bltu	s1,a5,800052b8 <exec+0x2f0>
    if(ph.vaddr % PGSIZE != 0)
    80005346:	de043703          	ld	a4,-544(s0)
    8000534a:	8ff9                	and	a5,a5,a4
    8000534c:	fbad                	bnez	a5,800052be <exec+0x2f6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    8000534e:	e1c42503          	lw	a0,-484(s0)
    80005352:	00000097          	auipc	ra,0x0
    80005356:	c5c080e7          	jalr	-932(ra) # 80004fae <flags2perm>
    8000535a:	86aa                	mv	a3,a0
    8000535c:	8626                	mv	a2,s1
    8000535e:	85ca                	mv	a1,s2
    80005360:	855a                	mv	a0,s6
    80005362:	ffffc097          	auipc	ra,0xffffc
    80005366:	0ae080e7          	jalr	174(ra) # 80001410 <uvmalloc>
    8000536a:	dea43c23          	sd	a0,-520(s0)
    8000536e:	d939                	beqz	a0,800052c4 <exec+0x2fc>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005370:	e2843c03          	ld	s8,-472(s0)
    80005374:	e2042c83          	lw	s9,-480(s0)
    80005378:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    8000537c:	f60b83e3          	beqz	s7,800052e2 <exec+0x31a>
    80005380:	89de                	mv	s3,s7
    80005382:	4481                	li	s1,0
    80005384:	bb9d                	j	800050fa <exec+0x132>

0000000080005386 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005386:	7179                	addi	sp,sp,-48
    80005388:	f406                	sd	ra,40(sp)
    8000538a:	f022                	sd	s0,32(sp)
    8000538c:	ec26                	sd	s1,24(sp)
    8000538e:	e84a                	sd	s2,16(sp)
    80005390:	1800                	addi	s0,sp,48
    80005392:	892e                	mv	s2,a1
    80005394:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80005396:	fdc40593          	addi	a1,s0,-36
    8000539a:	ffffe097          	auipc	ra,0xffffe
    8000539e:	99c080e7          	jalr	-1636(ra) # 80002d36 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800053a2:	fdc42703          	lw	a4,-36(s0)
    800053a6:	47bd                	li	a5,15
    800053a8:	02e7eb63          	bltu	a5,a4,800053de <argfd+0x58>
    800053ac:	ffffc097          	auipc	ra,0xffffc
    800053b0:	600080e7          	jalr	1536(ra) # 800019ac <myproc>
    800053b4:	fdc42703          	lw	a4,-36(s0)
    800053b8:	01a70793          	addi	a5,a4,26 # fffffffffffff01a <end+0xffffffff7ffdc86a>
    800053bc:	078e                	slli	a5,a5,0x3
    800053be:	953e                	add	a0,a0,a5
    800053c0:	611c                	ld	a5,0(a0)
    800053c2:	c385                	beqz	a5,800053e2 <argfd+0x5c>
    return -1;
  if(pfd)
    800053c4:	00090463          	beqz	s2,800053cc <argfd+0x46>
    *pfd = fd;
    800053c8:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800053cc:	4501                	li	a0,0
  if(pf)
    800053ce:	c091                	beqz	s1,800053d2 <argfd+0x4c>
    *pf = f;
    800053d0:	e09c                	sd	a5,0(s1)
}
    800053d2:	70a2                	ld	ra,40(sp)
    800053d4:	7402                	ld	s0,32(sp)
    800053d6:	64e2                	ld	s1,24(sp)
    800053d8:	6942                	ld	s2,16(sp)
    800053da:	6145                	addi	sp,sp,48
    800053dc:	8082                	ret
    return -1;
    800053de:	557d                	li	a0,-1
    800053e0:	bfcd                	j	800053d2 <argfd+0x4c>
    800053e2:	557d                	li	a0,-1
    800053e4:	b7fd                	j	800053d2 <argfd+0x4c>

00000000800053e6 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800053e6:	1101                	addi	sp,sp,-32
    800053e8:	ec06                	sd	ra,24(sp)
    800053ea:	e822                	sd	s0,16(sp)
    800053ec:	e426                	sd	s1,8(sp)
    800053ee:	1000                	addi	s0,sp,32
    800053f0:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800053f2:	ffffc097          	auipc	ra,0xffffc
    800053f6:	5ba080e7          	jalr	1466(ra) # 800019ac <myproc>
    800053fa:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800053fc:	0d050793          	addi	a5,a0,208
    80005400:	4501                	li	a0,0
    80005402:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005404:	6398                	ld	a4,0(a5)
    80005406:	cb19                	beqz	a4,8000541c <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005408:	2505                	addiw	a0,a0,1
    8000540a:	07a1                	addi	a5,a5,8
    8000540c:	fed51ce3          	bne	a0,a3,80005404 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005410:	557d                	li	a0,-1
}
    80005412:	60e2                	ld	ra,24(sp)
    80005414:	6442                	ld	s0,16(sp)
    80005416:	64a2                	ld	s1,8(sp)
    80005418:	6105                	addi	sp,sp,32
    8000541a:	8082                	ret
      p->ofile[fd] = f;
    8000541c:	01a50793          	addi	a5,a0,26
    80005420:	078e                	slli	a5,a5,0x3
    80005422:	963e                	add	a2,a2,a5
    80005424:	e204                	sd	s1,0(a2)
      return fd;
    80005426:	b7f5                	j	80005412 <fdalloc+0x2c>

0000000080005428 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005428:	715d                	addi	sp,sp,-80
    8000542a:	e486                	sd	ra,72(sp)
    8000542c:	e0a2                	sd	s0,64(sp)
    8000542e:	fc26                	sd	s1,56(sp)
    80005430:	f84a                	sd	s2,48(sp)
    80005432:	f44e                	sd	s3,40(sp)
    80005434:	f052                	sd	s4,32(sp)
    80005436:	ec56                	sd	s5,24(sp)
    80005438:	e85a                	sd	s6,16(sp)
    8000543a:	0880                	addi	s0,sp,80
    8000543c:	8b2e                	mv	s6,a1
    8000543e:	89b2                	mv	s3,a2
    80005440:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005442:	fb040593          	addi	a1,s0,-80
    80005446:	fffff097          	auipc	ra,0xfffff
    8000544a:	e3e080e7          	jalr	-450(ra) # 80004284 <nameiparent>
    8000544e:	84aa                	mv	s1,a0
    80005450:	14050f63          	beqz	a0,800055ae <create+0x186>
    return 0;

  ilock(dp);
    80005454:	ffffe097          	auipc	ra,0xffffe
    80005458:	666080e7          	jalr	1638(ra) # 80003aba <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    8000545c:	4601                	li	a2,0
    8000545e:	fb040593          	addi	a1,s0,-80
    80005462:	8526                	mv	a0,s1
    80005464:	fffff097          	auipc	ra,0xfffff
    80005468:	b3a080e7          	jalr	-1222(ra) # 80003f9e <dirlookup>
    8000546c:	8aaa                	mv	s5,a0
    8000546e:	c931                	beqz	a0,800054c2 <create+0x9a>
    iunlockput(dp);
    80005470:	8526                	mv	a0,s1
    80005472:	fffff097          	auipc	ra,0xfffff
    80005476:	8aa080e7          	jalr	-1878(ra) # 80003d1c <iunlockput>
    ilock(ip);
    8000547a:	8556                	mv	a0,s5
    8000547c:	ffffe097          	auipc	ra,0xffffe
    80005480:	63e080e7          	jalr	1598(ra) # 80003aba <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005484:	000b059b          	sext.w	a1,s6
    80005488:	4789                	li	a5,2
    8000548a:	02f59563          	bne	a1,a5,800054b4 <create+0x8c>
    8000548e:	044ad783          	lhu	a5,68(s5) # fffffffffffff044 <end+0xffffffff7ffdc894>
    80005492:	37f9                	addiw	a5,a5,-2
    80005494:	17c2                	slli	a5,a5,0x30
    80005496:	93c1                	srli	a5,a5,0x30
    80005498:	4705                	li	a4,1
    8000549a:	00f76d63          	bltu	a4,a5,800054b4 <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    8000549e:	8556                	mv	a0,s5
    800054a0:	60a6                	ld	ra,72(sp)
    800054a2:	6406                	ld	s0,64(sp)
    800054a4:	74e2                	ld	s1,56(sp)
    800054a6:	7942                	ld	s2,48(sp)
    800054a8:	79a2                	ld	s3,40(sp)
    800054aa:	7a02                	ld	s4,32(sp)
    800054ac:	6ae2                	ld	s5,24(sp)
    800054ae:	6b42                	ld	s6,16(sp)
    800054b0:	6161                	addi	sp,sp,80
    800054b2:	8082                	ret
    iunlockput(ip);
    800054b4:	8556                	mv	a0,s5
    800054b6:	fffff097          	auipc	ra,0xfffff
    800054ba:	866080e7          	jalr	-1946(ra) # 80003d1c <iunlockput>
    return 0;
    800054be:	4a81                	li	s5,0
    800054c0:	bff9                	j	8000549e <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    800054c2:	85da                	mv	a1,s6
    800054c4:	4088                	lw	a0,0(s1)
    800054c6:	ffffe097          	auipc	ra,0xffffe
    800054ca:	456080e7          	jalr	1110(ra) # 8000391c <ialloc>
    800054ce:	8a2a                	mv	s4,a0
    800054d0:	c539                	beqz	a0,8000551e <create+0xf6>
  ilock(ip);
    800054d2:	ffffe097          	auipc	ra,0xffffe
    800054d6:	5e8080e7          	jalr	1512(ra) # 80003aba <ilock>
  ip->major = major;
    800054da:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    800054de:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    800054e2:	4905                	li	s2,1
    800054e4:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    800054e8:	8552                	mv	a0,s4
    800054ea:	ffffe097          	auipc	ra,0xffffe
    800054ee:	504080e7          	jalr	1284(ra) # 800039ee <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800054f2:	000b059b          	sext.w	a1,s6
    800054f6:	03258b63          	beq	a1,s2,8000552c <create+0x104>
  if(dirlink(dp, name, ip->inum) < 0)
    800054fa:	004a2603          	lw	a2,4(s4)
    800054fe:	fb040593          	addi	a1,s0,-80
    80005502:	8526                	mv	a0,s1
    80005504:	fffff097          	auipc	ra,0xfffff
    80005508:	cb0080e7          	jalr	-848(ra) # 800041b4 <dirlink>
    8000550c:	06054f63          	bltz	a0,8000558a <create+0x162>
  iunlockput(dp);
    80005510:	8526                	mv	a0,s1
    80005512:	fffff097          	auipc	ra,0xfffff
    80005516:	80a080e7          	jalr	-2038(ra) # 80003d1c <iunlockput>
  return ip;
    8000551a:	8ad2                	mv	s5,s4
    8000551c:	b749                	j	8000549e <create+0x76>
    iunlockput(dp);
    8000551e:	8526                	mv	a0,s1
    80005520:	ffffe097          	auipc	ra,0xffffe
    80005524:	7fc080e7          	jalr	2044(ra) # 80003d1c <iunlockput>
    return 0;
    80005528:	8ad2                	mv	s5,s4
    8000552a:	bf95                	j	8000549e <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    8000552c:	004a2603          	lw	a2,4(s4)
    80005530:	00003597          	auipc	a1,0x3
    80005534:	3b058593          	addi	a1,a1,944 # 800088e0 <systemCallsNames+0x2b0>
    80005538:	8552                	mv	a0,s4
    8000553a:	fffff097          	auipc	ra,0xfffff
    8000553e:	c7a080e7          	jalr	-902(ra) # 800041b4 <dirlink>
    80005542:	04054463          	bltz	a0,8000558a <create+0x162>
    80005546:	40d0                	lw	a2,4(s1)
    80005548:	00003597          	auipc	a1,0x3
    8000554c:	3a058593          	addi	a1,a1,928 # 800088e8 <systemCallsNames+0x2b8>
    80005550:	8552                	mv	a0,s4
    80005552:	fffff097          	auipc	ra,0xfffff
    80005556:	c62080e7          	jalr	-926(ra) # 800041b4 <dirlink>
    8000555a:	02054863          	bltz	a0,8000558a <create+0x162>
  if(dirlink(dp, name, ip->inum) < 0)
    8000555e:	004a2603          	lw	a2,4(s4)
    80005562:	fb040593          	addi	a1,s0,-80
    80005566:	8526                	mv	a0,s1
    80005568:	fffff097          	auipc	ra,0xfffff
    8000556c:	c4c080e7          	jalr	-948(ra) # 800041b4 <dirlink>
    80005570:	00054d63          	bltz	a0,8000558a <create+0x162>
    dp->nlink++;  // for ".."
    80005574:	04a4d783          	lhu	a5,74(s1)
    80005578:	2785                	addiw	a5,a5,1
    8000557a:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000557e:	8526                	mv	a0,s1
    80005580:	ffffe097          	auipc	ra,0xffffe
    80005584:	46e080e7          	jalr	1134(ra) # 800039ee <iupdate>
    80005588:	b761                	j	80005510 <create+0xe8>
  ip->nlink = 0;
    8000558a:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    8000558e:	8552                	mv	a0,s4
    80005590:	ffffe097          	auipc	ra,0xffffe
    80005594:	45e080e7          	jalr	1118(ra) # 800039ee <iupdate>
  iunlockput(ip);
    80005598:	8552                	mv	a0,s4
    8000559a:	ffffe097          	auipc	ra,0xffffe
    8000559e:	782080e7          	jalr	1922(ra) # 80003d1c <iunlockput>
  iunlockput(dp);
    800055a2:	8526                	mv	a0,s1
    800055a4:	ffffe097          	auipc	ra,0xffffe
    800055a8:	778080e7          	jalr	1912(ra) # 80003d1c <iunlockput>
  return 0;
    800055ac:	bdcd                	j	8000549e <create+0x76>
    return 0;
    800055ae:	8aaa                	mv	s5,a0
    800055b0:	b5fd                	j	8000549e <create+0x76>

00000000800055b2 <sys_dup>:
{
    800055b2:	7179                	addi	sp,sp,-48
    800055b4:	f406                	sd	ra,40(sp)
    800055b6:	f022                	sd	s0,32(sp)
    800055b8:	ec26                	sd	s1,24(sp)
    800055ba:	e84a                	sd	s2,16(sp)
    800055bc:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800055be:	fd840613          	addi	a2,s0,-40
    800055c2:	4581                	li	a1,0
    800055c4:	4501                	li	a0,0
    800055c6:	00000097          	auipc	ra,0x0
    800055ca:	dc0080e7          	jalr	-576(ra) # 80005386 <argfd>
    return -1;
    800055ce:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800055d0:	02054363          	bltz	a0,800055f6 <sys_dup+0x44>
  if((fd=fdalloc(f)) < 0)
    800055d4:	fd843903          	ld	s2,-40(s0)
    800055d8:	854a                	mv	a0,s2
    800055da:	00000097          	auipc	ra,0x0
    800055de:	e0c080e7          	jalr	-500(ra) # 800053e6 <fdalloc>
    800055e2:	84aa                	mv	s1,a0
    return -1;
    800055e4:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800055e6:	00054863          	bltz	a0,800055f6 <sys_dup+0x44>
  filedup(f);
    800055ea:	854a                	mv	a0,s2
    800055ec:	fffff097          	auipc	ra,0xfffff
    800055f0:	310080e7          	jalr	784(ra) # 800048fc <filedup>
  return fd;
    800055f4:	87a6                	mv	a5,s1
}
    800055f6:	853e                	mv	a0,a5
    800055f8:	70a2                	ld	ra,40(sp)
    800055fa:	7402                	ld	s0,32(sp)
    800055fc:	64e2                	ld	s1,24(sp)
    800055fe:	6942                	ld	s2,16(sp)
    80005600:	6145                	addi	sp,sp,48
    80005602:	8082                	ret

0000000080005604 <sys_read>:
{
    80005604:	7179                	addi	sp,sp,-48
    80005606:	f406                	sd	ra,40(sp)
    80005608:	f022                	sd	s0,32(sp)
    8000560a:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    8000560c:	fd840593          	addi	a1,s0,-40
    80005610:	4505                	li	a0,1
    80005612:	ffffd097          	auipc	ra,0xffffd
    80005616:	746080e7          	jalr	1862(ra) # 80002d58 <argaddr>
  argint(2, &n);
    8000561a:	fe440593          	addi	a1,s0,-28
    8000561e:	4509                	li	a0,2
    80005620:	ffffd097          	auipc	ra,0xffffd
    80005624:	716080e7          	jalr	1814(ra) # 80002d36 <argint>
  if(argfd(0, 0, &f) < 0)
    80005628:	fe840613          	addi	a2,s0,-24
    8000562c:	4581                	li	a1,0
    8000562e:	4501                	li	a0,0
    80005630:	00000097          	auipc	ra,0x0
    80005634:	d56080e7          	jalr	-682(ra) # 80005386 <argfd>
    80005638:	87aa                	mv	a5,a0
    return -1;
    8000563a:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000563c:	0007cc63          	bltz	a5,80005654 <sys_read+0x50>
  return fileread(f, p, n);
    80005640:	fe442603          	lw	a2,-28(s0)
    80005644:	fd843583          	ld	a1,-40(s0)
    80005648:	fe843503          	ld	a0,-24(s0)
    8000564c:	fffff097          	auipc	ra,0xfffff
    80005650:	43c080e7          	jalr	1084(ra) # 80004a88 <fileread>
}
    80005654:	70a2                	ld	ra,40(sp)
    80005656:	7402                	ld	s0,32(sp)
    80005658:	6145                	addi	sp,sp,48
    8000565a:	8082                	ret

000000008000565c <sys_write>:
{
    8000565c:	7179                	addi	sp,sp,-48
    8000565e:	f406                	sd	ra,40(sp)
    80005660:	f022                	sd	s0,32(sp)
    80005662:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005664:	fd840593          	addi	a1,s0,-40
    80005668:	4505                	li	a0,1
    8000566a:	ffffd097          	auipc	ra,0xffffd
    8000566e:	6ee080e7          	jalr	1774(ra) # 80002d58 <argaddr>
  argint(2, &n);
    80005672:	fe440593          	addi	a1,s0,-28
    80005676:	4509                	li	a0,2
    80005678:	ffffd097          	auipc	ra,0xffffd
    8000567c:	6be080e7          	jalr	1726(ra) # 80002d36 <argint>
  if(argfd(0, 0, &f) < 0)
    80005680:	fe840613          	addi	a2,s0,-24
    80005684:	4581                	li	a1,0
    80005686:	4501                	li	a0,0
    80005688:	00000097          	auipc	ra,0x0
    8000568c:	cfe080e7          	jalr	-770(ra) # 80005386 <argfd>
    80005690:	87aa                	mv	a5,a0
    return -1;
    80005692:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005694:	0007cc63          	bltz	a5,800056ac <sys_write+0x50>
  return filewrite(f, p, n);
    80005698:	fe442603          	lw	a2,-28(s0)
    8000569c:	fd843583          	ld	a1,-40(s0)
    800056a0:	fe843503          	ld	a0,-24(s0)
    800056a4:	fffff097          	auipc	ra,0xfffff
    800056a8:	4a6080e7          	jalr	1190(ra) # 80004b4a <filewrite>
}
    800056ac:	70a2                	ld	ra,40(sp)
    800056ae:	7402                	ld	s0,32(sp)
    800056b0:	6145                	addi	sp,sp,48
    800056b2:	8082                	ret

00000000800056b4 <sys_close>:
{
    800056b4:	1101                	addi	sp,sp,-32
    800056b6:	ec06                	sd	ra,24(sp)
    800056b8:	e822                	sd	s0,16(sp)
    800056ba:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800056bc:	fe040613          	addi	a2,s0,-32
    800056c0:	fec40593          	addi	a1,s0,-20
    800056c4:	4501                	li	a0,0
    800056c6:	00000097          	auipc	ra,0x0
    800056ca:	cc0080e7          	jalr	-832(ra) # 80005386 <argfd>
    return -1;
    800056ce:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800056d0:	02054463          	bltz	a0,800056f8 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    800056d4:	ffffc097          	auipc	ra,0xffffc
    800056d8:	2d8080e7          	jalr	728(ra) # 800019ac <myproc>
    800056dc:	fec42783          	lw	a5,-20(s0)
    800056e0:	07e9                	addi	a5,a5,26
    800056e2:	078e                	slli	a5,a5,0x3
    800056e4:	953e                	add	a0,a0,a5
    800056e6:	00053023          	sd	zero,0(a0)
  fileclose(f);
    800056ea:	fe043503          	ld	a0,-32(s0)
    800056ee:	fffff097          	auipc	ra,0xfffff
    800056f2:	260080e7          	jalr	608(ra) # 8000494e <fileclose>
  return 0;
    800056f6:	4781                	li	a5,0
}
    800056f8:	853e                	mv	a0,a5
    800056fa:	60e2                	ld	ra,24(sp)
    800056fc:	6442                	ld	s0,16(sp)
    800056fe:	6105                	addi	sp,sp,32
    80005700:	8082                	ret

0000000080005702 <sys_fstat>:
{
    80005702:	1101                	addi	sp,sp,-32
    80005704:	ec06                	sd	ra,24(sp)
    80005706:	e822                	sd	s0,16(sp)
    80005708:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    8000570a:	fe040593          	addi	a1,s0,-32
    8000570e:	4505                	li	a0,1
    80005710:	ffffd097          	auipc	ra,0xffffd
    80005714:	648080e7          	jalr	1608(ra) # 80002d58 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80005718:	fe840613          	addi	a2,s0,-24
    8000571c:	4581                	li	a1,0
    8000571e:	4501                	li	a0,0
    80005720:	00000097          	auipc	ra,0x0
    80005724:	c66080e7          	jalr	-922(ra) # 80005386 <argfd>
    80005728:	87aa                	mv	a5,a0
    return -1;
    8000572a:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000572c:	0007ca63          	bltz	a5,80005740 <sys_fstat+0x3e>
  return filestat(f, st);
    80005730:	fe043583          	ld	a1,-32(s0)
    80005734:	fe843503          	ld	a0,-24(s0)
    80005738:	fffff097          	auipc	ra,0xfffff
    8000573c:	2de080e7          	jalr	734(ra) # 80004a16 <filestat>
}
    80005740:	60e2                	ld	ra,24(sp)
    80005742:	6442                	ld	s0,16(sp)
    80005744:	6105                	addi	sp,sp,32
    80005746:	8082                	ret

0000000080005748 <sys_link>:
{
    80005748:	7169                	addi	sp,sp,-304
    8000574a:	f606                	sd	ra,296(sp)
    8000574c:	f222                	sd	s0,288(sp)
    8000574e:	ee26                	sd	s1,280(sp)
    80005750:	ea4a                	sd	s2,272(sp)
    80005752:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005754:	08000613          	li	a2,128
    80005758:	ed040593          	addi	a1,s0,-304
    8000575c:	4501                	li	a0,0
    8000575e:	ffffd097          	auipc	ra,0xffffd
    80005762:	61c080e7          	jalr	1564(ra) # 80002d7a <argstr>
    return -1;
    80005766:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005768:	10054e63          	bltz	a0,80005884 <sys_link+0x13c>
    8000576c:	08000613          	li	a2,128
    80005770:	f5040593          	addi	a1,s0,-176
    80005774:	4505                	li	a0,1
    80005776:	ffffd097          	auipc	ra,0xffffd
    8000577a:	604080e7          	jalr	1540(ra) # 80002d7a <argstr>
    return -1;
    8000577e:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005780:	10054263          	bltz	a0,80005884 <sys_link+0x13c>
  begin_op();
    80005784:	fffff097          	auipc	ra,0xfffff
    80005788:	d02080e7          	jalr	-766(ra) # 80004486 <begin_op>
  if((ip = namei(old)) == 0){
    8000578c:	ed040513          	addi	a0,s0,-304
    80005790:	fffff097          	auipc	ra,0xfffff
    80005794:	ad6080e7          	jalr	-1322(ra) # 80004266 <namei>
    80005798:	84aa                	mv	s1,a0
    8000579a:	c551                	beqz	a0,80005826 <sys_link+0xde>
  ilock(ip);
    8000579c:	ffffe097          	auipc	ra,0xffffe
    800057a0:	31e080e7          	jalr	798(ra) # 80003aba <ilock>
  if(ip->type == T_DIR){
    800057a4:	04449703          	lh	a4,68(s1)
    800057a8:	4785                	li	a5,1
    800057aa:	08f70463          	beq	a4,a5,80005832 <sys_link+0xea>
  ip->nlink++;
    800057ae:	04a4d783          	lhu	a5,74(s1)
    800057b2:	2785                	addiw	a5,a5,1
    800057b4:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800057b8:	8526                	mv	a0,s1
    800057ba:	ffffe097          	auipc	ra,0xffffe
    800057be:	234080e7          	jalr	564(ra) # 800039ee <iupdate>
  iunlock(ip);
    800057c2:	8526                	mv	a0,s1
    800057c4:	ffffe097          	auipc	ra,0xffffe
    800057c8:	3b8080e7          	jalr	952(ra) # 80003b7c <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800057cc:	fd040593          	addi	a1,s0,-48
    800057d0:	f5040513          	addi	a0,s0,-176
    800057d4:	fffff097          	auipc	ra,0xfffff
    800057d8:	ab0080e7          	jalr	-1360(ra) # 80004284 <nameiparent>
    800057dc:	892a                	mv	s2,a0
    800057de:	c935                	beqz	a0,80005852 <sys_link+0x10a>
  ilock(dp);
    800057e0:	ffffe097          	auipc	ra,0xffffe
    800057e4:	2da080e7          	jalr	730(ra) # 80003aba <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800057e8:	00092703          	lw	a4,0(s2)
    800057ec:	409c                	lw	a5,0(s1)
    800057ee:	04f71d63          	bne	a4,a5,80005848 <sys_link+0x100>
    800057f2:	40d0                	lw	a2,4(s1)
    800057f4:	fd040593          	addi	a1,s0,-48
    800057f8:	854a                	mv	a0,s2
    800057fa:	fffff097          	auipc	ra,0xfffff
    800057fe:	9ba080e7          	jalr	-1606(ra) # 800041b4 <dirlink>
    80005802:	04054363          	bltz	a0,80005848 <sys_link+0x100>
  iunlockput(dp);
    80005806:	854a                	mv	a0,s2
    80005808:	ffffe097          	auipc	ra,0xffffe
    8000580c:	514080e7          	jalr	1300(ra) # 80003d1c <iunlockput>
  iput(ip);
    80005810:	8526                	mv	a0,s1
    80005812:	ffffe097          	auipc	ra,0xffffe
    80005816:	462080e7          	jalr	1122(ra) # 80003c74 <iput>
  end_op();
    8000581a:	fffff097          	auipc	ra,0xfffff
    8000581e:	cea080e7          	jalr	-790(ra) # 80004504 <end_op>
  return 0;
    80005822:	4781                	li	a5,0
    80005824:	a085                	j	80005884 <sys_link+0x13c>
    end_op();
    80005826:	fffff097          	auipc	ra,0xfffff
    8000582a:	cde080e7          	jalr	-802(ra) # 80004504 <end_op>
    return -1;
    8000582e:	57fd                	li	a5,-1
    80005830:	a891                	j	80005884 <sys_link+0x13c>
    iunlockput(ip);
    80005832:	8526                	mv	a0,s1
    80005834:	ffffe097          	auipc	ra,0xffffe
    80005838:	4e8080e7          	jalr	1256(ra) # 80003d1c <iunlockput>
    end_op();
    8000583c:	fffff097          	auipc	ra,0xfffff
    80005840:	cc8080e7          	jalr	-824(ra) # 80004504 <end_op>
    return -1;
    80005844:	57fd                	li	a5,-1
    80005846:	a83d                	j	80005884 <sys_link+0x13c>
    iunlockput(dp);
    80005848:	854a                	mv	a0,s2
    8000584a:	ffffe097          	auipc	ra,0xffffe
    8000584e:	4d2080e7          	jalr	1234(ra) # 80003d1c <iunlockput>
  ilock(ip);
    80005852:	8526                	mv	a0,s1
    80005854:	ffffe097          	auipc	ra,0xffffe
    80005858:	266080e7          	jalr	614(ra) # 80003aba <ilock>
  ip->nlink--;
    8000585c:	04a4d783          	lhu	a5,74(s1)
    80005860:	37fd                	addiw	a5,a5,-1
    80005862:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005866:	8526                	mv	a0,s1
    80005868:	ffffe097          	auipc	ra,0xffffe
    8000586c:	186080e7          	jalr	390(ra) # 800039ee <iupdate>
  iunlockput(ip);
    80005870:	8526                	mv	a0,s1
    80005872:	ffffe097          	auipc	ra,0xffffe
    80005876:	4aa080e7          	jalr	1194(ra) # 80003d1c <iunlockput>
  end_op();
    8000587a:	fffff097          	auipc	ra,0xfffff
    8000587e:	c8a080e7          	jalr	-886(ra) # 80004504 <end_op>
  return -1;
    80005882:	57fd                	li	a5,-1
}
    80005884:	853e                	mv	a0,a5
    80005886:	70b2                	ld	ra,296(sp)
    80005888:	7412                	ld	s0,288(sp)
    8000588a:	64f2                	ld	s1,280(sp)
    8000588c:	6952                	ld	s2,272(sp)
    8000588e:	6155                	addi	sp,sp,304
    80005890:	8082                	ret

0000000080005892 <sys_unlink>:
{
    80005892:	7151                	addi	sp,sp,-240
    80005894:	f586                	sd	ra,232(sp)
    80005896:	f1a2                	sd	s0,224(sp)
    80005898:	eda6                	sd	s1,216(sp)
    8000589a:	e9ca                	sd	s2,208(sp)
    8000589c:	e5ce                	sd	s3,200(sp)
    8000589e:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800058a0:	08000613          	li	a2,128
    800058a4:	f3040593          	addi	a1,s0,-208
    800058a8:	4501                	li	a0,0
    800058aa:	ffffd097          	auipc	ra,0xffffd
    800058ae:	4d0080e7          	jalr	1232(ra) # 80002d7a <argstr>
    800058b2:	18054163          	bltz	a0,80005a34 <sys_unlink+0x1a2>
  begin_op();
    800058b6:	fffff097          	auipc	ra,0xfffff
    800058ba:	bd0080e7          	jalr	-1072(ra) # 80004486 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800058be:	fb040593          	addi	a1,s0,-80
    800058c2:	f3040513          	addi	a0,s0,-208
    800058c6:	fffff097          	auipc	ra,0xfffff
    800058ca:	9be080e7          	jalr	-1602(ra) # 80004284 <nameiparent>
    800058ce:	84aa                	mv	s1,a0
    800058d0:	c979                	beqz	a0,800059a6 <sys_unlink+0x114>
  ilock(dp);
    800058d2:	ffffe097          	auipc	ra,0xffffe
    800058d6:	1e8080e7          	jalr	488(ra) # 80003aba <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800058da:	00003597          	auipc	a1,0x3
    800058de:	00658593          	addi	a1,a1,6 # 800088e0 <systemCallsNames+0x2b0>
    800058e2:	fb040513          	addi	a0,s0,-80
    800058e6:	ffffe097          	auipc	ra,0xffffe
    800058ea:	69e080e7          	jalr	1694(ra) # 80003f84 <namecmp>
    800058ee:	14050a63          	beqz	a0,80005a42 <sys_unlink+0x1b0>
    800058f2:	00003597          	auipc	a1,0x3
    800058f6:	ff658593          	addi	a1,a1,-10 # 800088e8 <systemCallsNames+0x2b8>
    800058fa:	fb040513          	addi	a0,s0,-80
    800058fe:	ffffe097          	auipc	ra,0xffffe
    80005902:	686080e7          	jalr	1670(ra) # 80003f84 <namecmp>
    80005906:	12050e63          	beqz	a0,80005a42 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    8000590a:	f2c40613          	addi	a2,s0,-212
    8000590e:	fb040593          	addi	a1,s0,-80
    80005912:	8526                	mv	a0,s1
    80005914:	ffffe097          	auipc	ra,0xffffe
    80005918:	68a080e7          	jalr	1674(ra) # 80003f9e <dirlookup>
    8000591c:	892a                	mv	s2,a0
    8000591e:	12050263          	beqz	a0,80005a42 <sys_unlink+0x1b0>
  ilock(ip);
    80005922:	ffffe097          	auipc	ra,0xffffe
    80005926:	198080e7          	jalr	408(ra) # 80003aba <ilock>
  if(ip->nlink < 1)
    8000592a:	04a91783          	lh	a5,74(s2)
    8000592e:	08f05263          	blez	a5,800059b2 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005932:	04491703          	lh	a4,68(s2)
    80005936:	4785                	li	a5,1
    80005938:	08f70563          	beq	a4,a5,800059c2 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    8000593c:	4641                	li	a2,16
    8000593e:	4581                	li	a1,0
    80005940:	fc040513          	addi	a0,s0,-64
    80005944:	ffffb097          	auipc	ra,0xffffb
    80005948:	38e080e7          	jalr	910(ra) # 80000cd2 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000594c:	4741                	li	a4,16
    8000594e:	f2c42683          	lw	a3,-212(s0)
    80005952:	fc040613          	addi	a2,s0,-64
    80005956:	4581                	li	a1,0
    80005958:	8526                	mv	a0,s1
    8000595a:	ffffe097          	auipc	ra,0xffffe
    8000595e:	50c080e7          	jalr	1292(ra) # 80003e66 <writei>
    80005962:	47c1                	li	a5,16
    80005964:	0af51563          	bne	a0,a5,80005a0e <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005968:	04491703          	lh	a4,68(s2)
    8000596c:	4785                	li	a5,1
    8000596e:	0af70863          	beq	a4,a5,80005a1e <sys_unlink+0x18c>
  iunlockput(dp);
    80005972:	8526                	mv	a0,s1
    80005974:	ffffe097          	auipc	ra,0xffffe
    80005978:	3a8080e7          	jalr	936(ra) # 80003d1c <iunlockput>
  ip->nlink--;
    8000597c:	04a95783          	lhu	a5,74(s2)
    80005980:	37fd                	addiw	a5,a5,-1
    80005982:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005986:	854a                	mv	a0,s2
    80005988:	ffffe097          	auipc	ra,0xffffe
    8000598c:	066080e7          	jalr	102(ra) # 800039ee <iupdate>
  iunlockput(ip);
    80005990:	854a                	mv	a0,s2
    80005992:	ffffe097          	auipc	ra,0xffffe
    80005996:	38a080e7          	jalr	906(ra) # 80003d1c <iunlockput>
  end_op();
    8000599a:	fffff097          	auipc	ra,0xfffff
    8000599e:	b6a080e7          	jalr	-1174(ra) # 80004504 <end_op>
  return 0;
    800059a2:	4501                	li	a0,0
    800059a4:	a84d                	j	80005a56 <sys_unlink+0x1c4>
    end_op();
    800059a6:	fffff097          	auipc	ra,0xfffff
    800059aa:	b5e080e7          	jalr	-1186(ra) # 80004504 <end_op>
    return -1;
    800059ae:	557d                	li	a0,-1
    800059b0:	a05d                	j	80005a56 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    800059b2:	00003517          	auipc	a0,0x3
    800059b6:	f3e50513          	addi	a0,a0,-194 # 800088f0 <systemCallsNames+0x2c0>
    800059ba:	ffffb097          	auipc	ra,0xffffb
    800059be:	b86080e7          	jalr	-1146(ra) # 80000540 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800059c2:	04c92703          	lw	a4,76(s2)
    800059c6:	02000793          	li	a5,32
    800059ca:	f6e7f9e3          	bgeu	a5,a4,8000593c <sys_unlink+0xaa>
    800059ce:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800059d2:	4741                	li	a4,16
    800059d4:	86ce                	mv	a3,s3
    800059d6:	f1840613          	addi	a2,s0,-232
    800059da:	4581                	li	a1,0
    800059dc:	854a                	mv	a0,s2
    800059de:	ffffe097          	auipc	ra,0xffffe
    800059e2:	390080e7          	jalr	912(ra) # 80003d6e <readi>
    800059e6:	47c1                	li	a5,16
    800059e8:	00f51b63          	bne	a0,a5,800059fe <sys_unlink+0x16c>
    if(de.inum != 0)
    800059ec:	f1845783          	lhu	a5,-232(s0)
    800059f0:	e7a1                	bnez	a5,80005a38 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800059f2:	29c1                	addiw	s3,s3,16
    800059f4:	04c92783          	lw	a5,76(s2)
    800059f8:	fcf9ede3          	bltu	s3,a5,800059d2 <sys_unlink+0x140>
    800059fc:	b781                	j	8000593c <sys_unlink+0xaa>
      panic("isdirempty: readi");
    800059fe:	00003517          	auipc	a0,0x3
    80005a02:	f0a50513          	addi	a0,a0,-246 # 80008908 <systemCallsNames+0x2d8>
    80005a06:	ffffb097          	auipc	ra,0xffffb
    80005a0a:	b3a080e7          	jalr	-1222(ra) # 80000540 <panic>
    panic("unlink: writei");
    80005a0e:	00003517          	auipc	a0,0x3
    80005a12:	f1250513          	addi	a0,a0,-238 # 80008920 <systemCallsNames+0x2f0>
    80005a16:	ffffb097          	auipc	ra,0xffffb
    80005a1a:	b2a080e7          	jalr	-1238(ra) # 80000540 <panic>
    dp->nlink--;
    80005a1e:	04a4d783          	lhu	a5,74(s1)
    80005a22:	37fd                	addiw	a5,a5,-1
    80005a24:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005a28:	8526                	mv	a0,s1
    80005a2a:	ffffe097          	auipc	ra,0xffffe
    80005a2e:	fc4080e7          	jalr	-60(ra) # 800039ee <iupdate>
    80005a32:	b781                	j	80005972 <sys_unlink+0xe0>
    return -1;
    80005a34:	557d                	li	a0,-1
    80005a36:	a005                	j	80005a56 <sys_unlink+0x1c4>
    iunlockput(ip);
    80005a38:	854a                	mv	a0,s2
    80005a3a:	ffffe097          	auipc	ra,0xffffe
    80005a3e:	2e2080e7          	jalr	738(ra) # 80003d1c <iunlockput>
  iunlockput(dp);
    80005a42:	8526                	mv	a0,s1
    80005a44:	ffffe097          	auipc	ra,0xffffe
    80005a48:	2d8080e7          	jalr	728(ra) # 80003d1c <iunlockput>
  end_op();
    80005a4c:	fffff097          	auipc	ra,0xfffff
    80005a50:	ab8080e7          	jalr	-1352(ra) # 80004504 <end_op>
  return -1;
    80005a54:	557d                	li	a0,-1
}
    80005a56:	70ae                	ld	ra,232(sp)
    80005a58:	740e                	ld	s0,224(sp)
    80005a5a:	64ee                	ld	s1,216(sp)
    80005a5c:	694e                	ld	s2,208(sp)
    80005a5e:	69ae                	ld	s3,200(sp)
    80005a60:	616d                	addi	sp,sp,240
    80005a62:	8082                	ret

0000000080005a64 <sys_open>:

uint64
sys_open(void)
{
    80005a64:	7131                	addi	sp,sp,-192
    80005a66:	fd06                	sd	ra,184(sp)
    80005a68:	f922                	sd	s0,176(sp)
    80005a6a:	f526                	sd	s1,168(sp)
    80005a6c:	f14a                	sd	s2,160(sp)
    80005a6e:	ed4e                	sd	s3,152(sp)
    80005a70:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005a72:	f4c40593          	addi	a1,s0,-180
    80005a76:	4505                	li	a0,1
    80005a78:	ffffd097          	auipc	ra,0xffffd
    80005a7c:	2be080e7          	jalr	702(ra) # 80002d36 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005a80:	08000613          	li	a2,128
    80005a84:	f5040593          	addi	a1,s0,-176
    80005a88:	4501                	li	a0,0
    80005a8a:	ffffd097          	auipc	ra,0xffffd
    80005a8e:	2f0080e7          	jalr	752(ra) # 80002d7a <argstr>
    80005a92:	87aa                	mv	a5,a0
    return -1;
    80005a94:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005a96:	0a07c963          	bltz	a5,80005b48 <sys_open+0xe4>

  begin_op();
    80005a9a:	fffff097          	auipc	ra,0xfffff
    80005a9e:	9ec080e7          	jalr	-1556(ra) # 80004486 <begin_op>

  if(omode & O_CREATE){
    80005aa2:	f4c42783          	lw	a5,-180(s0)
    80005aa6:	2007f793          	andi	a5,a5,512
    80005aaa:	cfc5                	beqz	a5,80005b62 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005aac:	4681                	li	a3,0
    80005aae:	4601                	li	a2,0
    80005ab0:	4589                	li	a1,2
    80005ab2:	f5040513          	addi	a0,s0,-176
    80005ab6:	00000097          	auipc	ra,0x0
    80005aba:	972080e7          	jalr	-1678(ra) # 80005428 <create>
    80005abe:	84aa                	mv	s1,a0
    if(ip == 0){
    80005ac0:	c959                	beqz	a0,80005b56 <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005ac2:	04449703          	lh	a4,68(s1)
    80005ac6:	478d                	li	a5,3
    80005ac8:	00f71763          	bne	a4,a5,80005ad6 <sys_open+0x72>
    80005acc:	0464d703          	lhu	a4,70(s1)
    80005ad0:	47a5                	li	a5,9
    80005ad2:	0ce7ed63          	bltu	a5,a4,80005bac <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005ad6:	fffff097          	auipc	ra,0xfffff
    80005ada:	dbc080e7          	jalr	-580(ra) # 80004892 <filealloc>
    80005ade:	89aa                	mv	s3,a0
    80005ae0:	10050363          	beqz	a0,80005be6 <sys_open+0x182>
    80005ae4:	00000097          	auipc	ra,0x0
    80005ae8:	902080e7          	jalr	-1790(ra) # 800053e6 <fdalloc>
    80005aec:	892a                	mv	s2,a0
    80005aee:	0e054763          	bltz	a0,80005bdc <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005af2:	04449703          	lh	a4,68(s1)
    80005af6:	478d                	li	a5,3
    80005af8:	0cf70563          	beq	a4,a5,80005bc2 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005afc:	4789                	li	a5,2
    80005afe:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005b02:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005b06:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005b0a:	f4c42783          	lw	a5,-180(s0)
    80005b0e:	0017c713          	xori	a4,a5,1
    80005b12:	8b05                	andi	a4,a4,1
    80005b14:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005b18:	0037f713          	andi	a4,a5,3
    80005b1c:	00e03733          	snez	a4,a4
    80005b20:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005b24:	4007f793          	andi	a5,a5,1024
    80005b28:	c791                	beqz	a5,80005b34 <sys_open+0xd0>
    80005b2a:	04449703          	lh	a4,68(s1)
    80005b2e:	4789                	li	a5,2
    80005b30:	0af70063          	beq	a4,a5,80005bd0 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005b34:	8526                	mv	a0,s1
    80005b36:	ffffe097          	auipc	ra,0xffffe
    80005b3a:	046080e7          	jalr	70(ra) # 80003b7c <iunlock>
  end_op();
    80005b3e:	fffff097          	auipc	ra,0xfffff
    80005b42:	9c6080e7          	jalr	-1594(ra) # 80004504 <end_op>

  return fd;
    80005b46:	854a                	mv	a0,s2
}
    80005b48:	70ea                	ld	ra,184(sp)
    80005b4a:	744a                	ld	s0,176(sp)
    80005b4c:	74aa                	ld	s1,168(sp)
    80005b4e:	790a                	ld	s2,160(sp)
    80005b50:	69ea                	ld	s3,152(sp)
    80005b52:	6129                	addi	sp,sp,192
    80005b54:	8082                	ret
      end_op();
    80005b56:	fffff097          	auipc	ra,0xfffff
    80005b5a:	9ae080e7          	jalr	-1618(ra) # 80004504 <end_op>
      return -1;
    80005b5e:	557d                	li	a0,-1
    80005b60:	b7e5                	j	80005b48 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005b62:	f5040513          	addi	a0,s0,-176
    80005b66:	ffffe097          	auipc	ra,0xffffe
    80005b6a:	700080e7          	jalr	1792(ra) # 80004266 <namei>
    80005b6e:	84aa                	mv	s1,a0
    80005b70:	c905                	beqz	a0,80005ba0 <sys_open+0x13c>
    ilock(ip);
    80005b72:	ffffe097          	auipc	ra,0xffffe
    80005b76:	f48080e7          	jalr	-184(ra) # 80003aba <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005b7a:	04449703          	lh	a4,68(s1)
    80005b7e:	4785                	li	a5,1
    80005b80:	f4f711e3          	bne	a4,a5,80005ac2 <sys_open+0x5e>
    80005b84:	f4c42783          	lw	a5,-180(s0)
    80005b88:	d7b9                	beqz	a5,80005ad6 <sys_open+0x72>
      iunlockput(ip);
    80005b8a:	8526                	mv	a0,s1
    80005b8c:	ffffe097          	auipc	ra,0xffffe
    80005b90:	190080e7          	jalr	400(ra) # 80003d1c <iunlockput>
      end_op();
    80005b94:	fffff097          	auipc	ra,0xfffff
    80005b98:	970080e7          	jalr	-1680(ra) # 80004504 <end_op>
      return -1;
    80005b9c:	557d                	li	a0,-1
    80005b9e:	b76d                	j	80005b48 <sys_open+0xe4>
      end_op();
    80005ba0:	fffff097          	auipc	ra,0xfffff
    80005ba4:	964080e7          	jalr	-1692(ra) # 80004504 <end_op>
      return -1;
    80005ba8:	557d                	li	a0,-1
    80005baa:	bf79                	j	80005b48 <sys_open+0xe4>
    iunlockput(ip);
    80005bac:	8526                	mv	a0,s1
    80005bae:	ffffe097          	auipc	ra,0xffffe
    80005bb2:	16e080e7          	jalr	366(ra) # 80003d1c <iunlockput>
    end_op();
    80005bb6:	fffff097          	auipc	ra,0xfffff
    80005bba:	94e080e7          	jalr	-1714(ra) # 80004504 <end_op>
    return -1;
    80005bbe:	557d                	li	a0,-1
    80005bc0:	b761                	j	80005b48 <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005bc2:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005bc6:	04649783          	lh	a5,70(s1)
    80005bca:	02f99223          	sh	a5,36(s3)
    80005bce:	bf25                	j	80005b06 <sys_open+0xa2>
    itrunc(ip);
    80005bd0:	8526                	mv	a0,s1
    80005bd2:	ffffe097          	auipc	ra,0xffffe
    80005bd6:	ff6080e7          	jalr	-10(ra) # 80003bc8 <itrunc>
    80005bda:	bfa9                	j	80005b34 <sys_open+0xd0>
      fileclose(f);
    80005bdc:	854e                	mv	a0,s3
    80005bde:	fffff097          	auipc	ra,0xfffff
    80005be2:	d70080e7          	jalr	-656(ra) # 8000494e <fileclose>
    iunlockput(ip);
    80005be6:	8526                	mv	a0,s1
    80005be8:	ffffe097          	auipc	ra,0xffffe
    80005bec:	134080e7          	jalr	308(ra) # 80003d1c <iunlockput>
    end_op();
    80005bf0:	fffff097          	auipc	ra,0xfffff
    80005bf4:	914080e7          	jalr	-1772(ra) # 80004504 <end_op>
    return -1;
    80005bf8:	557d                	li	a0,-1
    80005bfa:	b7b9                	j	80005b48 <sys_open+0xe4>

0000000080005bfc <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005bfc:	7175                	addi	sp,sp,-144
    80005bfe:	e506                	sd	ra,136(sp)
    80005c00:	e122                	sd	s0,128(sp)
    80005c02:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005c04:	fffff097          	auipc	ra,0xfffff
    80005c08:	882080e7          	jalr	-1918(ra) # 80004486 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005c0c:	08000613          	li	a2,128
    80005c10:	f7040593          	addi	a1,s0,-144
    80005c14:	4501                	li	a0,0
    80005c16:	ffffd097          	auipc	ra,0xffffd
    80005c1a:	164080e7          	jalr	356(ra) # 80002d7a <argstr>
    80005c1e:	02054963          	bltz	a0,80005c50 <sys_mkdir+0x54>
    80005c22:	4681                	li	a3,0
    80005c24:	4601                	li	a2,0
    80005c26:	4585                	li	a1,1
    80005c28:	f7040513          	addi	a0,s0,-144
    80005c2c:	fffff097          	auipc	ra,0xfffff
    80005c30:	7fc080e7          	jalr	2044(ra) # 80005428 <create>
    80005c34:	cd11                	beqz	a0,80005c50 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005c36:	ffffe097          	auipc	ra,0xffffe
    80005c3a:	0e6080e7          	jalr	230(ra) # 80003d1c <iunlockput>
  end_op();
    80005c3e:	fffff097          	auipc	ra,0xfffff
    80005c42:	8c6080e7          	jalr	-1850(ra) # 80004504 <end_op>
  return 0;
    80005c46:	4501                	li	a0,0
}
    80005c48:	60aa                	ld	ra,136(sp)
    80005c4a:	640a                	ld	s0,128(sp)
    80005c4c:	6149                	addi	sp,sp,144
    80005c4e:	8082                	ret
    end_op();
    80005c50:	fffff097          	auipc	ra,0xfffff
    80005c54:	8b4080e7          	jalr	-1868(ra) # 80004504 <end_op>
    return -1;
    80005c58:	557d                	li	a0,-1
    80005c5a:	b7fd                	j	80005c48 <sys_mkdir+0x4c>

0000000080005c5c <sys_mknod>:

uint64
sys_mknod(void)
{
    80005c5c:	7135                	addi	sp,sp,-160
    80005c5e:	ed06                	sd	ra,152(sp)
    80005c60:	e922                	sd	s0,144(sp)
    80005c62:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005c64:	fffff097          	auipc	ra,0xfffff
    80005c68:	822080e7          	jalr	-2014(ra) # 80004486 <begin_op>
  argint(1, &major);
    80005c6c:	f6c40593          	addi	a1,s0,-148
    80005c70:	4505                	li	a0,1
    80005c72:	ffffd097          	auipc	ra,0xffffd
    80005c76:	0c4080e7          	jalr	196(ra) # 80002d36 <argint>
  argint(2, &minor);
    80005c7a:	f6840593          	addi	a1,s0,-152
    80005c7e:	4509                	li	a0,2
    80005c80:	ffffd097          	auipc	ra,0xffffd
    80005c84:	0b6080e7          	jalr	182(ra) # 80002d36 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005c88:	08000613          	li	a2,128
    80005c8c:	f7040593          	addi	a1,s0,-144
    80005c90:	4501                	li	a0,0
    80005c92:	ffffd097          	auipc	ra,0xffffd
    80005c96:	0e8080e7          	jalr	232(ra) # 80002d7a <argstr>
    80005c9a:	02054b63          	bltz	a0,80005cd0 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005c9e:	f6841683          	lh	a3,-152(s0)
    80005ca2:	f6c41603          	lh	a2,-148(s0)
    80005ca6:	458d                	li	a1,3
    80005ca8:	f7040513          	addi	a0,s0,-144
    80005cac:	fffff097          	auipc	ra,0xfffff
    80005cb0:	77c080e7          	jalr	1916(ra) # 80005428 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005cb4:	cd11                	beqz	a0,80005cd0 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005cb6:	ffffe097          	auipc	ra,0xffffe
    80005cba:	066080e7          	jalr	102(ra) # 80003d1c <iunlockput>
  end_op();
    80005cbe:	fffff097          	auipc	ra,0xfffff
    80005cc2:	846080e7          	jalr	-1978(ra) # 80004504 <end_op>
  return 0;
    80005cc6:	4501                	li	a0,0
}
    80005cc8:	60ea                	ld	ra,152(sp)
    80005cca:	644a                	ld	s0,144(sp)
    80005ccc:	610d                	addi	sp,sp,160
    80005cce:	8082                	ret
    end_op();
    80005cd0:	fffff097          	auipc	ra,0xfffff
    80005cd4:	834080e7          	jalr	-1996(ra) # 80004504 <end_op>
    return -1;
    80005cd8:	557d                	li	a0,-1
    80005cda:	b7fd                	j	80005cc8 <sys_mknod+0x6c>

0000000080005cdc <sys_chdir>:

uint64
sys_chdir(void)
{
    80005cdc:	7135                	addi	sp,sp,-160
    80005cde:	ed06                	sd	ra,152(sp)
    80005ce0:	e922                	sd	s0,144(sp)
    80005ce2:	e526                	sd	s1,136(sp)
    80005ce4:	e14a                	sd	s2,128(sp)
    80005ce6:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005ce8:	ffffc097          	auipc	ra,0xffffc
    80005cec:	cc4080e7          	jalr	-828(ra) # 800019ac <myproc>
    80005cf0:	892a                	mv	s2,a0
  
  begin_op();
    80005cf2:	ffffe097          	auipc	ra,0xffffe
    80005cf6:	794080e7          	jalr	1940(ra) # 80004486 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005cfa:	08000613          	li	a2,128
    80005cfe:	f6040593          	addi	a1,s0,-160
    80005d02:	4501                	li	a0,0
    80005d04:	ffffd097          	auipc	ra,0xffffd
    80005d08:	076080e7          	jalr	118(ra) # 80002d7a <argstr>
    80005d0c:	04054b63          	bltz	a0,80005d62 <sys_chdir+0x86>
    80005d10:	f6040513          	addi	a0,s0,-160
    80005d14:	ffffe097          	auipc	ra,0xffffe
    80005d18:	552080e7          	jalr	1362(ra) # 80004266 <namei>
    80005d1c:	84aa                	mv	s1,a0
    80005d1e:	c131                	beqz	a0,80005d62 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005d20:	ffffe097          	auipc	ra,0xffffe
    80005d24:	d9a080e7          	jalr	-614(ra) # 80003aba <ilock>
  if(ip->type != T_DIR){
    80005d28:	04449703          	lh	a4,68(s1)
    80005d2c:	4785                	li	a5,1
    80005d2e:	04f71063          	bne	a4,a5,80005d6e <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005d32:	8526                	mv	a0,s1
    80005d34:	ffffe097          	auipc	ra,0xffffe
    80005d38:	e48080e7          	jalr	-440(ra) # 80003b7c <iunlock>
  iput(p->cwd);
    80005d3c:	15093503          	ld	a0,336(s2)
    80005d40:	ffffe097          	auipc	ra,0xffffe
    80005d44:	f34080e7          	jalr	-204(ra) # 80003c74 <iput>
  end_op();
    80005d48:	ffffe097          	auipc	ra,0xffffe
    80005d4c:	7bc080e7          	jalr	1980(ra) # 80004504 <end_op>
  p->cwd = ip;
    80005d50:	14993823          	sd	s1,336(s2)
  return 0;
    80005d54:	4501                	li	a0,0
}
    80005d56:	60ea                	ld	ra,152(sp)
    80005d58:	644a                	ld	s0,144(sp)
    80005d5a:	64aa                	ld	s1,136(sp)
    80005d5c:	690a                	ld	s2,128(sp)
    80005d5e:	610d                	addi	sp,sp,160
    80005d60:	8082                	ret
    end_op();
    80005d62:	ffffe097          	auipc	ra,0xffffe
    80005d66:	7a2080e7          	jalr	1954(ra) # 80004504 <end_op>
    return -1;
    80005d6a:	557d                	li	a0,-1
    80005d6c:	b7ed                	j	80005d56 <sys_chdir+0x7a>
    iunlockput(ip);
    80005d6e:	8526                	mv	a0,s1
    80005d70:	ffffe097          	auipc	ra,0xffffe
    80005d74:	fac080e7          	jalr	-84(ra) # 80003d1c <iunlockput>
    end_op();
    80005d78:	ffffe097          	auipc	ra,0xffffe
    80005d7c:	78c080e7          	jalr	1932(ra) # 80004504 <end_op>
    return -1;
    80005d80:	557d                	li	a0,-1
    80005d82:	bfd1                	j	80005d56 <sys_chdir+0x7a>

0000000080005d84 <sys_exec>:

uint64
sys_exec(void)
{
    80005d84:	7145                	addi	sp,sp,-464
    80005d86:	e786                	sd	ra,456(sp)
    80005d88:	e3a2                	sd	s0,448(sp)
    80005d8a:	ff26                	sd	s1,440(sp)
    80005d8c:	fb4a                	sd	s2,432(sp)
    80005d8e:	f74e                	sd	s3,424(sp)
    80005d90:	f352                	sd	s4,416(sp)
    80005d92:	ef56                	sd	s5,408(sp)
    80005d94:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005d96:	e3840593          	addi	a1,s0,-456
    80005d9a:	4505                	li	a0,1
    80005d9c:	ffffd097          	auipc	ra,0xffffd
    80005da0:	fbc080e7          	jalr	-68(ra) # 80002d58 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005da4:	08000613          	li	a2,128
    80005da8:	f4040593          	addi	a1,s0,-192
    80005dac:	4501                	li	a0,0
    80005dae:	ffffd097          	auipc	ra,0xffffd
    80005db2:	fcc080e7          	jalr	-52(ra) # 80002d7a <argstr>
    80005db6:	87aa                	mv	a5,a0
    return -1;
    80005db8:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005dba:	0c07c363          	bltz	a5,80005e80 <sys_exec+0xfc>
  }
  memset(argv, 0, sizeof(argv));
    80005dbe:	10000613          	li	a2,256
    80005dc2:	4581                	li	a1,0
    80005dc4:	e4040513          	addi	a0,s0,-448
    80005dc8:	ffffb097          	auipc	ra,0xffffb
    80005dcc:	f0a080e7          	jalr	-246(ra) # 80000cd2 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005dd0:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005dd4:	89a6                	mv	s3,s1
    80005dd6:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005dd8:	02000a13          	li	s4,32
    80005ddc:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005de0:	00391513          	slli	a0,s2,0x3
    80005de4:	e3040593          	addi	a1,s0,-464
    80005de8:	e3843783          	ld	a5,-456(s0)
    80005dec:	953e                	add	a0,a0,a5
    80005dee:	ffffd097          	auipc	ra,0xffffd
    80005df2:	eaa080e7          	jalr	-342(ra) # 80002c98 <fetchaddr>
    80005df6:	02054a63          	bltz	a0,80005e2a <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    80005dfa:	e3043783          	ld	a5,-464(s0)
    80005dfe:	c3b9                	beqz	a5,80005e44 <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005e00:	ffffb097          	auipc	ra,0xffffb
    80005e04:	ce6080e7          	jalr	-794(ra) # 80000ae6 <kalloc>
    80005e08:	85aa                	mv	a1,a0
    80005e0a:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005e0e:	cd11                	beqz	a0,80005e2a <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005e10:	6605                	lui	a2,0x1
    80005e12:	e3043503          	ld	a0,-464(s0)
    80005e16:	ffffd097          	auipc	ra,0xffffd
    80005e1a:	ed4080e7          	jalr	-300(ra) # 80002cea <fetchstr>
    80005e1e:	00054663          	bltz	a0,80005e2a <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80005e22:	0905                	addi	s2,s2,1
    80005e24:	09a1                	addi	s3,s3,8
    80005e26:	fb491be3          	bne	s2,s4,80005ddc <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005e2a:	f4040913          	addi	s2,s0,-192
    80005e2e:	6088                	ld	a0,0(s1)
    80005e30:	c539                	beqz	a0,80005e7e <sys_exec+0xfa>
    kfree(argv[i]);
    80005e32:	ffffb097          	auipc	ra,0xffffb
    80005e36:	bb6080e7          	jalr	-1098(ra) # 800009e8 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005e3a:	04a1                	addi	s1,s1,8
    80005e3c:	ff2499e3          	bne	s1,s2,80005e2e <sys_exec+0xaa>
  return -1;
    80005e40:	557d                	li	a0,-1
    80005e42:	a83d                	j	80005e80 <sys_exec+0xfc>
      argv[i] = 0;
    80005e44:	0a8e                	slli	s5,s5,0x3
    80005e46:	fc0a8793          	addi	a5,s5,-64
    80005e4a:	00878ab3          	add	s5,a5,s0
    80005e4e:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005e52:	e4040593          	addi	a1,s0,-448
    80005e56:	f4040513          	addi	a0,s0,-192
    80005e5a:	fffff097          	auipc	ra,0xfffff
    80005e5e:	16e080e7          	jalr	366(ra) # 80004fc8 <exec>
    80005e62:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005e64:	f4040993          	addi	s3,s0,-192
    80005e68:	6088                	ld	a0,0(s1)
    80005e6a:	c901                	beqz	a0,80005e7a <sys_exec+0xf6>
    kfree(argv[i]);
    80005e6c:	ffffb097          	auipc	ra,0xffffb
    80005e70:	b7c080e7          	jalr	-1156(ra) # 800009e8 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005e74:	04a1                	addi	s1,s1,8
    80005e76:	ff3499e3          	bne	s1,s3,80005e68 <sys_exec+0xe4>
  return ret;
    80005e7a:	854a                	mv	a0,s2
    80005e7c:	a011                	j	80005e80 <sys_exec+0xfc>
  return -1;
    80005e7e:	557d                	li	a0,-1
}
    80005e80:	60be                	ld	ra,456(sp)
    80005e82:	641e                	ld	s0,448(sp)
    80005e84:	74fa                	ld	s1,440(sp)
    80005e86:	795a                	ld	s2,432(sp)
    80005e88:	79ba                	ld	s3,424(sp)
    80005e8a:	7a1a                	ld	s4,416(sp)
    80005e8c:	6afa                	ld	s5,408(sp)
    80005e8e:	6179                	addi	sp,sp,464
    80005e90:	8082                	ret

0000000080005e92 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005e92:	7139                	addi	sp,sp,-64
    80005e94:	fc06                	sd	ra,56(sp)
    80005e96:	f822                	sd	s0,48(sp)
    80005e98:	f426                	sd	s1,40(sp)
    80005e9a:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005e9c:	ffffc097          	auipc	ra,0xffffc
    80005ea0:	b10080e7          	jalr	-1264(ra) # 800019ac <myproc>
    80005ea4:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005ea6:	fd840593          	addi	a1,s0,-40
    80005eaa:	4501                	li	a0,0
    80005eac:	ffffd097          	auipc	ra,0xffffd
    80005eb0:	eac080e7          	jalr	-340(ra) # 80002d58 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005eb4:	fc840593          	addi	a1,s0,-56
    80005eb8:	fd040513          	addi	a0,s0,-48
    80005ebc:	fffff097          	auipc	ra,0xfffff
    80005ec0:	dc2080e7          	jalr	-574(ra) # 80004c7e <pipealloc>
    return -1;
    80005ec4:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005ec6:	0c054463          	bltz	a0,80005f8e <sys_pipe+0xfc>
  fd0 = -1;
    80005eca:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005ece:	fd043503          	ld	a0,-48(s0)
    80005ed2:	fffff097          	auipc	ra,0xfffff
    80005ed6:	514080e7          	jalr	1300(ra) # 800053e6 <fdalloc>
    80005eda:	fca42223          	sw	a0,-60(s0)
    80005ede:	08054b63          	bltz	a0,80005f74 <sys_pipe+0xe2>
    80005ee2:	fc843503          	ld	a0,-56(s0)
    80005ee6:	fffff097          	auipc	ra,0xfffff
    80005eea:	500080e7          	jalr	1280(ra) # 800053e6 <fdalloc>
    80005eee:	fca42023          	sw	a0,-64(s0)
    80005ef2:	06054863          	bltz	a0,80005f62 <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005ef6:	4691                	li	a3,4
    80005ef8:	fc440613          	addi	a2,s0,-60
    80005efc:	fd843583          	ld	a1,-40(s0)
    80005f00:	68a8                	ld	a0,80(s1)
    80005f02:	ffffb097          	auipc	ra,0xffffb
    80005f06:	76a080e7          	jalr	1898(ra) # 8000166c <copyout>
    80005f0a:	02054063          	bltz	a0,80005f2a <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005f0e:	4691                	li	a3,4
    80005f10:	fc040613          	addi	a2,s0,-64
    80005f14:	fd843583          	ld	a1,-40(s0)
    80005f18:	0591                	addi	a1,a1,4
    80005f1a:	68a8                	ld	a0,80(s1)
    80005f1c:	ffffb097          	auipc	ra,0xffffb
    80005f20:	750080e7          	jalr	1872(ra) # 8000166c <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005f24:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005f26:	06055463          	bgez	a0,80005f8e <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80005f2a:	fc442783          	lw	a5,-60(s0)
    80005f2e:	07e9                	addi	a5,a5,26
    80005f30:	078e                	slli	a5,a5,0x3
    80005f32:	97a6                	add	a5,a5,s1
    80005f34:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005f38:	fc042783          	lw	a5,-64(s0)
    80005f3c:	07e9                	addi	a5,a5,26
    80005f3e:	078e                	slli	a5,a5,0x3
    80005f40:	94be                	add	s1,s1,a5
    80005f42:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005f46:	fd043503          	ld	a0,-48(s0)
    80005f4a:	fffff097          	auipc	ra,0xfffff
    80005f4e:	a04080e7          	jalr	-1532(ra) # 8000494e <fileclose>
    fileclose(wf);
    80005f52:	fc843503          	ld	a0,-56(s0)
    80005f56:	fffff097          	auipc	ra,0xfffff
    80005f5a:	9f8080e7          	jalr	-1544(ra) # 8000494e <fileclose>
    return -1;
    80005f5e:	57fd                	li	a5,-1
    80005f60:	a03d                	j	80005f8e <sys_pipe+0xfc>
    if(fd0 >= 0)
    80005f62:	fc442783          	lw	a5,-60(s0)
    80005f66:	0007c763          	bltz	a5,80005f74 <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80005f6a:	07e9                	addi	a5,a5,26
    80005f6c:	078e                	slli	a5,a5,0x3
    80005f6e:	97a6                	add	a5,a5,s1
    80005f70:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005f74:	fd043503          	ld	a0,-48(s0)
    80005f78:	fffff097          	auipc	ra,0xfffff
    80005f7c:	9d6080e7          	jalr	-1578(ra) # 8000494e <fileclose>
    fileclose(wf);
    80005f80:	fc843503          	ld	a0,-56(s0)
    80005f84:	fffff097          	auipc	ra,0xfffff
    80005f88:	9ca080e7          	jalr	-1590(ra) # 8000494e <fileclose>
    return -1;
    80005f8c:	57fd                	li	a5,-1
}
    80005f8e:	853e                	mv	a0,a5
    80005f90:	70e2                	ld	ra,56(sp)
    80005f92:	7442                	ld	s0,48(sp)
    80005f94:	74a2                	ld	s1,40(sp)
    80005f96:	6121                	addi	sp,sp,64
    80005f98:	8082                	ret
    80005f9a:	0000                	unimp
    80005f9c:	0000                	unimp
	...

0000000080005fa0 <kernelvec>:
    80005fa0:	7111                	addi	sp,sp,-256
    80005fa2:	e006                	sd	ra,0(sp)
    80005fa4:	e40a                	sd	sp,8(sp)
    80005fa6:	e80e                	sd	gp,16(sp)
    80005fa8:	ec12                	sd	tp,24(sp)
    80005faa:	f016                	sd	t0,32(sp)
    80005fac:	f41a                	sd	t1,40(sp)
    80005fae:	f81e                	sd	t2,48(sp)
    80005fb0:	fc22                	sd	s0,56(sp)
    80005fb2:	e0a6                	sd	s1,64(sp)
    80005fb4:	e4aa                	sd	a0,72(sp)
    80005fb6:	e8ae                	sd	a1,80(sp)
    80005fb8:	ecb2                	sd	a2,88(sp)
    80005fba:	f0b6                	sd	a3,96(sp)
    80005fbc:	f4ba                	sd	a4,104(sp)
    80005fbe:	f8be                	sd	a5,112(sp)
    80005fc0:	fcc2                	sd	a6,120(sp)
    80005fc2:	e146                	sd	a7,128(sp)
    80005fc4:	e54a                	sd	s2,136(sp)
    80005fc6:	e94e                	sd	s3,144(sp)
    80005fc8:	ed52                	sd	s4,152(sp)
    80005fca:	f156                	sd	s5,160(sp)
    80005fcc:	f55a                	sd	s6,168(sp)
    80005fce:	f95e                	sd	s7,176(sp)
    80005fd0:	fd62                	sd	s8,184(sp)
    80005fd2:	e1e6                	sd	s9,192(sp)
    80005fd4:	e5ea                	sd	s10,200(sp)
    80005fd6:	e9ee                	sd	s11,208(sp)
    80005fd8:	edf2                	sd	t3,216(sp)
    80005fda:	f1f6                	sd	t4,224(sp)
    80005fdc:	f5fa                	sd	t5,232(sp)
    80005fde:	f9fe                	sd	t6,240(sp)
    80005fe0:	b85fc0ef          	jal	ra,80002b64 <kerneltrap>
    80005fe4:	6082                	ld	ra,0(sp)
    80005fe6:	6122                	ld	sp,8(sp)
    80005fe8:	61c2                	ld	gp,16(sp)
    80005fea:	7282                	ld	t0,32(sp)
    80005fec:	7322                	ld	t1,40(sp)
    80005fee:	73c2                	ld	t2,48(sp)
    80005ff0:	7462                	ld	s0,56(sp)
    80005ff2:	6486                	ld	s1,64(sp)
    80005ff4:	6526                	ld	a0,72(sp)
    80005ff6:	65c6                	ld	a1,80(sp)
    80005ff8:	6666                	ld	a2,88(sp)
    80005ffa:	7686                	ld	a3,96(sp)
    80005ffc:	7726                	ld	a4,104(sp)
    80005ffe:	77c6                	ld	a5,112(sp)
    80006000:	7866                	ld	a6,120(sp)
    80006002:	688a                	ld	a7,128(sp)
    80006004:	692a                	ld	s2,136(sp)
    80006006:	69ca                	ld	s3,144(sp)
    80006008:	6a6a                	ld	s4,152(sp)
    8000600a:	7a8a                	ld	s5,160(sp)
    8000600c:	7b2a                	ld	s6,168(sp)
    8000600e:	7bca                	ld	s7,176(sp)
    80006010:	7c6a                	ld	s8,184(sp)
    80006012:	6c8e                	ld	s9,192(sp)
    80006014:	6d2e                	ld	s10,200(sp)
    80006016:	6dce                	ld	s11,208(sp)
    80006018:	6e6e                	ld	t3,216(sp)
    8000601a:	7e8e                	ld	t4,224(sp)
    8000601c:	7f2e                	ld	t5,232(sp)
    8000601e:	7fce                	ld	t6,240(sp)
    80006020:	6111                	addi	sp,sp,256
    80006022:	10200073          	sret
    80006026:	00000013          	nop
    8000602a:	00000013          	nop
    8000602e:	0001                	nop

0000000080006030 <timervec>:
    80006030:	34051573          	csrrw	a0,mscratch,a0
    80006034:	e10c                	sd	a1,0(a0)
    80006036:	e510                	sd	a2,8(a0)
    80006038:	e914                	sd	a3,16(a0)
    8000603a:	6d0c                	ld	a1,24(a0)
    8000603c:	7110                	ld	a2,32(a0)
    8000603e:	6194                	ld	a3,0(a1)
    80006040:	96b2                	add	a3,a3,a2
    80006042:	e194                	sd	a3,0(a1)
    80006044:	4589                	li	a1,2
    80006046:	14459073          	csrw	sip,a1
    8000604a:	6914                	ld	a3,16(a0)
    8000604c:	6510                	ld	a2,8(a0)
    8000604e:	610c                	ld	a1,0(a0)
    80006050:	34051573          	csrrw	a0,mscratch,a0
    80006054:	30200073          	mret
	...

000000008000605a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000605a:	1141                	addi	sp,sp,-16
    8000605c:	e422                	sd	s0,8(sp)
    8000605e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006060:	0c0007b7          	lui	a5,0xc000
    80006064:	4705                	li	a4,1
    80006066:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006068:	c3d8                	sw	a4,4(a5)
}
    8000606a:	6422                	ld	s0,8(sp)
    8000606c:	0141                	addi	sp,sp,16
    8000606e:	8082                	ret

0000000080006070 <plicinithart>:

void
plicinithart(void)
{
    80006070:	1141                	addi	sp,sp,-16
    80006072:	e406                	sd	ra,8(sp)
    80006074:	e022                	sd	s0,0(sp)
    80006076:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006078:	ffffc097          	auipc	ra,0xffffc
    8000607c:	908080e7          	jalr	-1784(ra) # 80001980 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006080:	0085171b          	slliw	a4,a0,0x8
    80006084:	0c0027b7          	lui	a5,0xc002
    80006088:	97ba                	add	a5,a5,a4
    8000608a:	40200713          	li	a4,1026
    8000608e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006092:	00d5151b          	slliw	a0,a0,0xd
    80006096:	0c2017b7          	lui	a5,0xc201
    8000609a:	97aa                	add	a5,a5,a0
    8000609c:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    800060a0:	60a2                	ld	ra,8(sp)
    800060a2:	6402                	ld	s0,0(sp)
    800060a4:	0141                	addi	sp,sp,16
    800060a6:	8082                	ret

00000000800060a8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800060a8:	1141                	addi	sp,sp,-16
    800060aa:	e406                	sd	ra,8(sp)
    800060ac:	e022                	sd	s0,0(sp)
    800060ae:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800060b0:	ffffc097          	auipc	ra,0xffffc
    800060b4:	8d0080e7          	jalr	-1840(ra) # 80001980 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800060b8:	00d5151b          	slliw	a0,a0,0xd
    800060bc:	0c2017b7          	lui	a5,0xc201
    800060c0:	97aa                	add	a5,a5,a0
  return irq;
}
    800060c2:	43c8                	lw	a0,4(a5)
    800060c4:	60a2                	ld	ra,8(sp)
    800060c6:	6402                	ld	s0,0(sp)
    800060c8:	0141                	addi	sp,sp,16
    800060ca:	8082                	ret

00000000800060cc <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800060cc:	1101                	addi	sp,sp,-32
    800060ce:	ec06                	sd	ra,24(sp)
    800060d0:	e822                	sd	s0,16(sp)
    800060d2:	e426                	sd	s1,8(sp)
    800060d4:	1000                	addi	s0,sp,32
    800060d6:	84aa                	mv	s1,a0
  int hart = cpuid();
    800060d8:	ffffc097          	auipc	ra,0xffffc
    800060dc:	8a8080e7          	jalr	-1880(ra) # 80001980 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800060e0:	00d5151b          	slliw	a0,a0,0xd
    800060e4:	0c2017b7          	lui	a5,0xc201
    800060e8:	97aa                	add	a5,a5,a0
    800060ea:	c3c4                	sw	s1,4(a5)
}
    800060ec:	60e2                	ld	ra,24(sp)
    800060ee:	6442                	ld	s0,16(sp)
    800060f0:	64a2                	ld	s1,8(sp)
    800060f2:	6105                	addi	sp,sp,32
    800060f4:	8082                	ret

00000000800060f6 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800060f6:	1141                	addi	sp,sp,-16
    800060f8:	e406                	sd	ra,8(sp)
    800060fa:	e022                	sd	s0,0(sp)
    800060fc:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800060fe:	479d                	li	a5,7
    80006100:	04a7cc63          	blt	a5,a0,80006158 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80006104:	0001c797          	auipc	a5,0x1c
    80006108:	56c78793          	addi	a5,a5,1388 # 80022670 <disk>
    8000610c:	97aa                	add	a5,a5,a0
    8000610e:	0187c783          	lbu	a5,24(a5)
    80006112:	ebb9                	bnez	a5,80006168 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80006114:	00451693          	slli	a3,a0,0x4
    80006118:	0001c797          	auipc	a5,0x1c
    8000611c:	55878793          	addi	a5,a5,1368 # 80022670 <disk>
    80006120:	6398                	ld	a4,0(a5)
    80006122:	9736                	add	a4,a4,a3
    80006124:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80006128:	6398                	ld	a4,0(a5)
    8000612a:	9736                	add	a4,a4,a3
    8000612c:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80006130:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80006134:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80006138:	97aa                	add	a5,a5,a0
    8000613a:	4705                	li	a4,1
    8000613c:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80006140:	0001c517          	auipc	a0,0x1c
    80006144:	54850513          	addi	a0,a0,1352 # 80022688 <disk+0x18>
    80006148:	ffffc097          	auipc	ra,0xffffc
    8000614c:	198080e7          	jalr	408(ra) # 800022e0 <wakeup>
}
    80006150:	60a2                	ld	ra,8(sp)
    80006152:	6402                	ld	s0,0(sp)
    80006154:	0141                	addi	sp,sp,16
    80006156:	8082                	ret
    panic("free_desc 1");
    80006158:	00002517          	auipc	a0,0x2
    8000615c:	7d850513          	addi	a0,a0,2008 # 80008930 <systemCallsNames+0x300>
    80006160:	ffffa097          	auipc	ra,0xffffa
    80006164:	3e0080e7          	jalr	992(ra) # 80000540 <panic>
    panic("free_desc 2");
    80006168:	00002517          	auipc	a0,0x2
    8000616c:	7d850513          	addi	a0,a0,2008 # 80008940 <systemCallsNames+0x310>
    80006170:	ffffa097          	auipc	ra,0xffffa
    80006174:	3d0080e7          	jalr	976(ra) # 80000540 <panic>

0000000080006178 <virtio_disk_init>:
{
    80006178:	1101                	addi	sp,sp,-32
    8000617a:	ec06                	sd	ra,24(sp)
    8000617c:	e822                	sd	s0,16(sp)
    8000617e:	e426                	sd	s1,8(sp)
    80006180:	e04a                	sd	s2,0(sp)
    80006182:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006184:	00002597          	auipc	a1,0x2
    80006188:	7cc58593          	addi	a1,a1,1996 # 80008950 <systemCallsNames+0x320>
    8000618c:	0001c517          	auipc	a0,0x1c
    80006190:	60c50513          	addi	a0,a0,1548 # 80022798 <disk+0x128>
    80006194:	ffffb097          	auipc	ra,0xffffb
    80006198:	9b2080e7          	jalr	-1614(ra) # 80000b46 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000619c:	100017b7          	lui	a5,0x10001
    800061a0:	4398                	lw	a4,0(a5)
    800061a2:	2701                	sext.w	a4,a4
    800061a4:	747277b7          	lui	a5,0x74727
    800061a8:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800061ac:	14f71b63          	bne	a4,a5,80006302 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800061b0:	100017b7          	lui	a5,0x10001
    800061b4:	43dc                	lw	a5,4(a5)
    800061b6:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800061b8:	4709                	li	a4,2
    800061ba:	14e79463          	bne	a5,a4,80006302 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800061be:	100017b7          	lui	a5,0x10001
    800061c2:	479c                	lw	a5,8(a5)
    800061c4:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800061c6:	12e79e63          	bne	a5,a4,80006302 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800061ca:	100017b7          	lui	a5,0x10001
    800061ce:	47d8                	lw	a4,12(a5)
    800061d0:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800061d2:	554d47b7          	lui	a5,0x554d4
    800061d6:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800061da:	12f71463          	bne	a4,a5,80006302 <virtio_disk_init+0x18a>
  *R(VIRTIO_MMIO_STATUS) = status;
    800061de:	100017b7          	lui	a5,0x10001
    800061e2:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800061e6:	4705                	li	a4,1
    800061e8:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800061ea:	470d                	li	a4,3
    800061ec:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800061ee:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800061f0:	c7ffe6b7          	lui	a3,0xc7ffe
    800061f4:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fdbfaf>
    800061f8:	8f75                	and	a4,a4,a3
    800061fa:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800061fc:	472d                	li	a4,11
    800061fe:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80006200:	5bbc                	lw	a5,112(a5)
    80006202:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80006206:	8ba1                	andi	a5,a5,8
    80006208:	10078563          	beqz	a5,80006312 <virtio_disk_init+0x19a>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    8000620c:	100017b7          	lui	a5,0x10001
    80006210:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80006214:	43fc                	lw	a5,68(a5)
    80006216:	2781                	sext.w	a5,a5
    80006218:	10079563          	bnez	a5,80006322 <virtio_disk_init+0x1aa>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    8000621c:	100017b7          	lui	a5,0x10001
    80006220:	5bdc                	lw	a5,52(a5)
    80006222:	2781                	sext.w	a5,a5
  if(max == 0)
    80006224:	10078763          	beqz	a5,80006332 <virtio_disk_init+0x1ba>
  if(max < NUM)
    80006228:	471d                	li	a4,7
    8000622a:	10f77c63          	bgeu	a4,a5,80006342 <virtio_disk_init+0x1ca>
  disk.desc = kalloc();
    8000622e:	ffffb097          	auipc	ra,0xffffb
    80006232:	8b8080e7          	jalr	-1864(ra) # 80000ae6 <kalloc>
    80006236:	0001c497          	auipc	s1,0x1c
    8000623a:	43a48493          	addi	s1,s1,1082 # 80022670 <disk>
    8000623e:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80006240:	ffffb097          	auipc	ra,0xffffb
    80006244:	8a6080e7          	jalr	-1882(ra) # 80000ae6 <kalloc>
    80006248:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000624a:	ffffb097          	auipc	ra,0xffffb
    8000624e:	89c080e7          	jalr	-1892(ra) # 80000ae6 <kalloc>
    80006252:	87aa                	mv	a5,a0
    80006254:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80006256:	6088                	ld	a0,0(s1)
    80006258:	cd6d                	beqz	a0,80006352 <virtio_disk_init+0x1da>
    8000625a:	0001c717          	auipc	a4,0x1c
    8000625e:	41e73703          	ld	a4,1054(a4) # 80022678 <disk+0x8>
    80006262:	cb65                	beqz	a4,80006352 <virtio_disk_init+0x1da>
    80006264:	c7fd                	beqz	a5,80006352 <virtio_disk_init+0x1da>
  memset(disk.desc, 0, PGSIZE);
    80006266:	6605                	lui	a2,0x1
    80006268:	4581                	li	a1,0
    8000626a:	ffffb097          	auipc	ra,0xffffb
    8000626e:	a68080e7          	jalr	-1432(ra) # 80000cd2 <memset>
  memset(disk.avail, 0, PGSIZE);
    80006272:	0001c497          	auipc	s1,0x1c
    80006276:	3fe48493          	addi	s1,s1,1022 # 80022670 <disk>
    8000627a:	6605                	lui	a2,0x1
    8000627c:	4581                	li	a1,0
    8000627e:	6488                	ld	a0,8(s1)
    80006280:	ffffb097          	auipc	ra,0xffffb
    80006284:	a52080e7          	jalr	-1454(ra) # 80000cd2 <memset>
  memset(disk.used, 0, PGSIZE);
    80006288:	6605                	lui	a2,0x1
    8000628a:	4581                	li	a1,0
    8000628c:	6888                	ld	a0,16(s1)
    8000628e:	ffffb097          	auipc	ra,0xffffb
    80006292:	a44080e7          	jalr	-1468(ra) # 80000cd2 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006296:	100017b7          	lui	a5,0x10001
    8000629a:	4721                	li	a4,8
    8000629c:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    8000629e:	4098                	lw	a4,0(s1)
    800062a0:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    800062a4:	40d8                	lw	a4,4(s1)
    800062a6:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    800062aa:	6498                	ld	a4,8(s1)
    800062ac:	0007069b          	sext.w	a3,a4
    800062b0:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800062b4:	9701                	srai	a4,a4,0x20
    800062b6:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800062ba:	6898                	ld	a4,16(s1)
    800062bc:	0007069b          	sext.w	a3,a4
    800062c0:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800062c4:	9701                	srai	a4,a4,0x20
    800062c6:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    800062ca:	4705                	li	a4,1
    800062cc:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    800062ce:	00e48c23          	sb	a4,24(s1)
    800062d2:	00e48ca3          	sb	a4,25(s1)
    800062d6:	00e48d23          	sb	a4,26(s1)
    800062da:	00e48da3          	sb	a4,27(s1)
    800062de:	00e48e23          	sb	a4,28(s1)
    800062e2:	00e48ea3          	sb	a4,29(s1)
    800062e6:	00e48f23          	sb	a4,30(s1)
    800062ea:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    800062ee:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    800062f2:	0727a823          	sw	s2,112(a5)
}
    800062f6:	60e2                	ld	ra,24(sp)
    800062f8:	6442                	ld	s0,16(sp)
    800062fa:	64a2                	ld	s1,8(sp)
    800062fc:	6902                	ld	s2,0(sp)
    800062fe:	6105                	addi	sp,sp,32
    80006300:	8082                	ret
    panic("could not find virtio disk");
    80006302:	00002517          	auipc	a0,0x2
    80006306:	65e50513          	addi	a0,a0,1630 # 80008960 <systemCallsNames+0x330>
    8000630a:	ffffa097          	auipc	ra,0xffffa
    8000630e:	236080e7          	jalr	566(ra) # 80000540 <panic>
    panic("virtio disk FEATURES_OK unset");
    80006312:	00002517          	auipc	a0,0x2
    80006316:	66e50513          	addi	a0,a0,1646 # 80008980 <systemCallsNames+0x350>
    8000631a:	ffffa097          	auipc	ra,0xffffa
    8000631e:	226080e7          	jalr	550(ra) # 80000540 <panic>
    panic("virtio disk should not be ready");
    80006322:	00002517          	auipc	a0,0x2
    80006326:	67e50513          	addi	a0,a0,1662 # 800089a0 <systemCallsNames+0x370>
    8000632a:	ffffa097          	auipc	ra,0xffffa
    8000632e:	216080e7          	jalr	534(ra) # 80000540 <panic>
    panic("virtio disk has no queue 0");
    80006332:	00002517          	auipc	a0,0x2
    80006336:	68e50513          	addi	a0,a0,1678 # 800089c0 <systemCallsNames+0x390>
    8000633a:	ffffa097          	auipc	ra,0xffffa
    8000633e:	206080e7          	jalr	518(ra) # 80000540 <panic>
    panic("virtio disk max queue too short");
    80006342:	00002517          	auipc	a0,0x2
    80006346:	69e50513          	addi	a0,a0,1694 # 800089e0 <systemCallsNames+0x3b0>
    8000634a:	ffffa097          	auipc	ra,0xffffa
    8000634e:	1f6080e7          	jalr	502(ra) # 80000540 <panic>
    panic("virtio disk kalloc");
    80006352:	00002517          	auipc	a0,0x2
    80006356:	6ae50513          	addi	a0,a0,1710 # 80008a00 <systemCallsNames+0x3d0>
    8000635a:	ffffa097          	auipc	ra,0xffffa
    8000635e:	1e6080e7          	jalr	486(ra) # 80000540 <panic>

0000000080006362 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006362:	7119                	addi	sp,sp,-128
    80006364:	fc86                	sd	ra,120(sp)
    80006366:	f8a2                	sd	s0,112(sp)
    80006368:	f4a6                	sd	s1,104(sp)
    8000636a:	f0ca                	sd	s2,96(sp)
    8000636c:	ecce                	sd	s3,88(sp)
    8000636e:	e8d2                	sd	s4,80(sp)
    80006370:	e4d6                	sd	s5,72(sp)
    80006372:	e0da                	sd	s6,64(sp)
    80006374:	fc5e                	sd	s7,56(sp)
    80006376:	f862                	sd	s8,48(sp)
    80006378:	f466                	sd	s9,40(sp)
    8000637a:	f06a                	sd	s10,32(sp)
    8000637c:	ec6e                	sd	s11,24(sp)
    8000637e:	0100                	addi	s0,sp,128
    80006380:	8aaa                	mv	s5,a0
    80006382:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006384:	00c52d03          	lw	s10,12(a0)
    80006388:	001d1d1b          	slliw	s10,s10,0x1
    8000638c:	1d02                	slli	s10,s10,0x20
    8000638e:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    80006392:	0001c517          	auipc	a0,0x1c
    80006396:	40650513          	addi	a0,a0,1030 # 80022798 <disk+0x128>
    8000639a:	ffffb097          	auipc	ra,0xffffb
    8000639e:	83c080e7          	jalr	-1988(ra) # 80000bd6 <acquire>
  for(int i = 0; i < 3; i++){
    800063a2:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    800063a4:	44a1                	li	s1,8
      disk.free[i] = 0;
    800063a6:	0001cb97          	auipc	s7,0x1c
    800063aa:	2cab8b93          	addi	s7,s7,714 # 80022670 <disk>
  for(int i = 0; i < 3; i++){
    800063ae:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800063b0:	0001cc97          	auipc	s9,0x1c
    800063b4:	3e8c8c93          	addi	s9,s9,1000 # 80022798 <disk+0x128>
    800063b8:	a08d                	j	8000641a <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    800063ba:	00fb8733          	add	a4,s7,a5
    800063be:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    800063c2:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    800063c4:	0207c563          	bltz	a5,800063ee <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    800063c8:	2905                	addiw	s2,s2,1
    800063ca:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    800063cc:	05690c63          	beq	s2,s6,80006424 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    800063d0:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    800063d2:	0001c717          	auipc	a4,0x1c
    800063d6:	29e70713          	addi	a4,a4,670 # 80022670 <disk>
    800063da:	87ce                	mv	a5,s3
    if(disk.free[i]){
    800063dc:	01874683          	lbu	a3,24(a4)
    800063e0:	fee9                	bnez	a3,800063ba <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    800063e2:	2785                	addiw	a5,a5,1
    800063e4:	0705                	addi	a4,a4,1
    800063e6:	fe979be3          	bne	a5,s1,800063dc <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    800063ea:	57fd                	li	a5,-1
    800063ec:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    800063ee:	01205d63          	blez	s2,80006408 <virtio_disk_rw+0xa6>
    800063f2:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    800063f4:	000a2503          	lw	a0,0(s4)
    800063f8:	00000097          	auipc	ra,0x0
    800063fc:	cfe080e7          	jalr	-770(ra) # 800060f6 <free_desc>
      for(int j = 0; j < i; j++)
    80006400:	2d85                	addiw	s11,s11,1
    80006402:	0a11                	addi	s4,s4,4
    80006404:	ff2d98e3          	bne	s11,s2,800063f4 <virtio_disk_rw+0x92>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006408:	85e6                	mv	a1,s9
    8000640a:	0001c517          	auipc	a0,0x1c
    8000640e:	27e50513          	addi	a0,a0,638 # 80022688 <disk+0x18>
    80006412:	ffffc097          	auipc	ra,0xffffc
    80006416:	d1e080e7          	jalr	-738(ra) # 80002130 <sleep>
  for(int i = 0; i < 3; i++){
    8000641a:	f8040a13          	addi	s4,s0,-128
{
    8000641e:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80006420:	894e                	mv	s2,s3
    80006422:	b77d                	j	800063d0 <virtio_disk_rw+0x6e>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006424:	f8042503          	lw	a0,-128(s0)
    80006428:	00a50713          	addi	a4,a0,10
    8000642c:	0712                	slli	a4,a4,0x4

  if(write)
    8000642e:	0001c797          	auipc	a5,0x1c
    80006432:	24278793          	addi	a5,a5,578 # 80022670 <disk>
    80006436:	00e786b3          	add	a3,a5,a4
    8000643a:	01803633          	snez	a2,s8
    8000643e:	c690                	sw	a2,8(a3)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006440:	0006a623          	sw	zero,12(a3)
  buf0->sector = sector;
    80006444:	01a6b823          	sd	s10,16(a3)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80006448:	f6070613          	addi	a2,a4,-160
    8000644c:	6394                	ld	a3,0(a5)
    8000644e:	96b2                	add	a3,a3,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006450:	00870593          	addi	a1,a4,8
    80006454:	95be                	add	a1,a1,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006456:	e28c                	sd	a1,0(a3)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80006458:	0007b803          	ld	a6,0(a5)
    8000645c:	9642                	add	a2,a2,a6
    8000645e:	46c1                	li	a3,16
    80006460:	c614                	sw	a3,8(a2)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006462:	4585                	li	a1,1
    80006464:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[0]].next = idx[1];
    80006468:	f8442683          	lw	a3,-124(s0)
    8000646c:	00d61723          	sh	a3,14(a2)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80006470:	0692                	slli	a3,a3,0x4
    80006472:	9836                	add	a6,a6,a3
    80006474:	058a8613          	addi	a2,s5,88
    80006478:	00c83023          	sd	a2,0(a6)
  disk.desc[idx[1]].len = BSIZE;
    8000647c:	0007b803          	ld	a6,0(a5)
    80006480:	96c2                	add	a3,a3,a6
    80006482:	40000613          	li	a2,1024
    80006486:	c690                	sw	a2,8(a3)
  if(write)
    80006488:	001c3613          	seqz	a2,s8
    8000648c:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006490:	00166613          	ori	a2,a2,1
    80006494:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    80006498:	f8842603          	lw	a2,-120(s0)
    8000649c:	00c69723          	sh	a2,14(a3)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800064a0:	00250693          	addi	a3,a0,2
    800064a4:	0692                	slli	a3,a3,0x4
    800064a6:	96be                	add	a3,a3,a5
    800064a8:	58fd                	li	a7,-1
    800064aa:	01168823          	sb	a7,16(a3)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800064ae:	0612                	slli	a2,a2,0x4
    800064b0:	9832                	add	a6,a6,a2
    800064b2:	f9070713          	addi	a4,a4,-112
    800064b6:	973e                	add	a4,a4,a5
    800064b8:	00e83023          	sd	a4,0(a6)
  disk.desc[idx[2]].len = 1;
    800064bc:	6398                	ld	a4,0(a5)
    800064be:	9732                	add	a4,a4,a2
    800064c0:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800064c2:	4609                	li	a2,2
    800064c4:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[2]].next = 0;
    800064c8:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800064cc:	00baa223          	sw	a1,4(s5)
  disk.info[idx[0]].b = b;
    800064d0:	0156b423          	sd	s5,8(a3)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800064d4:	6794                	ld	a3,8(a5)
    800064d6:	0026d703          	lhu	a4,2(a3)
    800064da:	8b1d                	andi	a4,a4,7
    800064dc:	0706                	slli	a4,a4,0x1
    800064de:	96ba                	add	a3,a3,a4
    800064e0:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    800064e4:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    800064e8:	6798                	ld	a4,8(a5)
    800064ea:	00275783          	lhu	a5,2(a4)
    800064ee:	2785                	addiw	a5,a5,1
    800064f0:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    800064f4:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800064f8:	100017b7          	lui	a5,0x10001
    800064fc:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006500:	004aa783          	lw	a5,4(s5)
    sleep(b, &disk.vdisk_lock);
    80006504:	0001c917          	auipc	s2,0x1c
    80006508:	29490913          	addi	s2,s2,660 # 80022798 <disk+0x128>
  while(b->disk == 1) {
    8000650c:	4485                	li	s1,1
    8000650e:	00b79c63          	bne	a5,a1,80006526 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    80006512:	85ca                	mv	a1,s2
    80006514:	8556                	mv	a0,s5
    80006516:	ffffc097          	auipc	ra,0xffffc
    8000651a:	c1a080e7          	jalr	-998(ra) # 80002130 <sleep>
  while(b->disk == 1) {
    8000651e:	004aa783          	lw	a5,4(s5)
    80006522:	fe9788e3          	beq	a5,s1,80006512 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    80006526:	f8042903          	lw	s2,-128(s0)
    8000652a:	00290713          	addi	a4,s2,2
    8000652e:	0712                	slli	a4,a4,0x4
    80006530:	0001c797          	auipc	a5,0x1c
    80006534:	14078793          	addi	a5,a5,320 # 80022670 <disk>
    80006538:	97ba                	add	a5,a5,a4
    8000653a:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    8000653e:	0001c997          	auipc	s3,0x1c
    80006542:	13298993          	addi	s3,s3,306 # 80022670 <disk>
    80006546:	00491713          	slli	a4,s2,0x4
    8000654a:	0009b783          	ld	a5,0(s3)
    8000654e:	97ba                	add	a5,a5,a4
    80006550:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006554:	854a                	mv	a0,s2
    80006556:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    8000655a:	00000097          	auipc	ra,0x0
    8000655e:	b9c080e7          	jalr	-1124(ra) # 800060f6 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006562:	8885                	andi	s1,s1,1
    80006564:	f0ed                	bnez	s1,80006546 <virtio_disk_rw+0x1e4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006566:	0001c517          	auipc	a0,0x1c
    8000656a:	23250513          	addi	a0,a0,562 # 80022798 <disk+0x128>
    8000656e:	ffffa097          	auipc	ra,0xffffa
    80006572:	71c080e7          	jalr	1820(ra) # 80000c8a <release>
}
    80006576:	70e6                	ld	ra,120(sp)
    80006578:	7446                	ld	s0,112(sp)
    8000657a:	74a6                	ld	s1,104(sp)
    8000657c:	7906                	ld	s2,96(sp)
    8000657e:	69e6                	ld	s3,88(sp)
    80006580:	6a46                	ld	s4,80(sp)
    80006582:	6aa6                	ld	s5,72(sp)
    80006584:	6b06                	ld	s6,64(sp)
    80006586:	7be2                	ld	s7,56(sp)
    80006588:	7c42                	ld	s8,48(sp)
    8000658a:	7ca2                	ld	s9,40(sp)
    8000658c:	7d02                	ld	s10,32(sp)
    8000658e:	6de2                	ld	s11,24(sp)
    80006590:	6109                	addi	sp,sp,128
    80006592:	8082                	ret

0000000080006594 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006594:	1101                	addi	sp,sp,-32
    80006596:	ec06                	sd	ra,24(sp)
    80006598:	e822                	sd	s0,16(sp)
    8000659a:	e426                	sd	s1,8(sp)
    8000659c:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    8000659e:	0001c497          	auipc	s1,0x1c
    800065a2:	0d248493          	addi	s1,s1,210 # 80022670 <disk>
    800065a6:	0001c517          	auipc	a0,0x1c
    800065aa:	1f250513          	addi	a0,a0,498 # 80022798 <disk+0x128>
    800065ae:	ffffa097          	auipc	ra,0xffffa
    800065b2:	628080e7          	jalr	1576(ra) # 80000bd6 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800065b6:	10001737          	lui	a4,0x10001
    800065ba:	533c                	lw	a5,96(a4)
    800065bc:	8b8d                	andi	a5,a5,3
    800065be:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800065c0:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800065c4:	689c                	ld	a5,16(s1)
    800065c6:	0204d703          	lhu	a4,32(s1)
    800065ca:	0027d783          	lhu	a5,2(a5)
    800065ce:	04f70863          	beq	a4,a5,8000661e <virtio_disk_intr+0x8a>
    __sync_synchronize();
    800065d2:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800065d6:	6898                	ld	a4,16(s1)
    800065d8:	0204d783          	lhu	a5,32(s1)
    800065dc:	8b9d                	andi	a5,a5,7
    800065de:	078e                	slli	a5,a5,0x3
    800065e0:	97ba                	add	a5,a5,a4
    800065e2:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800065e4:	00278713          	addi	a4,a5,2
    800065e8:	0712                	slli	a4,a4,0x4
    800065ea:	9726                	add	a4,a4,s1
    800065ec:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    800065f0:	e721                	bnez	a4,80006638 <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800065f2:	0789                	addi	a5,a5,2
    800065f4:	0792                	slli	a5,a5,0x4
    800065f6:	97a6                	add	a5,a5,s1
    800065f8:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    800065fa:	00052223          	sw	zero,4(a0)
    wakeup(b);
    800065fe:	ffffc097          	auipc	ra,0xffffc
    80006602:	ce2080e7          	jalr	-798(ra) # 800022e0 <wakeup>

    disk.used_idx += 1;
    80006606:	0204d783          	lhu	a5,32(s1)
    8000660a:	2785                	addiw	a5,a5,1
    8000660c:	17c2                	slli	a5,a5,0x30
    8000660e:	93c1                	srli	a5,a5,0x30
    80006610:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006614:	6898                	ld	a4,16(s1)
    80006616:	00275703          	lhu	a4,2(a4)
    8000661a:	faf71ce3          	bne	a4,a5,800065d2 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    8000661e:	0001c517          	auipc	a0,0x1c
    80006622:	17a50513          	addi	a0,a0,378 # 80022798 <disk+0x128>
    80006626:	ffffa097          	auipc	ra,0xffffa
    8000662a:	664080e7          	jalr	1636(ra) # 80000c8a <release>
}
    8000662e:	60e2                	ld	ra,24(sp)
    80006630:	6442                	ld	s0,16(sp)
    80006632:	64a2                	ld	s1,8(sp)
    80006634:	6105                	addi	sp,sp,32
    80006636:	8082                	ret
      panic("virtio_disk_intr status");
    80006638:	00002517          	auipc	a0,0x2
    8000663c:	3e050513          	addi	a0,a0,992 # 80008a18 <systemCallsNames+0x3e8>
    80006640:	ffffa097          	auipc	ra,0xffffa
    80006644:	f00080e7          	jalr	-256(ra) # 80000540 <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051073          	csrw	sscratch,a0
    80007004:	02000537          	lui	a0,0x2000
    80007008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000700a:	0536                	slli	a0,a0,0xd
    8000700c:	02153423          	sd	ra,40(a0)
    80007010:	02253823          	sd	sp,48(a0)
    80007014:	02353c23          	sd	gp,56(a0)
    80007018:	04453023          	sd	tp,64(a0)
    8000701c:	04553423          	sd	t0,72(a0)
    80007020:	04653823          	sd	t1,80(a0)
    80007024:	04753c23          	sd	t2,88(a0)
    80007028:	f120                	sd	s0,96(a0)
    8000702a:	f524                	sd	s1,104(a0)
    8000702c:	fd2c                	sd	a1,120(a0)
    8000702e:	e150                	sd	a2,128(a0)
    80007030:	e554                	sd	a3,136(a0)
    80007032:	e958                	sd	a4,144(a0)
    80007034:	ed5c                	sd	a5,152(a0)
    80007036:	0b053023          	sd	a6,160(a0)
    8000703a:	0b153423          	sd	a7,168(a0)
    8000703e:	0b253823          	sd	s2,176(a0)
    80007042:	0b353c23          	sd	s3,184(a0)
    80007046:	0d453023          	sd	s4,192(a0)
    8000704a:	0d553423          	sd	s5,200(a0)
    8000704e:	0d653823          	sd	s6,208(a0)
    80007052:	0d753c23          	sd	s7,216(a0)
    80007056:	0f853023          	sd	s8,224(a0)
    8000705a:	0f953423          	sd	s9,232(a0)
    8000705e:	0fa53823          	sd	s10,240(a0)
    80007062:	0fb53c23          	sd	s11,248(a0)
    80007066:	11c53023          	sd	t3,256(a0)
    8000706a:	11d53423          	sd	t4,264(a0)
    8000706e:	11e53823          	sd	t5,272(a0)
    80007072:	11f53c23          	sd	t6,280(a0)
    80007076:	140022f3          	csrr	t0,sscratch
    8000707a:	06553823          	sd	t0,112(a0)
    8000707e:	00853103          	ld	sp,8(a0)
    80007082:	02053203          	ld	tp,32(a0)
    80007086:	01053283          	ld	t0,16(a0)
    8000708a:	00053303          	ld	t1,0(a0)
    8000708e:	12000073          	sfence.vma
    80007092:	18031073          	csrw	satp,t1
    80007096:	12000073          	sfence.vma
    8000709a:	8282                	jr	t0

000000008000709c <userret>:
    8000709c:	12000073          	sfence.vma
    800070a0:	18051073          	csrw	satp,a0
    800070a4:	12000073          	sfence.vma
    800070a8:	02000537          	lui	a0,0x2000
    800070ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800070ae:	0536                	slli	a0,a0,0xd
    800070b0:	02853083          	ld	ra,40(a0)
    800070b4:	03053103          	ld	sp,48(a0)
    800070b8:	03853183          	ld	gp,56(a0)
    800070bc:	04053203          	ld	tp,64(a0)
    800070c0:	04853283          	ld	t0,72(a0)
    800070c4:	05053303          	ld	t1,80(a0)
    800070c8:	05853383          	ld	t2,88(a0)
    800070cc:	7120                	ld	s0,96(a0)
    800070ce:	7524                	ld	s1,104(a0)
    800070d0:	7d2c                	ld	a1,120(a0)
    800070d2:	6150                	ld	a2,128(a0)
    800070d4:	6554                	ld	a3,136(a0)
    800070d6:	6958                	ld	a4,144(a0)
    800070d8:	6d5c                	ld	a5,152(a0)
    800070da:	0a053803          	ld	a6,160(a0)
    800070de:	0a853883          	ld	a7,168(a0)
    800070e2:	0b053903          	ld	s2,176(a0)
    800070e6:	0b853983          	ld	s3,184(a0)
    800070ea:	0c053a03          	ld	s4,192(a0)
    800070ee:	0c853a83          	ld	s5,200(a0)
    800070f2:	0d053b03          	ld	s6,208(a0)
    800070f6:	0d853b83          	ld	s7,216(a0)
    800070fa:	0e053c03          	ld	s8,224(a0)
    800070fe:	0e853c83          	ld	s9,232(a0)
    80007102:	0f053d03          	ld	s10,240(a0)
    80007106:	0f853d83          	ld	s11,248(a0)
    8000710a:	10053e03          	ld	t3,256(a0)
    8000710e:	10853e83          	ld	t4,264(a0)
    80007112:	11053f03          	ld	t5,272(a0)
    80007116:	11853f83          	ld	t6,280(a0)
    8000711a:	7928                	ld	a0,112(a0)
    8000711c:	10200073          	sret
	...
