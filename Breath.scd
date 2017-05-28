(
p = SerialPort(
    "/dev/cu.usbmodem1421",
    baudrate: 9600,
   crtscts: true);
)
p.close
// read a byte from the device

p.next;            // doesn't block
fork{p.read.postln};


(
r= Routine({
    var byte, str, res;
	{
        if(p.read==10, {
            str = "";
            while({byte = p.read; byte !=13 }, {
                str= str++byte.asAscii;
            });
            res= str.asInteger;
            ("read value:"+res).postln;
        });
		0.0001.wait;
	}.loop;
}).play;
)

(
r= Routine({
    var byte, str, res;
    99999.do{|i|
        if(p.read==10, {
            str = "";
            while({byte = p.read; byte !=13 }, {
                str= str++byte.asAscii;
            });
            res= str.asInteger;
            ("read value:"+res).postln;
			0.00001.wait;
        });
    };
}).play;
)
r.stop;

(


Ndef(\synth2, { | vol=0.25, freq=220, baseFreq = 300 |
	var out = LFTri.ar(freq) * LFPulse.ar(2, width: 0.15).unipolar.lag(0.2) * vol !2;

	FreeVerb.ar(out);
});
)
Ndef(\synth2).play;
Ndef(\synth2).set(\vol, 0.0);
(
OSCdef(\tracker, { |msg|

	if(msg[1] == 1023, {
		msg.postln;
		Ndef(\synth2).set(\freq, 65.midicps);
	});
}, '/ntk/out/1');

OSCdef(\tracker2, { |msg|

		if(msg[1] == 1023, {
		msg.postln;
		Ndef(\synth2).set(\freq, 62.midicps);
	});
}, '/ntk/out/2');
)




Quarks.gui
/////////

SerialPort.listDevices
//choose appropriate index. You can also cut and paste the path name directly in the port argument
d = SerialPort.devices[3]; //select correct index for serial port

p = SCPyduino.new(d);
p.analog[0].active_(1)

	//post value of analog pin 0
(
a = fork{
		loop{
			p.iterate;
			p.analog[0].value.postln;
		0.1.wait;
		}
};
)
a.stop;