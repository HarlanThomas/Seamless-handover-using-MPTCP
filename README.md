# Seamless-handover-using-MPTCP
Seamless heterogeneous wireless network handover method using cycled ESN FAHP and MPTCP


The training Data uses real-world mobile users' mobility data http://crawdad.org/ncsu/mobilitymodels/20090723/index.html


The method is divided into 3 parts:
1. predict users' future trajectory using cycled-ESN 
2. select the target network using FAHP
3. excute network handover using MPTCP

The cycled-ESN's code realization is in the script “test_tracjectory_direction_plot.m”， 'data1.mat' is the pre-proccessed trajectory data which is extracted from the dataset as mentioned above.
