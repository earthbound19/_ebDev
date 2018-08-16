# cut and paste for reference as I totally redo the algorithm in colorGrowth.py to handle multiple Coordinates:
import sys

sys.exit()

while unusedCoords:
	chosenCoord = mutateCoordinate(chosenCoord[0], chosenCoord[1])
	boolIsInUsedCoords = chosenCoord in usedCoords
	if not boolIsInUsedCoords:		# If the coordinate is NOT in usedCoords, use it (whether or not it is, the coordinate is still mutated; this loop keeps mutating the coordinate (and pooping colors on newly arrived at unused coordinates) until terminate conditions are met).
		# print('chosenCoord ', chosenCoord, ' is NOT in usedCoords. Will use.')
		usedCoords.append(chosenCoord)
		arrXidx = chosenCoord[0]
		arrYidx = chosenCoord[1]
		newColor = previousColor + np.random.random_integers(-rshift, rshift, size=3) / 2
		# Clip that within RGB range if it wandered outside of that range. If this slows it down too much and you don't care if colors randomly freak out (bitmap conversion seems to take colors outside range as wrapping around?) comment the next line out:
		newColor = np.clip(newColor, 0, 255)
		arr[arrYidx][arrXidx] = newColor
		previousColor = newColor
		unusedCoords.remove(chosenCoord)
		# Also, if a parameter was passed saying to do so, save an animation frame (if we are at the Nth (-a) mutation:
		if animationSaveEveryNframes:
			if (animationSaveNFramesCounter % animationSaveEveryNframes) == 0:
				strOfThat = str(animationFrameCounter)
				frameFilePathAndFileName = animFramesFolderName + '/' + strOfThat.zfill(padAnimationSaveFramesNumbersTo) + '.png'
				im = Image.fromarray(arr.astype(np.uint8)).convert('RGB')
				im.save(frameFilePathAndFileName)
				animationFrameCounter += 1		# Increment that *after* because by default ffmpeg expects frame count to start at 0.
			animationSaveNFramesCounter += 1

	else:		# If the coordinate is NOT NOT used (is used), print a progress message.
		failedCoordMutationCount += 1
		# If coordiante mutation fails failedMutationsThreshold times, get a new random coordinate, and print a message saying so.
		if failedCoordMutationCount == failedMutationsThreshold:
			chosenCoord = getRNDunusedCoord()
			print('Coordinate mutation failure threshold met at ', failedMutationsThreshold, '. New random, unused coordinate selected: ', chosenCoord)
			printProgress()
			failedCoordMutationCount = 0
			# if a switch was passed saying to revert or randomise the color mutation base when we reach revertColorOnMutationFail, do so (actually, change the "previous color" to the mutation color base, and the next color mutation will be off that) :
			if revertColorOnMutationFail == 1:
				previousColor = colorMutationBase
	# Running progress report:
	if reportStatsNthLoopCounter == 0 or reportStatsNthLoopCounter == reportStatsEveryNthLoop:
		# Save a progress snapshot image.
		print('Saving prograss snapshot image ', stateIMGfileName, ' . . .')
		im = Image.fromarray(arr.astype(np.uint8)).convert('RGB')
		im.save(stateIMGfileName)
		printProgress()
		reportStatsNthLoopCounter = 1
	reportStatsNthLoopCounter += 1
	# This will terminate all coordinate and color mutation at an arbitary number of mutations.
	usedCoordsCount = len(usedCoords)
	if usedCoordsCount == terminatePaintingAtFillCount:
		print('Pixel fill (successful mutation) termination count ', terminatePaintingAtFillCount, ' reached. Ending algorithm and painting.')
		break

# Save final image file and delete progress (state, temp) image file.
print('Saving image ', imgFileName, ' . . .')
im = Image.fromarray(arr.astype(np.uint8)).convert('RGB')
im.save(imgFileName)
print('Created ', n, ' of ', numIMGsToMake, ' images.')
os.remove(stateIMGfileName)