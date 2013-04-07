LinkLevelMCSim
==============

The aim of the course project is to perform link level Monte-Carlo simulations in order to study the performance of convolutional codes over wireless channels.

Simulator Design (Convolutional Codes: Design and Performance)
--------------------------------------------------------------
In this project, we will develop a link level simulator using Matlab for a basic wireless communications system. The simulator should consist of the following blocks:
* Bernoulli source that generates a sequence of 0’s and 1’s. The source data is generated in frames of size F = 1000 bits.
* Convolutional encoder with the following parameters: rate R_c = 1/N ; generator polynomials g_i (1 ≤ i ≤ N ); number of memory elements M.
* Block or pseudo-random interleaver (it is up to you to select what you think is better).
* BPSK modulator with the following mapping of encoded bits to symbols: 0 mapped to +1 and 1 mapped to −1.
* Wireless channel with the following parameters: AWGN with variance N_o/E_b ; flat Rayleigh fading with unity average power and Jakes power spectral density.
* BPSK demodulator and detector.
* Block or pseudo-random de-interleaver.
* Viterbi convolutional decoder with the following parameters: hard decision decoding (HDD) or soft decision decoding (SDD); with full CSI info or without CSI info.
* For each simulated frame, the number of decoded bit errors should be calculated to obtain a corresponding bit error rate (BER) value.
* For each SNR (E_b/N_o) level, the simulation chain should be executed over a large enough number of frames K in order to guarantee reliable statistics at the corresponding BER level. You have to decide how to set the value of K in various cases. You can control the SNR level by controlling the AWGN variance (i.e., assume E_b normalized to 1).
* For generating a complete BER plot for a given set of parameters, you have to run the simulation chain from E_b/N_o = 0 dB till you reach a target BER P_{target} = 10E−5.

Simulator Implementation
------------------------
For the implementation of the simulator, please note the following:
* Feel free to use any needed functions from the Matlab toolboxes including the Communications Toolbox (e.g., rayleighchan.m, convenc.m, vitdec.m). Check Matlab help and demos in order to learn more about the Communications toolbox.
* For modelling AWGN and flat Rayleigh fading, you can use functions from the Communications toolbox. Make sure that the normalized fading power is equal to 1. For flat fading, assume Doppler shifts that correspond to mobile speeds of v = 3 km/hr (low mobility) and v = 120 km/hr (high mobility) with carrier frequency f_c = 900 MHz.
* Plot BER in log scale versus E_b/N_o in dB where Eb is energy per source information bit and not per coded bit. Take care of proper normalization for fair comparisons.
* Your simulator can have two modes of operation. One mode for demonstration purposes in case results are required for a given set of input parameters. Another mode for automation purposes in case results are required based on a search over a wide set of possible input parameters.
* In order to make your simulator more user friendly, provide the values of input parameters either via a file or via a graphical user interface (GUI). The user should not reenter all input parameters in case only one of the parameters need to be changed.
* Creating a GUI for your implementation is regarded as an additional feature especially for demonstration purposes.

Project Requirements
--------------------
The project requirements are kept broad in order to allow for creativity in terms of what to do and how to do it. The project requirements can be divided into basic features, additional features, and special features. The following are the main project requirements:

1.  Use your simulator in order to search for the the generator polynomials of the best convolutional codes with R = 1/2 and M = 2, M = 3. To do this, you have to simulate the performance of all possible codes and select the ones that have the best BER in the range around 10E−3 . Assume HDD and AWGN.

    * Provide the generator polynomials of the best codes for each value of M.
    * Sketch schematics for the encoders of the best convolutional codes.
    * Present complete BER curves for the best convolutional codes over AWGN channels.
    * Present complete BER curves for the best convolutional codes over wireless channels flat fading (assume low mobility).
    * Obtaining and providing results for the cases with M = 4 and M = 8 will be regarded as additional/special features.

2.  Repeat the previous parts for convolutional encoders with R = 1/3.

3.  Answer the following analysis questions based on your results and facts from the literature (books and papers):

    * Compare the performance of convolutional codes with different values of M.
    * Compare the performance of convolutional codes with/without fading in the channel.
    * Compare the performance of convolutional codes with different rates (R = 1/2 versus R = 1/3).
    * Are the best encoders over AWGN channels also the best encoders over flat fading channels? Justify your answer either intuitively or via simulations.

4.  For the best convolutional code with R = 1/2 and M = 3, perform necessary simulations and present complete BER curves in order to answer the following questions:

    * Compare the performance between HDD and SDD over AWGN channel.
    * Compare the performance between HDD with/without CSI and SDD with/without CSI over flat fading channel (low mobility).
    * Compare the cases with and without interleaving over flat fading channel (low mobility). Assume HDD.
    * Compare the cases with low mobility flat fading channel and high mobility flat fading channel. Assume HDD.

5.  The following are additional/specail features that you can add to your implementation and analysis:

    * Benchmark your results, whenever possible, against results published in the literature (books and papers). This is very important to justify the correctness of your work. Include clear referencing whenever applicable.
    * For the best convolutional code with R = 1/2 and M = 3, compare the performance with a repetition code having the same coding rate. Perform necessary simulations and present complete BER curves. Assume HDD and AWGN channel.
    * For the best convolutional code with R = 1/3 and M = 3, perform necessary simulations in order to search for the best puncturing matrix to obtain a code with rate R = 1/2. You have to determine how to do the decoding when puncturing is performed at the transmitter side. Compare the performance of the best R = 1/2 code with the obtained R = 1/2 punctured code over AWGN channel with HDD.
    * For the best convolutional code with R = 1/2 and M = 3, investigate the impact of channel estimation errors on the decoder performance with SDD. Model CSI error via some statistical model (e.g., Gaussian estimation noise with zero mean and given variance) and include results for various levels (variances) of error. Compare with HDD, SDD with full perfect CSI, and SDD without CSI.
    * Feel free to add any other special features, e.g. include diversity, higher order modulation, etc.

Running the Project
-------------------
Open the 'project.fig' in matlab and run it. Note that the project was developed and tested on matlab 2007a and 2008a.

Simulation Files Descriptions:
------------------------------
	        automation.m: contains the automation mode code
	bernoulliGenerator.m: contains bernoulli generator source code
	     deinterleaver.m: contains the block deinterleaver code
	     demonstration.m: contains the demonstration mode code
	           EbNoval.m: contains the code of the function that calculates SNR for a given BER
	       interleaver.m: contains the block interleaver code
	         project.fig: contains the simulation GUI interface
	           project.m: contains the simulation GUI code
	  ShowCodingScheme.m: contains the code that draw the convolutional code scheme

References:
-----------
Zaher Dawy, American University of Beirut, <a href="http://staff.aub.edu.lb/~zd03/" target="_new">More</a>
