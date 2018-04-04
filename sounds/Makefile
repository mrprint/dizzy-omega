all: energy-minus.ogg energy-plus.ogg jump.wav step.wav

%.ogg: %.wav
	ffmpeg -i $< -c:a libvorbis -qscale:a 5 $@

%.wav: %.ck
	chuck $<

clean:
	rm -f energy-minus.ogg energy-plus.ogg jump.wav step.wav
