CLANG := clang++-14
CUDA_BASE := /usr/local/cuda-11.5.0
CUDA_LIBDIR := $(CUDA_BASE)/lib64
CUDA-ARCH := 50 60 70
CLANG_FLAGS := -x cuda -std=c++17 -O3 -g -include noinline.h -Wno-deprecated-declarations  -fPIC -I$(CUDA_BASE)/include $(foreach ARCH,$(CUDA_ARCH), --cuda-gpu-arch=sm_$(ARCH))
CLANG_LDFLAGS := -L$(CUDA_LIBDIR) -lcudart -ldl -lrt -O3 -fPIC -pthread -Wl,-E -lstdc++fs

SRCS    = $(wildcard *.cu)
OBJS = $(patsubst %.cu,%.o,$(SRCS))
%.o: %.cu
	@[ -d $(@D) ] || mkdir -p $(@D)
	$(CLANG) $(CLANG_FLAGS) -c $< -o $@ -MMD

.PHONY: all
all: $(patsubst %.o,%,$(OBJS))
%: %.o
	@[ -d $(@D) ] || mkdir -p $(@D)
	$(CLANG) $(CLANG_LDFLAGS) $< -o $@

.PRECIOUS: %.o

clean:
	rm -fR $(OBJS) $(patsubst %.o,%.d,$(OBJS)) $(patsubst %.o,%,$(OBJS))

environment: env.sh
env.sh: Makefile
	@echo '#! /bin/bash'                                                    >  $@
	@echo 'if [ -f .original_env ]; then'                                   >> $@
	@echo '  source .original_env'                                          >> $@
	@echo 'else'                                                            >> $@
	@echo '  echo "#! /bin/bash"                       >  .original_env'    >> $@
	@echo '  echo "PATH=$$PATH"                         >> .original_env'   >> $@
	@echo '  echo "LD_LIBRARY_PATH=$$LD_LIBRARY_PATH"   >> .original_env'   >> $@
	@echo 'fi'                                                              >> $@
	@echo                                                                   >> $@
	@echo -n 'export LD_LIBRARY_PATH='                                      >> $@
	@echo -n '$(CUDA_LIBDIR):'                                              >> $@
	@echo '$$LD_LIBRARY_PATH'                                               >> $@
	@echo -n 'export PATH='                                                 >> $@
	@echo -n '$(CUDA_BASE)/bin:'                                            >> $@
	@echo '$$PATH'                                                          >> $@
