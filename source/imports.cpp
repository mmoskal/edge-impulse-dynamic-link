#include "interface.h"

extern "C" {

void abort(void) {
  vectors.imports.abort();
  while (1)
    ;
}
void exit(int r) { abort(); }

void *realloc(void *ptr, size_t size) {
  return vectors.imports.realloc(ptr, size);
}
void *malloc(size_t sz) { return realloc(NULL, sz); }
void free(void *ptr) {
  void *dummy = realloc(ptr, 0);
  (void)dummy;
}

void __cxa_pure_virtual() { abort(); }

// make sure the libc allocator is not pulled in
void *_malloc_r(struct _reent *, size_t len) { return malloc(len); }
void *_realloc_r(struct _reent *, void *ptr, size_t len) {
  return realloc(ptr, len);
}
void _free_r(struct _reent *, void *addr) { free(addr); }

int vprintf(const char *format, va_list ap) {
  return vectors.imports.vprintf(format, ap);
}

int printf(const char *format, ...) {
  va_list arg;
  va_start(arg, format);
  vprintf(format, arg);
  va_end(arg);
  return 0;
}

// gcc optimizes printf() to fwrite()
size_t fwrite(const void *errmsg, size_t x, size_t y, void *f) {
  return printf("%s", errmsg);
}

void __assert_func() { abort(); }
} // extern C

void DebugLog(const char *s) { printf("%s", s); }

int ei_run_impulse_check_canceled() { return 0; }

int ei_sleep(int32_t time_ms) {
  // usleep(time_ms * 1000);
  return 0;
}

uint64_t ei_read_timer_ms() { return vectors.imports.get_time_ms(); }

uint64_t ei_read_timer_us() { return vectors.imports.get_time_us(); }

void ei_printf(const char *format, ...) {
  va_list arg;
  va_start(arg, format);
  vprintf(format, arg);
  va_end(arg);
}

void ei_printf_float(float f) {
  // TODO
  ei_printf("%f", f);
}

void *operator new(size_t sz) { return malloc(sz); }
void *operator new[](size_t sz) { return malloc(sz); }
void operator delete(void *p) { free(p); }

void operator delete[](void *p) { free(p); }

namespace std {
void __throw_bad_alloc() { abort(); }
void __throw_out_of_range_fmt(char const *, ...) { abort(); }
} // namespace std
