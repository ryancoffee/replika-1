s.waitForBoot({
	var host = NetAddr.new("127.0.0.1", 9002),
	currentGesture = \none;

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
		[name, message].postln;
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
				if(bestMatch[0] != currentGesture, {
					currentGesture = bestMatch[0];
					transmit.value(\gestureTracked, currentGesture);
				});
			}, {
				if(currentGesture != \none, {
						currentGesture = \none;
						bestMatch.postln;
						transmit.value(\gestureTracked, currentGesture);
				});
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

	~muscleSensorSlider = Slider(bounds: Rect(0,0,200,50));

	w = Window.new("FACEMINA");
	w.layout = HLayout(VLayout(
		[StaticText( bounds: Rect(10, 10, 200, 20)).string_("Eyebrow Height")],
		HLayout([~leftEyebrow], Button().states_([["max"]]).action_({~faceRanges[\leftEyebrow][2] = ~faceRAW[\leftEyebrow];})),
		HLayout([~rightEyebrow], Button().states_([["max"]]).action_({~faceRanges[\rightEyebrow][2] = ~faceRAW[\rightEyebrow];})),
		[StaticText( bounds: Rect(10, 10, 200, 20)).string_("Eye Openness")],
		HLayout([~leftEyeOpenness], Button().states_([["max"]]).action_({~faceRanges[\leftEyeOpenness][2] = ~faceRAW[\leftEyeOpenness];})),
		HLayout([~rightEyeOpenness], Button().states_([["max"]]).action_({~faceRanges[\rightEyeOpenness][2] = ~faceRAW[\rightEyeOpenness];})),
		[StaticText().string_("Nostril Flare")],
		HLayout([~nostrilFlare], Button().states_([["max"]]).action_({~faceRanges[\nostrilFlare][2] = ~faceRAW[\nostrilFlare];})),
		[StaticText().string_("Mouth Width/Height")],
		HLayout([~mouthWidth], Button().states_([["max"]]).action_({~faceRanges[\mouthWidth][2] = ~faceRAW[\mouthWidth];})),
		HLayout([~mouthHeight], Button().states_([["max"]]).action_({~faceRanges[\mouthHeight][2] = ~faceRAW[\mouthHeight];})),
		[StaticText().string_("Jaw Openness")],
		HLayout([~jawOpenness], Button().states_([["max"]]).action_({~faceRanges[\jawOpenness][2] = ~faceRAW[\jawOpenness];})),
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

	),
		HLayout(VLayout(
			[StaticText( bounds: Rect(10, 10, 200, 20)).string_("Muscle Sensor")],
			[~muscleSensorSlider],
			[nil, s: 2],
		))
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
		\mouthWidth -> [0,0,0],
		\mouthHeight -> [0,0,0],
		\leftEyebrow -> [0,0,0],
		\rightEyebrow -> [0,0,0],
		\leftEyeOpenness -> [0,0,0],
		\rightEyeOpenness -> [0,0,0],
		\jawOpenness -> [0,0,0],
		\nostrilFlare -> [0,0,0]
	];


	thisProcess.removeOSCRecvFunc(f);
	f = { |msg, time, replyAddr, recvPort|

		var val = msg[1].asFloat;

		if(recvPort == 8338, {

			switch( msg[0],
				'/gesture/mouth/width', {
					var computedVal = val / (~faceRanges[\mouthWidth][0]*2);

					AppClock.sched(0, {
						~mouthWidth.value = computedVal;
					});
					~face[\mouthWidth] = computedVal;
					~faceRAW[\mouthWidth] = val;
				},
				'/gesture/mouth/height', {
					var computedVal = val / (~faceRanges[\mouthHeight][0]*2);

					AppClock.sched(0, {
						~mouthHeight.value = computedVal;
					});
					~face[\mouthHeight] = computedVal;
					~faceRAW[\mouthHeight] = val;
				},
				'/gesture/eyebrow/left', {
					var computedVal = val / (~faceRanges[\leftEyebrow][0]*2);

					AppClock.sched(0, {
						~leftEyebrow.value = computedVal;
					});
					~face[\leftEyebrow] = computedVal;
					~faceRAW[\leftEyebrow] = val;
				},

				'/gesture/eyebrow/right', {
					var computedVal = val / (~faceRanges[\rightEyebrow][0]*2);
					AppClock.sched(0, {
						~rightEyebrow.value = computedVal;
					});
					~face[\rightEyebrow] = computedVal;
					~faceRAW[\rightEyebrow] = val;
				},
				'/gesture/eye/right', {
					var computedVal = val / (~faceRanges[\rightEyeOpenness][0]*2);

					AppClock.sched(0, {
						~rightEyeOpenness.value = computedVal;
					});

					~face[\rightEyeOpenness] = computedVal;
					~faceRAW[\rightEyeOpenness] = val;
				},
				'/gesture/eye/left', {
					var computedVal = val / (~faceRanges[\leftEyeOpenness][0]*2);

					AppClock.sched(0, {
						~leftEyeOpenness.value = computedVal;
					});

					~face[\leftEyeOpenness] = computedVal;
					~faceRAW[\leftEyeOpenness] = val;
				},
				'/gesture/nostrils', {
					var computedVal = val / (~faceRanges[\nostrilFlare][0]*2);
					AppClock.sched(0, {
						~nostrilFlare.value = computedVal;
					});
					~face[\nostrilFlare] = computedVal;
					~faceRAW[\nostrilFlare] = val;
				},
				'/gesture/jaw', {
					var computedVal = val / (~faceRanges[\jawOpenness][0]*2);

					AppClock.sched(0, {
						~jawOpenness.value = computedVal;
					});
					~face[\jawOpenness] = computedVal;
					~faceRAW[\jawOpenness] = val;

					// transmit.value(\jawOpenness, computedVal);
				},
				{}
			);

			calculateGesture.value(~face, ~gestures);
		});
	};

	thisProcess.addOSCRecvFunc(f);

	OSCdef(\tracker, { |msg|
	}, '/gesture/mouth/width', recvPort: 8338);

	// Sensors

	/*p.close;*/
	/*r.stop;*/

/*	p = SerialPort("/dev/cu.usbserial-A96PH37B", baudrate: 9600, crtscts: true);

	r= Routine({
		var byte, str, res;
		{
			if(p.read==10, {
				str = "";
				while({byte = p.read; byte !=13 }, {
					str= str++byte.asAscii;
				});
				res= str.asInteger;
				transmit.value(\muscleSensor, res);
				AppClock.sched(0, {
					~muscleSensorSlider.value = res / 1024;
				});
				// ("read value:"+res).postln;
			});
			0.01.wait;
		}.loop;
	}).play;*/

	w.onClose = {
		/*p.close;*/
		r.stop;

		thisProcess.removeOSCRecvFunc(f);

		s.quit;
		0.exit();
	};

});


// A gesture is a

// Face tracker
// diaphragm
// microphone feedback
// contact mic / flexer

// One piece of software which controls all of them



// Create one more in the Max patch

// BReathing long noise breaths with nose
// Glottal stops on contact mic
// pitches that are sung

// Glottal holds sample indefinitely that was triggered by gesture
// stopping the sound by just rearticulating the gesture
