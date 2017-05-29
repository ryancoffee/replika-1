s.waitForBoot({
	var host = NetAddr.new("127.0.0.1", 9002);

var layout, tolerance=0.2;
	// computeProximityN()
	var computeProximityN = { | vectorA, vectorB |
		var euclideanDistance = 0;

		vectorA.do({ |itemA, i|
			var itemB = vectorB[i];

			euclideanDistance = ( euclideanDistance + ((itemB - itemA).pow(2)) );
		});

		euclideanDistance.sqrt;
	};

	// transmit()
	var transmit = { | name, message |
		host.sendMsg(name, message.asSymbol);
	};

	// calculateGesture()
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

	// printGesture()
	var printGesture = { | target |
		var faceSnapshot = ~face.copy;

		faceSnapshot.postln;
	};


	// GUI
	~gestures = Dictionary.new;

	~leftEyebrow = Slider(bounds: Rect(0,0,200,50));
	~rightEyebrow = Slider(bounds: Rect(0,0,200,50));
	~leftEyeOpenness = Slider(bounds: Rect(0,0,200,50));
	~rightEyeOpenness = Slider(bounds: Rect(0,0,200,50));

	~mouthWidth = Slider(bounds: Rect(0,0,200,50));
	~mouthHeight = Slider(bounds: Rect(0,0,200,50));
	~nostrilFlare = Slider(bounds: Rect(0,0,200,50));
	~jawOpenness = Slider(bounds: Rect(0,0,200,50));

	w = Window.new("FACEMINA");
	w.layout = VLayout(
		[StaticText( bounds: Rect(10, 10, 200, 20)).string_("Eyebrow Height")],
		HLayout([~leftEyebrow], Button().states_([["max"]]).action_({~faceRanges[\leftEyebrow][1] = ~faceRAW[\leftEyebrow];})),
		HLayout([~rightEyebrow], Button().states_([["max"]]).action_({~faceRanges[\rightEyebrow][1] = ~faceRAW[\rightEyebrow];})),
		[StaticText( bounds: Rect(10, 10, 200, 20)).string_("Eye Openness")],
		HLayout([~leftEyeOpenness], Button().states_([["max"]]).action_({~faceRanges[\leftEyeOpenness][1] = ~faceRAW[\leftEyeOpenness];})),
		HLayout([~rightEyeOpenness], Button().states_([["max"]]).action_({~faceRanges[\rightEyeOpenness][1] = ~faceRAW[\rightEyeOpenness];})),
		[StaticText().string_("Nostril Flare")],
		HLayout([~nostrilFlare], Button().states_([["max"]]).action_({~faceRanges[\nostrilFlare][1] = ~faceRAW[\nostrilFlare];})),
		[StaticText().string_("Mouth Width/Height")],
		HLayout([~mouthWidth], Button().states_([["max"]]).action_({~faceRanges[\mouthWidth][1] = ~faceRAW[\mouthWidth];})),
		HLayout([~mouthHeight], Button().states_([["max"]]).action_({~faceRanges[\mouthHeight][1] = ~faceRAW[\mouthHeight];})),
		[StaticText().string_("Jaw Openness")],
		HLayout([~jawOpenness], Button().states_([["max"]]).action_({~faceRanges[\jawOpenness][1] = ~faceRAW[\jawOpenness];})),
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

	// DATA
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


	thisProcess.removeOSCRecvFunc(f);
	f = { |msg, time, replyAddr, recvPort|

		var val = msg[1].asFloat;

		if(recvPort == 8338, {

			switch( msg[0],
				'/gesture/mouth/width', {
					// msg.postln;
					AppClock.sched(0, {
						~mouthWidth.value = msg[1].asFloat/(~faceRanges[\mouthWidth][1]);
					});
					~face[\mouthWidth] = val / (~faceRanges[\mouthWidth][1]);
					~faceRAW[\mouthWidth] = val;
				},
				'/gesture/mouth/height', {
					// msg.postln;
					AppClock.sched(0, {
						~mouthHeight.value = msg[1].asFloat/(~faceRanges[\mouthHeight][1]);
					});
					~face[\mouthHeight] = val / (~faceRanges[\mouthHeight][1]);
					~faceRAW[\mouthHeight] = val;
				},
				'/gesture/eyebrow/left', {
					// msg.postln;
					AppClock.sched(0, {
						~leftEyebrow.value = msg[1].asFloat/(~faceRanges[\leftEyebrow][1]);
					});
					~face[\leftEyebrow] = val / (~faceRanges[\leftEyebrow][1]);
					~faceRAW[\leftEyebrow] = val;
				},

				'/gesture/eyebrow/right', {
					AppClock.sched(0, {
						~rightEyebrow.value = msg[1].asFloat/(~faceRanges[\rightEyebrow][1]);
					});
					~face[\rightEyebrow] = val / (~faceRanges[\rightEyebrow][1]);
					~faceRAW[\rightEyebrow] = val;
				},
				'/gesture/eye/right', {
					// msg.postln;
					AppClock.sched(0, {
						~rightEyeOpenness.value = msg[1].asFloat/(~faceRanges[\rightEyeOpenness][1]);
					});

					~face[\rightEyeOpenness] = val / (~faceRanges[\rightEyeOpenness][1]);
					~faceRAW[\rightEyeOpenness] = val;
				},
				'/gesture/eye/left', {
					// msg.postln;
					AppClock.sched(0, {
						~leftEyeOpenness.value = msg[1].asFloat/(~faceRanges[\leftEyeOpenness][1]);
					});

					~face[\leftEyeOpenness] = val / (~faceRanges[\leftEyeOpenness][1]);
					~faceRAW[\leftEyeOpenness] = val;
				},
				'/gesture/nostrils',
				{
					AppClock.sched(0, {
						~nostrilFlare.value = msg[1].asFloat/(~faceRanges[\nostrilFlare][1]);
					});
					~face[\nostrilFlare] = val / (~faceRanges[\nostrilFlare][1]);
					~faceRAW[\nostrilFlare] = val;
				},
				'/gesture/jaw',
				{
					// msg.postln;
					AppClock.sched(0, {
						~jawOpenness.value = msg[1].asFloat/(~faceRanges[\jawOpenness][1]);
					});
					~face[\jawOpenness] = val / (~faceRanges[\jawOpenness][1]);
					~faceRAW[\jawOpenness] = val;

					transmit.value(\jawOpenness, val / (~faceRanges[\jawOpenness][1]));
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
