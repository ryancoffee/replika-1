s.waitForBoot({

var layout;
	var calculateGesture = { | target |
		var faceSnapshot = ~face.copy;

		faceSnapshot.keysValuesDo({ |key, val|
			faceSnapshot[key] = val / (~faceRanges[key][0]*2);
		});

		// Calculate a gesture based on how it fits
	};

	var printGesture = { | target |
		var faceSnapshot = ~face.copy;

		faceSnapshot.keysValuesDo({ |key, val|
			faceSnapshot[key] = val / (~faceRanges[key][0]*2);
		});

		faceSnapshot.postln;
	};

~gestures = Dictionary.new;

~eyebrowHeightL = Slider(bounds: Rect(0,0,200,50));
~eyebrowHeightR = Slider(bounds: Rect(0,0,200,50));
~eyeOpennessL = Slider(bounds: Rect(0,0,200,50));
~eyeOpennessR = Slider(bounds: Rect(0,0,200,50));

~mouthWidth = Slider(bounds: Rect(0,0,200,50));
~mouthHeight = Slider(bounds: Rect(0,0,200,50));
~nostrilFlare = Slider(bounds: Rect(0,0,200,50));
~jawOpenness = Slider(bounds: Rect(0,0,200,50));

w = Window.new("FACEMINA");
w.layout = VLayout(
	[StaticText( bounds: Rect(10, 10, 200, 20)).string_("Eyebrow Height")],
	[~eyebrowHeightL],
	[~eyebrowHeightR],
	[StaticText( bounds: Rect(10, 10, 200, 20)).string_("Eye Openness")],
	[~eyeOpennessL],
	[~eyeOpennessR],
	[StaticText().string_("Nostril Flare")],
	[~nostrilFlare],
	[StaticText().string_("Mouth Width/Height")],
	[~mouthWidth],
	[~mouthHeight],
	[StaticText().string_("Jaw Openness")],
	[~jawOpenness],
		[Button().states_([["Set norms"]]).action_({ | button |
			~face.keysValuesDo({ |key, val|
				~faceRanges[key][0] = val;
			});
		})],
		[Button().states_([["Print gesture"]]).action_(printGesture)],

		[Button().states_([["Set scream"]]).action_({
			~gestures[\scream] = ~face.copy;

			~gestures[\scream].keysValuesDo({ |key, val|
				~gestures[\scream][key] = val / (~faceRanges[key][0]*2);
			});

		})],
		[Button().states_([["Set other"]]).action_({
			~gestures[\other] = ~face.copy;

			~gestures[\other].keysValuesDo({ |key, val|
				~gestures[\other][key] = val / (~faceRanges[key][0]*2);
			});

		})]

);

w.front;

~face = Dictionary[
	\mouthWidth -> 0,
	\mouthHeight -> 0,
	\leftEyebrow -> 0,
	\rightEyebrow -> 0,
	\leftEyeOpenness -> 0,
	\rightEyeOpenness -> 0,
	\jawOpenness -> 0,
	\nostrilFlare -> 0
];

	// [normal, max]
~faceRanges = Dictionary[
	\mouthWidth -> [0,0],
	\mouthHeight -> [0,0],
	\leftEyebrow -> [0,0],
	\rightEyebrow -> [0,0],
	\leftEyeOpenness -> [0,0],
	\rightEyeOpenness -> [0,0],
	\jawOpenness -> [0,0],
	\nostrilFlare -> [0,0]
];

Ndef(\synth, { | amp=0, freq=25, baseFreq = 300 |
	LFTri.ar((LFTri.kr(freq, mul: 1).unipolar) * baseFreq + 100) * amp.lag(0.15)!2;
});
	Ndef(\synth).set(\freq, 30, \baseFreq, 280, \amp, 0.1);
	Ndef(\synth).play;

	thisProcess.removeOSCRecvFunc(f);
f = { |msg, time, replyAddr, recvPort|


	if(recvPort == 8338, {

		switch( msg[0],
			'/gesture/mouth/width', {
					// msg.postln;
					AppClock.sched(0, {
						~mouthWidth.value = msg[1].asFloat/(~faceRanges[\mouthWidth][0]*2);
					});
				~face[\mouthWidth] = msg[1].asFloat;
			},
			'/gesture/mouth/height', {
					// msg.postln;
					AppClock.sched(0, {
						~mouthHeight.value = msg[1].asFloat/(~faceRanges[\mouthHeight][0]*2);
					});
				~face[\mouthHeight] = msg[1].asFloat;
			},
			'/gesture/eyebrow/left', {
					// msg.postln;
					AppClock.sched(0, {
						~eyebrowHeightL.value = msg[1].asFloat/(~faceRanges[\leftEyebrow][0]*2);
					});
				~face[\leftEyebrow] = msg[1].asFloat;
			},

			'/gesture/eyebrow/right', {
					AppClock.sched(0, {
						~eyebrowHeightR.value = msg[1].asFloat/(~faceRanges[\rightEyebrow][0]*2);
					});
					~face[\rightEyebrow] = msg[1].asFloat;
			},
			'/gesture/eye/right', {
					// msg.postln;
				AppClock.sched(0, {
					~eyeOpennessR.value = msg[1].asFloat/(~faceRanges[\rightEyeOpenness][0]*2);
				});

				~face[\rightEyeOpenness] = msg[1].asFloat;
			},
			'/gesture/eye/left', {
				// msg.postln;
				AppClock.sched(0, {
					~eyeOpennessL.value = msg[1].asFloat/(~faceRanges[\leftEyeOpenness][0]*2);
				});

				~face[\leftEyeOpenness] = msg[1].asFloat;
			},
			'/gesture/nostrils',
			{
				AppClock.sched(0, {
					~nostrilFlare.value = msg[1].asFloat/(~faceRanges[\nostrilFlare][0]*2);
				});
				~face[\nostrilFlare] = msg[1].asFloat;
			},
			'/gesture/jaw',
			{
					// msg.postln;
				AppClock.sched(0, {
					~jawOpenness.value = msg[1].asFloat/(~faceRanges[\jawOpenness][0]*2);
				});
				~face[\jawOpenness] = msg[1].asFloat;
			},
			{}
		);

		calculateGesture.value(~face);
	});
};

thisProcess.addOSCRecvFunc(f);

OSCdef(\tracker, { |msg|

	// msg.postln;
}, '/gesture/mouth/width', recvPort: 8338);

});



// A gesture is a

// Face tracker
// diaphragm
// microphone feedback
// contact mic / flexer

// One piece of software which controls all of them
