
function ALC ($scope, $http, $timeout) {

    $scope.ac = new webkitAudioContext();

    $scope.analysis = {levels:[]};

    $scope.displayWidth = 4096;

    $scope.cursorPos = 0;

    $scope.useMFCC = true;

    $scope.adjustCursorHeight = function () {
	$scope.cursorHeight = getComputedStyle(document.getElementById("imageContainer")).height;
    }

    $scope.sample = new Sample({"url":     "data.wav",
				"callback":function(sample){
				    $scope.sample.image = $scope.sample.drawImage($scope.displayWidth, 150, false);
				    $scope.$apply();
				    $timeout($scope.adjustCursorHeight, 10);
				}
			       }, $scope.ac);

    $scope.config = {nbLevels:3,
		     levels: [{nbVertical:1, structWeight:0, contWeight:1, hUseDTW:false, vUseDTW:false, cutAtMin:true, cutAtMax: false, cutBeforeMax: true},
			      {nbVertical:40, structWeight:.5, contWeight:.5, hUseDTW:false, vUseDTW:true, cutAtMin:true, cutAtMax: false, cutBeforeMax: true},
			      {nbVertical:4, structWeight:.5, contWeight:0, hUseDTW:true, vUseDTW:true, cutAtMin:true, cutAtMax: false, cutBeforeMax: true}]};

    $scope.adjustCursor = function (e) {
	//e = preprocessEvent(event);
	$scope.cursorPos = e.pageX;
    }

    $scope.resizeCursor = function() {
	var c = pageCoordinates(document.getElementById("imageContainer"));
	document.getElementById("cursor").style.width = ($scope.cursorPos+c.x-16)+'px';
	$timeout($scope.resizeCursor, 100);
    }

    $timeout($scope.resizeCursor, 100);

    $scope.zoomIn = function () {
	if ($scope.displayWidth < 10000) {
	    $scope.displayWidth *= 2;
	    $scope.sample.image = $scope.sample.drawImage($scope.displayWidth, 150, false);
	    $scope.computeBlocks();
	}
    }

    $scope.zoomOut = function () {
	if ($scope.displayWidth > 1000) {
	    $scope.displayWidth /= 2;
	    $scope.sample.image = $scope.sample.drawImage($scope.displayWidth, 150, false);
	    $scope.computeBlocks();
	}
    }

    $scope.compute = function () {
	configString = $scope.config.nbLevels;
	for (var i=0; i<$scope.config.levels.length; i++) {
	    var obj = $scope.config.levels[i];
	    configString += "%20"+obj.nbVertical+"%20"+obj.structWeight+"%20"+obj.contWeight+"%20"+(obj.vUseDTW ? 'd':'a')+"%20"+(obj.hUseDTW ? 'd':'a')+"%20"+obj.laWeight+"%20"+obj.targetSize+"%20"+obj.sigmaL+"%20"+obj.sigmaR+"%20"+obj.offset;
	}
	$http.get("alc_analysis.php?feat="+($scope.useMFCC ? "mfcc":"mel")+"&config="+configString).success(
	    function (data, status, headers, config) {
		console.log(data);
		$scope.analysis = data;
		// Reorder levels
		for (var i=0; i<$scope.analysis.nbLevels/2; i++) {
		    var tmp = $scope.analysis.levels[i];
		    $scope.analysis.levels[i] = $scope.analysis.levels[$scope.analysis.nbLevels-i-1];
		    $scope.analysis.levels[$scope.analysis.nbLevels-i-1] = tmp;
		}
		$scope.computeBlocks();
	    }
	);
    }

    $scope.compute1 = function () {
	configString = $scope.config.nbLevels;
	for (var i=0; i<$scope.config.levels.length; i++) {
	    var obj = $scope.config.levels[i];
	    var strategy = "";
	    if (obj.cutAtMin) strategy += "m";
	    if (obj.cutAtMax) strategy += "M";
	    if (obj.cutBeforeMax) strategy += "b";
	    configString += "%20"+obj.nbVertical+"%20"+obj.structWeight+"%20"+obj.contWeight+"%20"+(obj.vUseDTW ? 'd':'a')+"%20"+(obj.hUseDTW ? 'd':'a')+"%20"+strategy;
	}
	$http.get("alc_analysis.php?feat="+($scope.useMFCC ? "mfcc":"mel")+"&config="+configString);
    }

    $scope.compute2 = function () {
	$http.get("result.all.json").success(
	    function (data, status, headers, config) {
		console.log(data);
		$scope.analysis = data;
		// Reorder levels
		for (var i=0; i<$scope.analysis.nbLevels/2; i++) {
		    var tmp = $scope.analysis.levels[i];
		    $scope.analysis.levels[i] = $scope.analysis.levels[$scope.analysis.nbLevels-i-1];
		    $scope.analysis.levels[$scope.analysis.nbLevels-i-1] = tmp;
		}
		$scope.computeBlocks();
	    }
	);
    }

    $scope.computeBlocks = function () {
	var frameSize = $scope.displayWidth / $scope.analysis.nbFrames;
	var colors = [];
	var hex = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f'];
	for (var c=0; c<$scope.analysis.nbFrames; c++)
	    colors.push("#"+hex[Math.floor(16*Math.random())]+hex[Math.floor(16*Math.random())]+hex[Math.floor(16*Math.random())]
			   +hex[Math.floor(16*Math.random())]+hex[Math.floor(16*Math.random())]+hex[Math.floor(16*Math.random())]);
	for (var l=0; l<$scope.analysis.nbLevels; l++) {
	    var level = $scope.analysis.levels[l];
	    level.absoluteOnsets.push($scope.analysis.nbFrames);
	    level.blocks = [];
	    for (var i=0; i<level.nbObjects; i++) {
		level.blocks.push({"left":Math.round(frameSize*level.absoluteOnsets[i]),
				   "width":Math.round(frameSize*(level.absoluteOnsets[i+1]-level.absoluteOnsets[i])),
				   "height":10+Math.round(90*level.curve[i]),
				   "color":colors[level.labels[i]]
				  }
				 )
	    }
	}
	$timeout($scope.adjustCursorHeight, 10);
    }

}
