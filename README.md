## Reproducer for a bug with shared variables in clang

Shared variables sometimes seem not to be updated (unless their value is printed).
To reproduce:
```bash
git clone https://github.com/AuroraPerego/clangSharedVar
cd clangSharedVar
make environment
source env.sh
make all
```

This will trigger an assert.
Now go to `radiSort.h` and uncomment lines 181-182 and 206-207.

```bash
make clean
make all
./test
```

This will compile and run fine (and print a bunch of numbers).
