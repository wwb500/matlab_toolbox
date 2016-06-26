
function LedImage (color) {
    this.images = [];
    if (LedImage.prototype.computedImages[color]) {
	this.images = LedImage.prototype.computedImages[color];
    } else {
	var baseCol = new RGBColor(color);
	var canvas1 = document.createElement("canvas");
	canvas1.width = 16;
	canvas1.height = 16;
	var c = canvas1.getContext("2d");
	c.lineWidth = 0;
	c.fillStyle=baseCol.toHex();
	c.beginPath();
	c.arc(7.5, 7.5, 4, 0, 2*Math.PI, false);
	c.fill();
	var grad = c.createRadialGradient(7, 7, 0, 7.5, 7.5, 7.5)
	var lc = new RGBColor(baseCol).lighten(.5);
	grad.addColorStop(0, lc.toRGBA(1));
	grad.addColorStop(.1, lc.toRGBA(1));
	grad.addColorStop(.3, lc.toRGBA(0));
	grad.addColorStop(.4, lc.toRGBA(0));
	grad.addColorStop(.6, lc.toRGBA(.5));
	grad.addColorStop(.85, lc.toRGBA(.1));
	grad.addColorStop(1, lc.toRGBA(0));
	c.fillStyle = grad;
	c.fillRect(0, 0, 16, 16);
	this.images[1] = canvas1.toDataURL("image/png");

	var canvas2 = document.createElement("canvas");
	canvas2.width = 16;
	canvas2.height = 16;
	c = canvas2.getContext("2d");
	c.lineWidth = 0;
	c.fillStyle=new RGBColor(baseCol).darken(.5).toHex();
	c.beginPath();
	c.arc(7.5, 7.5, 4, 0, 2*Math.PI, false);
	c.fill();
	var grad = c.createRadialGradient(7, 7, 0, 7.5, 7.5, 7.5)
	grad.addColorStop(0, baseCol.toRGBA(.7));
	grad.addColorStop(0.3, baseCol.toRGBA(0));
	c.fillStyle = grad;
	c.fillRect(0, 0, 16, 16);
	this.images[0] = canvas2.toDataURL("image/png");

	LedImage.prototype.computedImages[color] = this.images;
    }
}

LedImage.prototype.computedImages = {};

LedImage.prototype.getOnImage = function () {return this.images[1];}
LedImage.prototype.getOffImage = function () {return this.images[0];}
