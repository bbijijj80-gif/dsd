obj-m += linux_tips.o

KDIR ?= /lib/modules/$(shell uname -r)/build
PWD  := $(shell pwd)

all:
	$(MAKE) -C $(KDIR) M=$(PWD) modules

clean:
	$(MAKE) -C $(KDIR) M=$(PWD) clean

load: all
	sudo insmod linux_tips.ko

unload:
	sudo rmmod linux_tips

.PHONY: all clean load unload
