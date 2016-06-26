if (!Array.prototype.multiplyBy) {
    Array.prototype.multiplyBy = function(f) {
	var a = f; 
	if (!a.length) a = [a];
	var l = a.length;
	if (l>this.length) l = this.length;
	for (var i=0; i<l; i++) this[i] *= a[i];
	for (var i=l; i<this.length; i++) this[i] *= a[l-1];
    }
}

if (!Array.prototype.add) {
    Array.prototype.add = function(f) {
	var a = f; 
	if (!a.length) a = [a];
	var l = a.length;
	if (l>this.length) l = this.length;
	for (var i=0; i<l; i++) this[i] += a[i];
	for (var i=l; i<this.length; i++) this[i] += a[l-1];
    }
}

if (!Array.prototype.copy) {
    Array.prototype.copy = function() {
	var n = [];
	for (var i=0; i<this.length; i++) n[i] = this[i];
	return n;
    }
}



if (!Function.prototype.curry) {
    Function.prototype.curry = function() {
	if (arguments.length<1) return this;
	var __method = this;
	var args = Array.prototype.slice.call(arguments);
	return function() {
	    return __method.apply(this, args.concat(Array.prototype.slice.call(arguments)));
	}
    }
}

if (!Function.prototype.bind) {
    Function.prototype.bind = function(object) {
	var __method = this;
	return function() {
	    return __method.apply(object, arguments);
	}
    }
}

if (!Object.prototype.clone) {
    Object.prototype.clone = function () {
	var target = {};
	for (var i in this) {
	    if (this.hasOwnProperty(i)) {
		target[i] = obj[i];
	    }
	}
	return target;
    }
}

if (!Object.prototype.inherit) {
    Object.prototype.inherit = function(baseConstructor) {
	this.prototype = baseConstructor.prototype.clone();
	this.prototype.constructor = this;
    };
}

// Defining a subclass, cheat sheet :

// function Subclass (sameParams) {
//     Superclass.call(this, sameParams);
//     this.otherStuff = "Hi there!";
// }
// Subclass.inherit(Superclass);

// Subclass.prototype.newFun = function () {
//     console.log(this.otherStuff);
// }

// Subclass.prototype.existingFun = function (sameParams) {
//     do_stuff();
//     Superclass.prototype.existingFun.call(this, sameParams); // if needed
//     do_stuff();
// }


function pageCoordinates (elem) {
    var res = {};
    res.x = 0;
    res.y = 0;
    if (elem.offsetParent) {
	do {
	    res.x += elem.offsetLeft;
	    res.y += elem.offsetTop;
        }while (elem = elem.offsetParent);
    }
    return res;
}

function preprocessEvent (e, dontBlock) {
    if (!e) e = window.event;
    if (typeof dontBlock == "undefined" || !dontBlock) {
	if (e.stopPropagation) e.stopPropagation();
	else e.cancelBubble = true;
	if (e.preventDefault) e.preventDefault();
    }
    if (!e.target) e.target = e.srcElement;
    if (e.target.nodeType == 3) // defeat Safari bug
	e.target = target.parentNode;
    return e;
}

function stopEvent (e) {
    if (e.stopPropagation) e.stopPropagation();
    else e.cancelBubble = true;
    if (e.preventDefault) e.preventDefault();
}

// Web Audio stuff

function dBToAmp (db) {
    if (db<-59.9) return 0; 
    return Math.pow(10, db/20);
}

function smoothParameterChange (audioParam, nv, time) {
    audioParam.cancelScheduledValues(time);
    audioParam.setValueAtTime(audioParam.value, time);
    audioParam.linearRampToValueAtTime(nv, time+.1);
}

function anchorAudioParam (audioParam, time) {
    audioParam.cancelScheduledValues(time);
    audioParam.setValueAtTime(audioParam.value, time);
}

function circleAngle (centerX, centerY, pointX, pointY) {
    if (pointX == centerX) {
	if (pointY<centerY) return -Math.PI/2;
	else return Math.PI/2;
    }
    var tangent = (pointY-centerY)/(pointX-centerX);
    var angle = ((pointX >= centerX) ? Math.atan(tangent) : Math.PI+Math.atan(tangent));
    while (angle > Math.PI) angle -= 2*Math.PI;
    return angle;
}

function viewAngle (centerX, centerY, point1X, point1Y, point2X, point2Y) {
    var a1 = circleAngle(centerX, centerY, point1X, point1Y);
    var a2 = circleAngle(centerX, centerY, point2X, point2Y);
    var a = a2-a1;
    while (a > Math.PI) a-= 2*Math.PI;
    return a;
}

function lineSymmetry (xO, yO, xA, yA, xB, yB) {
    if (xA == xB)
	return [2*xA-xO, yO];
    if (yA == yB)
	return [xO, 2*yA-yO];
    var dx = xB-xA;
    var dy = yB-yA;
    var k2 = (xO-xA-(dx/dy)*(yO-yA))/(dy+dx*dx/dy);
    return [xO-2*k2*dy, yO+2*k2*dx];
}

function mod (a, b) {
    return ((a%b)+b)%b;
}
