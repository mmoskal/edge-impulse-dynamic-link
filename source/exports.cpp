#include "interface.h"

#include "numpy_types.h"
#include "ei_classifier_porting.h"
#include "ei_classifier_types.h"
#include "ei_run_classifier.h"

using namespace ei;

static const float *dataP;

static int get_feature_data(size_t offset, size_t length, float *out_ptr) {
  memcpy(out_ptr, dataP + offset, length * sizeof(float));
  return 0;
}

extern "C" int ei_interface(const float *data, unsigned numdata, float *classification) {
  signal_t signal;
  dataP = data;
  signal.total_length = numdata;
  signal.get_data = &get_feature_data;

  ei_impulse_result_t result;

  EI_IMPULSE_ERROR res = run_classifier(&signal, &result, true);
  if (res)
    return res;

  // TODO return timing results?
  for (int i = 0; i < EI_CLASSIFIER_LABEL_COUNT; ++i)
    classification[i] = result.classification[i].value;
  
  return 0;
}

extern uint32_t _sidata, _sdata, _edata, _ebss;

static void my_init(void *comm_data, uint32_t comm_size) {
  if (comm_data != &_sdata)
    abort();
  if ((uint8_t *)&_ebss - (uint8_t *)comm_data > (int)comm_size)
    abort();
  uint32_t *dst = &_sdata;
  uint32_t *end = &_edata;
  uint32_t *src = &_sidata;
  while (dst < end)
    *dst++ = *src++;
  end = &_ebss;
  while (dst < end)
    *dst++ = 0;
}

__attribute__((section(".ei_vector"))) __attribute__((used))
const struct interface_vectors vectors = {
    //
    IFACE_MAGIC,
    (uint32_t)&vectors,
    (uint32_t)&_sdata,
    (uint32_t)&_ebss,
    {0}, // imports
    // metadata follows
    EI_CLASSIFIER_RAW_SAMPLE_COUNT,
    EI_CLASSIFIER_RAW_SAMPLES_PER_FRAME,
    EI_CLASSIFIER_INTERVAL_MS,
    EI_CLASSIFIER_LABEL_COUNT,
    EI_CLASSIFIER_HAS_ANOMALY,
    ei_classifier_inferencing_categories,
    {0},
    my_init,
    ei_interface,
    {0}};
