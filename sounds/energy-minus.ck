SqrOsc s => JCRev r => WvOut w => blackhole;
"energy-minus.wav" => w.wavFilename;

.2 => r.mix;
for (2000 => float f; f > 500; f - 50 => f)
{
    f => s.freq;
    for (1.0 => float g; g >= 0.0; g - 0.05 => g)
    {
        g => s.gain;
        48::samp => now;
    }
    20::ms => now;
}

0.0 => s.gain;
2000::ms => now;