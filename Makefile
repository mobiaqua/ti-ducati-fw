include Rules.make

.PHONY:	all clean base ipu ipu_clean

all: bios osal ipc xdais fc ce rpmsg ipumm

base: bios osal ipc xdais fc ce

ipu: base rpmsg ipumm

ipu_clean: rpmsg_clean ipumm_clean

clean: bios_clean osal_clean ipc_clean xdais_clean fc_clean ce_clean rpmsg_clean ipumm_clean

ipc:
	$(MAKE) -C $(IPC_INSTALL_DIR) $(IPC_CONF) ti.targets.arm.elf.M3=${TMS470CGTOOLPATH} -ef ipc.mak all

ipc_clean:
	$(MAKE) -C $(IPC_INSTALL_DIR) $(IPC_CONF) -f ipc.mak clean

fc:
	$(MAKE) -C $(FC_INSTALL_DIR) $(FC_CONF) ti.targets.arm.elf.M3=${TMS470CGTOOLPATH} -ef fc.mak all

fc_clean:
	$(MAKE) -C $(FC_INSTALL_DIR) $(FC_CONF) -f fc.mak clean

ce:
	$(MAKE) -C $(CE_INSTALL_DIR) $(CE_CONF) ti.targets.arm.elf.M3=${TMS470CGTOOLPATH} -ef codec_engine.mak all

ce_clean:
	$(MAKE) -C $(CE_INSTALL_DIR) $(CE_CONF) -f codec_engine.mak clean

xdais:
	$(MAKE) -C $(XDAIS_INSTALL_DIR) $(XDAIS_CONF) ti.targets.arm.elf.M3=${TMS470CGTOOLPATH} -ef xdais.mak all

xdais_clean:
	$(MAKE) -C $(XDAIS_INSTALL_DIR) $(XDAIS_CONF) -f xdais.mak clean

osal:
	$(MAKE) -C $(OSAL_INSTALL_DIR) $(OSAL_CONF) ti.targets.arm.elf.M3=${TMS470CGTOOLPATH} -ef osal.mak all

osal_clean:
	$(MAKE) -C $(OSAL_INSTALL_DIR) $(OSAL_CONF) -f osal.mak clean

bios:
	$(MAKE) -C $(BIOS_INSTALL_DIR) $(BIOS_CONF) ti.targets.arm.elf.M3=${TMS470CGTOOLPATH} -f bios.mak all

bios_clean:
	$(MAKE) -C $(BIOS_INSTALL_DIR) $(BIOS_CONF) -f bios.mak clean

rpmsg:.
	$(MAKE) -C $(RPMSG_INSTALL_DIR) $(RPMSG_CONF) smp_config
	$(MAKE) -C $(RPMSG_INSTALL_DIR) $(RPMSG_CONF)

rpmsg_clean:
	$(MAKE) -C $(RPMSG_INSTALL_DIR) $(RPMSG_CONF) clean

ipumm:
	$(MAKE) -C $(IPUMM_INSTALL_DIR) $(IPUMM_CONF) omap4_smp_config
	$(MAKE) -C $(IPUMM_INSTALL_DIR) $(IPUMM_CONF)

ipumm_clean:
	$(MAKE) -C $(IPUMM_INSTALL_DIR) $(IPUMM_CONF) clean