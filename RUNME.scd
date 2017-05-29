s.waitForBoot({
	var host = NetAddr.new("127.0.0.1", 9002);

var layout, tolerance=0.2;
	var computeProximityN = { | vectorA, vectorB |
		var euclideanDistance = 0;

		vectorA.do({ |itemA, i|
			var itemB = vectorB[i];

			euclideanDistance = ( euclideanDistance + ((itemB - itemA).pow(2)) );
		});

		euclideanDistance.sqrt;
	};

	var transmit = { | name, message |
		host.sendMsg(name, message.asSymbol);
	};

	var calculateGesture = { |faceData, gestures|
		var faceSnapshot = faceData.copy,
		gestureDistances = Dictionary.new,
		bestMatch = [nil,nil];



		// Calculate a gesture based on how it fits

		gestures.keysValuesDo({| gestureName, gestureData |
			var gestureDistance = 0;

			var snapshotArray = List.new,
			gestureArray = List.new,
			keyOrder = List.new;

			faceSnapshot.keysValuesDo({ | key, val |
				keyOrder.add(key);

				snapshotArray.add(val);
				gestureArray.add(gestureData[key]);
			});

			gestureDistance = computeProximityN.value(snapshotArray, gestureArray);

			gestureDistances[gestureName] = gestureDistance;
		});

		gestureDistances.keysValuesDo({ |key, val|
			if(bestMatch[0].isNil(), { bestMatch = [key,val];});

			if(val < bestMatch[1], {
				bestMatch = [key,val];
			});
		});

		if(bestMatch[0].notNil(), {
			if(bestMatch[1] < tolerance, {
				bestMatch.postln;
				transmit.value(\gestureTracked, bestMatch[0]);
			});
		});
	};

	var printGesture = { | target |
		var faceSnapshot = ~face.copy;

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
		[nil, s: 2],
		[Button().states_([["Set norms"]]).action_({ | button |
			~faceRAW.keysValuesDo({ |key, val|
				~faceRanges[key][0] = val;
			});
		})],
		[StaticText().string_("Gesture Learning:")],
		HLayout(
			[Button().states_([["A"]]).action_({
				~gestures[\A] = ~face.copy;
			})],
			[Button().states_([["B"]]).action_({
				~gestures[\B] = ~face.copy;
			})],
			[Button().states_([["C"]]).action_({
				~gestures[\A] = ~face.copy;
			})],
			[Button().states_([["D"]]).action_({
				~gestures[\B] = ~face.copy;
			})],
			[Button().states_([["E"]]).action_({
				~gestures[\A] = ~face.copy;
			})],
			[Button().states_([["F"]]).action_({
				~gestures[\B] = ~face.copy;
			})]
		),
		[StaticText().string_("Tolerance")],
		[Knob(bounds: Rect(0,0,200,200)).action_({|knob| tolerance = knob.value})]

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
~faceRAW = Dictionary[
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

	var val = msg[1].asFloat;

	if(recvPort == 8338, {

		switch( msg[0],
			'/gesture/mouth/width', {
					// msg.postln;
					AppClock.sched(0, {
						~mouthWidth.value = msg[1].asFloat/(~faceRanges[\mouthWidth][0]*2);
					});
				~face[\mouthWidth] = val / (~faceRanges[\mouthWidth][0]*2);
				~faceRAW[\mouthWidth] = val;
			},
			'/gesture/mouth/height', {
					// msg.postln;
					AppClock.sched(0, {
						~mouthHeight.value = msg[1].asFloat/(~faceRanges[\mouthHeight][0]*2);
					});
				~face[\mouthHeight] = val / (~faceRanges[\mouthHeight][0]*2);
				~faceRAW[\mouthHeight] = val;
				},
			'/gesture/eyebrow/left', {
					// msg.postln;
					AppClock.sched(0, {
						~eyebrowHeightL.value = msg[1].asFloat/(~faceRanges[\leftEyebrow][0]*2);
					});
				~face[\leftEyebrow] = val / (~faceRanges[\leftEyebrow][0]*2);
					~faceRAW[\leftEyebrow] = val;
			},

			'/gesture/eyebrow/right', {
					AppClock.sched(0, {
						~eyebrowHeightR.value = msg[1].asFloat/(~faceRanges[\rightEyebrow][0]*2);
					});
					~face[\rightEyebrow] = val / (~faceRanges[\rightEyebrow][0]*2);
					~faceRAW[\rightEyebrow] = val;
			},
			'/gesture/eye/right', {
					// msg.postln;
				AppClock.sched(0, {
					~eyeOpennessR.value = msg[1].asFloat/(~faceRanges[\rightEyeOpenness][0]*2);
				});

				~face[\rightEyeOpenness] = val / (~faceRanges[\rightEyeOpenness][0]*2);
					~faceRAW[\rightEyeOpenness] = val;
			},
			'/gesture/eye/left', {
				// msg.postln;
				AppClock.sched(0, {
					~eyeOpennessL.value = msg[1].asFloat/(~faceRanges[\leftEyeOpenness][0]*2);
				});

				~face[\leftEyeOpenness] = val / (~faceRanges[\leftEyeOpenness][0]*2);
					~faceRAW[\leftEyeOpenness] = val;
			},
			'/gesture/nostrils',
			{
				AppClock.sched(0, {
					~nostrilFlare.value = msg[1].asFloat/(~faceRanges[\nostrilFlare][0]*2);
				});
				~face[\nostrilFlare] = val / (~faceRanges[\nostrilFlare][0]*2);
					~faceRAW[\nostrilFlare] = val;
			},
			'/gesture/jaw',
			{
					// msg.postln;
				AppClock.sched(0, {
					~jawOpenness.value = msg[1].asFloat/(~faceRanges[\jawOpenness][0]*2);
				});
				~face[\jawOpenness] = val / (~faceRanges[\jawOpenness][0]*2);
				~faceRAW[\jawOpenness] = val;

				transmit.value(\jawOpenness, val / (~faceRanges[\jawOpenness][0]*2));
			},
			{}
		);

		calculateGesture.value(~face, ~gestures);
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
