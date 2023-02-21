CLANG_BASE := /cvmfs/patatrack.cern.ch/externals/x86_64/rhel8/intel/sycl/nightly/20230119
CLANG := $(CLANG_BASE)/bin/clang++
CUDA_BASE := /usr/local/cuda
CUDA_LIBDIR := $(CUDA_BASE)/lib64
CUDA_ARCH := 60
CLANG_FLAGS := -x cuda -std=c++17 -O3 -g -fPIC -include noinline.h -Wno-deprecated-declarations --cuda-path=$(CUDA_BASE) -I$(CUDA_BASE)/include $(foreach ARCH,$(CUDA_ARCH), --cuda-gpu-arch=sm_$(ARCH))
CLANG_LDFLAGS := -L$(CUDA_LIBDIR) -lcudart -ldl -lrt -O3 -fPIC -pthread -Wl,-E -lstdc++fs

SRCS    = $(wildcard *.cu)
OBJS = $(patsubst %.cu,%.o,$(SRCS))
%.o: %.cu
	$(CLANG) $(CLANG_FLAGS) -c $< -o $@

.PHONY: all
all: $(patsubst %.o,%,$(OBJS))
%: %.o
	$(CLANG) $(CLANG_LDFLAGS) $< -o $@

clean:
	rm -fR $(patsubst %.o,%,$(OBJS))

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
	@echo -n '$(CLANG_BASE)/lib64:'                                              >> $@
	@echo '$$LD_LIBRARY_PATH'                                               >> $@
	@echo -n 'export PATH='                                                 >> $@
	@echo -n '$(CUDA_BASE)/bin:'                                            >> $@
	@echo -n '$(CLANG_BASE)/bin:'                                            >> $@
	@echo '$$PATH'                                                          >> $@
