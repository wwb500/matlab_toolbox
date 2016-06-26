function Sample (config, audioContext) {
    this.ac = audioContext;
    if (typeof(config.callback) == "undefined") config.callback=null;
    this.callback = config.callback;
    if (config.url) {
	this.display = "Loading " + config.url;
	var request = new XMLHttpRequest();
	request.open('GET', config.url, true);
	request.responseType = 'arraybuffer';
	request.onload = function (request) {
	    this.ac.decodeAudioData(request.target.response, Sample.prototype.bufferInit.bind(this),
				    function () {alert("Problem occurred while decoding audio");});
	}.bind(this);
	request.send();
    } else if (config.file) {
	this.display = "Loading " + config.file.name;
	var reader = new FileReader();
	reader.onload = function (evt) {
	    this.ac.decodeAudioData(evt.target.result, Sample.prototype.bufferInit.bind(this),
				    function () {alert("Problem occurred while decoding audio");});
	}.bind(this);
	reader.readAsArrayBuffer(config.file);
    } else if (config.data) {
	this.buffer = config.data;
	this.bufferLength = this.buffer.getChannelData(0).length;
	this.duration = this.bufferLength/this.buffer.sampleRate;
	this.dispFileName = "Audio";
    } else {
	alert("Error creating Sample: need to specify source URL or file reference, or provide data");
    }
}

Sample.prototype.setAudioContext = function (ac) {
    this.ac = ac;
}

Sample.prototype.bufferInit = function(buffer) {
    this.buffer = buffer;
    this.bufferLength = this.buffer.getChannelData(0).length;
    this.duration = this.bufferLength/this.buffer.sampleRate;
    this.dispFileName = this.display.replace("Loading ", "");
    if (this.callback) this.callback(this);
}

Sample.prototype.play = function (time, wayOut, config) {
    if (typeof(config)=="undefined") config = {};
    if (typeof(config.gain)=="undefined") config.gain = 1;
    if (typeof(config.speedFactor)=="undefined") config.speedFactor = 1;
    if (typeof(config.addSilence)=="undefined") config.addSilence = 0;
    if (typeof(config.loop)=="undefined") config.loop = false;
    if (typeof(config.reverse)=="undefined") config.reverse = false;
    if (typeof(config.crossfade)=="undefined") config.crossfade = 0;
    if (typeof(config.start)=="undefined") config.start = 0;

    var ampFactor = config.gain;
    var speedFactor = config.speedFactor;
    var addSilence = Math.ceil(this.ac.sampleRate*config.addSilence);
    var crossfade = Math.round(this.ac.sampleRate*config.crossfade*speedFactor);
    var start = Math.round(this.ac.sampleRate*config.start);
    if (typeof(config.startIndex)!="undefined") start = Math.round(config.startIndex);
    var length = this.bufferLength-start;
    if (typeof(config.length)!="undefined") length = Math.round(this.ac.sampleRate*config.length);

    this.bufferNode = this.ac.createBufferSource();
    if (config.gain==1 && !config.addSilence && !config.reverse && !config.crossfade && !config.start) {
	this.bufferNode.buffer = this.buffer;
    } else {
	this.bufferNode.buffer = this.ac.createBuffer(this.buffer.numberOfChannels, length+addSilence, this.ac.sampleRate);
	for (var c=0; c<this.buffer.numberOfChannels; c++) {
	    var src = this.buffer.getChannelData(c);
	    var dst = this.bufferNode.buffer.getChannelData(c);
	    if (ampFactor != 1) {
		if (config.reverse)
		    for (var i=0; i<length; i++)
			dst[i] = ampFactor*src[start+length-i-1];
		else
		    for (var i=0; i<length; i++)
			dst[i] = ampFactor*src[start+i];
	    } else {
		if (config.reverse)
		    for (var i=0; i<length; i++)
			dst[i] = src[start+length-i-1];
		else
		    for (var i=0; i<length; i++)
			dst[i] = src[start+i];
	    }
	    if (crossfade) {
		for (var i=0; i<crossfade; i++) {
		    var g = Math.cos(((crossfade-i)/crossfade)*0.5*Math.PI);
		    dst[i] *= g;
		    dst[length-i-1] *= g;
		}
	    }
	}
    }
    this.bufferNode.loop = config.loop;
    this.bufferNode.playbackRate.setValueAtTime(speedFactor, 0);
    if (wayOut.length)
	for (var i=0; i<wayOut.length; i++)
	    this.bufferNode.connect(wayOut[i]);
    else
	this.bufferNode.connect(wayOut);
    if (config.scope) {
	this.bufferNode.onended = function(sample, scope) {
	    sample.startTime = sample.timeToPlay = 0;
	    sample.playing=false;
	    scope.$apply();
	}.curry(this, config.scope);
    }
    this.bufferNode.start(time);
    this.playing = true;
    this.looping = config.loop;
    this.startTime = time;
    this.timeToPlay = (length/this.ac.sampleRate)/speedFactor;
}

Sample.prototype.stop = function (time) {
    if (typeof(time)=="undefined") time = 0;
    if (this.bufferNode) {
	this.bufferNode.stop(time);
	this.bufferNode = null;
    }
    this.playing = false;
}

Sample.prototype.free = function () {
    this.stop(0);
    this.buffer = null;
    this.bufferLength = this.duration = 0;
}

Sample.prototype.playedRatio = function (time) {
    if (!this.timeToPlay) return 0;
    var t = time-this.startTime;
    if (this.looping) while (t>this.duration) t -= this.duration;
    var res = t/this.timeToPlay;
    return res;
}

Sample.prototype.colorRange = [new RGBColor([255,255,0]), new RGBColor([255,127,0]), new RGBColor([0,255,0]), new RGBColor([0,0,255]), new RGBColor([127,0,255])];

Sample.prototype.drawImage = function (width, height, half) {
    if (typeof half == "undefined") half = false;
    var dat = this.buffer.getChannelData(0);
    var power = [];
    var acid = [];
    var maxP = 0;
    var maxAcid = -1000;
    var minAcid = 1000;
    for (var i=0; i<width; i++) {
	var start = Math.round(i*this.bufferLength/width);
	var end = Math.round((i+1)*this.bufferLength/width);
	var powerAcc = 0;
	var acidAcc = 0;
	for (var j=start; j<end; j++) {
	    powerAcc += dat[j]*dat[j];
	    if(j>0) acidAcc += (dat[j]-dat[j-1])*(dat[j]-dat[j-1]);
	}
	var acidVal = ((powerAcc) ? acidAcc/powerAcc : 0);
	if (acidVal > maxAcid) maxAcid = acidVal;
	if (acidVal < minAcid) minAcid = acidVal;
	acid.push(acidVal);
	powerAcc /= end-start;
	if (powerAcc>maxP) maxP=powerAcc;
	power.push(powerAcc);
    }

    var canvas = document.createElement("canvas");
    canvas.width = width;
    canvas.height = height;
    var c = canvas.getContext("2d");
    c.lineWidth = 1;

    for (var i=0; i<width; i++) {
	var powerAcc = 1+(Math.log(power[i]/maxP)/5);
	if (powerAcc<0) powerAcc=0;
	var acidVal = 1+(Math.log(acid[i])/7);
	var col1 = this.colorRange[0].colorInRange(acidVal, this.colorRange);
	c.strokeStyle = col1.toHex();
	c.beginPath();
	if (half) {
	    c.moveTo(i+.5, height*(1-powerAcc));
	    c.lineTo(i+.5, height);
	} else { 
	    c.moveTo(i+.5, .5*height*(1-powerAcc));
	    c.lineTo(i+.5, .5*height*(1+powerAcc));
	}
	c.stroke();
    }
    return canvas.toDataURL("image/png");
}

