sound-event-detection-plca:
Detection of overlapping acoustic events using a temporally-constrained probabilistic model

Copyright (c) 2015 Emmanouil Benetos and Queen Mary University of London
emmanouil.benetos@qmul.ac.uk

For licence information see the file named COPYING.

If you use this code, please cite the following paper:
E. Benetos, G. Lafay, M. Lagrange, and M. D. Plumbley, "Detection of overlapping acoustic events using a temporally-constrained probabilistic model", IEEE International Conference on Acoustics, Speech, and Signal Processing, March 2016.

===

Description: This code performs sound event detection in complex acoustic environments. This version is trained with office sounds (16 event classes) from the DCASE 2013 Office Synthetic (OS) challenge: http://c4dm.eecs.qmul.ac.uk/sceneseventschallenge/ . The output is a list of detected events per onset, offset, and event class.
Environment: Tested on MATLAB 7.x 32/64 bit. 

Command line calling format: [onset,offset,classNames] = event_detection(filename,iter,S,sz,su); - more info on event_detection.m file

Example: [onset,offset,classNames] = event_detection('office_snr0_high.wav',30,20,0.95,1.05);

===

NOTE: This code includes and ERB spectrogram function developed by E. Vincent (http://www.irisa.fr/metiss/members/evincent/software).
