#pragma once

#include <stdint.h>
#include <stdlib.h>
#include <stdarg.h>

#define IFACE_MAGIC 0x30564945

struct import_vectors {
  void (*abort)();
  void *(*realloc)(void *ptr, size_t sz);
  int (*vprintf)(const char *fmt, va_list ap);
  uint32_t (*get_time_ms)();
  uint64_t (*get_time_us)();
  uint32_t paddingInterface[32 - 6];
};

struct interface_vectors {
  uint32_t magic;
  uint32_t text_base;
  uint32_t ram_start;
  uint32_t ram_end;

  struct import_vectors imports;

  uint32_t frames_in_window;
  uint32_t channels;
  uint32_t sampling_interval_ms;
  uint32_t num_classifier_labels;
  uint32_t has_anomaly;
  const char **labels;
  uint32_t paddingAttributes[32 - 6];

  void (*ei_init)(void *comm_data, uint32_t comm_size);
  int (*ei_classify)(const float *data, unsigned numdata, float *classification);
  uint32_t paddingEntries[14];
};

extern const struct interface_vectors vectors;
