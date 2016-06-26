app = angular.module('components',['ui']);

app.directive('numinput', function() {
    return {
	restrict:'E',
	transclude:false,
	replace:true,
	scope:{
	    min:'@',
	    max:'@',
	    modelValue:'=model',
	    size:'@',
	    precision:'@',
	    interval:'@'
	},
	controller:function($scope, $element, $timeout) {
	    //
	    // Init
	    //
	    $scope.editedVal = $scope.value;
	    $scope.dragging = false;
	    $scope.instant = false;
	    $scope.sliderPos = 0;
	    $scope.size=5;
	    $scope.interval=20;
	    $scope.sizeMultiplier = 10;

	    $scope.fillBar = $element.children()[0];
	    $scope.input = $element.children()[1];
	    $scope.overlay = $element.children()[2];

	    //
	    // Model watching
	    //
	    $scope.valTimer = null;

	    $scope.$watch('modelValue', function(nv, ov) {
		if (!$scope.dragging)
		    $scope.editedVal = $scope.value = nv;
	    });

	    $scope.$watch('value', function(nv,ov) {
		$scope.fillBar.style.width = Math.round(($scope.sizeMultiplier*$scope.size+3)*(nv-$scope.min)/($scope.max-$scope.min)) + "px";
		if ($scope.valTimer) return;
		$scope.valTimer = $timeout(function() {
			$scope.modelValue = $scope.value;
			$scope.valTimer = null;
		    }, $scope.interval
		);
	    });

	    $scope.$watch('editedVal', function(nv,ov) {
		if ($scope.checkEditedVal() && $scope.instant)
		    $scope.value = parseFloat(nv);
	    });

	    $scope.$watch('min', function(nv, ov) {
		$scope.min = nv = parseFloat(nv);
		if (isNaN(nv)) nv = $scope.min = 0;
	    });

	    $scope.$watch('max', function(nv, ov) {
		$scope.max = nv = parseFloat(nv);
		if (isNaN(nv)) nv = $scope.max = 1;
	    });

	    $scope.$watch('interval', function(nv, ov) {
		$scope.interval = (nv ? nv : 30);
	    });

	    $scope.$watch('precision', function(nv, ov) {
		$scope.precision = parseFloat($scope.precision);
		if (isNaN($scope.precision) || $scope.precision <= 0)
		    $scope.precision = .01;
	    });

	    //
	    // Utility Functions
	    //

	    $scope.checkEditedVal = function () {
		var v = parseFloat($scope.editedVal);
		return (!isNaN(v) && isFinite(v) && v>=$scope.min && v<=$scope.max);
	    };


	    //
	    // DOM interaction
	    //

	    $scope.input.addEventListener('keypress', function(scope, e){
		if (e.keyCode == 13 && scope.checkEditedVal())
		    scope.$apply("value="+parseFloat(scope.editedVal));
	    }.curry($scope));

	    $scope.input.addEventListener('blur', function(scope, e){
		if (scope.checkEditedVal())
		    scope.$apply("value="+parseFloat(scope.editedVal));
	    }.curry($scope));


	    $scope.input.addEventListener('mousewheel', function(scope, e){
		e = preprocessEvent(e);
		var delta = 0;
		if (e.wheelDelta) {
		    delta = e.wheelDelta/120;
		    if (window.opera) delta = -delta;
		} else if (e.detail) {
		    delta = -e.detail/3;
		}
		var prop = ($scope.value-$scope.min)/($scope.max-$scope.min);
		var sign = (delta < 0) ? -1 : 1;
		console.log(sign);
		if (sign<0) {
		    if ($scope.value==$scope.min) return;
		    if ($scope.value-$scope.precision < $scope.min) $scope.value = $scope.min;
		    else $scope.value -= $scope.precision;
		} else {
		    if ($scope.value==$scope.max) return;
		    if ($scope.value+$scope.precision > $scope.max) $scope.value = $scope.max;
		    else $scope.value += $scope.precision;
		}
		$scope.editedVal = $scope.value;
		$scope.$apply();
	    }.curry($scope));

	    $scope.lastDrag = {x:0, y:0};

	    $scope.input.addEventListener('mousedown', function (e) {
		$scope.input.focus();
		e = preprocessEvent(e);
		$scope.lastDrag = {x:e.pageX, y:e.pageY};
		$scope.overlay.style.display = "block";
		$scope.dragging = true;
		if (e.button == 0) $scope.instant = true;
	    }, true);

	    $scope.overlay.addEventListener('mousemove', function (e) {
		e = preprocessEvent(e);
		var delta = e.pageX-$scope.lastDrag.x - (e.pageY-$scope.lastDrag.y);
		$scope.lastDrag.x = e.pageX;
		$scope.lastDrag.y = e.pageY;
		var newVal = $scope.value+delta*$scope.precision;
		if (newVal > $scope.max) newVal = $scope.max;
		if (newVal < $scope.min) newVal = $scope.min;
		$scope.$apply("editedVal = "+newVal+"; value = "+newVal);
	    }, true);

	    $scope.overlay.addEventListener('mouseup', function (e) {
		e = preprocessEvent(e);
		$scope.instant = $scope.dragging=false;
		$scope.overlay.style.display="none";
	    }, true);

	    $scope.overlay.style.display = "none";
	    $timeout(function(){$scope.fillBar.style.width = Math.round(($scope.sizeMultiplier*$scope.size+3)*($scope.value-$scope.min)/($scope.max-$scope.min)) + "px";},10);
	},
	template:'<div class="numinput" ng-style="{width:(sizeMultiplier*size+5)+\'px\'}"><div class="fillBar"></div><input type="text" ng-style="{width:(sizeMultiplier*size)+\'px\'}" ng-model="editedVal"/><div class="numinputOverlay"></div></div>'
    };
});


app.directive('led', function() {
    return {
	restrict:'E',
	transclude:false,
	replace:true,
	scope:{
	    on:'=onModel',
	    color:'@',
	    readonly:'@'
	},
	controller:function($scope, $element) {
	    //
	    // Init
	    //

	    $scope.img = ["", ""];

	    $scope.$watch('color', function (nv, ov) {
		var ledImg = new LedImage(nv);
		$scope.img = [ledImg.getOffImage(), ledImg.getOnImage()];
	    });

	    $scope.$watch('on', function (nv, ov) {
		$scope.on = ((nv===true || nv=="true" || nv=="on" || nv==1) ? 1 : 0);
	    });

	    $scope.clickHandler = function(e) {
		if ($scope.on) $scope.$apply("on=0");
		else $scope.$apply("on=1");
	    }

	    $scope.$watch('readonly', function (nv, ov) {
		var ro = (nv===true || nv=="true" || nv=="on" || nv==1);
		if (ro) {
		    $element[0].removeEventListener('click', $scope.clickHandler);
		    $scope.cursor='default';
		} else {
		    $element[0].addEventListener('click', $scope.clickHandler);
		    $scope.cursor='pointer';
		}
	    });

	    //
	    // DOM interaction
	    //
	    $element[0].addEventListener('click', $scope.clickHandler);
	    $scope.cursor='pointer';

	},
	template:'<div class="led" style="cursor:{{cursor}};background:url({{img[on]}})"></div>'
    };
});


app.directive('imgselect', function() {
    return {
	restrict:'E',
	transclude:false,
	replace:true,
	scope:{
	    value:'=model',
	    nbvals: '@',
	    img:'@'
	},
	controller:function($scope, $element) {
	    //
	    // DOM interaction
	    //
	    $element[0].addEventListener('click', function(e){
		var newVal = (($scope.value==$scope.nbvals-1) ? 0 : $scope.value+1)
		$scope.$apply("value="+newVal);
	    });

	},
	template:'<div class="imgselect"><img src="{{img}}" style="left:{{-14*value}}px"/></div>'
    };
});


app.directive('ledselect', function() {
    return {
	restrict:'E',
	transclude:false,
	replace:true,
	scope:{
	    value:'=model',
	    num:'@',
	    spacing:'@',
	    dir:'@',
	    color:'@'
	},
	controller:function($scope, $element) {
	    //
	    // Init
	    //
	    $scope.state = [];
	    $scope.img = ["", ""];

	    $scope.$watch('color', function (nv, ov) {
		var ledImg = new LedImage(nv);
		$scope.img = [ledImg.getOffImage(), ledImg.getOnImage()];
	    });

	    $scope.$watch('num', function (nv, ov) {
		$scope.state = [];
		for (i=0; i<$scope.num; i++)
		    $scope.state[i] = ((i==$scope.value) ? 1 : 0);
	    });

	    $scope.$watch('value', function (nv, ov) {
		$scope.state = [];
		for (i=0; i<$scope.num; i++)
		    $scope.state[i] = ((i==$scope.value) ? 1 : 0);
	    });

	    $scope.selectVal = function(i) {
		$scope.state[$scope.value] = 0;
		if (i==$scope.value) {
		    $scope.value = -1;
		} else {
		    $scope.value = i;
		    $scope.state[i] = 1;
		}
	    }
	    
	},
	template:'<div class="ledselect {{dir}}"><div ng-repeat="i in state" class="led" style="background:url({{img[i]}}); margin-right:{{spacing}}px; margin-bottom:{{spacing}}px" ng-click="selectVal($index)"></div></div>'
    };
});



app.directive('vumeter', function() {
    return {
	restrict:'E',
	transclude:false,
	replace:true,
	scope:{
	    value:'=value',
	    numleds:'@',
	    spacing:'@',
	    dir:'@',
	    color1:'@',
	    color2:'@',
	    color3:'@'
	},
	controller:function($scope, $element) {
	    //
	    // Init
	    //

	    $scope.onImg = [];
	    $scope.offImg = [];
	    $scope.images = [];
	    $scope.numleds = 10;
	    $scope.spacing=0;

	    $scope.genImages = function() {
		if (!$scope.color1) $scope.color1="#0f0";
		if (!$scope.color2) $scope.color2="#ff0";
		if (!$scope.color3) $scope.color3="#f00";
		var colorRange = [new RGBColor($scope.color1), new RGBColor($scope.color2), new RGBColor($scope.color3)];
		$scope.onImg = [];
		$scope.offImg = [];
		for (var i=0; i<$scope.numleds; i++) {
		    var col = colorRange[0].colorInRange(i/($scope.numleds-1), colorRange);
		    var ledImg = new LedImage(col.toHex());
		    $scope.onImg.push(ledImg.getOnImage());
		    $scope.offImg.push(ledImg.getOffImage());
		}
	    }

	    $scope.$watch('color1', function (nv, ov) {$scope.genImages();});
	    $scope.$watch('color2', function (nv, ov) {$scope.genImages();});
	    $scope.$watch('color3', function (nv, ov) {$scope.genImages();});
	    $scope.$watch('numleds', function (nv, ov) {$scope.genImages();});
	    $scope.$watch('value', function (nv, ov) {
		var nbOnLeds = Math.round(nv*$scope.numleds);
		var i=0;
		for (; i<nbOnLeds; i++) $scope.images[i] = $scope.onImg[i];
		for (; i<$scope.numleds; i++) $scope.images[i] = $scope.offImg[i];
	    });
	    
	},
	template:'<div class="vumeter {{dir}}"><div ng-repeat="i in images" class="led" style="background:url({{i}}); margin-right:{{spacing}}px; margin-bottom:{{spacing}}px; pointer:default"></div></div>'
    };
});








