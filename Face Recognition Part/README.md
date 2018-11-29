# Face-Recognition

Face Recognition Based on Neural Network

## Training the process of database and model building

1) the main application of this experiment is fatigue driving detection system. Based on head posture estimation, the main methods used are SDM face alignment and Posit three-dimensional attitude estimation.

2) the database I use has LFPW (68 points), LFW (66 points) and Helen(66 points).

3) the three databases can be used for academic reference value comparison, and the corresponding training set and test set can be used to compare the experimental results.

4) the specific database used for the establishment of SDM model is Helen (complete data set, 2000 face images) and LFW(partial data set, 2481 face images).

5) SDM model: two models are established: DM (detection model) and TM (tracking model).

First of all, the most important point is that both models are built under the same standard, that is, what kind of face box is used in training and what kind of face box is used in testing.

To be specific, for the detection model, we need to conduct on the basis of face detection. Currently, we usually use the face detector provided by opencv to get a rough face region, which is usually more than the face frame obtained from the critical point of the face

The region (which is the face frame standard adopted by the tracking model) was larger, and we trained with opencv's face box, and tested with opencv's face box. For the tracking model, we predict the face shape of the next frame based on the face shape of the previous frame.

At this time, the face area was obtained according to the shape of the previous face, so we trained with the real face box, and tested with the shape of the previous face.

Note: since there is a shift or scale change in the face shape of the previous frame and the current frame for tracking, we must give some disturbance (both shift and scale) when training.

## An overview of file directories and functions

The main folder is SDM (Matlab), containing common, data, libs, model, Posit, rot, setup&train, source and other subfolders plus some functions such as tracker, smdtrack.

Common: it contains many important calling functions, which can be regarded as a library. It needs to emphasize the desc and fea folders. Under these two folders are feature extraction functions

There are mainly characteristic functions such as xx_sift, xx_hog, xx_pool, my_sift and mt_sift. The original feature provided by the author is that xx_sift works best, but there is only one xx_sift64-bit mex interface function, which cannot be read and rewritten. So I'm using a hog

The sift feature is replaced by a feature that is slightly less effective and less speedy, but generally acceptable. Xx_pool is used for experimental comparison and is a mixture of hog and sift features. My_sift feature is a mex interface function that is rewritten according to the matlab version of sift

The corresponding mt_sift is the sift feature of matlab version, but the speed is too slow, completely unacceptable.

Note: the sift feature mentioned here is not a traditional feature detection point, but a feature of dense sift, that is, a feature of taking blocks, and the uniform size of a given block is 32*32.

Data: contains data for comparison of experimental results for academic comparison.

Libs: is liblinear package, is the function package used to train the linear regression model.

Model: contains trained model DM, TM, basic shape model and data perturbation parameters (i.e. given perturbation parameters).

Posit: it contains the main functions for 3d attitude estimation and 3d model data (10 point models).

Rot: is the true attitude value used by the standard video test, which is optional.

Setup&train: contains installation parameter functions and training model functions, as well as external functions.

Source: divided into training and testing functions, including the main function of training and testing process.

## The function function under SDM (Matlab) file is described below

Tracker: the main function used for fatigue driving detection, which runs directly to display the effect. The main function called inside is faceTracker.

Sdmtrack is the main function of face posture estimation. Similar to the fatigue driving detection function, it lacks the fatigue detection part. It can be used to demonstrate the effect of face tracking and attitude estimation, and also can be directly operated.

Sdmvid: real time video one frame by one detection display face alignment effect, direct operation can be.

Do_testing and testing: both use a standard database for testing.

TrainDMLFWandHelen: is used for LFWandHelen database training detection models, and is saved with DM.

TrainTMLFWandHelen: LFWandHelen were used to track and detect the model, and were stored by TM. Here is the face frame standard of 66 human face feature points.

TrainTM2LFWandHelen: it is used to track and detect the model with LFWandHelen database, and it is saved by TM. Here, the face frame standard is obtained by using 49 facial feature points (the face contour is removed).