
FlowNet for Torch
=======
## Summary

This repository is a torch implementation of [FlowNet](http://lmb.informatik.uni-freiburg.de/Publications/2015/DFIB15/), by [Alexey Dosovitskiy](http://lmb.informatik.uni-freiburg.de/people/dosovits/) et al. in Torch

This code is mainly inspired from soumith's [imagenet-multiGPU.torch](https://github.com/soumith/imagenet-multiGPU.torch%5D) , Flow file loader taken from [artistic-videos](https://github.com/manuelruder/artistic-videos). It has not been tested for multiple GPU, but it should work just as in soumith's code. You may have to modify the models specifications.

The code provides a training example, using [the flying chair dataset](http://lmb.informatik.uni-freiburg.de/resources/datasets/FlyingChairs.en.html) , with data augmentation. An implementation for [Scene Flow Datasets](http://lmb.informatik.uni-freiburg.de/resources/datasets/SceneFlowDatasets.en.html) may be added in the future.

The four neural network models that are provided are :

 - **FlowNetS**
 - **FlowNetSBN**
 - **FlowNetSGraph**
 - **FlowNetSBNGraph**

**FlowNetSGraph** and **FlowNetSBNGraph** need `nngraph` to be used, and need `graph` to be displayed while **FlowNetS** and **FlowNetSBN** can be directly printed in console, but they are much simpler.
We recommend using FlowNetSBNGraph, as it reaches a better EPE (End Point Error)

There is not current implementation of FlowNetC as a specific Correlation layer module would need to be written (feel free to contribute !)

## Pretrained Models
Thanks to [loadcaffe](https://github.com/szagoruyko/loadcaffe) and [Pauline Luc](https://github.com/paulineluc)'s [commit](https://github.com/szagoruyko/loadcaffe/pull/75) , we were able to load pretrained caffe models in torch. If you don't want to install this unofficial pull request, you can get them directly here (float version) :

 - [Drive Folder](https://drive.google.com/open?id=0B5EC7HMbyk3CbjFPb0RuODI3NmM)

No training is currently provided for DispNet

*Note on expected inputs ranges*

the input is supposed to be BGR [0,1] for the caffe pretrained models. But in the end it does not really matter if you take RGB [0,1] or BGR [0,1], since during caffe training they did color warps as data augmentation.

Torch pretrained models however (with 'from_scratch' appended to the name) expects a normalized inputs as in the training code.

## Training on Flying Chair Dataset

First, you need to download the [the flying chair dataset](http://lmb.informatik.uni-freiburg.de/resources/datasets/FlyingChairs.en.html) . It is ~64GB big and we recommend you put in a SSD Drive.

Default HyperParameters provided in `opts.lua` are the same as in the caffe training scripts.

Example usage for FlowNetSGraph, fine tuning from FlowNetS_SmallDisp :

    th main.lua -data /path/to/flying_chairs/ -batchSize 8 -nDonkeys 8 -netType FlowNetSBNGraph -nEpochs 80 -retrain model_flownet_finetuning.t7

We recommend you set nDonkeys (number of data threads) to high if you use DataAugmentation as to avoid data loading to slow the training.

For further help you can type

	th main.lua -h

(as in Soumith's Original code)

*Note on loss function* : The training error used here, is the L1 Error (`nn.AbsCriterion`) whereas they say in the paper they used End Point Error (which is not the same as mean square error implementation provided by `nn.MSECriterion`). However the Criterion used in the code they provided is clearly the L1 criterion. We chose to use this criterion as an EPE criterion would require to hardcode a new criterion in CUDA. We also name it EPE instead of 'L1Error' to save space on CLI.
*Update* : A real 'EPE' has been implemented [here](https://github.com/ClementPinard/FlowNetTorch/blob/master/EPECriterion.lua). As pointed by some, caffe code actually includes an EPE layer before Criterion. 'L1Error' is then used compared to a zero-filled array. We did the same thing here, while keeping inside a criterion, in order to have the same model specifications for both training and test.
However, tests showed that convergence was not better.

## Training Results

|  FlowNetS | FlowNetSBN |
|---|----|
![train_result](https://github.com/ClementPinard/FlowNetTorch/blob/master/images/FlowNetStrain.png) |  ![test_result](https://github.com/ClementPinard/FlowNetTorch/blob/master/images/FlowNetSBNtrain.png)
![train_result](https://github.com/ClementPinard/FlowNetTorch/blob/master/images/FlowNetStest.png) |  ![test_result](https://github.com/ClementPinard/FlowNetTorch/blob/master/images/FlowNetSBNtest.png)


## Live Demo

Thanks to [Sergey Zagoruyko](https://github.com/szagoruyko)'s [Torch OpenCV Demo](https://github.com/szagoruyko/torch-opencv-demos) , you can run a live demo using [OpenCV bindings for torch](https://github.com/VisionLabs/torch-opencv)
It has been tested on a **Quadro K2200M** powered Laptop at ~3 fps using training input size (you can speed it up by reducing input size)

	th liveDemo.lua --model FlowNetS_pretrained.t7 --input_height 256 --output_height 1200

The code is optimized for BGR [0,1] inputs (so for caffe pretrained networks), but still works decently for models from torch.

## Update regarding flying chairs dataset.

[the flying chair dataset](http://lmb.informatik.uni-freiburg.de/resources/datasets/FlyingChairs.en.html) is no longer using a list file, which made this implementation unable to retrieve image and flow files. The code has been updated to get it by itself (as the filenames follow a very regular pattern).

However, if you want to add your own image pairs to the dataset, the compatibility with the list file is keeped. You can grab a (maybe outdated) backup of list file [here](https://drive.google.com/open?id=0B5EC7HMbyk3COEVEZ1VETzhhMnc)
