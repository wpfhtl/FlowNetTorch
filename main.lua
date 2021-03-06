--
--  Copyright (c) 2014, Facebook, Inc.
--  All rights reserved.
--
--  This source code is licensed under the BSD-style license found in the
--  LICENSE file in the root directory of this source tree. An additional grant
--  of patent rights can be found in the PATENTS file in the same directory.
--
require 'torch'
require 'cutorch'
require 'paths'
require 'xlua'
require 'optim'
require 'nn'
require 'cunn'
require 'cudnn'

torch.setdefaulttensortype('torch.FloatTensor')

local opts = paths.dofile('opts.lua')

opt = opts.parse(arg)

nClasses = opt.nClasses

print('Saving everything to: ' .. opt.save)
paths.mkdir(opt.save)

paths.dofile('util.lua')
paths.dofile('model.lua')
opt.imageSize = model.imageSize or {opt.width,opt.height}
opt.imageCrop = model.imageCrop or {opt.cropWith,opt.cropHeight}

print(opt)

cutorch.setDevice(opt.GPU) -- by default, use GPU 1
if opt.cudnnMode == 1 then
  cudnn.benchmark = true
elseif opt.cudnnMode == 2 then
  cudnn.benchmark = true
  cudnn.fastest = true
end
torch.manualSeed(opt.manualSeed)



paths.dofile('data.lua')
paths.dofile('train.lua')
paths.dofile('test.lua')

epoch = opt.epochNumber - 1
if opt.retrain ~= 'none' then
    test()
end
for i=1,opt.nEpochs do
   epoch = epoch +1
   train()
   test()
   testLogger:plot()
   trainLogger:plot()
end
