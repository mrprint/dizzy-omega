Noise n => BiQuad f => WvOut w => blackhole;
"jump.wav" => w.wavFilename;

0.5 => n.gain;

// set biquad pole radius
.5 => f.prad;
// set biquad gain
.025 => f.gain;
// set equal zeros
1 => f.eqzs;

10 => f.pfreq;
0.9 => f.prad;

1000::ms => now;

