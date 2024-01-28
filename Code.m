clc
clear
close all

df = '2.8A.csv';
f = fileread(df);
v = (strsplit(f));
I = hex2dec(v);
I1 = ((I - 127) * 0.10557);
% Converting scaled data to real values.
% (5/256 ADC conversion multiplied with 1A/185mV)bit -> Voltage -> Current
I1 = I1(1:15000);

prompt = 'Choose a Signal Processing Technique: \n1. FFT\n2. IIR-FFT\n3. Wiener Filter\nEnter your choice: ';
filterChoice = input(prompt);

switch filterChoice
    case 1
        % FFT
        Fs = 200;
        L = length(I1); 
        T = 1/Fs; 
        t = (0:L-1)*T; 

        Y = fft(I1);
        P2 = abs(Y); 
        P1 = P2(1:L); 
        frequencies = Fs*(0:(L-1))/L; 

        figure;
        plot(t, I1);
        title('Original Current Signal');
        xlabel('Time (s)');
        ylabel('Amplitude');

        figure;
        plot(frequencies, P1);
        title('FFT of Original Signal');
        xlabel('Frequency (Hz)');
        ylabel('Amplitude');
        
    case 2
        % IIR-FFT
        % Get filter type
        prompt = 'Choose a filter type:\n1. Chebyshev Type I\n2. Chebyshev Type II \n3. Butterworth\nEnter your choice: ';
        innerChoice = input(prompt);

        switch innerChoice
            case 1
                Rp = 1; 
                Rs = 20; 
                Fpass = 0.50; 

                [n, W] = cheb1ord(Fpass, Fpass+0.1, Rp, Rs); 
                [b, a] = cheby1(n, Rp, W, 'low');
            case 2
                Rp = 1;
                Rs = 20; 
                Fstop = 0.60; 

                [n, W] = cheb2ord(Fstop-0.1, Fstop, Rp, Rs); 
                [b, a] = cheby2(n, Rs, W, 'high');
            case 3
                Fpass1 = 0.40; 
                Fpass2 = 0.60; 
                [n, Wn] = buttord([Fpass1, Fpass2], [Fpass1-0.05, Fpass2+0.05], 1, 20); 
                [b, a] = butter(n, Wn, 'bandpass');
            otherwise
                disp('Invalid choice. Please enter 1, 2, or 3.');
                return;
        end

        filtered_signal = filter(b, a, I1);

        Fs = 200;
        L = length(filtered_signal); 
        T = 1/Fs; 
        t = (0:L-1)*T; 

        Y_original = fft(I1);
        P2_original = abs(Y_original); 
        P1_original = P2_original(1:L); 
        frequencies_original = Fs*(0:(L-1))/L; 

        Y_filtered = fft(filtered_signal);
        P2_filtered = abs(Y_filtered); 
        P1_filtered = P2_filtered(1:L); 
        frequencies_filtered = Fs*(0:(L-1))/L; 

        figure;
        plot(t, I1);
        title('Original Current Signal');
        xlabel('Time (s)');
        ylabel('Amplitude');

        figure;
        subplot(2, 1, 1);
        plot(frequencies_original, P1_original);
        title('FFT of Original Signal');
        xlabel('Frequency (Hz)');
        ylabel('Amplitude');

        subplot(2, 1, 2);
        plot(frequencies_filtered, P1_filtered);
        title('FFT of Filtered Signal');
        xlabel('Frequency (Hz)');
        ylabel('Amplitude');
        
    case 3
        % Wiener
        N = 200; % Order
        [xest, ~, ~] = wienerFilt(I1, I1, N); 

        L_filtered = length(xest);

        Fs = 200; 
        T = 1 / Fs;
        L = length(I1); 
        t = (0:(L_filtered-1)) * T;

        figure;
        plot(t, xest);
        title('Wiener Filtered Signal');
        xlabel('Time (s)');
        ylabel('Amplitude');

        Y_original = fft(I1);
        P2_original = abs(Y_original); 
        P1_original = P2_original(1:L/2+1); 
        frequencies_original = Fs*(0:(L/2))/L;

        Y_filtered_wiener = fft(xest);
        P2_filtered_wiener = abs(Y_filtered_wiener);
        P1_filtered_wiener = P2_filtered_wiener(1:length(Y_filtered_wiener)/2+1); 
        frequencies_filtered_wiener = Fs*(0:(length(Y_filtered_wiener)/2))/length(Y_filtered_wiener); 

        figure;
        subplot(2, 1, 1);
        plot(frequencies_original, P1_original);
        title('FFT of Original Signal');
        xlabel('Frequency (Hz)');
        ylabel('Amplitude');

        subplot(2, 1, 2);
        plot(frequencies_filtered_wiener, P1_filtered_wiener);
        title('FFT of Wiener Filtered Signal');
        xlabel('Frequency (Hz)');
        ylabel('Amplitude');


    otherwise
        disp('Invalid choice. Please choose 1, 2, or 3.');
end
