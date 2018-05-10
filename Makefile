
RISCV_GNU_TOOLCHAIN_GIT_REVISION = bf5697a
RISCV_GNU_TOOLCHAIN_INSTALL_PREFIX = /space/riscv32

VCDPRUNE = ./vcdprune

SHELL = bash
TEST_OBJS = $(addsuffix .o,$(basename $(wildcard tests/*.S)))
HELLO_OBJS = start.o tb.o hello/irq.o hello/main.o
GCC_WARNS  = -Werror -Wall -Wextra -Wshadow -Wundef -Wpointer-arith -Wcast-qual -Wcast-align -Wwrite-strings
GCC_WARNS += -Wredundant-decls -Wstrict-prototypes -pedantic # -Wconversion
TOOLCHAIN_PREFIX = $(RISCV_GNU_TOOLCHAIN_INSTALL_PREFIX)imc/bin/riscv32-unknown-elf-
COMPRESSED_ISA = C

default: hello_verilator

hello_icarus: hello/hello.hex icarus.vcd
hello_verilator: hello/hello.hex verilator.vcd

icarus.vcd: testbench.vvp
	vvp -N $< +vcd +trace +noerror +dumplevel=1

testbench.vvp: tb_icar.v ddgp_rv32i.v
	iverilog -o $@ $(subst C,-DCOMPRESSED_ISA,$(COMPRESSED_ISA)) $^
	chmod -x $@

obj_dir/Vtb_veri: tb_veri.v tb_veri.cc ddgp_rv32i.v
	verilator --cc --exe \
		--trace \
		--trace-depth 1 \
		-Wno-fatal \
		--top-module tb_veri \
		--clk i_clk \
		tb_veri.cc \
		tb_veri.v ddgp_rv32i.v
	$(MAKE) -C obj_dir -f Vtb_veri.mk

verilator.vcd: obj_dir/Vtb_veri
	obj_dir/Vtb_veri
	mv $@ $@.unpruned
	$(VCDPRUNE) $@.unpruned -o $@
	rm $@.unpruned

firmware/firmware.hex: firmware/firmware.bin makehex.py
	python3 makehex.py $< 16384 > $@

firmware/firmware.bin: firmware/firmware.elf
	$(TOOLCHAIN_PREFIX)objcopy -O binary $< $@
	chmod -x $@

firmware/firmware.elf: $(FIRMWARE_OBJS) $(TEST_OBJS) firmware/sections.lds
	$(TOOLCHAIN_PREFIX)gcc -Os -ffreestanding -nostdlib -o $@ \
		-Wl,-Bstatic,-T,firmware/sections.lds,-Map,firmware/firmware.map,--strip-debug \
		$(FIRMWARE_OBJS) $(TEST_OBJS) -lgcc
	chmod -x $@

firmware/start.o: firmware/start.S
	$(TOOLCHAIN_PREFIX)gcc -c -march=rv32im$(subst C,c,$(COMPRESSED_ISA)) -o $@ $<

firmware/%.o: firmware/%.c
	$(TOOLCHAIN_PREFIX)gcc -c -march=rv32i$(subst C,c,$(COMPRESSED_ISA)) -Os --std=c99 $(GCC_WARNS) -ffreestanding -nostdlib -o $@ $<


fft1024/fft1024.hex: fft1024/fft1024.bin makehex.py
	python3 makehex.py $< 16384 > $@
	cp $@ test.hex

fft1024/fft1024.bin: fft1024/fft1024.elf
	$(TOOLCHAIN_PREFIX)objcopy -O binary $< $@
	chmod -x $@

fft1024/fft1024.elf: $(FFT1024_OBJS) fft1024/sections.lds
	$(TOOLCHAIN_PREFIX)gcc -Os -ffreestanding -nostdlib -o $@ \
		-Wl,-Bstatic,-T,fft1024/sections.lds,-Map,fft1024/fft1024.map,--strip-debug \
		$(FFT1024_OBJS) -lm -lgcc
	chmod -x $@
	$(TOOLCHAIN_PREFIX)objdump -D $@ > $@.dasm

fft1024/%.o: fft1024/%.c
	$(TOOLCHAIN_PREFIX)gcc -c -march=rv32imc \
		-Os --std=c99 $(GCC_WARNS) -ffreestanding -nostdlib \
		-I . -o $@ $<


hello/hello.hex: hello/hello.bin makehex.py
	python3 makehex.py $< 16384 > $@
	cp $@ test.hex

hello/hello.bin: hello/hello.elf
	$(TOOLCHAIN_PREFIX)objcopy -O binary $< $@
	chmod -x $@

hello/hello.elf: $(HELLO_OBJS) hello/sections.lds
	$(TOOLCHAIN_PREFIX)gcc -Os -ffreestanding -nostdlib -o $@ \
		-Wl,-Bstatic,-T,hello/sections.lds,-Map,hello/hello.map,--strip-debug \
		$(HELLO_OBJS) -lm -lgcc
	chmod -x $@
	$(TOOLCHAIN_PREFIX)objdump -D $@ > $@.dasm

hello/%.o: hello/%.c
	$(TOOLCHAIN_PREFIX)gcc -c -march=rv32i$(subst C,c,$(COMPRESSED_ISA)) \
		-Os --std=c99 $(GCC_WARNS) -ffreestanding -nostdlib \
		-I . -o $@ $<

%.o: %.c
	$(TOOLCHAIN_PREFIX)gcc -c -march=rv32i$(subst C,c,$(COMPRESSED_ISA)) \
		-Os --std=c99 $(GCC_WARNS) -ffreestanding -nostdlib \
		-o $@ $<

%.o: %.S
	$(TOOLCHAIN_PREFIX)gcc -c -march=rv32im$(subst C,c,$(COMPRESSED_ISA)) \
	-o $@ $<


tests/%.o: tests/%.S tests/riscv_test.h tests/test_macros.h
	$(TOOLCHAIN_PREFIX)gcc -c -march=rv32im -o $@ -DTEST_FUNC_NAME=$(notdir $(basename $<)) \
		-DTEST_FUNC_TXT='"$(notdir $(basename $<))"' -DTEST_FUNC_RET=$(notdir $(basename $<))_ret $<

download-tools:
	sudo bash -c 'set -ex; mkdir -p /var/cache/distfiles; \
	$(foreach REPO,riscv-gnu-toolchain riscv-binutils-gdb riscv-dejagnu riscv-gcc riscv-glibc riscv-newlib, \
		if ! test -d /var/cache/distfiles/$(REPO).git; then rm -rf /var/cache/distfiles/$(REPO).git.part; \
			git clone --bare https://github.com/riscv/$(REPO) /var/cache/distfiles/$(REPO).git.part; \
			mv /var/cache/distfiles/$(REPO).git.part /var/cache/distfiles/$(REPO).git; else \
			(cd /var/cache/distfiles/$(REPO).git; git fetch https://github.com/riscv/$(REPO)); fi;)'

define build_tools_template
build-$(1)-tools:
	@read -p "This will remove all existing data from $(RISCV_GNU_TOOLCHAIN_INSTALL_PREFIX)$(subst riscv32,,$(1)). Type YES to continue: " reply && [[ "$$$$reply" == [Yy][Ee][Ss] || "$$$$reply" == [Yy] ]]
	sudo bash -c "set -ex; rm -rf $(RISCV_GNU_TOOLCHAIN_INSTALL_PREFIX)$(subst riscv32,,$(1)); mkdir -p $(RISCV_GNU_TOOLCHAIN_INSTALL_PREFIX)$(subst riscv32,,$(1)); chown $$$${USER}. $(RISCV_GNU_TOOLCHAIN_INSTALL_PREFIX)$(subst riscv32,,$(1))"
	+$(MAKE) build-$(1)-tools-bh

build-$(1)-tools-bh:
	+set -ex; \
	if [ -d /var/cache/distfiles/riscv-gnu-toolchain.git ]; then reference_riscv_gnu_toolchain="--reference /var/cache/distfiles/riscv-gnu-toolchain.git"; else reference_riscv_gnu_toolchain=""; fi; \
	if [ -d /var/cache/distfiles/riscv-binutils-gdb.git ]; then reference_riscv_binutils_gdb="--reference /var/cache/distfiles/riscv-binutils-gdb.git"; else reference_riscv_binutils_gdb=""; fi; \
	if [ -d /var/cache/distfiles/riscv-dejagnu.git ]; then reference_riscv_dejagnu="--reference /var/cache/distfiles/riscv-dejagnu.git"; else reference_riscv_dejagnu=""; fi; \
	if [ -d /var/cache/distfiles/riscv-gcc.git ]; then reference_riscv_gcc="--reference /var/cache/distfiles/riscv-gcc.git"; else reference_riscv_gcc=""; fi; \
	if [ -d /var/cache/distfiles/riscv-glibc.git ]; then reference_riscv_glibc="--reference /var/cache/distfiles/riscv-glibc.git"; else reference_riscv_glibc=""; fi; \
	if [ -d /var/cache/distfiles/riscv-newlib.git ]; then reference_riscv_newlib="--reference /var/cache/distfiles/riscv-newlib.git"; else reference_riscv_newlib=""; fi; \
	rm -rf riscv-gnu-toolchain-$(1); git clone $$$$reference_riscv_gnu_toolchain https://github.com/riscv/riscv-gnu-toolchain riscv-gnu-toolchain-$(1); \
	cd riscv-gnu-toolchain-$(1); git checkout $(RISCV_GNU_TOOLCHAIN_GIT_REVISION); \
	git submodule update --init $$$$reference_riscv_binutils_gdb riscv-binutils-gdb; \
	git submodule update --init $$$$reference_riscv_dejagnu riscv-dejagnu; \
	git submodule update --init $$$$reference_riscv_gcc riscv-gcc; \
	git submodule update --init $$$$reference_riscv_glibc riscv-glibc; \
	git submodule update --init $$$$reference_riscv_newlib riscv-newlib; \
	mkdir build; cd build; ../configure --with-arch=$(2) --prefix=$(RISCV_GNU_TOOLCHAIN_INSTALL_PREFIX)$(subst riscv32,,$(1)); make

.PHONY: build-$(1)-tools
endef

$(eval $(call build_tools_template,riscv32i,rv32i))
$(eval $(call build_tools_template,riscv32ic,rv32ic))
$(eval $(call build_tools_template,riscv32im,rv32im))
$(eval $(call build_tools_template,riscv32imc,rv32imc))

build-tools:
	@echo "This will remove all existing data from $(RISCV_GNU_TOOLCHAIN_INSTALL_PREFIX)i, $(RISCV_GNU_TOOLCHAIN_INSTALL_PREFIX)ic, $(RISCV_GNU_TOOLCHAIN_INSTALL_PREFIX)im, and $(RISCV_GNU_TOOLCHAIN_INSTALL_PREFIX)imc."
	@read -p "Type YES to continue: " reply && [[ "$$reply" == [Yy][Ee][Ss] || "$$reply" == [Yy] ]]
	sudo bash -c "set -ex; rm -rf $(RISCV_GNU_TOOLCHAIN_INSTALL_PREFIX){i,ic,im,imc}; mkdir -p $(RISCV_GNU_TOOLCHAIN_INSTALL_PREFIX){i,ic,im,imc}; chown $${USER}. $(RISCV_GNU_TOOLCHAIN_INSTALL_PREFIX){i,ic,im,imc}"
	+$(MAKE) build-riscv32i-tools-bh
	+$(MAKE) build-riscv32ic-tools-bh
	+$(MAKE) build-riscv32im-tools-bh
	+$(MAKE) build-riscv32imc-tools-bh

toc:
	gawk '/^-+$$/ { y=tolower(x); gsub("[^a-z0-9]+", "-", y); gsub("-$$", "", y); printf("- [%s](#%s)\n", x, y); } { x=$$0; }' README.md

clean:
	rm -rf riscv-gnu-toolchain-riscv32i riscv-gnu-toolchain-riscv32ic \
		riscv-gnu-toolchain-riscv32im riscv-gnu-toolchain-riscv32imc
	rm -vrf $(TEST_OBJS) check.smt2 check.vcd synth.v synth.log \
		$(FIRMWARE_OBJS) \
		$(FFT1024_OBJS) \
		$(HELLO_OBJS) \
		*.eva/ \
		*/*.elf */*.elf.dasm */*.bin */*.hex */*.map *.vvp *.vcd *.trace obj_dir

.PHONY: test test_vcd test_sp test_axi test_wb test_wb_vcd test_ez test_ez_vcd test_synth download-tools build-tools toc clean
