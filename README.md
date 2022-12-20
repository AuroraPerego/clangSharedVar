## Reproducer for a bug with shared variables in clang

Shared variables sometimes seem not to be updated (unless their value is printed).
This behaviour has been observed on a NVIDIA GeForce GTX 1080 Ti (sm_61) and on a Tesla P100 (sm_60), but not on newer GPUs.
(Older GPUs have not been tested).

To reproduce:
```bash
git clone https://github.com/AuroraPerego/clangSharedVar
cd clangSharedVar
make environment
source env.sh
make
```

This will trigger an assert.
Now go to `radiSort.h` and uncomment lines 181-182 and 206-207.
Another way to obtain correct results is to remove the `__syncthreads()` at lines 180-205
or to replace them with `__threadfence_block()`.

After one of these changes:
```bash
make clean
make
./test
```

This will compile and run fine (and print a bunch of numbers).
