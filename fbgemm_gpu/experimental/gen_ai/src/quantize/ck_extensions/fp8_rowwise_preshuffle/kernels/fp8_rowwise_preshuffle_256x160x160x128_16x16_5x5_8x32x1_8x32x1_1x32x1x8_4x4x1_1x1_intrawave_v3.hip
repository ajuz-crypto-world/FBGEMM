/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree.
 */

#include "fp8_rowwise_preshuffle_common.h"

at::Tensor
fp8_rowwise_preshuffle_256x160x160x128_16x16_5x5_8x32x1_8x32x1_1x32x1x8_4x4x1_1x1_intrawave_v3(
    at::Tensor XQ,
    at::Tensor WQ,
    at::Tensor x_scale,
    at::Tensor w_scale,
    at::Tensor Y) {
  return f8f8bf16_rowwise_preshuffle_wrapper<
      256,
      160,
      160,
      128,
      16,
      16,
      5,
      5,
      S<8, 32, 1>,
      S<8, 32, 1>,
      S<1, 32, 1, 8>,
      S<4, 4, 1>,
      1,
      1,
      ck::BlockGemmPipelineScheduler::Intrawave,
      ck::BlockGemmPipelineVersion::v3>(XQ, WQ, x_scale, w_scale, Y, 1);
}
