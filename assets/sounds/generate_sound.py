import wave
import struct
import math

def generate_success_sound(filename, duration=0.4, sample_rate=44100):
    """Generate a smooth, mild success sound - single soft bell tone"""
    num_samples = int(duration * sample_rate)
    
    with wave.open(filename, 'w') as wav_file:
        wav_file.setnchannels(1)
        wav_file.setsampwidth(2)
        wav_file.setframerate(sample_rate)
        
        for i in range(num_samples):
            t = float(i) / sample_rate
            # Single pleasant tone at A4 (440 Hz) - smooth and mild
            freq = 440.0
            
            # Very smooth exponential decay envelope
            envelope = math.exp(-3.5 * t)
            
            # Add slight harmonic richness
            fundamental = math.sin(2 * math.pi * freq * t)
            harmonic = 0.15 * math.sin(2 * math.pi * freq * 2 * t)
            
            value = envelope * (fundamental + harmonic)
            
            # Convert to 16-bit integer with reduced amplitude (softer)
            data = int(value * 28000)
            wav_file.writeframes(struct.pack('<h', data))

generate_success_sound('completion.wav')
print("Generated smooth completion sound")
