s.boot;


(
OSCdef(\tracker, { |msg|

	// msg.postln;
}, '/gesture/mouth/width', recvPort: 8338);
)
/*
mouth width: /gesture/mouth/width
mouth height: /gesture/mouth/height
left eyebrow height: /gesture/eyebrow/left
right eyebrow height: /gesture/eyebrow/right
left eye openness: /gesture/eye/left
right eye openness: /gesture/eye/right
jaw openness: /gesture/jaw
nostril flate: /gesture/nostrils
*/
(
~face = Dictionary[
	\mouthWidth -> 0,
	\mouthHeight -> 0,
	\leftEyebrow -> 0,
	\rightEyebrow -> 0,
	\leftEyeOpenness -> 0,
	\rightEyeOpenness -> 0,
	\jawOpenness -> 0,
	\nostrilFlate -> 0
];

Ndef(\synth, { | amp=0, freq=25, baseFreq = 300 |
	LFTri.ar((LFTri.kr(freq, mul: 1).unipolar) * baseFreq + 100) * amp.lag(0.15)!2;
});
)

Ndef(\synth).play;
Ndef(\synth).set(\freq, 30, \baseFreq, 280, \amp, 0.1);
Ndef(\synth).set(\freq, 20, \baseFreq, 880, \amp, 0.1);
Ndef(\synth).set(\baseFreq, 150);
(
thisProcess.removeOSCRecvFunc(f);
f = { |msg, time, replyAddr, recvPort|
	var calculateGesture = { | target |
		var sum = 0;



		if(target == "eyebrows", {
			if(~face[\leftEyebrow] > 8, {sum = 1});
			if(sum >= 1, {
				target.postln;
				// Ndef(\synth).set(\amp, 0.6, \baseFreq, 300);
				Ndef(\synth).set(\freq, 30, \baseFreq, 380, \amp, 0.1);
			}, {
				Ndef(\synth).set(\amp, 0);
			});
		});

		if(target == "mouth", {
			if(~face[\mouthHeight] > 8, {sum = 1});
			if(sum >= 1, {
				target.postln;
				// Ndef(\synth).set(\baseFreq, 1800);
				Ndef(\synth).set(\freq, 20, \baseFreq, 880, \amp, 0.1);
				Ndef(\synth).set(\amp, 0.6);
			}, {
					// Ndef(\synth).set(\baseFreq, 2500);
				Ndef(\synth).set(\amp, 0);
			});
		});
	};

	if(recvPort == 8338, {

		switch( msg[0],
			'/gesture/mouth/width', {
				msg.postln;
				~face[\mouthWidth] = msg[1].asFloat;
			},
			'/gesture/mouth/height', {
				msg.postln;
				~face[\mouthHeight] = msg[1].asFloat;
			},
			'/gesture/eyebrow/left', {
				msg.postln;
				~face[\leftEyebrow] = msg[1].asFloat;
			},
			'/gesture/eyebrow/right', {
				~face[\rightEyebrow] = msg[1].asFloat;
			},
			{}
		);

		calculateGesture.value("eyebrows");
		calculateGesture.value("mouth");
	});
};

thisProcess.addOSCRecvFunc(f);
)
thisProcess.addOSCRecvFunc(f);
thisProcess.removeOSCRecvFunc(f);

~face