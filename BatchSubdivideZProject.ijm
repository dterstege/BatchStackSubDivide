//"BatchSubdivideZProject"
//
//Takes input file sequence
//Subdivides stack by step size
//Creates z-projection of each subdivision
// 
// Copyright (C) 2021 Dylan Terstege - Epp Lab
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details
//
// Your should have received a copy of the GNU General Public License
// along with this program. If not, see <https://www.gnu.org/licenses/>.
//
// Created 09-19-2019 Dylan Terstege
// Epp Lab, University of Calgary
// Contact: dylan.terstege@ucalgary.ca

inputDir = getDirectory("Choose a Source Directory");
outputDir = getDirectory("Choose and Output Directory");
start=0; end=0; step=0;
outputFormats = newArray("TIFF", "8-bit TIFF", "JPEG", "GIF", "PNG", "PGM", "BMP", "FITS", "Text Image", "ZIP", "Raw");
projectionTypes = newArray("Max Intensity", "Min Intensity", "Average Intensity", "Sum Slices", "Standard Deviation", "Median");
Dialog.create("Select Stack and Projection Parameters");
Dialog.addMessage("Please Select the Parameters to be Used");
Dialog.addNumber("Start at Image: ", 0);
Dialog.addNumber("Trim Images from End: ", 0);
Dialog.addNumber("How Many Images per Stack: ", 0);
Dialog.addChoice("Save projection as: ", outputFormats, "TIFF");
Dialog.addChoice("Use Projection Type: ", projectionTypes, "Max Intensity");
Dialog.addCheckbox("Convert to 8 bit", true);
Dialog.show();
startAt = Dialog.getNumber();
endAt = Dialog.getNumber();
stepSize = Dialog.getNumber();
outputFormat = Dialog.getChoice();
projectionType = Dialog.getChoice();
outputEightBit = Dialog.getCheckbox();

setBatchMode(true);
run("Bio-Formats Macro Extensions");
count = 0;
countFiles(inputDir);
n = 0;
processFiles(inputDir);
//print(count+" files processed");

function countFiles(inputDir) {
  list = getFileList(inputDir);
  for (i=0; i<list.length; i++) {
    if (endsWith(list[i], "/"))
      countFiles(""+inputDir+list[i]);
    else
      count++;
  }
}

function processFiles(inputDir) {
  list = getFileList(inputDir);
  for (i=0; i<list.length; i++) {
    if (endsWith(list[i], "/"))
      processFiles(""+inputDir+list[i]);
    else {
      showProgress(n++, count);
      path = inputDir+list[i];
      processFiles(path);
    }
  }
}

path=getDirectory("temp")+"list.txt";
f=File.open(path);
list = getFileList(inputDir);
for (j=0; j<list.length; j++){
  print(f, inputDir+list[j]);
}
File.close(f);

//fileName=list[0];
//path=inputDir+fileName;

run("Stack From List...", "open="+path+" use");
stepStart=startAt;
for (i=0; i<(((list.length)-(2*endAt))/stepSize); i++){
  stepEnd=((i+1)*stepSize)+startAt;
  run("Z Project...", "start=stepStart stop=stepEnd projection=["+projectionType+"]");
  stepStart=stepEnd+1;
  if(outputEightBit && bitDepth() % 16 == 0){
    run("8-bit");
  }
  saveAs(outputFormat, outputDir + "substack_to_"+stepEnd);
  close();
}
close();
  


 
