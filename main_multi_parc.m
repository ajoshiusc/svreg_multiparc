clc;clear all;close all;restoredefaultpath;

addpath('src');

uscbrain_multi_atlas = '<path>/USCBrainMulti';%correct this
subbasename = '';% correct this
BrainSuitePath = '/home/ajoshi/BrainSuite19b'; % correct this

a=tic;
svreg_multiparc(subbasename,uscbrain_multi_atlas,BrainSuitePath,'all');
toc(a)



