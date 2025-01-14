// Open the raw EM image


beadDiameter = 40; // nm

emPath = "/Users/lukasvandenheuvel/Documents/PhD/Data-temp/20241022_iDA-figures/clem-immunogold/raw/Matek2-cU/Image-0059.tif";
cellOutlinePath = "/Users/lukasvandenheuvel/Documents/PhD/Data-temp/20241022_iDA-figures/clem-immunogold/raw/Matek2-cU/ig-detection-inset02/outline.roi";
outPath = "/Users/lukasvandenheuvel/Documents/PhD/Data-temp/20241022_iDA-figures/clem-immunogold/raw/Matek2-cU/ig-detection-inset02";

close("*");
open(emPath);
waitForUser("Change pixel size to nm");
getPixelSize(unit, pixelWidth, pixelHeight);
s = File.separator;
title =  getTitle();
directory = getInfo("image.directory");

run("Select None");

if (( indexOf(unit, "nm"))==-1) {
	exit("Stop! First set pixel size to nm");
}

run("Duplicate...", "title=duplicate");
beadDiameterPixels = (beadDiameter / pixelWidth);
sigma1 = beadDiameterPixels / (1 + sqrt(2)) / 2; // sigma1 = radius-object / (1+sqrt(2))
sigma2 = sqrt(2) * sigma1;

run("Invert");
run("Duplicate...", "title=sigma1");
run("Duplicate...", "title=sigma2");

selectImage("duplicate");
close();

selectImage("sigma1");
open(cellOutlinePath);
run("Gaussian Blur...", "sigma="+d2s(sigma1,3));

selectImage("sigma2");
open(cellOutlinePath);
run("Gaussian Blur...", "sigma="+d2s(sigma2,3));
imageCalculator("Subtract create 32-bit", "sigma1","sigma2");

selectImage("sigma1");
close();
selectImage("sigma2");
close();

selectImage("Result of sigma1");
open(cellOutlinePath);
setAutoThreshold("RenyiEntropy dark");
setOption("BlackBackground", true);

waitForUser("Adjust threshold");
run("Convert to Mask");

if (roiManager("count")>0) {
	roiManager("Delete");
}

run("Clear Results");

minSizePixels = beadDiameterPixels*beadDiameterPixels/4;
run("Analyze Particles...", "size="+d2s(minSizePixels,2)+"-Infinity pixel circularity=0.80-1.00 display clear add");
selectImage(title);
roiManager("Show None");
roiManager("Show All");

waitForUser("Add / remove ROIs if necessary");
run("Set Measurements...", "center redirect=None decimal=3");
run("Clear Results");
roiManager("Measure");
saveAs("Results",  outPath + s +  File.getNameWithoutExtension(title) + "-goldLocations.csv");

selectImage("Result of sigma1");
close();