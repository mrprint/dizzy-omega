SinOsc s => JCRev r => WvOut w => blackhole;
"step.wav" => w.wavFilename;
1.0 => s.gain;
.0 => r.mix;

0.5 => s.gain;
150 => s.freq;
(24000/s.freq())::samp => now;
300 => s.freq;
(24000/s.freq())::samp => now;
