import gradio as gr
import numpy as np
import matplotlib.pyplot as plt
from scipy.signal import cheb1ord, cheby1

def plot_signal(t, I1, title, xlabel, ylabel):
    fig, ax = plt.subplots(figsize=(10, 5))
    line, = ax.plot(t, I1)
    ax.set_title(title)
    ax.set_xlabel(xlabel)
    ax.set_ylabel(ylabel)
    return fig

def process_signal(df, filter_choice):
    with open(df, 'r') as file:
        f = file.read()
    v = f.split()
    I = np.array([int(i, 16) for i in v])
    I1 = (I - 127) * 0.10557

    Fs = 200
    L = len(I1)
    T = 1 / Fs
    t = np.arange(0, L * T, T)

    if filter_choice == 1:
        # FFT
        Y = np.fft.fft(I1)
        P2 = np.abs(Y)
        P1 = P2[:L]
        frequencies = Fs * np.arange(0, L) / L

        return plot_signal(t, I1, 'Original Current Signal', 'Time (s)', 'Amplitude'), \
               plot_signal(frequencies, P1, 'FFT of Original Signal', 'Frequency (Hz)', 'Amplitude')

    elif filter_choice == 2:
        # IIR-FFT
        Rp = 1  # Passband ripple
        Rs = 20  # Stopband attenuation
        Fpass = 0.50  # Normalized passband frequency

        n, W = cheb1ord(Fpass, Fpass + 0.1, Rp, Rs)
        b, a = cheby1(n, Rp, W, 'low')

        filtered_signal = np.convolve(I1, b/a, mode='same')

        Y_original = np.fft.fft(I1)
        P2_original = np.abs(Y_original)
        P1_original = P2_original[:L]
        frequencies_original = Fs * np.arange(0, L) / L

        Y_filtered = np.fft.fft(filtered_signal)
        P2_filtered = np.abs(Y_filtered)
        P1_filtered = P2_filtered[:L]
        frequencies_filtered = Fs * np.arange(0, L) / L

        original_plot = plot_signal(t, I1, 'Original Current Signal', 'Time (s)', 'Amplitude')
        filtered_plot = plot_signal(frequencies_filtered, P1_filtered, 'FFT of IIR Filtered Signal', 'Frequency (Hz)', 'Amplitude')

        return original_plot, filtered_plot

    else:
        return 'Invalid choice. Please choose 1 or 2.'

iface = gr.Interface(
    fn=process_signal,
    inputs=["text", "number"],
    outputs=["plot", "plot"],
    live=True,
    examples=[['2.8A.csv'], ['2.8A_Healthy.csv'], ['3.1A.csv'], ['3.1A_Healthy.csv']],
    title="Signal Processing Interface",
    description="An interface to visualize FFT and IIR-filtered signals."
)

iface.launch()